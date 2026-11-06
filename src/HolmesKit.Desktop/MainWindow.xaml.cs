using System.Windows;
using HolmesKit.Desktop.Services;
using HolmesKit.Desktop.ViewModels;

namespace HolmesKit.Desktop;

public partial class MainWindow : Window
{
    private readonly MainViewModel viewModel;
    private bool startupLoaded;
    private bool applicationsLoaded;
    private CancellationTokenSource? monitoring;
    private bool closed;

    public MainWindow() : this(null) { }

    public MainWindow(MainViewModel? model)
    {
        InitializeComponent();
        var paths = new HolmesKitPathResolver();
        viewModel = model ?? new MainViewModel(new HolmesKitCommandService(new ProcessRunner(), paths), paths);
        viewModel.Confirm = (title, message) => new ConfirmationWindow(title, message) { Owner = this }.ShowDialog() == true;
        viewModel.Notify = (title, message, icon) => MessageBox.Show(this, message, title, MessageBoxButton.OK, icon);
        DataContext = viewModel;
        viewModel.Activity.CollectionChanged += (_, _) => Dispatcher.BeginInvoke(() =>
        {
            if (viewModel.Activity.Count > 0) ActivityList.ScrollIntoView(viewModel.Activity[^1]);
        });
        Loaded += async (_, _) => { await viewModel.InitializeAsync(); UpdateMonitoring(); };
        StateChanged += (_, _) => UpdateMonitoring();
        IsVisibleChanged += (_, _) => UpdateMonitoring();
        viewModel.PropertyChanged += (_, e) => { if (e.PropertyName == nameof(MainViewModel.IsBusy)) UpdateMonitoring(); };
        Closed += (_, _) => { closed = true; StopMonitoring(); };
        Closing += (_, e) =>
        {
            if (viewModel.IsMutationRunning)
            {
                e.Cancel = true;
                MessageBox.Show(this, "Wait for the active operation to finish before closing HolmesKit. Interrupting it can leave partial changes.", "Operation running", MessageBoxButton.OK, MessageBoxImage.Information);
            }
            else if (viewModel.CancelCommand.CanExecute(null)) viewModel.CancelCommand.Execute(null);
        };
    }

    private void OnPageChanged(object sender, System.Windows.Controls.SelectionChangedEventArgs e)
    {
        if (!IsLoaded || e.Source != ShellTabs) return;
        UpdateMonitoring();
        if (ShellTabs.SelectedIndex == 5 && !startupLoaded)
        {
            if (!viewModel.RefreshStartupCommand.CanExecute(null)) return;
            startupLoaded = true;
            viewModel.RefreshStartupCommand.Execute(null);
        }
        else if (ShellTabs.SelectedIndex == 6 && !applicationsLoaded)
        {
            if (!viewModel.RefreshApplicationsCommand.CanExecute(null)) return;
            applicationsLoaded = true;
            viewModel.RefreshApplicationsCommand.Execute(null);
        }
        else if (ShellTabs.SelectedIndex == 9)
        {
            viewModel.RefreshLogsCommand.Execute(null);
        }
    }

    private void StopMonitoring()
    {
        monitoring?.Cancel();
        monitoring = null;
        viewModel.Dashboard.IsMonitoring = false;
    }

    private void UpdateMonitoring()
    {
        if (viewModel is null || closed) return;
        if (!DesktopMonitor.ShouldRun(IsLoaded && IsVisible, WindowState == WindowState.Minimized, ShellTabs.SelectedIndex, viewModel.IsBusy))
        { StopMonitoring(); return; }
        if (monitoring is not null) return;
        var lifetime = new CancellationTokenSource();
        monitoring = lifetime;
        viewModel.Dashboard.IsMonitoring = true;
        _ = MonitorAsync(lifetime);
    }

    private async Task MonitorAsync(CancellationTokenSource lifetime)
    {
        try
        {
            await Task.Run(() => DesktopMonitor.RunAsync(new WindowsTelemetrySampler(), TimeSpan.FromSeconds(2),
                async sample =>
                {
                    if (!Dispatcher.HasShutdownStarted)
                        await Dispatcher.InvokeAsync(() =>
                        {
                            if (!lifetime.IsCancellationRequested && !closed) viewModel.Dashboard.Record(sample);
                        });
                }, lifetime.Token));
        }
        catch (OperationCanceledException) when (lifetime.IsCancellationRequested || closed) { }
        catch (Exception ex)
        {
            if (!closed)
            {
                viewModel.Dashboard.Record(new(DateTimeOffset.UtcNow, null, null, null, null));
                viewModel.Activity.Add($"Live metrics unavailable: {ex.Message}");
            }
        }
        finally
        {
            if (ReferenceEquals(monitoring, lifetime))
            {
                monitoring = null;
                viewModel.Dashboard.IsMonitoring = false;
            }
            lifetime.Dispose();
        }
    }
}
