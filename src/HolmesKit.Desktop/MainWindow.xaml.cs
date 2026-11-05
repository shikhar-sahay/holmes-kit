using System.Windows;
using HolmesKit.Desktop.Services;
using HolmesKit.Desktop.ViewModels;

namespace HolmesKit.Desktop;

public partial class MainWindow : Window
{
    private readonly MainViewModel viewModel;
    private bool startupLoaded;
    private bool applicationsLoaded;

    public MainWindow()
    {
        InitializeComponent();
        var paths = new HolmesKitPathResolver();
        viewModel = new MainViewModel(new HolmesKitCommandService(new ProcessRunner(), paths), paths)
        {
            Confirm = (title, message) => MessageBox.Show(this, message, title, MessageBoxButton.YesNo, MessageBoxImage.Warning, MessageBoxResult.No) == MessageBoxResult.Yes,
            Notify = (title, message, icon) => MessageBox.Show(this, message, title, MessageBoxButton.OK, icon)
        };
        DataContext = viewModel;
        viewModel.Activity.CollectionChanged += (_, _) => Dispatcher.BeginInvoke(() =>
        {
            if (viewModel.Activity.Count > 0) ActivityList.ScrollIntoView(viewModel.Activity[^1]);
        });
        Loaded += async (_, _) => await viewModel.InitializeAsync();
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
}
