# HolmesKit user and developer handbook

## Start, review, apply

Use `HolmesKit.exe` with the complete adjacent Batch/modules folder, or run `HolmesKit.bat` as administrator. CLI use needs no .NET installation. Desktop source builds need the .NET 10 SDK; self-contained candidates include the runtime. Windows 10/11 x64 are targets, not a claim of validation on every build or policy configuration.

Home summarizes system and recovery state. Core, Advanced and Gaming show operation scope/tradeoffs before Review. Startup and Applications support search and Refresh; their row actions identify the selected underlying entry. System Info is an on-demand snapshot. Activity & Logs provides diagnostic output and a copyable audit log.

The matte-black visual system lives in `Themes/DarkPalette.xaml` and `Themes/Controls.xaml`: shared brushes, typography, page inset, panel radius, control sizing, focus/hover/disabled states and table styling. The ASCII mark remains the CLI identity; sidebar icons use Windows fonts with a fallback. No third-party UI/chart framework is required. Windows high contrast switches brushes using system colors, but interactive accessibility/DPI approval remains a release gate.

Home's CPU chart uses `GetSystemTimes`: total is kernel + user (kernel includes idle); utilization is `(delta total - delta idle) / delta total * 100`. It measures the interval between samples, not a cumulative lifetime average. `GlobalMemoryStatusEx` supplies physical total/available bytes; used is total minus available and utilization is used/total. `GetTickCount64` supplies Windows boot uptime, including sleep. It is not the time since the most recent user sign-in.

Sampling uses one background loop at two-second intervals, only while Home is visible, not minimized and no command is busy. Navigation/minimization/busy transitions cancel it; reopening starts a fresh CPU counter baseline. The window cancels monitoring on close and each timer/cancellation source is disposed. The history holds at most 31 actual samples within 60 seconds. Charts use fixed 0–100% axes and actual timestamps, break unknown/long gaps, and never fill inactive periods with invented data. The first CPU sample is unavailable; text values accompany both charts. No sample history is saved or sent anywhere. Native metric failures show unavailable values; unexpected monitoring errors remain in session output.

System Info, power and storage capacity retain the existing refresh-based bridge. Home's storage figures are capacity used/free, **not I/O activity**; refresh System Info for new capacity/power metadata. CPU/memory snapshots can differ from live values because their observation times differ. No overall health score, FPS forecast or performance guarantee is implied.

Operation rows expand scope/recovery details and retain visible tradeoffs. Review opens the shared scrollable dialog; Escape, Cancel or closing the dialog declines, and Cancel is the default keyboard action. Confirm is still required before the existing ViewModel sends a command. The Activity page shows actual output and indeterminate progress, not an invented percentage; only read-only queries can be cancelled. Persistent Failed/Partial status must be investigated.

Recovery state labels distinguish no baseline, legacy/manual review, interrupted operation, invalid journal and ready baseline. The displayed date is **baseline creation**, not last modification. Last recorded engine operation is shown when recognized. A ready badge checks the envelope/identity at inspection time; the engine still validates full scope and conflicts at execution. A blocked managed restore does not grant permission to delete or edit the journal. Independent reset actions remain separately confirmed and do not promise exact recovery.

An operation starts only after affirmative confirmation. CLI accepts exactly Y/y; other input does not authorize changes. Apply All confirms once for the disclosed existing sequence, not for every internal step. It can close browsers/apps, delete files, change services and disrupt networking. Save work and use a recoverable environment. A failed stage may leave earlier changes applied.

Cancel is disabled and normal window closure blocked during mutations. Read-only queries remain cancellable. Killing the process or losing power is not rollback. Investigate a persistent failure/partial state in Activity & Logs rather than repeating Apply All blindly.

## What recovery can and cannot do

| Area | Recovery behavior |
|---|---|
| Managed registry values | Captured existence, type and data; no whole-key deletion/import; external conflicts skipped |
| Managed services | Captured startup, delayed flag and running state; not triggers/permissions/dependencies/paused transitions |
| Active power selection | Select captured GUID if it still exists; does not recreate or delete schemes |
| TCP globals, networking, NTFS, hibernation | Partial or reset-only; not exact original-state recovery |
| Deleted files, unsaved work, applications uninstalled | Not restored by HolmesKit |

The first managed baseline lives in `HolmesKit_Backups/recovery/baseline.json`. Before states persist across restarts and both interfaces. After states describe recorded HolmesKit results. Atomic staged publication retains the preceding envelope as `baseline.previous.json`; this is not a general backup history. A checksum detects corruption, not an attacker rewriting both payload and checksum. Scope and machine/current elevated user identity are checked before recovery.

If current state equals Before, recovery needs no write. If it equals After, the value can be restored. If it differs from both, the entry is a conflict and is skipped; exit 4 means partial recovery. Property ordering in JSON is irrelevant, while array order, value types and actual data matter. Another program can still race these checks; there is no Windows-wide transaction.

Corrupt, missing, mismatched or interrupted journals require review. Keep both journal files and diagnostics private. Do not edit checksums, delete the baseline to bypass a block, or copy another machine's journal into place. Changed adapter scope also requires review. Legacy `latest` exports remain untouched; they require manual handling because broad imports/deletion can overwrite unrelated state. No automatic migration or reconciliation is offered.

Elevation under another administrator targets that account's HKCU, not automatically the original desktop user's settings. Neither checksums nor internal engine markers authenticate code against a local administrator or malware able to edit the program folder. Use a trusted extracted distribution.

## Failure and removal

Keep the full operation identifier, exit code and error details when requesting help; redact usernames, commands and machine identifiers before sharing logs. The log view is bounded and clearing its view does not delete the audit trail. Native capability/policy failures are failures, not proof that a tweak was applied. Unsupported uninstall registrations may require Windows Settings.

Upgrade into a new ordinary folder; preserve the old folder and recovery data until validated. Protected-directory installation is not supported. Removing extracted program files does not reverse Windows changes. Preserve recovery data separately before removing files. Never delete a user's backup directory as an uninstall step.

## Developer boundaries and safe workflow

The Batch menus and allowlisted dispatcher remain the shared optimization engine. WPF uses `HolmesKitCommandService`/`ProcessRunner`; PowerShell supplies structured data and recovery policy/native adapters. `recovery.ps1` coordinates a checkout's exclusive lock and active journal before invoking internal engine execution. This is coordination, not a privileged authentication service.

Build/test from the repository root:

```powershell
dotnet restore HolmesKit.slnx
dotnet build HolmesKit.slnx -c Release --no-restore
dotnet test HolmesKit.slnx -c Release --no-build
```

Keep `HOLMESKIT_VISUAL_REVIEW_DIR` unset for ordinary safe tests. Tests use temporary files, inert CMD leaves, mocked native adapters and AST-loaded validation functions. Never point fixtures at the production engine/state. The WPF construction collection is isolated from subprocess tests and retains a bounded cold-start timeout and exception assertions. It initializes real resources without launching StartupUri, uses an inert service even if layout callbacks fire, lays out all ten pages offscreen at 900×620, 1120×760 and 1600×900, captures binding errors, and checks the confirmation default. Its dispatcher frame exit has a bounded high-priority tick so rendering cannot starve an idle-priority exit. Dashboard tests verify counter math, bounded history, chart gaps, monitoring eligibility and cancellation. Management fixtures verify sorting/filtering do not change the confirmed action target. These are not interactive visual, DPI or native recovery validation. The optional visual-review mode opens windows and queries local metadata; run it only with explicit desktop-review authorization, and keep its private captures untracked.

When modifying an existing optimization: enumerate every changed value/service/power setting, update the operation allowlist/catalog and `Get-HolmesOperationScope`, and add Before/After/conflict/type/absence/failure tests. Anything not captured must be labelled partial/reset-only/irreversible. Preserve CLI consent and non-interactive GUI dispatch. Do not change schema or adapter scope without a conservative compatibility decision; current scope mismatch fails closed.

Output bindings must remain OneWay where the target defaults to editing: this includes **Run.Text**, not just read-only TextBox.Text. Task 04's dispatcher exception capture exposed an inline Run attempting to write the computed Dashboard.AvailableText property; all bound output Runs now explicitly use OneWay. Construction fixtures include a populated drive so computed disk text receives the same runtime coverage. Capture dispatcher exceptions as test failures before the application's normal error dialog; otherwise a hidden modal can disguise an exception as a timeout. Do not suppress the exception assertions to make CI green.

For a native adapter change, test conversion/validation without Windows writes first, then use the [disposable-VM procedure](WINDOWS_VM_VERIFICATION.md). Review partial writes, denial, missing capabilities and interrupted publication before public release. No new optimization should be justified solely by FPS/latency claims without evidence.

## Candidate preparation and future release

### Task 05 acceptance harness

`tests/HolmesKit.Desktop.Acceptance` is a separate non-elevated QA executable using the production MainWindow, dialog, styles and telemetry. Run it only for authorized local UI review:

```powershell
dotnet run --project tests/HolmesKit.Desktop.Acceptance -c Release
```

The adapter delegates only the three read queries. Optimization, restoration, startup-toggle and uninstall methods return clearly labelled inert fixture results and never call the underlying native service. Tests check all three mutation methods for success/failure/partial fixture outcomes. Example lists are the default; switching list mode requires Refresh on the selected page. F12 hides/shows fixture controls. Slow/failing reads and inert failure/partial outcomes are test scenarios, not measured system behavior.

The harness has its own private QA log and optional UI-only baseline illustrations. These contain private identifiers; never commit, distribute or copy them into a real recovery directory. They are not authoritative engine journals. Fixture dialogs appear on the taskbar solely to aid QA-tool targeting; production dialogs retain their owned, taskbar-free behavior. The harness is built by CI but excluded from the portable product.

Task 05 directly observed a white confirmation background: an implicit Window style did not apply to the derived window. MainWindow and ConfirmationWindow now explicitly select that style. Tests assert actual dark backgrounds and a base FontSize of 13 device-independent units, in addition to binding/default-button checks. Cancel focus is set after content rendering and Escape has an explicit decline path. The session Clear view DockPanel no longer fills the remaining header width. Offscreen tests measure the content root explicitly: measuring an unshown Window alone can leave child widths zero. None of these checks certifies complete interactive keyboard or screen-reader behavior.

The packaged elevated executable's launch/data evidence, non-elevated fixture interaction, rendered captures, and automated tests are separate evidence classes. Integrity boundaries were preserved; no UAC/security workaround was introduced. Shared-helper focus/cache errors prevented complete click-by-click acceptance. Do not mark that gate PASS on the strength of screenshots or construction tests alone.

```powershell
./tools/Publish-Portable.ps1 -Version 0.6.0-rc.1
./tools/Test-PortableCandidate.ps1 -CandidateZip ./artifacts/packages/HolmesKit-0.6.0-rc.1-win-x64.zip
Get-FileHash ./artifacts/packages/HolmesKit-0.6.0-rc.1-win-x64.zip -Algorithm SHA256
```

Compare the archive hash to its `.sha256` sidecar. The verifier also checks complete runtime layout, duplicate/traversal paths, manifest coverage and each payload hash; it does not authenticate the publisher or execute the EXE. Keep each version unique; tooling does not overwrite release assets. Build/archive timestamps and SDK differences mean bit-for-bit reproducibility is not guaranteed.

Windows CI runs safe verification. The manual `Prepare unsigned portable candidate` workflow runs tests and uploads an Actions artifact, without publishing a Release or tag. Downloaded artifacts must be independently checked. This project has no approved licence file: public source visibility does not grant normal reuse/distribution permissions. Owner decisions may include a permissive licence (MIT/Apache-2.0), copyleft terms (GPL), or proprietary distribution; compatibility and obligations need owner/legal review. No licence text is selected here.

If workflow dispatch is unavailable to the connected tools, an authorized operator can open **Actions → Prepare unsigned portable candidate → Run workflow**, select `master`, enter a fresh version (do not overwrite a local/hosted candidate identifier), then download `unsigned-portable-candidate`. Extract the artifact wrapper and run `Test-PortableCandidate.ps1` on its product ZIP; compare engine/module/document payloads to that run's exact source SHA. A successful local package is not a hosted packaging result, and neither publishes a GitHub Release.

Candidates are unsigned; SmartScreen warnings may occur. Do not weaken Windows security to hide them. A real certificate and signing policy would be separate work. A public Release/download site requires the [release gates](RELEASE_READINESS.md), owner approval and a recorded VM evidence matrix. No public release or website is created by these scripts.

## Task 06 functional hardening and privilege decision

Desktop retains `requireAdministrator` at startup and `uiAccess=false`. Cancelling UAC prevents startup; it is not an in-app error. System/telemetry reads normally need no administrator token; HKLM startup approval, scheduled tasks, services, networking and engine writes do. Enumeration can be incomplete under a restricted account. Internal engine markers are coordination, not caller authentication. `--run` remains an allowlisted already-authorized caller interface, with no interactive console prompt.

Elevation-on-demand is **deferred**. A safe follow-up must provide an authenticated same-user IPC endpoint with explicit operation IDs, request/result correlation and replay rejection; validate the helper executable and adjacent mutable scripts; protect shared state with appropriate ACLs; preserve the engine lock and process lifetime; and reject alternate-user UAC until HKCU ownership is explicitly resolved. Never elevate arbitrary command text or trust an environment variable as approval. Progress/error capture and UAC denial must be tested with inert adapters and then an authorized VM. Simply changing the manifest or adding `runas` would not meet these requirements. [Microsoft's manifest reference](https://learn.microsoft.com/en-us/windows/win32/sbscs/application-manifests) documents execution levels; this project-specific decision follows the current journal/account architecture.

Management actions now share the PowerShell bridge in both interfaces. Startup changes re-enumerate the exact identity/protection and reject a changed enabled state before writing. A race with another tool after that check is still possible. Uninstall transport uses separate Base64 scalar `-Data` and `-NameData` parameters: native Windows PowerShell `-File` does not deliver two trailing CLI arguments as the former array contract assumed. The bridge validates the current registered name/command and rejects relative, interpreter-based and ambiguous commands. Argument-free executable registrations omit `ArgumentList`. MSI cancellation (1602), restart-required (3010) and failures remain distinct. Unsupported registrations require Windows Settings; HolmesKit does not provide app recovery. CLI menus and fresh confirmation remain intact; they need Batch/PowerShell, not the GUI/.NET.

Read-only bridge queries have a 60-second deadline and retain user cancellation. Timeout is a failure with a diagnostic; user cancellation is Cancelled. Neither deadline nor cancellation kills a modifying operation. Stale/null/malformed management identities fail instead of becoming actionable rows; empty application enumeration returns `[]`. Success/failure output from management commands appears in Activity, including stdout-only and diagnostic-free failures. Opening the log folder handles access/launch errors. Pages selected while another query runs are loaded after it finishes; no second click is needed. Existing bounded logs, sticky failure/partial states, monitoring lifecycle and close guards remain.

Local safe verification covers actual parameter binding through `powershell.exe -File` with an inert script, AST-selected action bodies with native functions replaced, management outcomes and actual WPF Loaded/selection/busy events. The fixture's three mutation methods remain disconnected. A real uninstall, startup change, optimization or recovery was **not** executed. Source/read-only comparisons on the current Windows 11 workstation do not certify Windows 10, policy or alternate-user scenarios.

Use currently serviced Windows/.NET builds when preparing a public candidate. The [.NET 10 OS matrix](https://github.com/dotnet/core/blob/main/release-notes/10.0/supported-os.md) distinguishes Windows releases/editions; “Windows 10/11” is a target family, not support for all releases. Record exact OS/SDK/bundled-runtime versions, and rebuild with current security servicing before public distribution. The local pinned SDK is development evidence, not a servicing policy.

### Owner licensing and distribution choices

No licence is chosen here. These are decision aids; review the actual terms and third-party notices before approval:

| Option | Practical consequence |
|---|---|
| [MIT](https://opensource.org/license/mit) | Broad reuse, modification and commercial distribution; retain copyright/permission notices. |
| [Apache-2.0](https://www.apache.org/licenses/LICENSE-2.0) | Permissive reuse with explicit patent provisions and redistribution/notice conditions. |
| [GPLv3](https://opensource.org/license/gpl-3.0) | Copyleft distribution, including corresponding-source and licence obligations for covered derivatives. |
| Proprietary / all rights reserved | Owner defines a distribution/use agreement; no open-source permission is implied. |

The MVP distribution should remain a complete portable ZIP with version, source SHA, checksums, unsigned disclosure and preserved recovery data. A future manual GitHub Release can link concise installation/recovery notes after owner approval and native validation. An installer/updater or public static overview is optional later; a website cannot perform local privileged operations. No public assets are published by this milestone.
