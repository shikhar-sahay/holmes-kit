namespace HolmesKit.Desktop.Services;

public interface IHolmesKitPathResolver
{
    string RootDirectory { get; }
    string BatchFile { get; }
    string BridgeScript { get; }
    string LogFile { get; }
    void Validate();
}

public sealed class HolmesKitPathResolver : IHolmesKitPathResolver
{
    public HolmesKitPathResolver(string? startDirectory = null)
    {
        var current = new DirectoryInfo(startDirectory ?? AppContext.BaseDirectory);
        for (var i = 0; current is not null && i < 7; i++, current = current.Parent)
        {
            if (File.Exists(Path.Combine(current.FullName, "HolmesKit.bat")) && Directory.Exists(Path.Combine(current.FullName, "modules")))
            {
                RootDirectory = current.FullName;
                return;
            }
        }
        RootDirectory = Path.GetFullPath(startDirectory ?? AppContext.BaseDirectory);
    }

    public string RootDirectory { get; }
    public string BatchFile => Path.Combine(RootDirectory, "HolmesKit.bat");
    public string BridgeScript => Path.Combine(RootDirectory, "modules", "gui_bridge.ps1");
    public string LogFile => Path.Combine(RootDirectory, "HolmesKit_Backups", "holmeskit.log");

    public void Validate()
    {
        if (!File.Exists(BatchFile)) throw new FileNotFoundException("HolmesKit.bat was not found beside the application.", BatchFile);
        if (!File.Exists(BridgeScript)) throw new FileNotFoundException("The HolmesKit GUI bridge script was not found.", BridgeScript);
    }
}
