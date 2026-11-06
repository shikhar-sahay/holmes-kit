using System.IO;
using System.Text;
using System.Text.Json;
using System.Security.Cryptography;
using System.Security.Principal;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Input;
using HolmesKit.Desktop.Services;
using HolmesKit.Desktop.ViewModels;

namespace HolmesKit.Desktop.Acceptance;

public static class Program
{
    [STAThread]
    public static void Main()
    {
        // Separate non-elevated test executable: production manifest and engine stay unchanged.
        var app = new App { ShutdownMode = ShutdownMode.OnMainWindowClose };
        app.Resources.MergedDictionaries.Add(new() { Source = new Uri("pack://application:,,,/HolmesKit;component/Themes/DarkPalette.xaml") });
        app.Resources.MergedDictionaries.Add(new() { Source = new Uri("pack://application:,,,/HolmesKit;component/Themes/Controls.xaml") });
        var queries = new HolmesKitCommandService(new ProcessRunner(), new HolmesKitPathResolver());
        var service = new AcceptanceService(queries);
        var paths = new FixturePaths();
        var model = new MainViewModel(service, paths);
        var window = new MainWindow(model) { Title = "HolmesKit — QA fixture · native actions disconnected" };
        // Expose fixture modals as targetable windows to desktop QA tools; production stays taskbar-free.
        model.Confirm = (title, message) => new ConfirmationWindow(title, message) { Owner = window, ShowInTaskbar = true }.ShowDialog() == true;
        app.MainWindow = window;
        var panel = new StackPanel { Margin = new Thickness(16) };
        panel.Children.Add(new TextBlock { Text = "QA controls · fixtures only", FontWeight = FontWeights.Bold });
        void Button(string title, Action action)
        {
            var button = new Button { Content = title, Margin = new Thickness(0, 8, 0, 0) };
            button.Click += (_, _) => action(); panel.Children.Add(button);
        }
        Button("900 × 620", () => { window.WindowState = WindowState.Normal; window.Width = 900; window.Height = 620; });
        Button("1120 × 760", () => { window.WindowState = WindowState.Normal; window.Width = 1120; window.Height = 760; });
        Button("1600 × 900", () => { window.WindowState = WindowState.Normal; window.Width = 1600; window.Height = 900; });
        Button("Maximize", () => window.WindowState = WindowState.Maximized);
        Button("Real lists (then Refresh page)", () => service.FixtureLists = false);
        Button("Example lists (then Refresh page)", () => service.FixtureLists = true);
        Button("Slow fixture reads on / off", () => service.SlowReads = !service.SlowReads);
        Button("Fail next read", () => service.FailNextRead = true);
        Button("Fail next inert action", () => service.NextExitCode = 1);
        Button("Partial next inert action", () => service.NextExitCode = 4);
        Button("Interrupted baseline fixture", () => { WriteJournal(paths, "Running"); model.RefreshSystemCommand.Execute(null); });
        Button("Ready baseline fixture", () => { WriteJournal(paths, "Ready"); model.RefreshSystemCommand.Execute(null); });
        Button("Capture current content (private)", () =>
        {
            var content = (FrameworkElement)window.Content;
            var bitmap = new RenderTargetBitmap((int)content.ActualWidth, (int)content.ActualHeight, 96, 96, PixelFormats.Pbgra32);
            bitmap.Render(content);
            var encoder = new PngBitmapEncoder(); encoder.Frames.Add(BitmapFrame.Create(bitmap));
            Directory.CreateDirectory(paths.RootDirectory);
            using var file = File.Create(Path.Combine(paths.RootDirectory, $"view-{model.SelectedPageIndex}-{DateTime.UtcNow:HHmmss}.png"));
            encoder.Save(file);
        });
        var controls = new Window { Title = "HolmesKit QA controls", Content = new ScrollViewer { Content = panel }, Width = 310, Height = 760 };
        window.Loaded += (_, _) => { controls.Owner = window; controls.Show(); };
        window.PreviewKeyDown += (_, args) =>
        {
            if (args.Key != Key.F12) return;
            if (controls.IsVisible) controls.Hide(); else controls.Show();
            args.Handled = true;
        };
        app.Run(window);
    }

    private static void WriteJournal(FixturePaths paths, string status)
    {
        using var identity = WindowsIdentity.GetCurrent();
        var payload = JsonSerializer.Serialize(new { Version = 1, Status = status, CreatedUtc = DateTime.UtcNow,
            User = identity.User?.Value, Machine = Convert.ToString(Microsoft.Win32.Registry.GetValue(@"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Cryptography", "MachineGuid", null)),
            Entries = new[] { new { Fixture = true } }, Operation = "power-high" });
        var directory = Path.Combine(paths.RootDirectory, "HolmesKit_Backups", "recovery"); Directory.CreateDirectory(directory);
        File.WriteAllText(Path.Combine(directory, "baseline.json"), JsonSerializer.Serialize(new { Payload = payload, Sha256 = Convert.ToBase64String(SHA256.HashData(Encoding.UTF8.GetBytes(payload))) }));
    }

    private sealed class FixturePaths : IHolmesKitPathResolver
    {
        public string RootDirectory { get; } = Path.Combine(AppContext.BaseDirectory, "private-qa-state");
        public string BatchFile => throw new InvalidOperationException("The fixture has no engine.");
        public string BridgeScript => throw new InvalidOperationException("The fixture has no mutation bridge.");
        public string LogFile => Path.Combine(RootDirectory, "HolmesKit_Backups", "qa.log");
        public void Validate() => throw new InvalidOperationException("Native dispatch is disconnected.");
    }
}
