using System.Globalization;
using HolmesKit.Desktop.Services;

namespace HolmesKit.Desktop.Tests;

public class CommandServiceTests
{
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
