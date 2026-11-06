# Disposable Windows validation and release gate

Never perform native optimization/recovery integration tests on the development workstation. Ordinary tests use temporary files, command stubs and mocked native adapters.

## Execution authorization and evidence

No suitable VM has been explicitly authorized in the Task 03 workspace. Native scenarios are **NOT EXECUTED**. A virtualization indicator is not permission. An operator must separately confirm the VM is disposable, a usable checkpoint exists, modifications are authorized, and reversion is possible. Do not run native tests on the development workstation.

On the authorized VM, capture read-only evidence before, after and after reversion, using a fresh output filename each time:

```powershell
./tools/Collect-ValidationEvidence.ps1 -CandidateZip ./artifacts/packages/HolmesKit-0.4.0-rc.3-win-x64.zip -EnvironmentLabel Win11-en-admin -CheckpointId checkpoint-name -Phase Before -OutputPath ./artifacts/before-private.json -IncludeManagedState
```

The collector never applies changes and leaves every scenario NOT EXECUTED. It records OS/PowerShell/runtime, source commit, candidate SHA-256, checkpoint label and optional managed state. Operator authorization, actual outcomes and successful reversion must be recorded separately. Managed state can contain sensitive paths/commands: never commit or upload raw evidence. It refuses to overwrite an existing file.

For each scenario, record: environment/build/locale/account, starting checkpoint, commit/version/hash, operation, expected result, actual result, PASS/FAIL/BLOCKED/NOT EXECUTED, diagnostic reference and reversion result. Use separate fresh checkpoints for interruption, access-denied, malformed journal and network reset tests; do not corrupt the only recovery evidence.

## Required environment matrix

Use current Windows 11 and an appropriately supported Windows 10 environment (document its servicing arrangement), non-English locale, policy restrictions, standard/admin accounts and alternate-administrator elevation. Test no native scenario unless that specific environment is authorized. No matrix row is considered passed merely because another row or Windows Server CI passed.

## Scenarios

Before a public release, use disposable Windows 10/11 x64 VMs with checkpoints, including a non-English installation and a policy-restricted configuration. Record exact OS build, PowerShell version, candidate version/hash, test outcome and unresolved failures. CI compilation alone is not Windows compatibility verification.

1. Checkpoint the VM. Install the unsigned candidate in an ordinary extracted folder. Keep the entire EXE/Batch/modules distribution. Do not use a protected installation directory for the MVP.
2. Seed allowlisted registry values of several supported types, including absent values. Record their existence/type/data, the active power GUID and the five managed service startup/running states. Include pre-existing legacy exports; verify those files remain byte-for-byte unchanged.
3. Verify Task 01 confirmation declines and EOF perform no modifications. Induce a journal-directory access failure; verify no engine step starts. Confirm an exclusive lock rejects a second CLI/desktop engine operation.
4. Apply one operation, repeat it, close/reopen HolmesKit, then apply a different operation through the other interface. Verify baseline ID, creation time and Before states remain unchanged. Check file integrity, After states and operation diagnostics.
5. Restore managed values/services/power. Compare actual existence/type/data and state against Before, including previously absent values. Unrelated keys/values created afterward must remain. NTFS behavior, hibernation and network resets are explicitly not exact-state recovery.
6. Change a managed value externally after optimization. Recovery must report a conflict and skip it. Verify partial outcome and retained diagnostics. Add/remove an adapter; changed recovery scope must fail closed for manual review.
7. Corrupt/truncate a copy of baseline.json, alter its identity/scope, or leave Status=Running. Verify mutation and automatic restoration are refused; preserve both journal files for review. Kill power during staging in a separate checkpoint and verify a usable prior envelope remains. Checksums are not malicious-tamper authentication.
8. During native changes, Cancel is disabled and closing the app is blocked. Read-only query cancellation remains available. Do not infer rollback from cancellation; forced termination must leave an interrupted marker and require manual review.
9. Check unavailable power plans, missing services/utilities, static IP/VPN adapters, elevated alternate-user HKCU, installer cancellation/reboot codes and application registrations changing after enumeration. Never invent a successful result for an unsupported feature.
10. Inspect all desktop pages, keyboard navigation, screen-reader names, small/default/maximized windows, high contrast and 125%/150% DPI. Capture only privacy-safe screenshots. Record startup/query time, peak working set and large-log responsiveness before claiming performance improvements.

The release workflow prepares CI artifacts only. Publish a versioned GitHub Release manually only after this matrix passes, project licensing is decided, candidate contents/checksums are reviewed, and unsigned-binary limitations are disclosed. Signing requires a real certificate. A portable ZIP is sufficient for the MVP; no installer/updater is implemented. Preserve the existing folder and its recovery data during upgrades. Removal deletes the extracted program only after recovery data is saved elsewhere; deleting files does not undo Windows changes.

A future static GitHub Pages overview may link requirements, recovery limits, source and verified downloads. Website deployment is deferred until release validation and licensing; no browser backend is needed.

## Task 05 acceptance follow-up

No disposable VM/checkpoint was separately authorized. Native mutation/recovery scenarios remain **NOT EXECUTED**. Task 05 inspected the real packaged startup/Home and used a non-elevated mutation-disconnected harness for UI review. Elevated input restrictions were not bypassed. Shared-helper active-request, foreground and observation-cache failures limited keyboard/click coverage. Rendered captures of all ten pages at supported sizes are layout evidence, not a full interactive PASS.

Before release, finish dialog Escape/Enter/close, search/sort/refresh, Copy/Reload/Clear view, fixture error/partial states, normal and maximized windows, actual 100/125/150% DPI, high contrast and Narrator checks in an isolated desktop session. Record the exact candidate SHA and distinguish fixture data from native state. Do not alter global accessibility/display settings without specific authorization, recording and restoring original settings. Never use QA baseline illustrations as actual recovery data.

## Task 04 desktop validation follow-up

Native recovery remains **NOT EXECUTED**. Task 04 adds no permission to modify this workstation. The interrupted desktop review was not resumed because the operator requested non-interactive verification only. After separate authorization, review all ten pages, expanded operation details, Cancel/Confirm/close behavior using inert fixtures, error/partial/progress states, long names/commands and empty filters. Check default, 900×620 and maximized windows at 100/125/150% scaling, keyboard-only use, screen-reader output and high contrast (including selected rows and charts). Offscreen size/layout checks do not establish these results.

Compare live CPU to an interval-based Windows counter over the same time window, and physical memory to total-minus-available from authoritative Windows sources. Expect the first CPU sample to be unavailable. Navigate away, minimize, run a fixture query and close; verify polling stops and returning creates only one fresh sampler. Check graph gaps across pauses, fixed 0–100% scale, bounded 60-second/31-sample history and no new metric logs/processes. Capacity data is a snapshot; never compare it as disk activity. Record startup/idle CPU/working set before making efficiency claims. Capture fresh privacy-safe screenshots only after review; the existing Core screenshot is historical.
