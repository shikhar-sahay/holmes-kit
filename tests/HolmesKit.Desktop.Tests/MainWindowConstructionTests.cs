using System.Xml.Linq;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Threading;
using HolmesKit.Desktop.ViewModels;

namespace HolmesKit.Desktop.Tests;

public class MainWindowConstructionTests
{
    [Fact]
    public void MainWindow_ConstructsAndAppliesBindingsOnStaThread()
    {
        Exception? failure = null;
        var thread = new Thread(() =>
        {
            try
            {
                SynchronizationContext.SetSynchronizationContext(new DispatcherSynchronizationContext());
                var app = new App { ShutdownMode = System.Windows.ShutdownMode.OnExplicitShutdown };
                app.InitializeComponent();
                var window = new MainWindow { Width = 1120, Height = 760 };
                var pages = Assert.IsType<TabControl>(window.FindName("ShellTabs"));
                Assert.Equal(10, pages.Items.Count);
                var outputDirectory = Environment.GetEnvironmentVariable("HOLMESKIT_VISUAL_REVIEW_DIR");
                if (!string.IsNullOrWhiteSpace(outputDirectory))
                {
                    Directory.CreateDirectory(outputDirectory);
                    window.Left = 20;
                    window.Top = 20;
                    window.ShowInTaskbar = false;
                    window.WindowStartupLocation = WindowStartupLocation.Manual;
                    window.Show();
                    WaitForIdle(window, TimeSpan.FromSeconds(10));
                    for (var index = 0; index < pages.Items.Count; index++)
                    {
                        pages.SelectedIndex = index;
                        WaitForIdle(window, TimeSpan.FromSeconds(10));
                        PumpDispatcher();
                        window.UpdateLayout();
                        var header = ((TabItem)pages.Items[index]).Header?.ToString() ?? $"page-{index}";
                        var safeName = string.Join("-", header.Split(Path.GetInvalidFileNameChars(), StringSplitOptions.RemoveEmptyEntries)).Replace(' ', '-').ToLowerInvariant();
                        SaveScreenshot(window, Path.Combine(outputDirectory, $"{index:00}-{safeName}.png"));
                    }
                    window.Width = 900;
                    window.Height = 620;
                    pages.SelectedIndex = 0;
                    PumpDispatcher();
                    window.UpdateLayout();
                    SaveScreenshot(window, Path.Combine(outputDirectory, "compact-00-home.png"));
                    pages.SelectedIndex = 1;
                    PumpDispatcher();
                    window.UpdateLayout();
                    SaveScreenshot(window, Path.Combine(outputDirectory, "compact-01-core.png"));
                    window.Width = 1600;
                    window.Height = 900;
                    pages.SelectedIndex = 7;
                    PumpDispatcher();
                    window.UpdateLayout();
                    SaveScreenshot(window, Path.Combine(outputDirectory, "wide-07-system-info.png"));
                }
                else
                {
                    window.ApplyTemplate();
                    window.Measure(new Size(1120, 760));
                    window.Arrange(new Rect(0, 0, 1120, 760));
                    window.UpdateLayout();
                    for (var index = 0; index < pages.Items.Count; index++)
                    {
                        pages.SelectedIndex = index;
                        window.UpdateLayout();
                        Assert.True(((TabItem)pages.Items[index]).IsSelected);
                    }
                }
                window.Close();
                app.Shutdown();
            }
            catch (Exception ex) { failure = ex; }
        });
        thread.SetApartmentState(ApartmentState.STA);
        thread.Start();
        var timeout = string.IsNullOrWhiteSpace(Environment.GetEnvironmentVariable("HOLMESKIT_VISUAL_REVIEW_DIR"))
            ? TimeSpan.FromSeconds(10)
            : TimeSpan.FromMinutes(2);
        Assert.True(thread.Join(timeout), "MainWindow construction timed out.");
        Assert.Null(failure);
    }

    [Fact]
    public void ReadOnlyTextBoxes_UseOneWayTextBindings()
    {
        var root = FindRepositoryRoot();
        var document = XDocument.Load(Path.Combine(root, "src", "HolmesKit.Desktop", "MainWindow.xaml"));
        XNamespace presentation = "http://schemas.microsoft.com/winfx/2006/xaml/presentation";
        var violations = document.Descendants(presentation + "TextBox")
            .Where(element => string.Equals((string?)element.Attribute("IsReadOnly"), "True", StringComparison.OrdinalIgnoreCase))
            .Select(element => (string?)element.Attribute("Text"))
            .Where(text => text is not null && text.Contains("{Binding", StringComparison.Ordinal) && !text.Contains("Mode=OneWay", StringComparison.Ordinal))
            .ToList();
        Assert.Empty(violations);
    }

    private static void WaitForIdle(MainWindow window, TimeSpan timeout)
    {
        var viewModel = Assert.IsType<MainViewModel>(window.DataContext);
        var deadline = DateTime.UtcNow + timeout;
        do
        {
            var frame = new DispatcherFrame();
            var timer = new DispatcherTimer(DispatcherPriority.Background) { Interval = TimeSpan.FromMilliseconds(80) };
            timer.Tick += (_, _) => { timer.Stop(); frame.Continue = false; };
            timer.Start();
            Dispatcher.PushFrame(frame);
        }
        while (viewModel.IsBusy && DateTime.UtcNow < deadline);
    }

    private static void SaveScreenshot(Window window, string path)
    {
        var target = Assert.IsAssignableFrom<FrameworkElement>(window.Content);
        var width = Math.Max(1, (int)Math.Ceiling(target.ActualWidth));
        var height = Math.Max(1, (int)Math.Ceiling(target.ActualHeight));
        var bitmap = new RenderTargetBitmap(width, height, 96, 96, PixelFormats.Pbgra32);
        bitmap.Render(target);
        var encoder = new PngBitmapEncoder();
        encoder.Frames.Add(BitmapFrame.Create(bitmap));
        using var stream = File.Create(path);
        encoder.Save(stream);
    }

    private static void PumpDispatcher()
    {
        var frame = new DispatcherFrame();
        var timer = new DispatcherTimer(DispatcherPriority.ApplicationIdle) { Interval = TimeSpan.FromMilliseconds(150) };
        timer.Tick += (_, _) => { timer.Stop(); frame.Continue = false; };
        timer.Start();
        Dispatcher.PushFrame(frame);
    }

    private static string FindRepositoryRoot()
    {
        var current = new DirectoryInfo(AppContext.BaseDirectory);
        while (current is not null)
        {
            if (File.Exists(Path.Combine(current.FullName, "HolmesKit.slnx"))) return current.FullName;
            current = current.Parent;
        }
        throw new DirectoryNotFoundException("Repository root was not found.");
    }
}
