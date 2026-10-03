namespace HolmesKit.Desktop.Models;

public sealed class SystemSnapshot
{
    public string ComputerName { get; set; } = "Unknown";
    public string Windows { get; set; } = "Unknown";
    public string Cpu { get; set; } = "Unknown";
    public double CpuPercent { get; set; }
    public double RamUsedGb { get; set; }
    public double RamTotalGb { get; set; }
    public double RamPercent { get; set; }
    public string Uptime { get; set; } = "Unknown";
    public string PowerPlan { get; set; } = "Unknown";
    public int StartupCount { get; set; }
    public List<DiskSnapshot> Disks { get; set; } = [];
}

public sealed class DiskSnapshot
{
    public string Name { get; set; } = "";
    public double UsedGb { get; set; }
    public double TotalGb { get; set; }
    public int Percent { get; set; }
}

public sealed class StartupEntry
{
    public string Type { get; set; } = "";
    public string Hive { get; set; } = "";
    public string RegPath { get; set; } = "";
    public string ApprovedPath { get; set; } = "";
    public string Name { get; set; } = "";
    public string Command { get; set; } = "";
    public string Status { get; set; } = "";
    public bool Locked { get; set; }
}

public sealed class InstalledApplication
{
    public string Name { get; set; } = "";
    public string Version { get; set; } = "";
    public string Size { get; set; } = "";
    public string UninstallData { get; set; } = "";
}
