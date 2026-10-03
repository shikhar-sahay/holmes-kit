using HolmesKit.Desktop.Services;

namespace HolmesKit.Desktop.Tests;

public class PathResolverTests
{
    [Fact]
    public void Resolver_FindsRootFromNestedDirectory()
    {
        var root = Path.Combine(Path.GetTempPath(), $"holmes-{Guid.NewGuid():N}");
        var nested = Path.Combine(root, "src", "app", "bin");
        Directory.CreateDirectory(Path.Combine(root, "modules"));
        Directory.CreateDirectory(nested);
        File.WriteAllText(Path.Combine(root, "HolmesKit.bat"), "@echo off");
        File.WriteAllText(Path.Combine(root, "modules", "gui_bridge.ps1"), "");
        try
        {
            var resolver = new HolmesKitPathResolver(nested);
            Assert.Equal(root, resolver.RootDirectory);
            resolver.Validate();
        }
        finally { Directory.Delete(root, true); }
    }

    [Fact]
    public void Validate_ReportsMissingBatch()
    {
        var folder = Path.Combine(Path.GetTempPath(), $"holmes-{Guid.NewGuid():N}");
        Directory.CreateDirectory(folder);
        try { Assert.Throws<FileNotFoundException>(() => new HolmesKitPathResolver(folder).Validate()); }
        finally { Directory.Delete(folder, true); }
    }
}
