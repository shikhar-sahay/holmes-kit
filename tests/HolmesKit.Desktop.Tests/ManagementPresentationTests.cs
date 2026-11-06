using HolmesKit.Desktop.Models;
using HolmesKit.Desktop.Services;
using HolmesKit.Desktop.ViewModels;

namespace HolmesKit.Desktop.Tests;

public class ManagementPresentationTests
{
    [Theory]
    [InlineData(false)]
    [InlineData(true)]
    public void FilteringSortingAndConfirmation_PreserveUnderlyingActionTarget(bool approved)
    {
        Exception? failure = null;
        var thread = new Thread(() =>
        {
            var root = Path.Combine(Path.GetTempPath(), "HolmesKit.ManagementFixture." + Guid.NewGuid().ToString("N"));
            Directory.CreateDirectory(root);
            try
            {
                var service = new FixtureService();
                var model = new MainViewModel(service, new FixturePaths(root)) { Confirm = (_, _) => approved };
                model.RefreshStartupCommand.Execute(null);
                model.StartupFilter = "Beta";
                model.StartupView.SortDescriptions.Add(new(nameof(StartupEntry.Name), System.ComponentModel.ListSortDirection.Descending));
                var startup = Assert.IsType<StartupEntry>(Assert.Single(model.StartupView.Cast<object>()));
                Assert.Same(service.Startup[1], startup);
                model.ToggleStartupCommand.Execute(startup);
                model.RefreshApplicationsCommand.Execute(null);
                model.AppFilter = "Beta";
                model.ApplicationsView.SortDescriptions.Add(new(nameof(InstalledApplication.Name), System.ComponentModel.ListSortDirection.Descending));
                var app = Assert.IsType<InstalledApplication>(Assert.Single(model.ApplicationsView.Cast<object>()));
                model.UninstallCommand.Execute(app);
                if (approved)
                {
                    Assert.Same(startup, service.Toggled);
                    Assert.Same(service.Apps[1], service.Uninstalled);
                }
                else { Assert.Null(service.Toggled); Assert.Null(service.Uninstalled); }
                model.AppFilter = "no matching application";
                Assert.True(model.ApplicationsView.IsEmpty);
                Assert.False(model.IsBusy);
            }
            catch (Exception ex) { failure = ex; }
            finally { Directory.Delete(root, true); }
        });
        thread.IsBackground = true;
        thread.SetApartmentState(ApartmentState.STA);
        thread.Start();
        Assert.True(thread.Join(TimeSpan.FromSeconds(10)));
        Assert.Null(failure);
    }

    private sealed class FixturePaths(string root) : IHolmesKitPathResolver
    {
        public string RootDirectory => root;
        public string BatchFile => Path.Combine(root, "unused.bat");
        public string BridgeScript => Path.Combine(root, "unused.ps1");
        public string LogFile => Path.Combine(root, "fixture.log");
        public void Validate() => throw new InvalidOperationException("No native processes are permitted in this fixture.");
    }
    private sealed class FixtureService : IHolmesKitCommandService
    {
        public StartupEntry[] Startup { get; } = [new() { Name = "Alpha" }, new() { Name = "Beta Ω", Command = new string('x', 400), Status = "Enabled" }];
        public InstalledApplication[] Apps { get; } = [new() { Name = "Alpha" }, new() { Name = "Beta Ω", UninstallData = "fixture-beta" }];
        public StartupEntry? Toggled;
        public InstalledApplication? Uninstalled;
        public Task<ProcessResult> RunOperationAsync(string id, IProgress<string>? progress, CancellationToken token) => throw new InvalidOperationException("No engine calls allowed.");
        public Task<SystemSnapshot> GetSystemInfoAsync(CancellationToken token) => Task.FromResult(new SystemSnapshot());
        public Task<IReadOnlyList<StartupEntry>> GetStartupEntriesAsync(CancellationToken token) => Task.FromResult<IReadOnlyList<StartupEntry>>(Startup);
        public Task<IReadOnlyList<InstalledApplication>> GetApplicationsAsync(CancellationToken token) => Task.FromResult<IReadOnlyList<InstalledApplication>>(Apps);
        public Task<ProcessResult> ToggleStartupAsync(StartupEntry entry, CancellationToken token) { Toggled = entry; return Task.FromResult(new ProcessResult(0, "Fixture only", "")); }
        public Task<ProcessResult> UninstallAsync(InstalledApplication app, CancellationToken token) { Uninstalled = app; return Task.FromResult(new ProcessResult(0, "Fixture only", "")); }
    }
}
