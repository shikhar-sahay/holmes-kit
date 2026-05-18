# HolmesKit

A Windows optimization toolkit that improves system responsiveness by removing the overhead Windows quietly runs in the background without asking.

Most machines are not underpowered. They are just spending too much of their resources on themselves. HolmesKit fixes that through targeted, reversible, and fully transparent changes. Every option tells you exactly what it will do before it does anything.

---

## What It Does

Windows ships with defaults tuned for broad compatibility and battery life, not performance. Background services run constantly, startup programs accumulate, power settings throttle the CPU to save energy, and network settings prioritize stability over speed. None of this is malicious, but together it adds up to a machine that is quietly working against you.

HolmesKit addresses this across four main areas:

**Background Services**
Three services that run continuously in the background are stopped and disabled: SysMain (which preloads apps into RAM and causes sustained disk activity), WSearch (which indexes your files constantly and hammers the disk, especially after fresh installs), and DiagTrack (Microsoft's telemetry service, which provides no user-facing functionality). Together these are responsible for a significant portion of idle CPU, RAM, and disk usage on a typical Windows machine.

**Windows Registry**
The registry is where Windows stores the configuration values that govern how the system behaves at a low level. HolmesKit writes to several key areas: `HKCU\Control Panel\Desktop` to reduce menu animation delay and give foreground processes longer CPU time slices via `Win32PrioritySeparation`, `HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer` to disable taskbar and window animations, `HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games` to raise GPU priority and set scheduling category to High for game threads via the Windows Multimedia Class Scheduler (MMCSS), and `HKCU\System\GameConfigStore` to disable Xbox Game DVR, which runs a background capture overlay even when you are not recording. All affected keys are exported before any changes are made and can be fully restored.

**Power Plan**
Windows defaults to Balanced power mode, which actively throttles CPU frequency during quieter periods to save energy. On a plugged-in machine this just means artificial performance limits. HolmesKit switches to High Performance using the `SCHEME_MIN` alias, with a GUID-based fallback for systems where the alias does not resolve. This removes those limits and lets the processor run at full capacity when needed.

**TCP/IP Stack**
A few network defaults that make sense for general use work against low-latency applications like gaming. HolmesKit makes the following changes via `netsh` and the registry: enables TCP Fast Open to reduce connection handshake overhead, enables RSS (Receive Side Scaling) to distribute network processing across CPU cores, disables TCP autotuning to fix the receive buffer at a smaller size for more consistent latency, and disables the Nagle algorithm by writing `TcpAckFrequency=1` and `TCPNoDelay=1` per network adapter. Nagle deliberately batches small packets to reduce network overhead, which helps for file transfers and actively hurts gaming where you want packets sent the moment they are ready. All TCP changes are fully reversed by the Restore menu.

---

## Key Features

**Descriptive and intuitive by design.** Before any option runs, HolmesKit shows you a plain-English breakdown of exactly what it will change, which system components are affected, and what the tradeoffs are. Nothing happens silently and nothing requires you to trust a black box.

**Nothing runs without your confirmation.** Every option requires an explicit Y before proceeding. The confirmation screen stays on screen long enough to read before you commit.

**Full restore system.** Every change has a corresponding undo path. Registry keys are backed up before modification and reimported on restore. Services are re-enabled with correct start types. Power plan and network settings revert to Windows defaults.

**Real-time System Info dashboard.** A live panel showing CPU load, RAM usage, disk usage per drive, current power plan, network activity, and the top processes by CPU and RAM. Refreshes every five seconds.

**Startup Manager.** Shows every program configured to run at login, across both registry startup keys and Task Scheduler logon triggers, in a single unified list. Entries can be toggled on or off using the same `StartupApproved` key mechanism that Task Manager uses, so nothing is deleted outright. Protected system entries are detected at scan time and flagged as locked rather than silently failing when toggled.

**Apps Manager.** Lists every installed application pulled from three registry hives (64-bit, 32-bit, and per-user) with version and size information. Selecting an application launches its own uninstaller with correct handling for both MSI and non-MSI uninstall strings.

**Session logging.** Every action is timestamped and written to `HolmesKit_Backups\holmeskit.log` so you always know what ran and when across all sessions.

**Apply All Tweaks.** A single guided pass that runs the full optimization sequence in one shot. Every step is listed with a description before anything begins, and the entire sequence is backed up before it runs.

---

## Menu Structure

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

## How to Use

1. Download or clone the repository
2. Right-click `HolmesKit.bat` and select Run as Administrator
3. Create a restore point when prompted (recommended)
4. Pick an option from the menu

---

## Recommended Usage

- **Core Optimization** for a quick general cleanup
- **Advanced Tweaks** for deeper system tuning
- **Gaming Mode** before a gaming session
- **Apply All Tweaks** for a full one-shot optimization pass
- **Restore Defaults** if anything feels off afterward

---

## A Few Things to Know

- Disabling WSearch means Windows Search stops updating its index. File search may return stale results until the service is re-enabled via the Restore menu
- TCP changes may reduce bulk download speeds as a tradeoff for lower latency
- Some networking changes take full effect after a restart
- The tool requires Administrator privileges to run

---

## Repository Structure

```
HolmesKit/
  HolmesKit.bat
  modules/
    logo.ps1
    sysinfo.ps1
    startup_mgr.ps1
    apps_mgr.ps1
  README.md
  LICENSE
  .gitattributes
  .gitignore
  HolmesKit_Backups/
```

---

## License

MIT
