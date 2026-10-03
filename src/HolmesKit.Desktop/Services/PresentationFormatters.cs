using System.Globalization;

namespace HolmesKit.Desktop.Services;

public static class PresentationFormatters
{
    public const string Unavailable = "Unavailable";

    public static string Bytes(long? bytes, IFormatProvider? provider = null)
    {
        if (bytes is null || bytes < 0) return Unavailable;
        provider ??= CultureInfo.CurrentCulture;
        string[] units = ["B", "KB", "MB", "GB", "TB"];
        var value = (double)bytes.Value;
        var unit = 0;
        while (value >= 1024 && unit < units.Length - 1) { value /= 1024; unit++; }
        var decimals = unit == 0 ? 0 : 1;
        return $"{value.ToString($"F{decimals}", provider)} {units[unit]}";
    }

    public static string Percent(double? value, IFormatProvider? provider = null)
    {
        if (value is null || double.IsNaN(value.Value) || double.IsInfinity(value.Value)) return Unavailable;
        provider ??= CultureInfo.CurrentCulture;
        return $"{Math.Clamp(Math.Round(value.Value, MidpointRounding.AwayFromZero), 0, 100).ToString("F0", provider)}%";
    }

    public static string Uptime(long? totalSeconds)
    {
        if (totalSeconds is null || totalSeconds < 0) return Unavailable;
        var value = TimeSpan.FromSeconds(totalSeconds.Value);
        return $"{(int)value.TotalDays}d {value.Hours}h {value.Minutes}m";
    }

    public static double? RatioPercent(long? used, long? total)
    {
        if (used is null || total is null || used < 0 || total <= 0 || used > total) return null;
        return used.Value * 100d / total.Value;
    }
}
