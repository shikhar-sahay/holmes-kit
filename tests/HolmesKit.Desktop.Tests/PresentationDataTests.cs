using System.Globalization;
using HolmesKit.Desktop.Models;
using HolmesKit.Desktop.Services;

namespace HolmesKit.Desktop.Tests;

public class PresentationDataTests
{
    [Theory]
    [InlineData(0, "0 B")]
    [InlineData(1536, "1.5 KB")]
    [InlineData(16802910208, "15.6 GB")]
    public void Bytes_UsesReadableBinaryUnits(long value, string expected) =>
        Assert.Equal(expected, PresentationFormatters.Bytes(value, CultureInfo.InvariantCulture));

    [Theory]
    [InlineData(39.5, "40%")]
    [InlineData(98.339, "98%")]
    [InlineData(-10, "0%")]
    [InlineData(120, "100%")]
    public void Percent_IsRoundedAndClamped(double value, string expected) =>
        Assert.Equal(expected, PresentationFormatters.Percent(value, CultureInfo.InvariantCulture));

    [Fact]
    public void UnknownNumericValues_AreNotPresentedAsZero()
    {
        Assert.Equal("Unavailable", PresentationFormatters.Bytes(null, CultureInfo.InvariantCulture));
        Assert.Equal("Unavailable", PresentationFormatters.Percent(null, CultureInfo.InvariantCulture));
        Assert.Equal("Unavailable", PresentationFormatters.Uptime(null));
    }

    [Fact]
    public void Uptime_UsesDaysHoursAndMinutes() =>
        Assert.Equal("11d 23h 17m", PresentationFormatters.Uptime((long)TimeSpan.FromDays(11).Add(TimeSpan.FromHours(23)).Add(TimeSpan.FromMinutes(17)).TotalSeconds));

    [Fact]
    public void RatioPercent_ValidatesAndCalculatesFromRawValues()
    {
        Assert.Equal(75d, PresentationFormatters.RatioPercent(3, 4));
        Assert.Null(PresentationFormatters.RatioPercent(5, 4));
        Assert.Null(PresentationFormatters.RatioPercent(0, 0));
    }

    [Fact]
    public void CustomPowerPlan_IsClearlyIdentified()
    {
        var snapshot = new SystemSnapshot { PowerPlanKind = "Custom", PowerPlanName = "unbundle", PowerPlanGuid = "custom-guid" };
        Assert.Equal("Custom power plan", snapshot.PowerPlanDisplay);
        Assert.Equal("Name: unbundle", snapshot.PowerPlanDetails);
    }

    [Fact]
    public void StandardPowerPlan_DoesNotExposeItsGuidInNormalUi()
    {
        var snapshot = new SystemSnapshot { PowerPlanKind = "Standard", PowerPlanName = "Balanced", PowerPlanGuid = "381b4222-f694-41f0-9685-ff5bb260df2e" };
        Assert.Equal("Balanced", snapshot.PowerPlanDisplay);
        Assert.Empty(snapshot.PowerPlanDetails);
    }

    [Fact]
    public void MissingApplicationMetadata_HasHonestFallbacks()
    {
        var app = new InstalledApplication();
        Assert.Equal("Unknown", app.PublisherDisplay);
        Assert.Equal("Unknown", app.VersionDisplay);
        Assert.Equal("Unavailable", app.SizeDisplay);
    }

    [Fact]
    public void StartupProtection_IsPresentedAsStatusRatherThanAControl()
    {
        Assert.Empty(new StartupEntry { Locked = false }.ProtectionDisplay);
        Assert.Equal("Protected", new StartupEntry { Locked = true }.ProtectionDisplay);
    }
}
