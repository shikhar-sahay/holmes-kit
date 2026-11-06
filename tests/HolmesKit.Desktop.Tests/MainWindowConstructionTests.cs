using System.Xml.Linq;
using System.Diagnostics;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Threading;
using HolmesKit.Desktop.ViewModels;
using HolmesKit.Desktop.Models;
using HolmesKit.Desktop.Services;
using HolmesKit.Desktop.Acceptance;

namespace HolmesKit.Desktop.Tests;

[CollectionDefinition("WpfConstruction", DisableParallelization = true)]
public sealed class WpfConstructionCollection { }

[Collection("WpfConstruction")]
public class MainWindowConstructionTests
{
    [Fact]
    public void MainWindow_ConstructsAndAppliesBindingsOnStaThread()
    {
        Exception? failure = null;
        var stage = "STA startup";
        var thread = new Thread(() =>
        {
            var bindingErrors = new BindingErrorListener();
            var previousLevel = PresentationTraceSources.DataBindingSource.Switch.Level;
            PresentationTraceSources.DataBindingSource.Switch.Level = SourceLevels.Error;
            PresentationTraceSources.DataBindingSource.Listeners.Add(bindingErrors);
            try
            {
                SynchronizationContext.SetSynchronizationContext(new DispatcherSynchronizationContext());
                stage = "application resources";
                var app = new App { ShutdownMode = System.Windows.ShutdownMode.OnExplicitShutdown };
                Exception? dispatcherFailure = null;
                app.DispatcherUnhandledException += (_, args) =>
                {
                    dispatcherFailure = args.Exception;
                    args.Handled = true; // Never leave an unattended error MessageBox on a hosted runner.
                };
                // Load the actual theme resources without App.xaml's StartupUri (which opens a window).
                app.Resources.MergedDictionaries.Add(new ResourceDictionary { Source = new Uri("pack://application:,,,/HolmesKit;component/Themes/DarkPalette.xaml") });
                app.Resources.MergedDictionaries.Add(new ResourceDictionary { Source = new Uri("pack://application:,,,/HolmesKit;component/Themes/Controls.xaml") });
                PumpDispatcher();
                stage = "window construction";
                var fixtureService = new ConstructionService();
                var fixture = new MainViewModel(fixtureService, new ConstructionPaths());
                fixture.RefreshSystemCommand.Execute(null);
                var outputDirectory = Environment.GetEnvironmentVariable("HOLMESKIT_VISUAL_REVIEW_DIR");
                // Ordinary construction must never depend on native scans or modal query errors.
                var review = new MainViewModel(new AcceptanceService(new HolmesKitCommandService(new ProcessRunner(), new HolmesKitPathResolver())), new ConstructionPaths());
                var window = string.IsNullOrWhiteSpace(outputDirectory)
                    ? new MainWindow(fixture) { Width = 1120, Height = 760 }
                    : new MainWindow(review) { Width = 1120, Height = 760, Title = "HolmesKit — inert rendered acceptance" };
                fixture.Notify = (_, message, _) => throw new InvalidOperationException(message);
                var pages = Assert.IsType<TabControl>(window.FindName("ShellTabs"));
                Assert.Equal(13, window.FontSize);
                Assert.Equal(Color.FromRgb(10, 10, 10), Assert.IsType<SolidColorBrush>(window.Background).Color);
                Assert.Equal(10, pages.Items.Count);
                if (!string.IsNullOrWhiteSpace(outputDirectory))
                {
                    Directory.CreateDirectory(outputDirectory);
                    window.Left = 20;
                    window.Top = 20;
                    window.ShowInTaskbar = false;
                    window.WindowStartupLocation = WindowStartupLocation.Manual;
                    window.Show();
                    WaitForIdle(window, TimeSpan.FromSeconds(10));
                    // Allow a second real CPU counter sample; do not seed charts with fixture history.
                    var sampleFrame = new DispatcherFrame();
                    var sampleTimer = new DispatcherTimer { Interval = TimeSpan.FromSeconds(2.2) };
                    sampleTimer.Tick += (_, _) => { sampleTimer.Stop(); sampleFrame.Continue = false; };
                    sampleTimer.Start();
                    Dispatcher.PushFrame(sampleFrame);
                    for (var index = 0; index < pages.Items.Count; index++)
                    {
                        pages.SelectedIndex = index;
                        WaitForIdle(window, TimeSpan.FromSeconds(10));
                        PumpDispatcher();
                        window.UpdateLayout();
                        var header = ((TabItem)pages.Items[index]).Header?.ToString() ?? $"page-{index}";
                        var safeName = string.Join("-", header.Split(Path.GetInvalidFileNameChars(), StringSplitOptions.RemoveEmptyEntries)).Replace(' ', '-').ToLowerInvariant();
                        var selected = (TabItem)pages.Items[index];
                        var title = FindVisual<TextBlock>((DependencyObject)selected.Content, block => ReferenceEquals(block.Style, window.FindResource("PageTitleStyle")));
                        if (title is not null)
                            File.AppendAllText(Path.Combine(outputDirectory, "layout-private.txt"), $"{index}: titleY={title.TranslatePoint(new Point(), (UIElement)window.Content).Y}; rootMargin={((FrameworkElement)selected.Content).Margin}\n");
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
                    var model = Assert.IsType<MainViewModel>(window.DataContext);
                    var now = DateTimeOffset.UtcNow;
                    model.Dashboard.Record(new(now.AddSeconds(-2), null, 1000, 250, 120));
                    model.Dashboard.Record(new(now, 25, 1000, 200, 122));
                    window.ApplyTemplate();
                    stage = "initial window measure";
                    window.Measure(new Size(1120, 760));
                    stage = "initial window arrange";
                    window.Arrange(new Rect(0, 0, 1120, 760));
                    stage = "initial window layout";
                    window.UpdateLayout();
                    for (var index = 0; index < pages.Items.Count; index++)
                    {
                        stage = $"page {index}, 1120x760 selection";
                        pages.SelectedIndex = index;
                        window.UpdateLayout();
                        stage = $"page {index}, 1120x760 dispatcher";
                        PumpDispatcher();
                        Assert.Null(dispatcherFailure);
                        ArrangeSurface(window, new Size(1120, 760));
                        Assert.True(((TabItem)pages.Items[index]).IsSelected);
                        if (index == 9)
                        {
                            var clear = FindVisual<Button>((DependencyObject)((TabItem)pages.Items[index]).Content, button => Equals(button.Content, "Clear view"));
                            Assert.NotNull(clear);
                            Assert.False(Assert.IsType<DockPanel>(clear.Parent).LastChildFill);
                            Assert.InRange(clear.ActualWidth, 1, 120);
                            model.Activity.Add("Inert session output");
                            clear.Command.Execute(null);
                            Assert.Empty(model.Activity);
                        }
                    }
                    foreach (var size in new[] { new Size(900, 620), new Size(1600, 900) })
                    {
                        window.Width = size.Width; window.Height = size.Height;
                        for (var index = 0; index < pages.Items.Count; index++)
                        {
                            stage = $"page {index}, {size} layout";
                            pages.SelectedIndex = index;
                            window.Measure(size); window.Arrange(new Rect(size)); window.UpdateLayout();
                            stage = $"page {index}, {size} dispatcher";
                            PumpDispatcher();
                            Assert.Null(dispatcherFailure);
                            ArrangeSurface(window, size);
                        }
                    }
                    Assert.False(model.IsBusy);
                    Assert.Equal(0, fixtureService.Mutations);
                    stage = "deferred management-page loading";
                    // Actual Loaded/selection/busy events; all service methods remain inert.
                    fixtureService.SystemGate = new();
                    pages.SelectedIndex = 0;
                    window.Left = -10000; window.Top = -10000; window.ShowInTaskbar = false;
                    window.Show();
                    PumpDispatcher();
                    Assert.True(model.IsBusy);
                    pages.SelectedIndex = 5;
                    Assert.Equal(0, fixtureService.StartupReads);
                    fixtureService.SystemGate.SetResult(new SystemSnapshot());
                    WaitForIdle(window, TimeSpan.FromSeconds(5));
                    PumpDispatcher();
                    Assert.Equal(1, fixtureService.StartupReads);
                    fixtureService.SystemGate = new();
                    model.RefreshSystemCommand.Execute(null);
                    pages.SelectedIndex = 6;
                    Assert.Equal(0, fixtureService.ApplicationReads);
                    fixtureService.SystemGate.SetResult(new SystemSnapshot());
                    WaitForIdle(window, TimeSpan.FromSeconds(5));
                    PumpDispatcher();
                    Assert.Equal(1, fixtureService.ApplicationReads);
                    Assert.Equal(0, fixtureService.Mutations);
                }
                stage = "confirmation construction";
                var confirmation = new ConfirmationWindow("Review test operation", "Scope\nRecovery limitations\nNo system operation is invoked by this test.");
                confirmation.Measure(new Size(590, 510));
                confirmation.Arrange(new Rect(0, 0, 590, 510));
                confirmation.UpdateLayout();
                Assert.Equal(13, confirmation.FontSize);
                Assert.Equal(Color.FromRgb(10, 10, 10), Assert.IsType<SolidColorBrush>(confirmation.Background).Color);
                var cancel = Assert.IsType<Button>(confirmation.FindName("CancelAction"));
                Assert.True(cancel.IsCancel);
                Assert.True(cancel.IsDefault);
                Assert.False(confirmation.ShowInTaskbar);
                var details = Assert.IsType<TextBox>(confirmation.FindName("Details"));
                Assert.True(details.IsReadOnly);
                Assert.Equal(ScrollBarVisibility.Auto, details.VerticalScrollBarVisibility);
                if (!string.IsNullOrWhiteSpace(outputDirectory)) SaveScreenshot(confirmation, Path.Combine(outputDirectory, "confirmation.png"));
                confirmation.Close();
                Assert.Null(dispatcherFailure);
                Assert.Empty(bindingErrors.Errors);
                window.Close();
                stage = "shutdown";
                app.Shutdown();
            }
            catch (Exception ex) { failure = ex; }
            finally
            {
                PresentationTraceSources.DataBindingSource.Listeners.Remove(bindingErrors);
                PresentationTraceSources.DataBindingSource.Switch.Level = previousLevel;
            }
        });
        thread.IsBackground = true;
        thread.SetApartmentState(ApartmentState.STA);
        thread.Start();
        var timeout = string.IsNullOrWhiteSpace(Environment.GetEnvironmentVariable("HOLMESKIT_VISUAL_REVIEW_DIR"))
            ? TimeSpan.FromSeconds(60)
            : TimeSpan.FromMinutes(2);
        Assert.True(thread.Join(timeout), $"MainWindow construction timed out during {stage}.");
        Assert.Null(failure);
    }

    private sealed class BindingErrorListener : TraceListener
    {
        public List<string> Errors { get; } = [];
        public override void Write(string? message) { if (!string.IsNullOrWhiteSpace(message)) Errors.Add(message); }
        public override void WriteLine(string? message) => Write(message);
    }

    private static T? FindVisual<T>(DependencyObject root, Predicate<T> predicate) where T : DependencyObject
    {
        if (root is T item && predicate(item)) return item;
        for (var i = 0; i < VisualTreeHelper.GetChildrenCount(root); i++)
            if (FindVisual(VisualTreeHelper.GetChild(root, i), predicate) is { } found) return found;
        return null;
    }

    private static void ArrangeSurface(Window window, Size size)
    {
        // An unshown Window has no HWND and can leave its content at zero size.
        // Measure the actual root explicitly so child-size assertions exercise real layout.
        var surface = Assert.IsAssignableFrom<FrameworkElement>(window.Content);
        surface.Measure(size);
        surface.Arrange(new Rect(size));
        surface.UpdateLayout();
    }

    private sealed class ConstructionPaths : IHolmesKitPathResolver
    {
        public string RootDirectory { get; } = Path.Combine(Path.GetTempPath(), "HolmesKit.Construction." + Guid.NewGuid().ToString("N"));
        public string BatchFile => Path.Combine(RootDirectory, "unused.bat");
        public string BridgeScript => Path.Combine(RootDirectory, "unused.ps1");
        public string LogFile => Path.Combine(RootDirectory, "unused.log");
        public void Validate() => throw new InvalidOperationException("No native process is permitted in construction tests.");
    }
    private sealed class ConstructionService : IHolmesKitCommandService
    {
        public int Mutations;
        public int StartupReads, ApplicationReads;
        public TaskCompletionSource<SystemSnapshot>? SystemGate;
        private Task<ProcessResult> RejectMutation() { Mutations++; throw new InvalidOperationException("No mutations permitted."); }
        public Task<ProcessResult> RunOperationAsync(string id, IProgress<string>? progress, CancellationToken token) => RejectMutation();
        public Task<ProcessResult> ToggleStartupAsync(StartupEntry entry, CancellationToken token) => RejectMutation();
        public Task<ProcessResult> UninstallAsync(InstalledApplication app, CancellationToken token) => RejectMutation();
        public Task<SystemSnapshot> GetSystemInfoAsync(CancellationToken token) => SystemGate?.Task ?? Task.FromResult(new SystemSnapshot { ComputerName = "Construction fixture", CpuName = "Fixture processor",
            Disks = [new() { Name = "C:", UsedBytes = 750, FreeBytes = 250, TotalBytes = 1000, Percent = 75 }] });
        public Task<IReadOnlyList<StartupEntry>> GetStartupEntriesAsync(CancellationToken token) { StartupReads++; return Task.FromResult<IReadOnlyList<StartupEntry>>([]); }
        public Task<IReadOnlyList<InstalledApplication>> GetApplicationsAsync(CancellationToken token) { ApplicationReads++; return Task.FromResult<IReadOnlyList<InstalledApplication>>([]); }
    }

    [Fact]
    public void InlineOutputRuns_ExplicitlyUseOneWayBindings()
    {
        XNamespace presentation = "http://schemas.microsoft.com/winfx/2006/xaml/presentation";
        var files = Directory.GetFiles(Path.Combine(FindRepositoryRoot(), "src", "HolmesKit.Desktop"), "*.xaml", SearchOption.AllDirectories)
            .Where(path => !path.Contains(Path.DirectorySeparatorChar + "obj" + Path.DirectorySeparatorChar) && !path.Contains(Path.DirectorySeparatorChar + "bin" + Path.DirectorySeparatorChar));
        foreach (var file in files)
            foreach (var run in XDocument.Load(file).Descendants(presentation + "Run"))
            {
                var text = (string?)run.Attribute("Text");
                if (text?.Contains("{Binding", StringComparison.Ordinal) == true)
                    Assert.Contains("Mode=OneWay", text);
            }
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
        // An idle-priority exit can starve behind continuous software-render work on hosted runners.
        // Still pump binding/layout work, but give the bounded frame exit priority over render traffic.
        var timer = new DispatcherTimer(DispatcherPriority.Send) { Interval = TimeSpan.FromMilliseconds(150) };
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
