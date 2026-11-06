using HolmesKit.Desktop.Services;

namespace HolmesKit.Desktop.ViewModels;

public sealed record MetricPoint(DateTimeOffset Timestamp, double? Value);

public sealed class DashboardViewModel : ObservableObject
{
    private readonly List<TelemetrySample> samples = [];
    private TelemetrySample? current;
    private bool isMonitoring;
    public bool IsMonitoring { get => isMonitoring; set { if (Set(ref isMonitoring, value)) Raise(nameof(SamplingText)); } }
    public IReadOnlyList<MetricPoint> CpuHistory => samples.Select(s => new MetricPoint(s.Timestamp, Clean(s.CpuPercent))).ToArray();
    public IReadOnlyList<MetricPoint> MemoryHistory => samples.Select(s => new MetricPoint(s.Timestamp, s.MemoryPercent)).ToArray();
    public string CpuText => PresentationFormatters.Percent(Clean(current?.CpuPercent));
    public string MemoryText => PresentationFormatters.Percent(current?.MemoryPercent);
    public string MemoryDetail => $"{PresentationFormatters.Bytes(current?.UsedBytes)} used / {PresentationFormatters.Bytes(current?.TotalBytes)}";
    public string AvailableText => $"{PresentationFormatters.Bytes(current?.AvailableBytes)} available";
    public string UptimeText => PresentationFormatters.Uptime(current?.UptimeSeconds);
    public string SamplingText => IsMonitoring
        ? current is null ? "Waiting for first sample…" : $"Live · 2 s interval · {current.Timestamp.ToLocalTime():T}"
        : "Monitoring paused";
    private static double? Clean(double? value) => value is >= 0 and <= 100 && double.IsFinite(value.Value) ? value : null;

    public void Record(TelemetrySample sample)
    {
        // Never bridge a paused interval with fabricated samples; the chart breaks long gaps.
        if (current is not null && sample.Timestamp <= current.Timestamp) return;
        current = sample;
        samples.Add(sample);
        samples.RemoveAll(s => s.Timestamp < sample.Timestamp.AddSeconds(-60));
        if (samples.Count > 31) samples.RemoveRange(0, samples.Count - 31);
        foreach (var property in new[] { nameof(CpuHistory), nameof(MemoryHistory), nameof(CpuText), nameof(MemoryText),
            nameof(MemoryDetail), nameof(AvailableText), nameof(UptimeText), nameof(SamplingText) }) Raise(property);
    }
}
