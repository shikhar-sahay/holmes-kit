namespace HolmesKit.Desktop.Models;

public sealed record OperationDefinition(
    string Id,
    string Category,
    string Name,
    string Description,
    string Affects,
    string Tradeoff,
    string Restart,
    bool IsRestore = false)
{
    public string RecoveryDescription => Id switch
    {
        "cleanup-temp" => "Deleted files cannot be recovered by HolmesKit.",
        "cleanup-background" or "restart-explorer" => "Closed windows and unsaved work cannot be recovered.",
        "network-maintenance" or "gaming-latency" or "restore-network" => "Network recovery is partial/reset-only; this is not a saved network profile.",
        "hibernation-disable" or "restore-hibernation" => "Hibernation uses a reset action, not exact previous-state recovery.",
        "core-full" or "gaming-fps" or "gaming-full" or "apply-all" => "Managed settings use the retained baseline; deleted files, unsaved work and some resets are not reversible.",
        "ui-responsive" => "Managed registry values are captured. NTFS configuration is not exact-state recovery.",
        _ => "Managed settings use a retained baseline. Restore revalidates scope and skips external conflicts."
    };
}

public static class OperationCatalog
{
    public static IReadOnlyList<OperationDefinition> All { get; } =
    [
        new("core-full", "Core", "Full Core Optimization", "Runs temp cleanup, High Performance power mode, background app cleanup, and restarts Explorer.", "Temporary files, power plan, running apps, Explorer", "Open apps in the cleanup list are closed; unsaved work in them may be lost.", "Explorer restarts"),
        new("cleanup-temp", "Core", "Clean Temp & Cache Files", "Clears user/Windows temporary files, browser cache, GPU shader caches, and flushes DNS.", "Temp folders, INetCache, shader caches, DNS cache", "Cached content is rebuilt as needed. Files currently in use are skipped.", "No"),
        new("power-high", "Core", "High Performance Power Plan", "Activates Windows High Performance mode.", "Active Windows power plan", "Increases power use and may reduce laptop battery life.", "No"),
        new("cleanup-background", "Core", "Close Background Applications", "Closes the background applications in HolmesKit's established cleanup list.", "Selected running applications", "Unsaved work in affected applications may be lost.", "No"),

        new("ui-responsive", "Advanced", "UI Responsiveness", "Reduces UI delays, adjusts foreground scheduling, and disables NTFS last-access updates.", "Desktop registry, priority control, NTFS behavior", "Apps may be ended sooner when they stop responding.", "Explorer restarts"),
        new("visual-performance", "Advanced", "Visual Performance Mode", "Disables several Windows animations and visual effects.", "Explorer and desktop visual settings", "Windows uses fewer visual effects.", "Explorer restarts"),
        new("startup-prune", "Advanced", "Startup Pruning", "Removes the specific common-app Run entries managed by the original CLI.", "HKCU/HKLM Run registry values", "Those apps no longer start at sign-in but remain installed.", "Next sign-in"),
        new("network-maintenance", "Advanced", "Network Maintenance", "Flushes DNS, renews the IP lease, and resets Winsock and TCP/IP.", "Active networking configuration", "Network connectivity is interrupted briefly.", "Recommended"),
        new("services-cleanup", "Advanced", "Background Services Cleanup", "Stops and disables SysMain, Windows Search, and DiagTrack.", "Three Windows services", "Search indexing stops; search results may become stale.", "No"),
        new("hibernation-disable", "Advanced", "Disable Hibernation", "Disables hibernation and removes hiberfil.sys.", "Windows hibernation", "Hibernate and Fast Startup may become unavailable.", "No"),

        new("gaming-fps", "Gaming", "FPS Tweaks", "Applies the existing Game DVR, MMCSS, visual, power, and app cleanup sequence.", "Game DVR, multimedia scheduling, power, visuals, apps", "Background capture is disabled and open apps in the cleanup list are closed.", "Explorer restarts"),
        new("gaming-latency", "Gaming", "Latency Maintenance", "Applies the existing TCP, DNS, RSS, Nagle, and update-delivery session changes.", "TCP/IP, Winsock, BITS, Delivery Optimization", "Bulk transfer throughput may decrease; update delivery services are stopped for the session.", "Recommended"),
        new("gaming-full", "Gaming", "Full Gaming Prep", "Runs both HolmesKit gaming sequences.", "All FPS and latency areas above", "Combines all listed gaming tradeoffs.", "Recommended"),

        new("apply-all", "ApplyAll", "Apply All Tweaks", "Runs every established HolmesKit optimization after validating the retained recovery baseline.", "Core, advanced, services, hibernation, gaming, network", "This is the broadest change set; review each category before proceeding.", "Recommended"),

        new("restore-registry", "Restore", "Restore Managed Registry Values", "Restores captured value existence, type and data from the retained baseline.", "Only allowlisted HolmesKit registry values", "Conflicting external changes are skipped; legacy exports require manual review. NTFS/network defaults are not restored here.", "Sign-out may be required", true),
        new("restore-power", "Restore", "Restore Previous Power Plan", "Selects the original captured power-plan GUID without recreating or deleting schemes.", "Active Windows power plan", "Requires the original plan to remain available; external changes are skipped.", "No", true),
        new("restore-services", "Restore", "Restore Managed Service States", "Restores captured startup and running states for the managed services.", "SysMain, Windows Search, DiagTrack, BITS, Delivery Optimization", "Conflicts and policy-managed changes are skipped or reported as failures.", "No", true),
        new("restore-hibernation", "Restore", "Re-enable Hibernation", "Turns Windows hibernation back on.", "Windows hibernation", "hiberfil.sys consumes disk space again.", "No", true),
        new("restore-network", "Restore", "Reset Network Defaults", "Resets Winsock/TCP/IP settings managed by HolmesKit.", "TCP/IP and Winsock", "Network connectivity is interrupted briefly.", "Recommended", true),
        new("restart-explorer", "Restore", "Restart Explorer", "Restarts the Windows shell to apply UI settings.", "Explorer shell", "Open File Explorer windows close and reopen.", "No", true)
    ];
}
