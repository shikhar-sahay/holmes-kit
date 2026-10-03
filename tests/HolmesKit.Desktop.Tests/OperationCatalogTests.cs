using HolmesKit.Desktop.Models;

namespace HolmesKit.Desktop.Tests;

public class OperationCatalogTests
{
    [Fact]
    public void OperationIds_AreUniqueAndNonEmpty()
    {
        Assert.All(OperationCatalog.All, operation => Assert.False(string.IsNullOrWhiteSpace(operation.Id)));
        Assert.Equal(OperationCatalog.All.Count, OperationCatalog.All.Select(x => x.Id).Distinct(StringComparer.OrdinalIgnoreCase).Count());
    }

    [Theory]
    [InlineData("Core")]
    [InlineData("Advanced")]
    [InlineData("Gaming")]
    [InlineData("ApplyAll")]
    [InlineData("Restore")]
    public void RequiredCategory_HasOperations(string category) => Assert.Contains(OperationCatalog.All, x => x.Category == category);

    [Fact]
    public void EveryOperation_ExplainsImpactAndRestart()
    {
        Assert.All(OperationCatalog.All, operation =>
        {
            Assert.False(string.IsNullOrWhiteSpace(operation.Affects));
            Assert.False(string.IsNullOrWhiteSpace(operation.Tradeoff));
            Assert.False(string.IsNullOrWhiteSpace(operation.Restart));
        });
    }
}
