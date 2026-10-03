using HolmesKit.Desktop.Models;
using HolmesKit.Desktop.Services;

namespace HolmesKit.Desktop.Tests;

public class BatchContractTests
{
    [Fact]
    public void BatchDispatcher_ExposesEveryDesktopOperation()
    {
        var paths = new HolmesKitPathResolver(AppContext.BaseDirectory);
        paths.Validate();
        var source = File.ReadAllText(paths.BatchFile);
        foreach (var operation in OperationCatalog.All)
            Assert.Contains($"\"{operation.Id}\"", source, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public void InteractiveCliMenus_RemainPresent()
    {
        var paths = new HolmesKitPathResolver(AppContext.BaseDirectory);
        var source = File.ReadAllText(paths.BatchFile);
        foreach (var label in new[] { ":main_menu", ":core_menu", ":advanced_menu", ":gaming_menu", ":restore_menu", ":startup_manager", ":apps_manager" })
            Assert.Contains(label, source, StringComparison.OrdinalIgnoreCase);
    }
}
