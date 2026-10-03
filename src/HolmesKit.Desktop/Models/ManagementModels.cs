using HolmesKit.Desktop.Services;

namespace HolmesKit.Desktop.Models;

public sealed class SystemSnapshot
{
    public string ComputerName { get; set; } = "Unknown";
    public string WindowsEdition { get; set; } = "Unknown";
    public string WindowsVersion { get; set; } = "";
    public string WindowsBuild { get; set; } = "";
    public string Architecture { get; set; } = "";
    public string CpuName { get; set; } = "Unknown";
    public int? CpuCores { get; set; }
    public int? CpuLogicalProcessors { get; set; }
    public double? CpuPercent { get; set; }
    public long? MemoryUsedBytes { get; set; }
    public long? MemoryAvailableBytes { get; set; }
    public long? MemoryTotalBytes { get; set; }
    public double? MemoryPercent { get; set; }
    public long? UptimeSeconds { get; set; }
    public string PowerPlanName { get; set; } = "Unknown";
    public string PowerPlanKind { get; set; } = "Unknown";
    public string PowerPlanGuid { get; set; } = "";
    public List<string> ActiveAdapters { get; set; } = [];
    public List<string> Diagnostics { get; set; } = [];
    public List<DiskSnapshot> Disks { get; set; } = [];

    public string WindowsDisplay => JoinKnown(WindowsEdition, WindowsVersion.Length > 0 ? $"{WindowsVersion} (build {WindowsBuild})" : "", Architecture);
    public string ProcessorDetails => CpuCores is > 0 && CpuLogicalProcessors is > 0 ? $"{CpuCores} cores · {CpuLogicalProcessors} logical processors" : PresentationFormatters.Unavailable;
    public string CpuPercentText => PresentationFormatters.Percent(CpuPercent);
    public string MemoryUsageText => $"{PresentationFormatters.Bytes(MemoryUsedBytes)} / {PresentationFormatters.Bytes(MemoryTotalBytes)}";
    public string MemoryAvailableText => MemoryAvailableBytes is null ? PresentationFormatters.Unavailable : $"{PresentationFormatters.Bytes(MemoryAvailableBytes)} available";
    public string MemoryPercentText => PresentationFormatters.Percent(MemoryPercent);
    public string UptimeText => PresentationFormatters.Uptime(UptimeSeconds);
    public string PowerPlanDisplay => PowerPlanKind == "Custom" ? "Custom power plan" : Clean(PowerPlanName);
    public string PowerPlanDetails => PowerPlanKind == "Custom" && !IsUnknown(PowerPlanName) ? $"Name: {PowerPlanName}" : "";
    public string NetworkDisplay => ActiveAdapters.Count == 0 ? "No active network adapter detected" : string.Join(", ", ActiveAdapters);

    private static string JoinKnown(params string[] values) => string.Join(" · ", values.Where(x => !IsUnknown(x)));
    private static string Clean(string value) => IsUnknown(value) ? "Unknown" : value;
    private static bool IsUnknown(string? value) => string.IsNullOrWhiteSpace(value) || value is "Unknown" or "Unavailable";
}

public sealed class DiskSnapshot
{
    public string Name { get; set; } = "Unknown";
    public long? UsedBytes { get; set; }
    public long? FreeBytes { get; set; }
    public long? TotalBytes { get; set; }
    public double? Percent { get; set; }
    public string UsedText => PresentationFormatters.Bytes(UsedBytes);
    public string FreeText => PresentationFormatters.Bytes(FreeBytes);
    public string TotalText => PresentationFormatters.Bytes(TotalBytes);
    public string PercentText => PresentationFormatters.Percent(Percent);
}

public sealed class StartupEntry
{
    public string Type { get; set; } = "";
    public string Source { get; set; } = "Unknown";
    public string Hive { get; set; } = "";
    public string RegPath { get; set; } = "";
    public string ApprovedPath { get; set; } = "";
    public string Name { get; set; } = "";
    public string Command { get; set; } = "";
    public string Status { get; set; } = "";
    public bool Locked { get; set; }
    public string ProtectionDisplay => Locked ? "Protected" : "";
}

public sealed class InstalledApplication
{
    public string Name { get; set; } = "";
    public string Publisher { get; set; } = "";
    public string Version { get; set; } = "";
    public long? SizeBytes { get; set; }
    public string InstallerType { get; set; } = "Unknown";
    public string UninstallData { get; set; } = "";
    public string PublisherDisplay => string.IsNullOrWhiteSpace(Publisher) ? "Unknown" : Publisher;
    public string VersionDisplay => string.IsNullOrWhiteSpace(Version) ? "Unknown" : Version;
    public string SizeDisplay => PresentationFormatters.Bytes(SizeBytes);
}
