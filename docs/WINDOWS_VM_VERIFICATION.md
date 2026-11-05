# Disposable Windows validation and release gate

Never perform native optimization/recovery integration tests on the development workstation. Ordinary tests use temporary files, command stubs and mocked native adapters.

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
