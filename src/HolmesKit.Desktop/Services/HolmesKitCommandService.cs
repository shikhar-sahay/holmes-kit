using System.Text.Json;
using HolmesKit.Desktop.Models;

namespace HolmesKit.Desktop.Services;

public interface IHolmesKitCommandService
{
    Task<ProcessResult> RunOperationAsync(string operationId, IProgress<string>? progress, CancellationToken token);
    Task<SystemSnapshot> GetSystemInfoAsync(CancellationToken token);
    Task<IReadOnlyList<StartupEntry>> GetStartupEntriesAsync(CancellationToken token);
    Task<ProcessResult> ToggleStartupAsync(StartupEntry entry, CancellationToken token);
    Task<IReadOnlyList<InstalledApplication>> GetApplicationsAsync(CancellationToken token);
    Task<ProcessResult> UninstallAsync(InstalledApplication app, CancellationToken token);
}

public sealed class HolmesKitCommandService(IProcessRunner runner, IHolmesKitPathResolver paths) : IHolmesKitCommandService
{
    private static readonly JsonSerializerOptions JsonOptions = new() { PropertyNameCaseInsensitive = true };

    public Task<ProcessResult> RunOperationAsync(string operationId, IProgress<string>? progress, CancellationToken token)
    {
        if (!OperationCatalog.All.Any(x => x.Id == operationId)) throw new ArgumentOutOfRangeException(nameof(operationId));
        paths.Validate();
        return runner.RunAsync(BuildBatchRequest(paths, operationId), progress, token);
    }

    public async Task<SystemSnapshot> GetSystemInfoAsync(CancellationToken token) =>
        await RunJsonAsync<SystemSnapshot>("system-info", [], token) ?? new();

    public async Task<IReadOnlyList<StartupEntry>> GetStartupEntriesAsync(CancellationToken token) =>
        await RunJsonAsync<List<StartupEntry>>("startup-list", [], token) ?? [];

    public Task<ProcessResult> ToggleStartupAsync(StartupEntry entry, CancellationToken token) =>
        RunBridgeAsync("startup-toggle", [Encode(JsonSerializer.Serialize(entry))], token);

    public async Task<IReadOnlyList<InstalledApplication>> GetApplicationsAsync(CancellationToken token) =>
        await RunJsonAsync<List<InstalledApplication>>("apps-list", [], token) ?? [];

    public Task<ProcessResult> UninstallAsync(InstalledApplication app, CancellationToken token) =>
        RunBridgeAsync("app-uninstall", [app.UninstallData, Encode(app.Name)], token);

    public static ProcessRequest BuildBatchRequest(IHolmesKitPathResolver paths, string operationId)
    {
        var command = $"\"{paths.BatchFile}\" --run {operationId}";
        return new(Environment.GetEnvironmentVariable("ComSpec") ?? "cmd.exe", ["/d", "/s", "/c", command], paths.RootDirectory);
    }

    private async Task<T?> RunJsonAsync<T>(string action, IReadOnlyList<string> arguments, CancellationToken token)
    {
        var result = await RunBridgeAsync(action, arguments, token);
        if (!result.Succeeded) throw new InvalidOperationException(string.IsNullOrWhiteSpace(result.StandardError) ? result.StandardOutput : result.StandardError);
        try { return JsonSerializer.Deserialize<T>(result.StandardOutput.Trim(), JsonOptions); }
        catch (JsonException ex) { throw new InvalidDataException("HolmesKit returned malformed data.", ex); }
    }

    private Task<ProcessResult> RunBridgeAsync(string action, IReadOnlyList<string> arguments, CancellationToken token)
    {
        paths.Validate();
        var args = new List<string> { "-NoProfile", "-NonInteractive", "-ExecutionPolicy", "Bypass", "-File", paths.BridgeScript, "-Action", action };
        if (arguments.Count > 0)
        {
            args.Add("-Data");
            args.AddRange(arguments);
        }
        return runner.RunAsync(new("powershell.exe", args, paths.RootDirectory), cancellationToken: token);
    }

    private static string Encode(string value) => Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes(value));
}
