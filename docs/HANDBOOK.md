# HolmesKit user and developer handbook

## Start, review, apply

Use `HolmesKit.exe` with the complete adjacent Batch/modules folder, or run `HolmesKit.bat` as administrator. CLI use needs no .NET installation. Desktop source builds need the .NET 10 SDK; self-contained candidates include the runtime. Windows 10/11 x64 are targets, not a claim of validation on every build or policy configuration.

Home summarizes system and recovery state. Core, Advanced and Gaming show operation scope/tradeoffs before Review. Startup and Applications support search and Refresh; their row actions identify the selected underlying entry. System Info is an on-demand snapshot. Activity & Logs provides diagnostic output and a copyable audit log.

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

Keep `HOLMESKIT_VISUAL_REVIEW_DIR` unset for ordinary safe tests. Tests use temporary files, inert CMD leaves, mocked native adapters and AST-loaded validation functions. Never point fixtures at the production engine/state. The WPF construction collection is isolated from subprocess tests and retains a bounded cold-start timeout and exception assertions. Source compilation/fixtures do not establish native Windows recovery correctness.

When modifying an existing optimization: enumerate every changed value/service/power setting, update the operation allowlist/catalog and `Get-HolmesOperationScope`, and add Before/After/conflict/type/absence/failure tests. Anything not captured must be labelled partial/reset-only/irreversible. Preserve CLI consent and non-interactive GUI dispatch. Do not change schema or adapter scope without a conservative compatibility decision; current scope mismatch fails closed.

For a native adapter change, test conversion/validation without Windows writes first, then use the [disposable-VM procedure](WINDOWS_VM_VERIFICATION.md). Review partial writes, denial, missing capabilities and interrupted publication before public release. No new optimization should be justified solely by FPS/latency claims without evidence.

## Candidate preparation and future release

```powershell
./tools/Publish-Portable.ps1 -Version 0.3.0-rc.1
./tools/Test-PortableCandidate.ps1 -CandidateZip ./artifacts/packages/HolmesKit-0.3.0-rc.1-win-x64.zip
Get-FileHash ./artifacts/packages/HolmesKit-0.3.0-rc.1-win-x64.zip -Algorithm SHA256
```

Compare the archive hash to its `.sha256` sidecar. The verifier also checks complete runtime layout, duplicate/traversal paths, manifest coverage and each payload hash; it does not authenticate the publisher or execute the EXE. Keep each version unique; tooling does not overwrite release assets. Build/archive timestamps and SDK differences mean bit-for-bit reproducibility is not guaranteed.

Windows CI runs safe verification. The manual `Prepare unsigned portable candidate` workflow runs tests and uploads an Actions artifact, without publishing a Release or tag. Downloaded artifacts must be independently checked. This project has no approved licence file: public source visibility does not grant normal reuse/distribution permissions. Owner decisions may include a permissive licence (MIT/Apache-2.0), copyleft terms (GPL), or proprietary distribution; compatibility and obligations need owner/legal review. No licence text is selected here.

Candidates are unsigned; SmartScreen warnings may occur. Do not weaken Windows security to hide them. A real certificate and signing policy would be separate work. A public Release/download site requires the [release gates](RELEASE_READINESS.md), owner approval and a recorded VM evidence matrix. No public release or website is created by these scripts.
