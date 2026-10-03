namespace HolmesKit.Desktop.Models;

public sealed record OperationDefinition(
    string Id,
    string Category,
    string Name,
    string Description,
    string Affects,
    string Tradeoff,
    string Restart,
    bool IsRestore = false);

public static class OperationCatalog
{
    public static IReadOnlyList<OperationDefinition> All { get; } =
    [
        new("core-full", "Core", "Full Core Optimization", "Runs temp cleanup, High Performance power mode, background app cleanup, and restarts Explorer.", "Temporary files, power plan, running apps, Explorer", "Open apps in the cleanup list are closed; unsaved work in them may be lost.", "Explorer restarts"),
        new("cleanup-temp", "Core", "Clean Temp & Cache Files", "Clears user/Windows temporary files, browser cache, GPU shader caches, and flushes DNS.", "Temp folders, INetCache, shader caches, DNS cache", "Cached content is rebuilt as needed. Files currently in use are skipped.", "No"),
        new("power-high", "Core", "High Performance Power Plan", "Activates Windows High Performance mode.", "Active Windows power plan", "Increases power use and may reduce laptop battery life.", "No"),
        new("cleanup-background", "Core", "Safe Background Cleanup", "Closes the background applications in HolmesKit's established cleanup list.", "Selected running applications", "Unsaved work in affected applications may be lost.", "No"),

        new("ui-responsive", "Advanced", "UI Responsiveness", "Reduces UI delays, adjusts foreground scheduling, and disables NTFS last-access updates.", "Desktop registry, priority control, NTFS behavior", "Apps may be ended sooner when they stop responding.", "Explorer restarts"),
        new("visual-performance", "Advanced", "Visual Performance Mode", "Disables several Windows animations and visual effects.", "Explorer and desktop visual settings", "Windows uses fewer visual effects.", "Explorer restarts"),
        new("startup-prune", "Advanced", "Startup Pruning", "Removes the specific common-app Run entries managed by the original CLI.", "HKCU/HKLM Run registry values", "Those apps no longer start at sign-in but remain installed.", "Next sign-in"),
        new("network-maintenance", "Advanced", "Network Maintenance", "Flushes DNS, renews the IP lease, and resets Winsock and TCP/IP.", "Active networking configuration", "Network connectivity is interrupted briefly.", "Recommended"),
        new("services-cleanup", "Advanced", "Background Services Cleanup", "Stops and disables SysMain, Windows Search, and DiagTrack.", "Three Windows services", "Search indexing stops; search results may become stale.", "No"),
        new("hibernation-disable", "Advanced", "Disable Hibernation", "Disables hibernation and removes hiberfil.sys.", "Windows hibernation", "Hibernate and Fast Startup may become unavailable.", "No"),

        new("gaming-fps", "Gaming", "FPS Tweaks", "Applies the existing Game DVR, MMCSS, visual, power, and app cleanup sequence.", "Game DVR, multimedia scheduling, power, visuals, apps", "Background capture is disabled and open apps in the cleanup list are closed.", "Explorer restarts"),
        new("gaming-latency", "Gaming", "Latency Maintenance", "Applies the existing TCP, DNS, RSS, Nagle, and update-delivery session changes.", "TCP/IP, Winsock, BITS, Delivery Optimization", "Bulk transfer throughput may decrease; update delivery services are stopped for the session.", "Recommended"),
        new("gaming-full", "Gaming", "Full Gaming Prep", "Runs both HolmesKit gaming sequences.", "All FPS and latency areas above", "Combines all listed gaming tradeoffs.", "Recommended"),

        new("apply-all", "ApplyAll", "Apply All Tweaks", "Runs every established HolmesKit optimization after creating the registry backup.", "Core, advanced, services, hibernation, gaming, network", "This is the broadest change set; review each category before proceeding.", "Recommended"),

        new("restore-registry", "Restore", "Restore Latest Registry Backup", "Imports the most recent HolmesKit registry backup and resets related TCP/NTFS defaults.", "Registry keys backed up by HolmesKit", "Uses only the latest backup set.", "Explorer restarts", true),
        new("restore-power", "Restore", "Restore Default Power Schemes", "Recreates Windows default power schemes.", "Windows power schemes", "Custom power plans can be removed by Windows' restore-default command.", "No", true),
        new("restore-services", "Restore", "Re-enable Background Services", "Re-enables SysMain, Windows Search, and DiagTrack using the CLI restore behavior.", "Three Windows services", "Background resource use and indexing resume.", "No", true),
        new("restore-hibernation", "Restore", "Re-enable Hibernation", "Turns Windows hibernation back on.", "Windows hibernation", "hiberfil.sys consumes disk space again.", "No", true),
        new("restore-network", "Restore", "Reset Network Defaults", "Resets Winsock/TCP/IP settings managed by HolmesKit.", "TCP/IP and Winsock", "Network connectivity is interrupted briefly.", "Recommended", true),
        new("restart-explorer", "Restore", "Restart Explorer", "Restarts the Windows shell to apply UI settings.", "Explorer shell", "Open File Explorer windows close and reopen.", "No", true)
    ];
}
