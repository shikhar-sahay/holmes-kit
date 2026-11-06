using System.Windows;

namespace HolmesKit.Desktop;

public partial class App : Application
{
    protected override void OnStartup(StartupEventArgs e)
    {
        ApplyContrastPreference();
        SystemParameters.StaticPropertyChanged += OnSystemPreferenceChanged;
        DispatcherUnhandledException += (_, args) =>
        {
            MessageBox.Show($"HolmesKit encountered an unexpected error.\n\n{args.Exception.Message}", "HolmesKit", MessageBoxButton.OK, MessageBoxImage.Error);
            args.Handled = true;
        };
        base.OnStartup(e);
    }

    private void OnSystemPreferenceChanged(object? sender, System.ComponentModel.PropertyChangedEventArgs e)
    {
        if (e.PropertyName == nameof(SystemParameters.HighContrast)) Dispatcher.Invoke(ApplyContrastPreference);
    }

    private void ApplyContrastPreference()
    {
        var palette = new ResourceDictionary { Source = new Uri("pack://application:,,,/HolmesKit;component/Themes/DarkPalette.xaml", UriKind.Absolute) };
        foreach (string key in palette.Keys)
        {
            if (!key.EndsWith("Brush", StringComparison.Ordinal)) continue;
            Resources[key] = !SystemParameters.HighContrast ? palette[key] : key switch
            {
                "AccentMutedBrush" => SystemColors.HighlightBrush,
                "SelectedTextBrush" => SystemColors.HighlightTextBrush,
                "TextPrimaryBrush" or "TextSecondaryBrush" or "TextTertiaryBrush" or "SuccessBrush" or "WarningBrush" or "DangerBrush" => SystemColors.WindowTextBrush,
                "AccentBrush" or "AccentStrongBrush" or "BorderBrush" or "BorderStrongBrush" => SystemColors.WindowTextBrush,
                _ => SystemColors.WindowBrush
            };
        }
    }

    protected override void OnExit(ExitEventArgs e)
    {
        SystemParameters.StaticPropertyChanged -= OnSystemPreferenceChanged;
        base.OnExit(e);
    }
}
