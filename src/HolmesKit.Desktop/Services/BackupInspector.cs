namespace HolmesKit.Desktop.Services;

public sealed record BackupInspection(bool IsValid, bool Exists, DateTime? Timestamp, string Summary);

public static class BackupInspector
{
    private static readonly (string Key, string File)[] ExpectedEntries =
    [
        (@"HKCU\Control Panel\Desktop", "desktop.reg"),
        (@"HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects", "visualeffects.reg"),
        (@"HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "explorer_advanced.reg"),
        (@"HKCU\Control Panel\Desktop\WindowMetrics", "windowmetrics.reg"),
        (@"HKCU\Software\Microsoft\Windows\CurrentVersion\Run", "hkcu_run.reg"),
        (@"HKLM\Software\Microsoft\Windows\CurrentVersion\Run", "hklm_run.reg"),
        (@"HKCU\System\GameConfigStore", "gameconfigstore.reg"),
        (@"HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR", "gamedvr.reg"),
        (@"HKLM\Software\Policies\Microsoft\Windows\GameDVR", "gamedvr_policy.reg"),
        (@"HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games", "mm_games.reg"),
        (@"HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile", "mm_profile.reg"),
        (@"HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters", "tcpip_params.reg")
    ];

    public static BackupInspection Inspect(string directory)
    {
        if (!Directory.Exists(directory)) return new(false, false, null, "No HolmesKit backup has been created.");

        try
        {
            var absentPath = Path.Combine(directory, "absent_keys.txt");
            var absent = File.Exists(absentPath)
                ? File.ReadLines(absentPath).Select(ParseAbsentEntry).Where(x => x is not null).ToHashSet()
                : [];
            var timestamps = new List<DateTime>();
            if (File.Exists(absentPath)) timestamps.Add(File.GetLastWriteTime(absentPath));

            foreach (var expected in ExpectedEntries)
            {
                var path = Path.Combine(directory, expected.File);
                if (File.Exists(path))
                {
                    using var reader = File.OpenText(path);
                    if (!string.Equals(reader.ReadLine()?.TrimStart('\uFEFF'), "Windows Registry Editor Version 5.00", StringComparison.Ordinal))
                        return new(false, true, Latest(timestamps), $"Backup is incomplete: {expected.File} is not a valid registry export.");
                    timestamps.Add(File.GetLastWriteTime(path));
                }
                else if (!absent.Contains($"{expected.Key}|{expected.File}"))
                {
                    return new(false, true, Latest(timestamps), $"Backup is incomplete: {expected.File} is missing.");
                }
            }

            return new(true, true, Latest(timestamps), "Complete registry backup available.");
        }
        catch (Exception ex)
        {
            return new(false, true, null, $"Backup could not be verified: {ex.Message}");
        }
    }

    private static string? ParseAbsentEntry(string line)
    {
        var value = line.Trim();
        return value.Count(c => c == '|') == 1 ? value : null;
    }

    private static DateTime? Latest(IReadOnlyCollection<DateTime> values) => values.Count == 0 ? null : values.Max();
}
