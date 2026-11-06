using System.Windows;
using System.Windows.Input;

namespace HolmesKit.Desktop;

public partial class ConfirmationWindow : Window
{
    public ConfirmationWindow(string title, string message)
    {
        InitializeComponent();
        Title = title;
        OperationHeading.Text = title;
        Details.Text = message;
        ContentRendered += (_, _) => Keyboard.Focus(CancelAction);
    }
    protected override void OnPreviewKeyDown(KeyEventArgs e)
    {
        if (e.Key == Key.Escape) { DialogResult = false; e.Handled = true; return; }
        base.OnPreviewKeyDown(e);
    }
    private void ConfirmClick(object sender, RoutedEventArgs e) => DialogResult = true;
}
