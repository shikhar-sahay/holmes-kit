using System.Runtime.InteropServices;

namespace HolmesKit.Desktop.Services;

public sealed record TelemetrySample(DateTimeOffset Timestamp, double? CpuPercent,
    long? TotalBytes, long? AvailableBytes, long? UptimeSeconds)
{
    public long? UsedBytes => TotalBytes is > 0 && AvailableBytes >= 0 && AvailableBytes <= TotalBytes
        ? TotalBytes - AvailableBytes : null;
    public double? MemoryPercent => PresentationFormatters.RatioPercent(UsedBytes, TotalBytes);
}

public interface ITelemetrySampler { TelemetrySample Read(); }

/// <summary>Read-only kernel counters. A new instance starts a fresh CPU baseline after each pause.</summary>
public sealed class WindowsTelemetrySampler : ITelemetrySampler
{
    private (ulong Idle, ulong Total)? previous;
    public TelemetrySample Read()
    {
        double? cpu = null;
        if (GetSystemTimes(out var idle, out var kernel, out var user))
        {
            var total = kernel + user; // Kernel time includes idle time.
            if (previous is { } last) cpu = CpuUsage(last.Idle, last.Total, idle, total);
            previous = (idle, total);
        }
        else previous = null;
        var memory = new MemoryStatus { Length = (uint)Marshal.SizeOf<MemoryStatus>() };
        var available = GlobalMemoryStatusEx(ref memory);
        return new(DateTimeOffset.UtcNow, cpu,
            available ? (long)memory.TotalPhysical : null,
            available ? (long)memory.AvailablePhysical : null, (long)(GetTickCount64() / 1000));
    }

    public static double? CpuUsage(ulong oldIdle, ulong oldTotal, ulong idle, ulong total)
    {
        if (total <= oldTotal || idle < oldIdle || idle - oldIdle > total - oldTotal) return null;
        return (total - oldTotal - (idle - oldIdle)) * 100d / (total - oldTotal);
    }

    [StructLayout(LayoutKind.Sequential)]
    private struct MemoryStatus
    {
        public uint Length, Load;
        public ulong TotalPhysical, AvailablePhysical, TotalPageFile, AvailablePageFile,
            TotalVirtual, AvailableVirtual, AvailableExtendedVirtual;
    }
    [DllImport("kernel32.dll")][return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool GetSystemTimes(out ulong idle, out ulong kernel, out ulong user);
    [DllImport("kernel32.dll")][return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool GlobalMemoryStatusEx(ref MemoryStatus status);
    [DllImport("kernel32.dll")] private static extern ulong GetTickCount64();
}

public static class DesktopMonitor
{
    public static bool ShouldRun(bool loaded, bool minimized, int page, bool busy) => loaded && !minimized && page == 0 && !busy;

    public static async Task RunAsync(ITelemetrySampler sampler, TimeSpan interval,
        Func<TelemetrySample, Task> publish, CancellationToken cancellation)
    {
        using var timer = new PeriodicTimer(interval);
        try
        {
            do
            {
                cancellation.ThrowIfCancellationRequested();
                TelemetrySample sample;
                try { sample = sampler.Read(); }
                catch { sample = new(DateTimeOffset.UtcNow, null, null, null, null); }
                cancellation.ThrowIfCancellationRequested();
                await publish(sample);
            } while (await timer.WaitForNextTickAsync(cancellation));
        }
        catch (OperationCanceledException) when (cancellation.IsCancellationRequested) { }
    }
}
