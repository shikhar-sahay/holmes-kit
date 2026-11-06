# Release gates

Task 05 fixes observed presentation defects and prepares an unsigned validation candidate, not a public release. A passing build/CI does not establish native recovery or complete interactive/accessibility acceptance. Historical Task 01–04 reports remain unchanged; evaluate each candidate by its own source commit and hash.

| Requirement | Task 05 gate | Evidence / remaining action |
|---|---|---|
| Release build / safe tests | PASS | Local zero-warning/error Release build; 342 passed, 0 failed/skipped |
| Hosted Windows CI | PASS | [Run 42230418681](https://github.com/shikhar-sahay/holmes-kit/actions/runs/42230418681), implementation 4d9f0db; observed zero-warning/error build and 342 passed / 0 failed / 0 skipped |
| Complete ZIP and checksums | PASS | Local packaging pipeline verified 19 files / 18 internal hashes and archive sidecar; final candidate version/hash/source-equality result in Task 05 report |
| Complete packaged-app acceptance | BLOCKED | Startup observations are recorded per exact version/hash in Task 05 report; launch alone does not certify elevated input/workflow acceptance |
| Complete interactive acceptance | BLOCKED | Elevated input boundary and shared-helper state/foreground errors; limited fixture interaction and all-page rendered review do not equal full PASS |
| Hosted candidate workflow | NOT EXECUTED | Dispatch manually if authorized tools/permissions permit; verify artifact |
| Native Windows 10/11 recovery | NOT EXECUTED | Authorized disposable VMs with checkpoint and before/after/reversion evidence |
| Alternate user, locale, policy, adapters | NOT EXECUTED | Complete matrix in WINDOWS_VM_VERIFICATION.md |
| Desktop DPI / screen reader / high contrast | NOT EXECUTED | No global settings changed; isolated actual DPI, keyboard, Narrator and high-contrast review remains required |
| Project licence | BLOCKED | Owner selects approved terms; no tracked licence file exists |
| Signing | BLOCKED for signed distribution | Candidates unsigned; disclose warnings; do not fabricate certificate |
| Safety documentation | Review per candidate | Ensure actual scope/reset limits and known failures are explicit |
| Release-blocking defects | Review per candidate | No unresolved safety regression; record independent review |
| Public release publication | BLOCKED | Owner approval after preceding gates; no automated publishing |

Record each executed scenario with environment, checkpoint, candidate hash, expected/actual outcome, diagnostics and checkpoint reversion result. NOT EXECUTED is not PASS. Preserve evidence privately; only sanitized summaries should be committed. Never publish machine-specific journals.

Current hashes, limitations and commit evidence are in the [Task 05 reviewer report](https://github.com/shikhar-sahay/holmes-kit/blob/master/HOLMESKIT_TASK_05_REPORT.md). The report remains outside the archive to avoid self-referential hashes. Distinguish direct packaged observations, mutation-disconnected fixture interaction, rendered captures, automated tests and unexecuted manual cases. Native Windows 10/11 recovery, full interactive/accessibility review, licensing and owner distribution approval remain release blockers. These gates do not authorize publication.
