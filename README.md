# HolmesKit

HolmesKit is a transparent, confirmation-based Windows optimization toolkit with two supported interfaces:

- **Desktop application:** `HolmesKit.exe`, a native Windows interface for reviewing, applying, and restoring changes.
- **CLI:** `HolmesKit.bat`, the original standalone Batch/PowerShell menu.

Both interfaces use the same HolmesKit operations. The desktop application calls the established Batch entry points rather than maintaining a separate set of Windows modifications, and the CLI remains fully usable without the GUI.

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

The GUI shows scope, tradeoffs, and restart guidance before each optimization. Long-running commands run away from the UI thread, stream visible activity, support cancellation, and are judged by exit status rather than process launch alone. Cancellation interrupts execution and may leave partial changes; it is not rollback.

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

Independently selected changes, including restore actions, startup toggles and launching uninstallers, require a fresh `Y` confirmation (`y` is accepted). Declined, blank, invalid or unavailable input does not authorize a change. The desktop supplies its own confirmation; the `--run` dispatcher is an automation boundary for an already-authorized caller and never prompts for console input.

Engine operations validate a retained recovery journal before modifying steps. Backup or validation failure stops execution. Apply All uses one confirmation and stops on a checked prerequisite or step failure. Earlier successful steps may remain applied; HolmesKit does not automatically roll them back. Cleanup may report partial failure when files are in use or inaccessible.

## Desktop application

The desktop application is a lightweight C#/WPF frontend targeting Windows 10 and Windows 11. It starts with administrator privileges because optimization and restore operations modify protected system configuration. Read-only data is collected in the background. Cancel is disabled and closing is blocked while modifications run; read-only queries remain cancellable. A forced process termination or power loss can still interrupt changes.

The interface includes:

- **Home** — system, power-plan, backup, and recent-activity summary
- **Core Optimization**, **Advanced Tweaks**, and **Gaming Mode** — operation groups with scope, restart guidance, and tradeoffs
- **Apply All** — the complete existing HolmesKit sequence with one confirmation
- **Startup Manager** — enabled-state management without deleting entries
- **Applications Manager** — installed-program metadata and registered uninstallers
- **System Information** — Windows, processor, memory, power, storage, and active-network details
- **Restore** — validated backup restoration and Windows-default recovery actions
- **Activity & Logs** — live command progress and the persistent audit log

![HolmesKit Core Optimization](docs/screenshots/desktop-core.png)

### Run a published build

Keep this distribution layout together:

```text
HolmesKit.exe
HolmesKit.bat
modules/
  gui_bridge.ps1
  ...
```

Launch `HolmesKit.exe` from the published folder. Windows requests administrator approval at startup. If UAC is declined, Windows cancels startup without making changes.

Do not copy only the executable: the adjacent Batch file and `modules` directory are the shared HolmesKit engine.

## Build and test

From PowerShell in the repository root:

```powershell
dotnet restore HolmesKit.slnx
dotnet build HolmesKit.slnx -c Release
dotnet test HolmesKit.slnx -c Release --no-build
```

Run the isolated Task 01 safety regressions with:

```powershell
dotnet test HolmesKit.slnx -c Release --filter "FullyQualifiedName~CliSafetyTests|FullyQualifiedName~GuiAuthorizationTests|FullyQualifiedName~ManagementConfirmationTests|FullyQualifiedName~RealDesktopBatchBoundary"
```

These tests execute real CMD control flow with all Windows-changing subroutines replaced by inert markers and test management approval fragments and the desktop process boundary with controlled fixtures. The full suite also exercises the recovery journal and lifecycle in temporary directories with native adapters replaced by inert state fixtures. It does not run the real optimization or restore engine. Existing optional visual tests can query system data; do not enable `HOLMESKIT_VISUAL_REVIEW_DIR` for the normal safety run.

Run the source-built application with:

```powershell
dotnet run --project src\HolmesKit.Desktop\HolmesKit.Desktop.csproj -c Release
```

## Publish a portable folder

```powershell
dotnet publish src\HolmesKit.Desktop\HolmesKit.Desktop.csproj -c Release -r win-x64 --self-contained true -o artifacts\publish\win-x64
```

Prepare an unsigned portable validation candidate with the complete engine and checksums:

```powershell
./tools/Publish-Portable.ps1 -Version 0.2.0-rc.1
```

The Windows CI workflow builds and runs safe tests. A separate manually triggered workflow prepares a downloadable Actions artifact, **not a public release**. Both workflows are prepared in source; their hosted execution must be checked after pushing. Public release/signing and a project website remain gated on [disposable-VM verification](docs/WINDOWS_VM_VERIFICATION.md) and a project licensing decision. No installer or automatic updater is included. These builds are unsigned.

The app is emitted as one managed executable, while `HolmesKit.bat` and `modules/` remain adjacent engine files by design. Copy the entire publish folder, not only the executable.

## Backup and restore

The first engine operation captures `HolmesKit_Backups\recovery\baseline.json`. Its baseline ID, creation time and original values persist across repeated operations, restarts and both interfaces. Same-volume staging/atomic publication preserves the prior envelope before replacement; `baseline.previous.json` retains the previous journal version. A file lock serializes engine operations. Incomplete staging files are not selected for recovery. Legacy files under `HolmesKit_Backups\latest` are preserved unchanged and require manual review; automatic broad registry import/deletion is disabled.

Managed recovery validates format, checksum, machine/user identity and an explicit current scope before mutation. Only captured registry values are restored, including their prior absence and types; unrelated keys/values are never deleted. Service startup/running states and the previous active power GUID are captured. Restore skips values that no longer match the recorded HolmesKit state and reports partial outcomes. The original power plan must still exist. Changed adapter scope, corruption, identity mismatch or an interrupted `Running` journal blocks automatic execution for manual review. Checksums detect accidental corruption, not malicious tampering by someone who can rewrite the journal and checksum. Do not share or manually edit recovery files.

Recovery is deliberately limited: network resets, TCP global defaults, NTFS last-access behavior and hibernation are not exact-state rollback. Deleted files, uninstalled applications and unsaved work cannot be recovered. Application rollback belongs to its installer. No baseline rotation/migration UI or interrupted-operation reconciliation is provided yet; preserve the journal and request review instead of deleting it to bypass a safety block. Activity is appended to `HolmesKit_Backups\holmeskit.log` without external telemetry.

Extract the portable app into an ordinary folder, keep all engine files together, and retain the existing folder and recovery data during upgrades. Protected-directory installation is not supported by this MVP. Removing the extracted program does not undo Windows changes; save recovery data separately before deleting program files.

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

System information crosses the PowerShell boundary as JSON with raw byte counts, nullable measurements, uptime seconds, and explicit power-plan metadata. Formatting is handled by the desktop presentation layer so locale differences or unavailable values do not become misleading zeroes. Custom power-plan names are retained and identified as custom plans.

See [the feature-parity audit](docs/feature-parity.md) for the source-derived operation inventory.

## Repository structure

```text
HolmesKit.bat                     CLI and shared optimization engine
modules/                          CLI modules and GUI data bridge
src/HolmesKit.Desktop/            WPF desktop application
tests/HolmesKit.Desktop.Tests/    safe tests
docs/                             audit and architecture notes
docs/screenshots/                 representative desktop screenshot
HolmesKit_Backups/                generated local state (ignored)
```

## Known limitations

- The desktop publish target is Windows x64.
- Privileged integration behavior must be validated on a disposable Windows test machine; automated tests never alter registry, services, networking, power plans, or installed applications.
- The retained baseline has a previous journal envelope, not a general backup history. Adapter/scope changes and interrupted operations require manual review.
- The hardening changes have isolated automated coverage but still require native apply/recover and accessibility/DPI checks on disposable Windows VMs before a public release.
- Application sizes come from optional Windows uninstall-registry estimates. Missing values are shown as unavailable, and reported sizes may differ from actual disk usage.
- CPU utilization is an on-demand Windows snapshot rather than continuous monitoring.
- Windows editions and organization policies can reject individual service, TCP, power, or registry commands. Diagnostics remain visible and logged.
