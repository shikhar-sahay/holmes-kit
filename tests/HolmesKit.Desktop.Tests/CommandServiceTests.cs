using System.Globalization;
using HolmesKit.Desktop.Services;

namespace HolmesKit.Desktop.Tests;

public class CommandServiceTests
{
    [Fact]
    public async Task ActualPowerShellFileBinding_PreservesBothUninstallIdentityValues()
    {
        var root = Path.Combine(Path.GetTempPath(), "HolmesKit transport " + Guid.NewGuid().ToString("N"));
        Directory.CreateDirectory(Path.Combine(root, "modules"));
        try
        {
            var source = File.ReadAllText(new HolmesKitPathResolver(AppContext.BaseDirectory).BridgeScript);
            // Only the real parameter block, never any engine/bridge action body.
            var parameters = source[..source.IndexOf("$ErrorActionPreference", StringComparison.Ordinal)];
            File.WriteAllText(Path.Combine(root, "modules", "gui_bridge.ps1"), parameters + "[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false); ConvertTo-Json -InputObject @{Data=$Data;NameData=$NameData} -Compress");
            var app = new HolmesKit.Desktop.Models.InstalledApplication { Name = "Example Ω & quoted \"name\"", UninstallData = Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes("C:\\Fixture with spaces\\uninstall.exe")) };
            var result = await new HolmesKitCommandService(new ProcessRunner(), new FakePaths(root)).UninstallAsync(app, TestContext.Current.CancellationToken);
            Assert.True(result.Succeeded, result.StandardError);
            using var json = System.Text.Json.JsonDocument.Parse(result.StandardOutput);
            Assert.Equal(app.UninstallData, json.RootElement.GetProperty("Data")[0].GetString());
            Assert.Equal(app.Name, System.Text.Encoding.UTF8.GetString(Convert.FromBase64String(json.RootElement.GetProperty("NameData").GetString()!)));
        }
        finally { Directory.Delete(root, true); }
    }
    [Fact]
    public async Task RealDesktopBatchBoundary_PropagatesPrerequisiteFailureWithoutInput()
    {
        var directory = Path.Combine(Path.GetTempPath(), "HolmesKit Boundary " + Guid.NewGuid().ToString("N"));
        Directory.CreateDirectory(directory);
        try
        {
            File.WriteAllText(Path.Combine(directory, "HolmesKit.bat"), "@echo off\r\necho Required backup failed\r\nexit /b 1\r\n");
            var service = new HolmesKitCommandService(new ProcessRunner(), new FakePaths(directory));
            var result = await service.RunOperationAsync("power-high", null, TestContext.Current.CancellationToken);
            Assert.False(result.Succeeded);
            Assert.Equal(1, result.ExitCode);
            Assert.Contains("Required backup failed", result.StandardOutput);
        }
        finally { Directory.Delete(directory, true); }
    }
    [Fact]
    public void BatchRequest_UsesResolvedPathsAndNonInteractiveOperation()
    {
        var paths = new FakePaths(@"C:\Holmes Kit");
        var request = HolmesKitCommandService.BuildBatchRequest(paths, "gaming-full");
        Assert.EndsWith("cmd.exe", request.FileName, StringComparison.OrdinalIgnoreCase);
        Assert.Equal(@"C:\Holmes Kit", request.WorkingDirectory);
        Assert.Contains("gaming-full", request.Arguments[^1]);
        Assert.Contains('"' + paths.BatchFile + '"', request.Arguments[^1]);
    }

    [Fact]
    public async Task UnknownOperation_IsRejectedBeforeLaunchingProcess()
    {
        var runner = new FakeRunner();
        var service = new HolmesKitCommandService(runner, new FakePaths(@"C:\Holmes Kit"));
        await Assert.ThrowsAsync<ArgumentOutOfRangeException>(() => service.RunOperationAsync("not-real", null, CancellationToken.None));
        Assert.Equal(0, runner.CallCount);
    }

    [Fact]
    public async Task ProcessRunner_CapturesOutputAndExitCode()
    {
        var runner = new ProcessRunner();
        var request = new ProcessRequest(Environment.GetEnvironmentVariable("ComSpec") ?? "cmd.exe", ["/d", "/c", "echo HolmesKit"], Environment.CurrentDirectory);
        var result = await runner.RunAsync(request, cancellationToken: TestContext.Current.CancellationToken);
        Assert.True(result.Succeeded);
        Assert.Contains("HolmesKit", result.StandardOutput);
    }

    [Fact]
    public async Task MalformedBridgeOutput_IsReported()
    {
        var runner = new FakeRunner { Result = new ProcessResult(0, "not-json", "") };
        var service = new HolmesKitCommandService(runner, new FakePaths(@"C:\Holmes Kit"));
        await Assert.ThrowsAsync<InvalidDataException>(() => service.GetSystemInfoAsync(TestContext.Current.CancellationToken));
    }

    [Fact]
    public async Task FailedBridgeProcess_PreservesDiagnostic()
    {
        var runner = new FakeRunner { Result = new ProcessResult(5, "", "Access denied") };
        var service = new HolmesKitCommandService(runner, new FakePaths(@"C:\Holmes Kit"));
        var error = await Assert.ThrowsAsync<InvalidOperationException>(() => service.GetApplicationsAsync(TestContext.Current.CancellationToken));
        Assert.Contains("Access denied", error.Message);
    }

    [Fact]
    public async Task CancelledRead_IsReportedAsCancellationRatherThanFailure()
    {
        var runner = new FakeRunner { Result = new ProcessResult(-1, "", "", WasCancelled: true) };
        var service = new HolmesKitCommandService(runner, new FakePaths(@"C:\Holmes Kit"));
        await Assert.ThrowsAsync<OperationCanceledException>(() => service.GetSystemInfoAsync(TestContext.Current.CancellationToken));
    }

    [Fact]
    public async Task StructuredNumbers_ParseIndependentlyOfCurrentCulture()
    {
        var prior = CultureInfo.CurrentCulture;
        try
        {
            CultureInfo.CurrentCulture = CultureInfo.GetCultureInfo("de-DE");
            var runner = new FakeRunner { Result = new ProcessResult(0, "{\"MemoryPercent\":86.55842748642033,\"PowerPlanKind\":\"Custom\",\"PowerPlanName\":\"Work plan\"}", "") };
            var snapshot = await new HolmesKitCommandService(runner, new FakePaths(@"C:\Holmes Kit")).GetSystemInfoAsync(TestContext.Current.CancellationToken);
            Assert.Equal(86.55842748642033, snapshot.MemoryPercent);
            Assert.Equal("Custom power plan", snapshot.PowerPlanDisplay);
        }
        finally { CultureInfo.CurrentCulture = prior; }
    }

    private sealed class FakeRunner : IProcessRunner
    {
        public int CallCount { get; private set; }
        public ProcessResult Result { get; set; } = new(0, "", "");
        public Task<ProcessResult> RunAsync(ProcessRequest request, IProgress<string>? progress = null, CancellationToken cancellationToken = default)
        { CallCount++; return Task.FromResult(Result); }
    }

    private sealed class FakePaths(string root) : IHolmesKitPathResolver
    {
        public string RootDirectory => root;
        public string BatchFile => Path.Combine(root, "HolmesKit.bat");
        public string BridgeScript => Path.Combine(root, "modules", "gui_bridge.ps1");
        public string LogFile => Path.Combine(root, "HolmesKit_Backups", "holmeskit.log");
        public void Validate() { }
    }
}
