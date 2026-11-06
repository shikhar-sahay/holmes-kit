using HolmesKit.Desktop.Models;
using HolmesKit.Desktop.Services;

namespace HolmesKit.Desktop.Acceptance;

/// <summary>QA-only adapter. Native dependencies are used solely for the three read queries.</summary>
public sealed class AcceptanceService(IHolmesKitCommandService readQueries) : IHolmesKitCommandService
{
    public bool FixtureLists { get; set; } = true;
    public bool SlowReads { get; set; }
    public bool FailNextRead { get; set; }
    public int NextExitCode { get; set; }
    public int InertActionCalls { get; private set; }
    public StartupEntry[] Startup { get; } =
    [new() { Name = "Example sync client", Command = @"C:\Example Tools\Sync Client\sync.exe --start", Status = "Enabled", Source = "Run", Hive = "HKCU" },
     new() { Name = "Protected example", Command = "Protected fixture", Status = "Enabled", Source = "Task", Locked = true },
     new() { Name = "Long path example Ω", Command = @"C:\Example Tools\" + new string('x', 180) + @"\client.exe --background", Status = "Disabled", Source = "Run", Hive = "HKCU" }];
    public InstalledApplication[] Apps { get; } =
    [new() { Name = "Example Editor", Publisher = "Example Publisher", Version = "2.4.0", InstallerType = "MSI", SizeBytes = 150 * 1024 * 1024, UninstallData = "inert-editor" },
     new() { Name = "Unknown size example", InstallerType = "EXE", UninstallData = "inert-unknown" },
     new() { Name = "Long application title Ω " + new string('x', 90), Publisher = "Example Publisher", InstallerType = "EXE", UninstallData = "inert-long" }];

    private async Task BeforeRead(CancellationToken token)
    {
        if (SlowReads) await Task.Delay(1500, token);
        if (FailNextRead) { FailNextRead = false; throw new InvalidOperationException("Inert QA fixture: query unavailable."); }
    }
    public async Task<SystemSnapshot> GetSystemInfoAsync(CancellationToken token)
    { await BeforeRead(token); return await readQueries.GetSystemInfoAsync(token); }
    public async Task<IReadOnlyList<StartupEntry>> GetStartupEntriesAsync(CancellationToken token)
    { await BeforeRead(token); return FixtureLists ? Startup : await readQueries.GetStartupEntriesAsync(token); }
    public async Task<IReadOnlyList<InstalledApplication>> GetApplicationsAsync(CancellationToken token)
    { await BeforeRead(token); return FixtureLists ? Apps : await readQueries.GetApplicationsAsync(token); }

    private ProcessResult InertResult()
    {
        InertActionCalls++;
        var code = NextExitCode; NextExitCode = 0;
        return new(code, "INERT ACCEPTANCE FIXTURE — no native operation executed.", code == 0 ? "" : "Inert fixture failure/conflict.");
    }
    public Task<ProcessResult> RunOperationAsync(string id, IProgress<string>? progress, CancellationToken token)
    { progress?.Report("INERT ACCEPTANCE FIXTURE — native engine disconnected."); return Task.FromResult(InertResult()); }
    public Task<ProcessResult> ToggleStartupAsync(StartupEntry entry, CancellationToken token) => Task.FromResult(InertResult());
    public Task<ProcessResult> UninstallAsync(InstalledApplication app, CancellationToken token) => Task.FromResult(InertResult());
}
