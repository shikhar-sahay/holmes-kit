# Release gates

Task 03 prepares a validation candidate, not a public release. A passing build/CI is necessary but does not prove native recovery. Historical results belong in the Task reports; evaluate every candidate against its own commit/version/hash.

| Requirement | Current Task 03 status | Required evidence/follow-up |
|---|---|---|
| Release build / safe tests | PASS | Local zero-warning build, 302 tests; see Task 03 report |
| Hosted Windows CI | PASS | [Run 42093231679](https://github.com/shikhar-sahay/holmes-kit/actions/runs/42093231679), commit fb48610, 302 tests passed |
| Complete ZIP and checksums | PASS | Local 0.3.0-rc.2: 18 files, 17 internal hashes and archive hash verified |
| Hosted candidate workflow | NOT EXECUTED | Dispatch manually if authorized tools/permissions permit; verify artifact |
| Native Windows 10/11 recovery | NOT EXECUTED | Authorized disposable VMs with checkpoint and before/after/reversion evidence |
| Alternate user, locale, policy, adapters | NOT EXECUTED | Complete matrix in WINDOWS_VM_VERIFICATION.md |
| Desktop DPI / screen reader / high contrast | NOT EXECUTED | Interactive review at 100/125/150%; construction is not visual verification |
| Project licence | BLOCKED | Owner selects approved terms; no tracked licence file exists |
| Signing | BLOCKED for signed distribution | Candidates unsigned; disclose warnings; do not fabricate certificate |
| Safety documentation | Review per candidate | Ensure actual scope/reset limits and known failures are explicit |
| Release-blocking defects | Review per candidate | No unresolved safety regression; record independent review |
| Public release publication | BLOCKED | Owner approval after preceding gates; no automated publishing |

Record each executed scenario with environment, checkpoint, candidate hash, expected/actual outcome, diagnostics and checkpoint reversion result. NOT EXECUTED is not PASS. Preserve evidence privately; only sanitized summaries should be committed. Never publish machine-specific journals.

Exact hashes, limitations and commit evidence are in the [Task 03 reviewer report](../HOLMESKIT_TASK_03_REPORT.md). These gates do not authorize publishing a public release.
