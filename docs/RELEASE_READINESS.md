# Release gates

Task 04 modernizes the desktop and prepares an unsigned validation candidate, not a public release. A passing build/CI is necessary but does not prove native recovery or visual/accessibility quality. Historical results remain in the Task 01–03 reports; evaluate each candidate against its own commit/version/hash.

| Requirement | Current Task 04 status | Required evidence/follow-up |
|---|---|---|
| Release build / safe tests | PASS locally | Zero warnings/errors; 332 passed, 0 failed, 0 skipped. Full results in Task 04 report |
| Hosted Windows CI | PASS | [Run 42137447730](https://github.com/shikhar-sahay/holmes-kit/actions/runs/42137447730), implementation 876cd17: zero-warning Release build and 332 passed / 0 failed / 0 skipped. Earlier failures are disclosed in the report |
| Complete ZIP and checksums | Recorded per candidate | Use Publish-Portable and Test-PortableCandidate for 0.4.0-rc.3; exact observed verification/hash in Task 04 report. Integrity checks do not execute the GUI |
| Hosted candidate workflow | NOT EXECUTED | Dispatch manually if authorized tools/permissions permit; verify artifact |
| Native Windows 10/11 recovery | NOT EXECUTED | Authorized disposable VMs with checkpoint and before/after/reversion evidence |
| Alternate user, locale, policy, adapters | NOT EXECUTED | Complete matrix in WINDOWS_VM_VERIFICATION.md |
| Desktop DPI / screen reader / high contrast | NOT EXECUTED | Operator kept Computer Use stopped. Offscreen binding/layout tests pass at three sizes but are not interactive visual verification |
| Project licence | BLOCKED | Owner selects approved terms; no tracked licence file exists |
| Signing | BLOCKED for signed distribution | Candidates unsigned; disclose warnings; do not fabricate certificate |
| Safety documentation | Review per candidate | Ensure actual scope/reset limits and known failures are explicit |
| Release-blocking defects | Review per candidate | No unresolved safety regression; record independent review |
| Public release publication | BLOCKED | Owner approval after preceding gates; no automated publishing |

Record each executed scenario with environment, checkpoint, candidate hash, expected/actual outcome, diagnostics and checkpoint reversion result. NOT EXECUTED is not PASS. Preserve evidence privately; only sanitized summaries should be committed. Never publish machine-specific journals.

Current hashes, limitations and commit evidence are in the [Task 04 reviewer report](https://github.com/shikhar-sahay/holmes-kit/blob/master/HOLMESKIT_TASK_04_REPORT.md). The report is kept in the source repository rather than embedded in an archive containing its own hash. Native Windows 10/11 recovery, interactive visual/accessibility review, licensing and distribution approval remain open. These gates do not authorize publishing a public release.
