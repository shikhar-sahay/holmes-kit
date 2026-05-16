# HolmesKit

HolmesKit is a Windows optimization and maintenance toolkit built around a simple principle:

Most systems are not underpowered — they are mismanaged, background-heavy, and poorly tuned.

HolmesKit is designed to improve responsiveness through **transparent, reversible, and user-confirmed system changes**, rather than aggressive or irreversible “tweak pack” behavior.

It combines cleanup utilities, performance tuning, gaming optimization, and system management tools into a single menu-driven batch interface.

---

# Core Philosophy

HolmesKit is intentionally designed to be:

- **Reversible** – every major change can be restored
- **Transparent** – every action is explained before execution
- **Backed up** – registry states are exported before modifications
- **Conservative by default** – avoids unsafe or undocumented tweaks
- **User-confirmed** – no silent system changes

Unlike typical “FPS booster” scripts, HolmesKit focuses on measurable system behavior and predictable outcomes.

---

# Main Menu Structure

```
[0] Apply All Tweaks
[1] Core Optimization
[2] Advanced Tweaks
[3] Gaming Mode
[4] Restore Defaults
[5] System Info
[6] Startup Manager
[7] Apps Manager
[8] Exit
```

---

# Core Optimization

## Full Core Optimization
Runs all core steps in sequence:

- Temp and cache cleanup
- DNS flush
- GPU shader cache cleanup
- High Performance power plan activation
- Background application termination
- Explorer restart

---

## Temp and Cache Cleanup

Removes temporary and cached data from:

- `%TEMP%`
- `AppData\Local\Temp`
- `Windows\Temp`
- `INetCache`
- `D3DSCache`
- NVIDIA DXCache / GLCache

Also performs:
- DNS cache flush

---

## Power Plan Optimization

Switches system power mode to:

- **High Performance**

This reduces CPU downclocking and improves responsiveness under load.

Fallback logic ensures activation even if default scheme GUID is unavailable.

---

## Safe Background Cleanup

Terminates common high-resource applications:

- OneDrive
- Microsoft Teams
- Discord
- Spotify
- Epic Games Launcher
- Battle.net
- Adobe background services
- Web browsers (Chrome / Edge / Firefox)

Apps can be reopened normally after cleanup.

---

# Advanced Tweaks

## UI Responsiveness Tweaks

Applies registry and system-level responsiveness improvements:

- Reduced menu animation delay
- Lower app hang timeout
- Faster app termination handling
- Foreground process CPU prioritization (Win32PrioritySeparation)
- Disables NTFS last-access timestamps (reduces disk I/O)

⚠️ This reduces background filesystem metadata updates, improving responsiveness on slower disks.

---

## Visual Effects Performance Mode

Disables visual overhead:

- Window animations
- Taskbar animations
- Listview shadows
- Alpha selection effects

Sets system visual effects to Performance mode (VisualFXSetting = 2).

---

## Startup Pruning

Removes auto-start registry entries for:

- OneDrive
- Discord
- Spotify
- Skype
- Zoom
- Epic Games Launcher
- Microsoft Teams

Apps remain installed and manually launchable.

---

## Network Maintenance

Runs a full network stack reset sequence:

- DNS flush
- IP release/renew
- Winsock reset
- TCP/IP reset

Useful for:
- unstable connections
- degraded routing states
- stale network configurations

---

## Background Services Cleanup

Stops and disables:

- SysMain (Superfetch)
- Windows Search (WSearch)
- Diagnostic Tracking Service (DiagTrack)

Behavior notes:
- SysMain: reduces background disk preloading
- WSearch: disables indexing (search may stop updating results)
- DiagTrack: disables telemetry service

Service states are recorded for restoration where possible.

---

## Disable Hibernation

Disables Windows hibernation:

- Removes `hiberfil.sys`
- Frees disk space (often multiple GB)
- Sleep mode remains unaffected

---

# Gaming Mode

## FPS Tweaks

Applies gaming-focused system adjustments:

- Disables Xbox Game DVR / capture overlay
- Optimizes MMCSS scheduler for games
- Sets GPU priority and scheduling category to High
- Sets SystemResponsiveness = 0
- Applies High Performance power plan
- Applies visual performance mode
- Cleans background applications

---

## Latency Maintenance

Applies network latency optimizations:

- DNS flush
- Winsock reset
- TCP Fast Open enabled
- RSS enabled (multi-core network distribution)
- TCP autotuning disabled (lower latency, reduced throughput)
- Nagle algorithm disabled (faster packet transmission)
- Temporarily stops:
  - BITS
  - Windows Update Delivery Optimization

⚠️ Tradeoff:
- Lower latency for gaming
- Reduced throughput for bulk downloads

---

## Full Gaming Prep

Runs both:
- FPS Tweaks
- Latency Maintenance

---

# Restore System

## Registry Restoration

Restores previously backed-up registry states from:

```
HolmesKit_Backups\latest
```

Includes:
- Desktop settings
- Visual effects
- Explorer settings
- Startup keys
- Game DVR settings
- MMCSS gaming profile
- TCP/IP parameters

---

## Power Restore

Restores default Windows power schemes:

- Reverts High Performance changes
- Restores system defaults via `powercfg /restoredefaultschemes`

---

## Service Restoration

Re-enables:

- SysMain
- Windows Search
- DiagTrack

Restores service startup types to defaults where defined.

---

## Network Restore

Reverts networking changes:

- Resets Winsock
- Resets TCP/IP stack
- Restores autotuning to normal
- Removes Nagle-related registry overrides
- Flushes DNS cache

---

## Hibernation Restore

Re-enables Windows hibernation:

- Restores `hiberfil.sys`

---

## Explorer Restart

Restarts Windows Explorer to apply UI changes instantly.

---

# Apply All Tweaks

A guided full-system optimization pipeline that runs:

- Backup creation
- Temp cleanup
- Power plan optimization
- Background cleanup
- UI responsiveness tweaks
- Visual performance mode
- Startup pruning
- Service cleanup
- Hibernation disable
- Gaming FPS tweaks
- Gaming latency tweaks

⚠️ Excludes:
- Network stack reset (requires reboot to be effective)
- Optional manual Explorer restart

All steps are:
- logged
- reversible
- pre-backed up where applicable

---

# System Info (Live Dashboard)

Launches a PowerShell-based real-time monitoring tool that displays:

- CPU usage
- RAM usage
- Disk activity
- Network activity
- System uptime
- Live refresh updates (every ~5 seconds)

This tool runs independently and exits cleanly when closed.

---

# Utility Tools

## Startup Manager

Interactive PowerShell-based tool that allows:

- Viewing startup registry entries
- Managing startup behavior
- Editing system autostart configuration

Targets:
- Registry Run keys
- Startup entries

---

## Apps Manager

Interactive application manager that:

- Lists installed applications
- Provides quick access to uninstall handlers
- Helps manage system bloat

---

# Logging System

HolmesKit generates a persistent log file:

```
HolmesKit_Backups\holmeskit.log
```

Tracks:

- Optimization runs
- Restore actions
- Tool usage
- Session events

---

# Backup System

Before making system-level changes, HolmesKit exports registry snapshots to:

```
HolmesKit_Backups\latest
```

Backup scope includes:

- UI settings
- Visual effects configuration
- Startup entries
- Gaming configuration keys
- TCP/IP settings
- System profile parameters

---

# Safety & Limitations

HolmesKit is designed to be safe, but it still modifies system-level settings.

Important notes:

- Some tweaks affect system behavior (services, networking, power)
- Some changes may reduce functionality (e.g., Windows Search indexing)
- Networking changes may require reboot to fully apply
- Not all system states (especially services) are perfectly restored to original custom configurations
- TCP tuning changes may reduce download throughput

---

# How to Use

1. Download `HolmesKit.bat`
2. Right-click → Run as Administrator
3. Allow restore point creation (recommended)
4. Choose desired optimization mode

---

# Recommended Usage

- Use **Core Optimization** for daily cleanup
- Use **Advanced Tweaks** for system tuning
- Use **Gaming Mode** before gaming sessions
- Use **Restore Defaults** if system behavior changes feel unwanted
- Use **Apply All Tweaks** for full optimization pass

---

# Repository Structure

```
HolmesKit/
├─ HolmesKit.bat
├─ README.md
├─ LICENSE
├─ .gitignore
├─ screenshots/
└─ HolmesKit_Backups/
```

---

# License

MIT License recommended for open use, modification, and redistribution with attribution.