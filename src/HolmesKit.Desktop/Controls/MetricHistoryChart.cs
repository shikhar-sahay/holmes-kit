using System.Windows;
using System.Windows.Media;
using System.Windows.Automation.Peers;
using HolmesKit.Desktop.ViewModels;

namespace HolmesKit.Desktop.Controls;

/// <summary>Small retained-mode chart, fixed 0–100 scale, no animation or chart dependency.</summary>
public sealed class MetricHistoryChart : FrameworkElement
{
    public static readonly DependencyProperty LineBrushProperty = DependencyProperty.Register(nameof(LineBrush), typeof(Brush), typeof(MetricHistoryChart), new FrameworkPropertyMetadata(Brushes.White, FrameworkPropertyMetadataOptions.AffectsRender));
    public static readonly DependencyProperty GridBrushProperty = DependencyProperty.Register(nameof(GridBrush), typeof(Brush), typeof(MetricHistoryChart), new FrameworkPropertyMetadata(Brushes.Gray, FrameworkPropertyMetadataOptions.AffectsRender));
    public Brush LineBrush { get => (Brush)GetValue(LineBrushProperty); set => SetValue(LineBrushProperty, value); }
    public Brush GridBrush { get => (Brush)GetValue(GridBrushProperty); set => SetValue(GridBrushProperty, value); }
    public MetricHistoryChart()
    {
        SetResourceReference(LineBrushProperty, "AccentStrongBrush");
        SetResourceReference(GridBrushProperty, "BorderBrush");
    }
    public static readonly DependencyProperty SamplesProperty = DependencyProperty.Register(nameof(Samples),
        typeof(IReadOnlyList<MetricPoint>), typeof(MetricHistoryChart), new FrameworkPropertyMetadata(null, FrameworkPropertyMetadataOptions.AffectsRender));
    public IReadOnlyList<MetricPoint>? Samples { get => (IReadOnlyList<MetricPoint>?)GetValue(SamplesProperty); set => SetValue(SamplesProperty, value); }
    protected override AutomationPeer OnCreateAutomationPeer() => new FrameworkElementAutomationPeer(this);
    protected override void OnRender(DrawingContext dc)
    {
        base.OnRender(dc);
        var line = new Pen(LineBrush, 1.5);
        var grid = new Pen(GridBrush, 1);
        var height = Math.Max(1, ActualHeight - 4);
        for (var i = 0; i <= 2; i++) dc.DrawLine(grid, new(0, 2 + height * i / 2), new(ActualWidth, 2 + height * i / 2));
        foreach (var segment in BuildSegments(Samples, ActualWidth, ActualHeight))
            for (var i = 0; i < segment.Count; i++)
            {
                if (i > 0) dc.DrawLine(line, segment[i - 1], segment[i]);
                dc.DrawEllipse(line.Brush, null, segment[i], 1.5, 1.5);
            }
    }

    public static IReadOnlyList<IReadOnlyList<Point>> BuildSegments(IReadOnlyList<MetricPoint>? samples, double width, double actualHeight)
    {
        if (samples is not { Count: > 0 } || !double.IsFinite(width) || !double.IsFinite(actualHeight) || width <= 0 || actualHeight <= 0) return [];
        var height = Math.Max(1, actualHeight - 4);
        var end = samples[^1].Timestamp;
        var segments = new List<IReadOnlyList<Point>>();
        List<Point>? segment = null;
        DateTimeOffset? lastTime = null;
        foreach (var sample in samples)
        {
            if (sample.Value is not (>= 0 and <= 100) || !double.IsFinite(sample.Value.Value)) { segment = null; continue; }
            var point = new Point(Math.Clamp(1 - (end - sample.Timestamp).TotalSeconds / 60, 0, 1) * width,
                2 + height * (1 - sample.Value.Value / 100));
            if (segment is null || lastTime is null || (sample.Timestamp - lastTime.Value).TotalSeconds > 5)
            { segment = []; segments.Add(segment); }
            segment.Add(point);
            lastTime = sample.Timestamp;
        }
        return segments;
    }
}
