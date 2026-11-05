using System.Text;
using System.Text.Json;
using System.Security.Cryptography;

namespace HolmesKit.Desktop.Services;

public sealed record BackupInspection(bool IsValid, bool Exists, DateTime? Timestamp, string Summary);

public static class BackupInspector
{
    public static BackupInspection Inspect(string directory)
    {
        var journal = Path.Combine(Path.GetDirectoryName(directory)!, "recovery", "baseline.json");
        if (File.Exists(journal)) return InspectJournal(journal);
        return Directory.Exists(directory)
            ? new(false, true, null, "Legacy registry exports preserved. Automatic import is disabled; manual review is required.")
            : new(false, false, null, "No HolmesKit recovery baseline has been created.");
    }

    public static BackupInspection InspectJournal(string path)
    {
        try
        {
            if (new FileInfo(path).Length > 4 * 1024 * 1024) throw new InvalidDataException("Journal is too large.");
            using var envelope = JsonDocument.Parse(File.ReadAllText(path));
            var payload = envelope.RootElement.GetProperty("Payload").GetString()!;
            var hash = Convert.ToBase64String(SHA256.HashData(Encoding.UTF8.GetBytes(payload)));
            if (hash != envelope.RootElement.GetProperty("Sha256").GetString()) throw new InvalidDataException("Integrity check failed.");
            using var data = JsonDocument.Parse(payload);
            var root = data.RootElement;
            if (root.GetProperty("Version").GetInt32() != 1 || root.GetProperty("Status").GetString() != "Ready")
                throw new InvalidDataException("Unsupported or interrupted recovery journal.");
            using var identity = System.Security.Principal.WindowsIdentity.GetCurrent();
            var machine = Convert.ToString(Microsoft.Win32.Registry.GetValue(@"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Cryptography", "MachineGuid", null));
            if (root.GetProperty("User").GetString() != identity.User?.Value || root.GetProperty("Machine").GetString() != machine)
                throw new InvalidDataException("Recovery journal belongs to a different machine or elevated account.");
            if (root.GetProperty("Entries").GetArrayLength() == 0) throw new InvalidDataException("Recovery scope is empty.");
            var timestamp = root.GetProperty("CreatedUtc").GetDateTime().ToLocalTime();
            return new(true, true, timestamp, "Retained baseline: managed registry values, service states and active power plan. Restore revalidates identity/scope and skips conflicts. Network resets, NTFS and hibernation are not exact recovery.");
        }
        catch (Exception ex) { return new(false, true, null, $"Recovery journal unavailable: {ex.Message}"); }
    }

}
