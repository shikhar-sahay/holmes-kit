using System.Windows;

namespace HolmesKit.Desktop;

public partial class ConfirmationWindow : Window
{
    public ConfirmationWindow(string title, string message)
    {
        InitializeComponent();
        Title = title;
        OperationHeading.Text = title;
        Details.Text = message;
        Loaded += (_, _) => CancelAction.Focus();
    }
    private void ConfirmClick(object sender, RoutedEventArgs e) => DialogResult = true;
}
