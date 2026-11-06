using HolmesKit.Desktop.Services;
using HolmesKit.Desktop.ViewModels;
using HolmesKit.Desktop.Controls;

namespace HolmesKit.Desktop.Tests;

public class DashboardTests
{
    [Fact]
    public void Chart_UsesRealTimeAndFixedPercentAxes()
    {
        var end = DateTimeOffset.UtcNow;
        var points = MetricHistoryChart.BuildSegments([new(end.AddSeconds(-2), 0), new(end, 100)], 600, 104).Single();
        Assert.Equal(new System.Windows.Point(580, 102), points[0]);
        Assert.Equal(new System.Windows.Point(600, 2), points[1]);
    }

    [Fact]
    public void Chart_DoesNotJoinUnknownValuesOrPausedIntervals()
    {
        var end = DateTimeOffset.UtcNow;
        var segments = MetricHistoryChart.BuildSegments([new(end.AddSeconds(-40), 50), new(end.AddSeconds(-38), null),
            new(end.AddSeconds(-36), 50), new(end, 50)], 600, 100);
        Assert.Equal(3, segments.Count);
        Assert.All(segments, segment => Assert.Single(segment));
        Assert.Empty(MetricHistoryChart.BuildSegments(null, 600, 100));
        Assert.Empty(MetricHistoryChart.BuildSegments([new(end, 50)], 0, 100));
    }
    [Theory]
    [InlineData(10, 100, 20, 200, 90)]
    [InlineData(10, 100, 110, 200, 0)]
    [InlineData(10, 100, 10, 200, 100)]
    public void Cpu_ExcludesIdleFromKernelAndUserDeltas(ulong oldIdle, ulong oldTotal, ulong idle, ulong total, double expected) =>
        Assert.Equal(expected, WindowsTelemetrySampler.CpuUsage(oldIdle, oldTotal, idle, total));

    [Theory]
    [InlineData(10, 100, 10, 100)]
    [InlineData(10, 100, 9, 200)]
    [InlineData(10, 100, 200, 200)]
    public void Cpu_InvalidCountersRemainUnknown(ulong oldIdle, ulong oldTotal, ulong idle, ulong total) =>
        Assert.Null(WindowsTelemetrySampler.CpuUsage(oldIdle, oldTotal, idle, total));

    [Theory]
    [InlineData(1000, 250, 750, 75)]
    [InlineData(1000, 1000, 0, 0)]
    [InlineData(1000, 0, 1000, 100)]
    public void Memory_UsesTotalMinusAvailable(long total, long available, long used, double percent)
    {
        var sample = new TelemetrySample(DateTimeOffset.UtcNow, null, total, available, 0);
        Assert.Equal(used, sample.UsedBytes);
        Assert.Equal(percent, sample.MemoryPercent);
    }

    [Fact]
    public void MissingAndImpossibleMemory_AreNotZero()
    {
        foreach (var sample in new[] { new TelemetrySample(DateTimeOffset.UtcNow, null, null, null, null),
            new TelemetrySample(DateTimeOffset.UtcNow, null, 10, 11, null) })
        {
            Assert.Null(sample.UsedBytes); Assert.Null(sample.MemoryPercent);
        }
        Assert.Equal("Unavailable", new DashboardViewModel().CpuText);
    }

    [Fact]
    public void History_IsBoundedByTimeAndCount_AndRejectsOlderSamples()
    {
        var vm = new DashboardViewModel();
        var time = DateTimeOffset.UtcNow;
        for (var i = 0; i < 1000; i++) vm.Record(new(time.AddSeconds(i), i % 100, 100, 50, i));
        Assert.Equal(31, vm.CpuHistory.Count);
        Assert.All(vm.CpuHistory, point => Assert.InRange(point.Timestamp, time.AddSeconds(939), time.AddSeconds(999)));
        vm.Record(new(time, 0, 100, 0, 0));
        Assert.Equal(time.AddSeconds(999), vm.CpuHistory[^1].Timestamp);
        vm.Record(new(time.AddSeconds(1100), null, null, null, null));
        Assert.Single(vm.CpuHistory);
        Assert.Null(vm.CpuHistory[0].Value);
        Assert.Equal("Unavailable", vm.CpuText);
    }

    [Fact]
    public void History_InvalidReadingsRemainGaps()
    {
        var vm = new DashboardViewModel();
        vm.Record(new(DateTimeOffset.UtcNow, double.NaN, null, null, null));
        Assert.Null(vm.CpuHistory.Single().Value);
        Assert.Equal("Unavailable", vm.MemoryText);
    }

    [Theory]
    [InlineData(true, false, 0, false, true)]
    [InlineData(false, false, 0, false, false)]
    [InlineData(true, true, 0, false, false)]
    [InlineData(true, false, 1, false, false)]
    [InlineData(true, false, 7, false, false)]
    [InlineData(true, false, 0, true, false)]
    public void Monitoring_OnlyRunsOnVisibleIdleHome(bool loaded, bool minimized, int page, bool busy, bool expected) =>
        Assert.Equal(expected, DesktopMonitor.ShouldRun(loaded, minimized, page, busy));

    [Fact]
    public async Task Monitor_CancellationStopsReadsAndPublications()
    {
        using var cancellation = new CancellationTokenSource();
        var sampler = new FakeSampler();
        var published = 0;
        await DesktopMonitor.RunAsync(sampler, TimeSpan.FromMilliseconds(10), _ =>
        {
            published++;
            if (published == 3) cancellation.Cancel();
            return Task.CompletedTask;
        }, cancellation.Token);
        Assert.Equal(3, published); Assert.Equal(3, sampler.Reads);
    }

    [Fact]
    public async Task Monitor_PreCancelledNeverReads()
    {
        using var cancellation = new CancellationTokenSource(); cancellation.Cancel();
        var sampler = new FakeSampler();
        await DesktopMonitor.RunAsync(sampler, TimeSpan.FromSeconds(2), _ => throw new Exception("Must not publish"), cancellation.Token);
        Assert.Equal(0, sampler.Reads);
    }

    [Fact]
    public async Task Monitor_SamplerFailurePublishesUnknownAndRemainsCancellable()
    {
        using var cancellation = new CancellationTokenSource();
        await DesktopMonitor.RunAsync(new ThrowingSampler(), TimeSpan.FromSeconds(2), sample =>
        {
            Assert.Null(sample.CpuPercent); Assert.Null(sample.TotalBytes);
            cancellation.Cancel(); return Task.CompletedTask;
        }, cancellation.Token);
    }

    private sealed class FakeSampler : ITelemetrySampler
    {
        public int Reads;
        public TelemetrySample Read() { Reads++; return new(DateTimeOffset.UtcNow, 30, 100, 60, 120); }
    }
    private sealed class ThrowingSampler : ITelemetrySampler
    {
        public TelemetrySample Read() => throw new InvalidOperationException("Simulated native query failure");
    }
}
