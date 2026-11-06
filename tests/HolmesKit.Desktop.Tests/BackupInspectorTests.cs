using HolmesKit.Desktop.Services;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;

namespace HolmesKit.Desktop.Tests;

public class BackupInspectorTests
{
    [Theory]
    [InlineData("Running", "Recovery blocked: interrupted operation")]
    [InlineData("Unknown", "Recovery blocked: invalid journal")]
    public void JournalState_IsExplicitAndNeverEnablesRestore(string status, string expected)
    {
        WithTemporaryDirectory(path =>
        {
            var payload = JsonSerializer.Serialize(new { Version = 1, Status = status });
            var journal = Path.Combine(path, "baseline.json");
            File.WriteAllText(journal, JsonSerializer.Serialize(new { Payload = payload,
                Sha256 = Convert.ToBase64String(SHA256.HashData(Encoding.UTF8.GetBytes(payload))) }));
            var result = BackupInspector.InspectJournal(journal);
            Assert.False(result.IsValid);
            Assert.Equal(expected, result.State);
        });
    }

    [Fact]
    public void CorruptJournal_IsBlockedNotMissing()
    {
        WithTemporaryDirectory(path =>
        {
            var journal = Path.Combine(path, "baseline.json");
            File.WriteAllText(journal, "not json");
            var result = BackupInspector.InspectJournal(journal);
            Assert.True(result.Exists);
            Assert.False(result.IsValid);
            Assert.Equal("Recovery blocked: invalid journal", result.State);
        });
    }
    private static readonly string[] AbsentEntries =
    [
        @"HKCU\Control Panel\Desktop|desktop.reg",
        @"HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects|visualeffects.reg",
        @"HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced|explorer_advanced.reg",
        @"HKCU\Control Panel\Desktop\WindowMetrics|windowmetrics.reg",
        @"HKCU\Software\Microsoft\Windows\CurrentVersion\Run|hkcu_run.reg",
        @"HKLM\Software\Microsoft\Windows\CurrentVersion\Run|hklm_run.reg",
        @"HKCU\System\GameConfigStore|gameconfigstore.reg",
        @"HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR|gamedvr.reg",
        @"HKLM\Software\Policies\Microsoft\Windows\GameDVR|gamedvr_policy.reg",
        @"HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games|mm_games.reg",
        @"HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile|mm_profile.reg",
        @"HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters|tcpip_params.reg"
    ];

    [Fact]
    public void MissingDirectory_IsNotAValidBackup()
    {
        var result = BackupInspector.Inspect(Path.Combine(Path.GetTempPath(), Guid.NewGuid().ToString("N")));
        Assert.False(result.Exists);
        Assert.False(result.IsValid);
    }

    [Fact]
    public void LegacyManifest_IsPreservedButNotAutomaticallyRestorable()
    {
        WithTemporaryDirectory(path =>
        {
            File.WriteAllLines(Path.Combine(path, "absent_keys.txt"), AbsentEntries);
            var result = BackupInspector.Inspect(path);
            Assert.True(result.Exists);
            Assert.False(result.IsValid);
            Assert.Contains("Legacy", result.Summary);
        });
    }

    [Fact]
    public void ArbitraryFile_DoesNotMasqueradeAsAValidBackup()
    {
        WithTemporaryDirectory(path =>
        {
            File.WriteAllText(Path.Combine(path, "partial.tmp"), "not a backup");
            var result = BackupInspector.Inspect(path);
            Assert.True(result.Exists);
            Assert.False(result.IsValid);
            Assert.Contains("Legacy", result.Summary, StringComparison.OrdinalIgnoreCase);
        });
    }

    private static void WithTemporaryDirectory(Action<string> action)
    {
        var path = Path.Combine(Path.GetTempPath(), $"HolmesKit.Tests.{Guid.NewGuid():N}");
        Directory.CreateDirectory(path);
        try { action(path); }
        finally { Directory.Delete(path, true); }
    }
}
