using HolmesKit.Desktop.Models;
using HolmesKit.Desktop.Services;
using HolmesKit.Desktop.ViewModels;

namespace HolmesKit.Desktop.Tests;

public class GuiAuthorizationTests
{
    [Theory]
    [InlineData(false, 0)]
    [InlineData(true, 1)]
    public void DialogApproval_IsRequiredAndFailedPrerequisiteNeverReportsSuccess(bool approved, int calls)
    {
        Exception? failure = null;
        var thread = new Thread(() =>
        {
            var directory = Path.Combine(Path.GetTempPath(), "HolmesKit.GuiSafety." + Guid.NewGuid().ToString("N"));
            Directory.CreateDirectory(directory);
            try
            {
                var runner = new FailedBackupRunner();
                var paths = new TempPaths(directory);
                var vm = new MainViewModel(new HolmesKitCommandService(runner, paths), paths) { Confirm = (_, _) => approved };
                vm.RunOperationCommand.Execute(OperationCatalog.All.Single(x => x.Id == "power-high"));
                Assert.Equal(calls, runner.Calls);
                Assert.DoesNotContain("Completed successfully.", vm.Activity);
                if (approved)
                {
                    Assert.Equal("Failed", vm.Status);
                    Assert.Contains(vm.Activity, x => x.Contains("Required backup failed"));
                    Assert.DoesNotContain(runner.Request!.Arguments, x => x.Contains("Read-Host"));
                }
            }
            catch (Exception ex) { failure = ex; }
            finally { Directory.Delete(directory, true); }
        });
        thread.SetApartmentState(ApartmentState.STA);
        thread.Start();
        Assert.True(thread.Join(TimeSpan.FromSeconds(10)));
        Assert.Null(failure);
    }

    private sealed class FailedBackupRunner : IProcessRunner
    {
        public int Calls;
        public ProcessRequest? Request;
        public Task<ProcessResult> RunAsync(ProcessRequest request, IProgress<string>? progress = null, CancellationToken cancellationToken = default)
        {
            Calls++; Request = request;
            return Task.FromResult(new ProcessResult(1, "Required backup failed. Protected operation was not started.", ""));
        }
    }
    private sealed class TempPaths(string root) : IHolmesKitPathResolver
    {
        public string RootDirectory => root;
        public string BatchFile => Path.Combine(root, "HolmesKit.bat");
        public string BridgeScript => Path.Combine(root, "modules", "gui_bridge.ps1");
        public string LogFile => Path.Combine(root, "holmeskit.log");
        public void Validate() { }
    }
}
