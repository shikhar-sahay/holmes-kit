# HolmesKit Task 02 — MVP Hardening Handoff

Date: 5 November 2026. Branch: `master`. This report distinguishes implemented safeguards from native Windows behavior that still requires disposable-VM verification.

## 1. Executive Summary

Implemented a retained, scoped recovery journal shared by the existing CLI and desktop; conservative restore/conflict handling; tighter management input validation; safer desktop mutation lifecycle; bounded diagnostics; Windows CI; and unsigned portable-candidate tooling. The Batch optimization bodies and WPF design remain recognizable. The first baseline is no longer deleted/replaced by subsequent operations. Existing legacy exports are preserved unchanged.

Local verification: Release build succeeded with zero warnings/errors; **284 tests passed, zero failed, zero skipped**. No real optimization, restoration, service/power/network/startup modification or uninstallation ran on the workstation. Native adapters remain unverified outside mocks. This is a tested hardening increment and validation candidate, **not a claim that public release or every Task 02 aspiration is complete**.

## 2. Implemented Improvements

- Recovery: versioned baseline envelope, identity metadata, corruption checksum, staged/write-through publication, atomic replacement with a previous envelope, exclusive operation lock, original Before-state retention, After-state tracking, explicit interrupted-state block, scoped/conflict-aware restoration.
- Safety: existing confirmation and allowlisted dispatch remain; inherited child-marker bypass is cleared on normal entry; private engine entry validates the active journal operation. Native failures retain more diagnostic output. Startup actions re-resolve current identities rather than trusting supplied paths/locks. Uninstall commands are checked against fresh registrations, reject ambiguous paths/scripts/interpreters, and distinguish cancellation/reboot outcomes.
- Desktop: mutation cancellation disabled, closing blocked during mutations, failure/partial states retained, current backup status refreshed after failure, lazy-page busy handling repaired, bounded output/activity and bounded off-thread log tail, recovery-specific descriptions, accessible search/refresh names, explicit-null snapshot normalization.
- Delivery: Windows verification workflow; manual candidate workflow without public-release publishing; complete portable ZIP plus checksums; updated README/inventory and a disposable-VM release-gate procedure.

## 3. Architecture Changes

`HolmesKit.bat --run` now enters `modules/recovery.ps1`, which serializes and validates the operation, then invokes the existing allowlisted Batch engine through an internal child entry. Interactive CLI confirmation reaches the same coordinator. The engine's backup prerequisite now validates the active journal instead of deleting/exporting a new `latest` directory. A child marker is coordination, not authentication against an administrator who can edit the scripts.

`recovery_core.ps1` contains policy/storage functions and isolated native Read/Write-HolmesState adapters. Tests replace those adapters, not the recovery policy. Registry scope is explicit and generated from HolmesKit's managed values, including current per-adapter Nagle values. Snapshot input never supplies an arbitrary registry path to restore. No service/daemon, production dependency or new GUI framework was added.

## 4. Backup and Restoration

The initial `HolmesKit_Backups/recovery/baseline.json` records format version, ID/time, machine GUID, current Windows user SID, operation/status and Before/After entries. Original Before values persist through repeated CLI/GUI calls and application restarts. Updates write/flush a unique staging file, check it, then rename/replace on the same volume. `baseline.previous.json` retains the preceding envelope. Staging files are not selected as backups. A failed new baseline prevents engine execution; failed post-operation publication leaves the earlier Running record for manual review.

Registry recovery restores only individual managed values, including original absence, CLR-compatible value types and data. It never deletes a whole registry key or imports broad subtrees. Service recovery captures startup mode, delayed flag and running state for SysMain, WSearch, DiagTrack, BITS and DoSvc. Power recovery selects the captured active GUID without deleting/recreating schemes. It requires that plan to remain available.

Recovery first validates schema, checksum, current identity and scope. Entries whose current state differs from both Before and recorded After are skipped as external conflicts; other entries can continue. Exit 4 reports partial restoration. A restored Before state is recognized idempotently. Managed operation preflight also refuses conflicting state instead of silently refreshing the baseline. Changing adapter scope blocks automatic recovery for review.

Legacy `latest` exports remain on disk. Automatic legacy replay is deliberately disabled because merge imports and arbitrary absent-key deletion cannot safely provide narrow recovery. No automatic migration is fabricated. Reset/session actions (network, hibernation enable, Explorer restart) remain explicitly labelled and serialized; they do not require an unrelated exact-state journal.

Limits: NTFS last-access behavior, TCP global settings, network resets and hibernation modes are not exact-state recovery. Files, uninstalled applications and unsaved work are not recoverable. Service triggers, permissions, dependencies and paused/transition states are not a full service backup. There is no baseline rotation UI, automatic interrupted-state reconciliation or automatic rollback. Checksums detect corruption, not malicious rewriting of both payload and checksum.

## 5. Safety and Failure Handling

Privileged mutation keeps existing admin/UAC behavior and explicit confirmation. Registry/user identity is the currently elevated account; alternate administrator credentials do not target the original user's HKCU automatically. Recovery rejects another SID/machine. Mutable engine files and user-owned recovery directories still require a trusted distribution/location; this does not defend against a local administrator or malware rewriting the engine.

Mutation requests ignore process-kill cancellation, and the UI disables Cancel and blocks normal window closure while they run. Read-only cancellation still kills/drains its child process. Forced termination/power failure is not rollback: ambiguous Running journals fail closed. Independent mutations are not transactional. More native errors are streamed; some legacy error handling remains outside the scope of this increment.

## 6. Desktop Improvements

The dark palette, sidebar, ASCII identity and current pages are retained. Managed restore controls now reflect journal availability and describe scoped registry, service and previous-plan recovery. Legacy data is shown as manual review. Partial recovery has a distinct retained status, rather than generic success. Search/refresh controls have automation names.

Log viewing reads at most a 256-KiB suffix off the UI thread and retains at most 500 lines; command output capture is capped at 512 KiB per stream and visible activity at 1,000 entries. This establishes bounded work/storage, not a measured startup or memory speedup. Very large structured responses may fail parsing after the capture limit rather than consume unbounded memory. Busy-page navigation no longer permanently marks a page loaded when its scan never started; explicit Refresh remains the retry path after query failure.

No fresh interactive visual/DPI/high-contrast/screen-reader review was performed. Existing STA construction tests exercise all ten views; that does not establish accessibility or rendered quality. System-wide high-contrast support remains incomplete.

## 7. Testing

Executed Release build and full suite: **284/284 passed**, zero skipped, zero warnings/errors. Task 01's 260 cases remain represented, with legacy-backup expectations and dispatcher fixtures adapted to the new policy; 24 cases were added.

- RecoveryPolicyTests: envelope roundtrip/retention, corruption, machine identity, duplicate/foreign scope, original absent/value/type restoration, conflicts, interrupted state, write failure, unrelated categories, CLR binary/multi-string conversion and operation-specific scope.
- RecoveryLifecycleTests: the actual coordinator runs across separate PowerShell processes with native adapters/engine replaced by inert file-state fixtures. It tests repeated/case-insensitive operation entry, retained original power state, legacy preservation, lock contention and corrupt-journal rejection.
- BridgeBoundaryTests: actual uninstaller path validator loaded from AST; filesystem existence mocked; relative paths, scripts and interpreter executables rejected. The bridge action switch never runs.
- DesktopHardeningTests: bounded large-log tail, non-killing mutation cancellation against echo-only CMD, corrupt-envelope UI status.
- Existing tests: confirmation matrix, prerequisite failures, partial Apply All, restore declines, process quoting, culture/formatting, paths, catalog and window construction.

Ordinary tests never execute native optimization/restoration bodies. PowerShell files were parsed for syntax. Intermediate fixture failures were investigated and fixed. The first hosted run built successfully and passed 283 tests but timed out the WPF construction test at its old 10-second limit. That smoke test is now isolated from parallel subprocess cases, has a bounded 60-second cold-start budget and reports its current stage on timeout; its construction/binding assertions remain. Local verification passes; the final hosted result is reported in delivery after checking CI. Native adapter semantics, policy behavior and actual rollback comparisons still require VM testing; mocks cannot establish those facts.

## 8. CI and Distribution

`.github/workflows/verify.yml` runs restore, Release build and safe tests on Windows with read-only repository permissions. GitHub registered it active. Initial run `42036204891` failed only the construction-test timeout described above; the delivery checks the follow-up run rather than substituting local success for hosted CI success.

`package.yml` is manual and uploads an unsigned Actions artifact only after build/tests. It does not create a tag or GitHub Release. `tools/Publish-Portable.ps1` validates a version, publishes self-contained win-x64, includes Batch/modules/docs/version, excludes local state/PDBs, and generates per-file and archive SHA-256 checksums. A local `0.2.0-rc.5` candidate was prepared for final content verification. Packaging is repeatable; bit-for-bit determinism across SDKs/timestamps is not claimed. No binary is signed and no public release, installer, updater or website was deployed.

Portable extraction to an ordinary folder is the supported MVP layout. Protected-directory installation is deferred until mutable state placement/ACLs are designed. Preserve the previous folder and recovery data during upgrades. Removing program files does not undo Windows changes.

## 9. Modified Files

- `HolmesKit.bat`: shared coordinator entry, non-destructive prerequisite, scoped recovery routing, native diagnostic propagation and accurate labels.
- `modules/recovery.ps1`, `recovery_core.ps1`: coordinator, journal lifecycle, validation, restore policy and native adapters.
- `modules/gui_bridge.ps1`: fresh startup/uninstall identity validation, constrained executable handling, installer outcomes.
- Desktop `BackupInspector`, `HolmesKitCommandService`, `ProcessRunner`, new `LogTailReader`: journal inspection, cancellation policy, data normalization, output/log bounds.
- Desktop `MainViewModel`, `MainWindow.xaml/.cs`, `OperationDefinition`: lifecycle/state, accessible labels and recovery descriptions.
- Tests: new policy/lifecycle/boundary/desktop cases, updated legacy/dispatcher fixtures, and `MainWindowConstructionTests` isolation/cold-start diagnostics.
- `.github/workflows/verify.yml`, `package.yml`, `tools/Publish-Portable.ps1`: safe CI and candidate preparation.
- `README.md`, `docs/feature-parity.md`, `docs/WINDOWS_VM_VERIFICATION.md`: actual behavior, packaging and release gates.
- This handoff; historical Task 01 and audit reports remain unchanged.

## 10. Deferred Improvements

Native VM matrix, automatic journal reconciliation/migration/rotation, exact TCP/NTFS/hibernation recovery, cooperative stage cancellation, fuller service semantics, comprehensive UI accessibility/high-contrast, CLI management consolidation, measured startup/query optimization, signing, licence selection and public release/site. A lightweight static overview is useful once there is a verified downloadable release; current repository documentation is preferable to advertising an unvalidated product. Apply All still repeats some established internal work; it was not reordered merely for a presumed performance benefit.

## 11. Known Risks

Configuration can change concurrently outside HolmesKit; conflict checks reduce but cannot eliminate those races. Locks serialize a checkout's engine operations, not all unrelated Windows tools or separate copies of HolmesKit. Adapter/schema changes and interrupted operations intentionally require manual review. Current-state queries or logging failure can block a change conservatively. Checksums are not signatures; machine/user identifiers and configuration in local recovery data should not be uploaded publicly. Privileged registration/path checks do not establish that a third-party executable is trustworthy. Windows compatibility is targeted, not proven by compilation.

## 12. Git Summary

- Branch: `master`, initially synchronized with `origin/master` at `7b4e813`; remote references fetched, no branch/PR/history rewrite/force push.
- `79691cf525263589d98b97d14a678a7111471203` — `feat: retain scoped recovery baseline and guard restoration`.
- `2a1a02a7c13998dd5e6900caeb9b9b01090b0b7b` — `fix: harden desktop operation state and add Windows CI`.
- Both implementation commits were successfully pushed after local verification. The subsequent `build: prepare portable candidates and stabilize Windows verification` commit contains release tooling/docs, the hosted smoke-test correction and this report; its own hash is obtainable with `git log -1 --format=%H -- HOLMESKIT_TASK_02_REPORT.md` (a report cannot embed its own commit hash without circularity).
- The pre-existing untracked `HOLMESKIT_AUDIT_SUMMARY.md` is preserved untouched and unstaged. Generated packages, build output, SDK, logs and recovery fixtures are excluded from Git. Final push/hash/status are checked in the delivery response.

## 13. Recommended Next Task

Execute the documented disposable-VM apply/recover and interruption matrix, review the native adapters independently, and close any failures before a public release. Prioritize actual registry type/absence behavior, service state transitions, original-power availability, interrupted-journal handling, alternate-user elevation, lock contention and conflict races. That evidence has higher value than adding optimization features or publishing a website now.
