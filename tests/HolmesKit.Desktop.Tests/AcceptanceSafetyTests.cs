using HolmesKit.Desktop.Acceptance;
using HolmesKit.Desktop.Models;
using HolmesKit.Desktop.Services;

namespace HolmesKit.Desktop.Tests;

public class AcceptanceSafetyTests
{
    [Theory]
    [InlineData("operation", 0)] [InlineData("operation", 1)] [InlineData("operation", 4)]
    [InlineData("startup", 0)] [InlineData("startup", 1)] [InlineData("startup", 4)]
    [InlineData("uninstall", 0)] [InlineData("uninstall", 1)] [InlineData("uninstall", 4)]
    public async Task EveryAcceptanceMutation_IsInertRegardlessOfRequestedOutcome(string action, int code)
    {
        var native = new RejectingNativeService();
        var service = new AcceptanceService(native) { NextExitCode = code };
        var result = action switch
        {
            "operation" => await service.RunOperationAsync("apply-all", null, CancellationToken.None),
            "startup" => await service.ToggleStartupAsync(new(), CancellationToken.None),
            _ => await service.UninstallAsync(new(), CancellationToken.None)
        };
        Assert.Equal(code, result.ExitCode);
        Assert.Contains("INERT", result.StandardOutput);
        Assert.Equal(1, service.InertActionCalls);
        Assert.Equal(0, native.Mutations);
    }

    [Fact]
    public async Task AcceptanceRealMode_DelegatesOnlyReadQueries()
    {
        var native = new RejectingNativeService();
        var service = new AcceptanceService(native) { FixtureLists = false };
        await service.GetSystemInfoAsync(CancellationToken.None);
        await service.GetStartupEntriesAsync(CancellationToken.None);
        await service.GetApplicationsAsync(CancellationToken.None);
        Assert.Equal(3, native.Reads);
        Assert.Equal(0, native.Mutations);
    }

    private sealed class RejectingNativeService : IHolmesKitCommandService
    {
        public int Reads, Mutations;
        private Task<ProcessResult> Reject() { Mutations++; throw new Exception("Native mutation must never be invoked."); }
        public Task<ProcessResult> RunOperationAsync(string id, IProgress<string>? progress, CancellationToken token) => Reject();
        public Task<ProcessResult> ToggleStartupAsync(StartupEntry entry, CancellationToken token) => Reject();
        public Task<ProcessResult> UninstallAsync(InstalledApplication app, CancellationToken token) => Reject();
        public Task<SystemSnapshot> GetSystemInfoAsync(CancellationToken token) { Reads++; return Task.FromResult(new SystemSnapshot()); }
        public Task<IReadOnlyList<StartupEntry>> GetStartupEntriesAsync(CancellationToken token) { Reads++; return Task.FromResult<IReadOnlyList<StartupEntry>>([]); }
        public Task<IReadOnlyList<InstalledApplication>> GetApplicationsAsync(CancellationToken token) { Reads++; return Task.FromResult<IReadOnlyList<InstalledApplication>>([]); }
    }
}
