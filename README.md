# HolmesKit

> A Windows optimization toolkit focused on improving responsiveness by removing unnecessary background overhead - transparently, reversibly, and without black-box tweaks.

Most machines are not underpowered. They are simply spending too many resources on Windows itself. HolmesKit addresses that through targeted optimizations that are fully explained before anything changes.

---

# Table of Contents

- [What It Does](#what-it-does)
  - [Background Services](#background-services)
  - [Windows Registry](#windows-registry)
  - [Power Plan](#power-plan)
  - [TCPIP Stack](#tcpip-stack)
- [Key Features](#key-features)
- [Menu Structure](#menu-structure)
- [How to Use](#how-to-use)
- [Recommended Usage](#recommended-usage)
- [Things to Know](#things-to-know)
- [Repository Structure](#repository-structure)
- [License](#license)

---

# What It Does

Windows ships with defaults tuned for broad compatibility, battery life, and general stability - not raw responsiveness. Over time, background services, startup tasks, telemetry, indexing, power throttling, and network buffering quietly accumulate overhead.

HolmesKit targets these areas directly while ensuring every change remains reversible.

---

## Background Services

HolmesKit stops and disables three constantly running background services:

| Service | Purpose | Why Disable It |
|---|---|---|
| `SysMain` | Preloads applications into memory | Can cause sustained disk activity and unnecessary RAM usage |
| `WSearch` | Indexes files for Windows Search | Constant indexing can heavily impact disk usage |
| `DiagTrack` | Microsoft telemetry service | Provides no direct user-facing functionality |

Together, these services are responsible for a significant portion of idle CPU, RAM, and disk activity on many Windows systems.

---

## Windows Registry

HolmesKit applies targeted registry optimizations across several low-level Windows subsystems.

### Desktop & UI Responsiveness

Path:
```reg
HKCU\Control Panel\Desktop
```

Changes include:

- Reduced menu animation delay
- Longer CPU time slices for foreground applications via:
  ```reg
  Win32PrioritySeparation
  ```

### Explorer & Animations

Path:
```reg
HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer
```

Changes include:

- Disabling taskbar animations
- Disabling window transition animations

### Gaming & MMCSS Scheduling

Path:
```reg
HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games
```

Changes include:

- Increased GPU priority
- MMCSS scheduling category set to `High`

This prioritizes game-related threads more aggressively.

### Xbox Game DVR

Path:
```reg
HKCU\System\GameConfigStore
```

Changes include:

- Disabling Xbox Game DVR background capture

Even when inactive, Game DVR can still maintain overlay-related processes in the background.

### Backup & Restore

Before any registry modification:

- Existing keys are exported automatically
- All changes can be fully restored later

---

## Power Plan

Windows defaults to the **Balanced** power profile, which dynamically lowers CPU frequency during lighter workloads.

HolmesKit switches the system to:

```text
High Performance (SCHEME_MIN)
```

If the alias fails to resolve, a GUID fallback is used automatically.

### Result

- Reduced CPU throttling
- Faster frequency ramp-up
- Improved responsiveness under load

---

## TCP/IP Stack

HolmesKit applies several low-latency networking optimizations using `netsh` and registry edits.

### Enabled

- TCP Fast Open
- RSS (Receive Side Scaling)

### Disabled / Adjusted

- TCP autotuning
- Nagle algorithm via:
  ```reg
  TcpAckFrequency=1
  TCPNoDelay=1
  ```

### Why It Matters

Nagle batching improves efficiency for bulk transfers but increases latency for real-time applications like gaming.

These changes prioritize:

- Faster packet dispatch
- Lower latency
- More consistent response times

All networking changes are fully reversible through the Restore menu.

---

# Key Features

## Transparent by Design

Every option includes:

- A plain-English explanation
- A breakdown of affected system components
- Clear tradeoffs and side effects

Nothing runs silently.

---

## Confirmation-Based Execution

No tweak runs automatically.

Every action requires explicit confirmation before execution.

---

## Full Restore System

HolmesKit includes a complete rollback path:

- Registry backups are restored automatically
- Services are re-enabled with correct startup types
- Power plans revert to defaults
- Networking settings are restored

---

## Real-Time System Info Dashboard

A live dashboard displaying:

- CPU usage
- RAM usage
- Disk usage per drive
- Current power plan
- Network activity
- Top processes by CPU and RAM usage

Refresh interval:
```text
Every 5 seconds
```

---

## Startup Manager

HolmesKit scans:

- Registry startup keys
- Task Scheduler logon triggers

Features include:

- Unified startup list
- Enable/disable toggles
- `StartupApproved`-based management
- Protected system entry detection

No startup entries are deleted outright.

---

## Apps Manager

Displays installed applications from:

- 64-bit registry hive
- 32-bit registry hive
- Per-user registry hive

Includes:

- Version information
- Reported application size
- MSI and non-MSI uninstall handling

---

## Session Logging

Every action is timestamped and logged to:

```text
HolmesKit_Backups\holmeskit.log
```

This provides a full audit trail across sessions.

---

## Apply All Tweaks

Runs the complete optimization sequence in one guided pass.

Before execution:

- Every step is explained
- The entire configuration is backed up

---

# Menu Structure

```text
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

# How to Use

## 1. Download or Clone the Repository

```bash
git clone <repository-url>
```

Or download the ZIP directly from GitHub.

---

## 2. Run HolmesKit as Administrator

Right-click:

```text
HolmesKit.bat
```

Then select:

```text
Run as Administrator
```

---

## 3. Create a Restore Point

HolmesKit recommends creating a Windows restore point before applying changes.

---

## 4. Choose an Option

Select the desired optimization module from the main menu.

---

# Recommended Usage

| Option | Recommended Use |
|---|---|
| Core Optimization | General cleanup and responsiveness improvements |
| Advanced Tweaks | Deeper low-level tuning |
| Gaming Mode | Pre-gaming optimization pass |
| Apply All Tweaks | Full optimization sequence |
| Restore Defaults | Rollback and troubleshooting |

---

# Things to Know

- Disabling `WSearch` stops live indexing updates
- File search results may become stale until restored
- TCP optimizations may reduce bulk download throughput
- Some network changes require a restart
- Administrator privileges are required

---

# Repository Structure

```text
HolmesKit/
│
├── HolmesKit.bat
├── README.md
├── LICENSE
├── .gitattributes
├── .gitignore
│
├── modules/
│   ├── logo.ps1
│   ├── sysinfo.ps1
│   ├── startup_mgr.ps1
│   └── apps_mgr.ps1
│
└── HolmesKit_Backups/
```

---

# License

Recommended License:

```text
MIT License
```

Allows:

- Open use
- Modification
- Redistribution
- Attribution-based sharing