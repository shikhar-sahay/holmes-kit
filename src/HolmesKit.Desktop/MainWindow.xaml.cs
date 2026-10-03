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
    }

    private void OnPageChanged(object sender, System.Windows.Controls.SelectionChangedEventArgs e)
    {
        if (!IsLoaded || e.Source != ShellTabs) return;
        if (ShellTabs.SelectedIndex == 5 && !startupLoaded)
        {
            startupLoaded = true;
            viewModel.RefreshStartupCommand.Execute(null);
        }
        else if (ShellTabs.SelectedIndex == 6 && !applicationsLoaded)
        {
            applicationsLoaded = true;
            viewModel.RefreshApplicationsCommand.Execute(null);
        }
        else if (ShellTabs.SelectedIndex == 9)
        {
            viewModel.RefreshLogsCommand.Execute(null);
        }
    }
}
