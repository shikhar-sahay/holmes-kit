# HolmesKit

HolmesKit is a transparent, confirmation-based Windows optimization toolkit with two interfaces:

- **CLI:** `HolmesKit.bat`, the original standalone menu experience.
- **Desktop:** `HolmesKit.exe`, a lightweight native Windows GUI built with C# and WPF.

The desktop app is an additional frontend, not a replacement. System-changing GUI actions call the same Batch operations used by the CLI so the optimization logic does not drift into two implementations.

> HolmesKit changes Windows configuration. Save open work, review each confirmation, and keep a current backup. No performance outcome is guaranteed on every system.

## Functionality

| Area | CLI | Desktop | Restore path |
|---|---:|---:|---:|
| Core / Advanced / Gaming operations | Yes | Yes | Component restore options |
| Apply All | Yes | Yes | Restore page |
| System information | Yes | Yes | N/A |
| Startup Manager | Yes | Yes | Toggle again |
| Applications Manager | Yes | Yes | Application-specific |
| Session/action logs | Yes | Yes | N/A |

The GUI shows scope, tradeoffs, and restart guidance before each optimization. Long-running commands run away from the UI thread, stream visible activity, support safe cancellation, and are judged by exit status rather than process launch alone.

## Requirements

- Windows 10 or Windows 11, x64
- Administrator access for system operations
- Windows PowerShell 5.1
- For source builds: [.NET 10 SDK](https://dotnet.microsoft.com/download/dotnet/10.0)

The published desktop app can be self-contained, so end users do not need to install .NET.

## Use the CLI

The CLI remains independent of the GUI:

1. Clone or download the repository.
2. Right-click `HolmesKit.bat` and select **Run as administrator**.
3. Review the startup safety notice and every operation confirmation.

Nothing in the CLI requires `HolmesKit.exe` or the .NET SDK. The Batch file also has a validated non-interactive entry point used by the desktop app: `HolmesKit.bat --run core-full`. Normal CLI use retains all interactive menus.

## Use the desktop app

Keep this distribution layout together:

```text
HolmesKit.exe
HolmesKit.bat
modules/
  gui_bridge.ps1
  ...
```

Launch `HolmesKit.exe`. Windows requests administrator approval at startup. If UAC is declined, Windows cancels startup without making changes.

The app includes a compact Home summary; Core, Advanced, and Gaming pages; Apply All; protected-entry-aware Startup Manager; installed Applications Manager; on-demand System Information; prominent Restore actions; and live activity plus the shared log.

## Build and test

From PowerShell in the repository root:

```powershell
dotnet restore HolmesKit.slnx
dotnet build HolmesKit.slnx -c Release
dotnet test HolmesKit.slnx -c Release --no-build
```

## Publish a portable folder

```powershell
dotnet publish src\HolmesKit.Desktop\HolmesKit.Desktop.csproj -c Release -r win-x64 --self-contained true -o artifacts\publish\win-x64
```

The app is emitted as one managed executable, while `HolmesKit.bat` and `modules/` remain adjacent engine files by design. Copy the entire publish folder, not only the executable.

## Backup and restore

Before optimization, HolmesKit creates its latest backup under `HolmesKit_Backups\latest`. Activity is appended to `HolmesKit_Backups\holmeskit.log`. This local machine state is excluded from Git.

The Restore page exposes the same registry, power, service, hibernation, network, and Explorer actions as the CLI. Deleted temporary files are not recoverable, closed applications must be reopened, and third-party uninstall rollback belongs to that application's installer.

## Safety notes

- Temp cleanup skips in-use files, but deleted cache/temp content is not backed up.
- Background cleanup force-closes the established app list; save work first.
- High Performance mode increases energy use.
- Disabling Windows Search stops live indexing.
- Disabling hibernation can also affect Fast Startup.
- Network operations can interrupt connectivity and may require a restart.
- Startup Manager changes enabled state and never deletes entries.
- Applications Manager launches the uninstaller registered with Windows.

## Troubleshooting

- **Missing script:** keep `HolmesKit.exe`, `HolmesKit.bat`, and `modules/` in the layout above.
- **PowerShell missing:** restore Windows PowerShell 5.1. The GUI reports the launch failure.
- **Access denied/UAC declined:** relaunch and approve the Windows prompt when ready.
- **Operation failure:** inspect **Activity & Logs** and `HolmesKit_Backups\holmeskit.log`.
- **Network issue:** use **Restore → Reset Network Defaults**, then restart Windows.
- **Search unavailable:** use **Restore → Re-enable Background Services**.

## Architecture

```text
                         HolmesKit operations
                         HolmesKit.bat labels
                                  |
                 +----------------+----------------+
                 |                                 |
       interactive CLI menus             --run dispatcher
          HolmesKit.bat                          |
                                          async WPF service
                                                 |
                                           HolmesKit.exe
```

`HolmesKitCommandService` is the GUI's single process boundary. It captures stdout, stderr, exit codes, progress lines, and cancellation. `gui_bridge.ps1` provides structured read/toggle/uninstall data for native tables while preserving the existing registry/task/uninstaller safety model.

See [the feature-parity audit](docs/feature-parity.md) for the source-derived operation inventory.

## Repository structure

```text
HolmesKit.bat                     CLI and shared optimization engine
modules/                          CLI modules and GUI data bridge
src/HolmesKit.Desktop/            WPF desktop application
tests/HolmesKit.Desktop.Tests/    safe tests
docs/                             audit and architecture notes
HolmesKit_Backups/                generated local state (ignored)
```

## Known limitations

- The desktop publish target is Windows x64.
- Privileged integration behavior must be validated on a disposable Windows test machine; automated tests never alter registry, services, networking, power plans, or installed applications.
- HolmesKit retains the original latest-backup model rather than backup history.
- Windows editions and organization policies can reject individual service, TCP, power, or registry commands. Diagnostics remain visible and logged.
