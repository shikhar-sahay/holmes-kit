using System.Windows;
using HolmesKit.Desktop.Services;
using HolmesKit.Desktop.ViewModels;

namespace HolmesKit.Desktop;

public partial class MainWindow : Window
{
    private readonly MainViewModel viewModel;

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
        Loaded += async (_, _) => await viewModel.InitializeAsync();
    }
}
