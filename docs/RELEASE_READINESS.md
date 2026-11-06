# Release gates

Task 06 fixes management dispatch and read-only reliability and prepares an unsigned validation candidate, not a public release. A passing build/CI does not establish native recovery or complete interactive/accessibility acceptance. Historical Task 01–05 reports remain unchanged; evaluate each candidate by its own source commit and hash.

| Requirement | Task 06 gate | Evidence / remaining action |
|---|---|---|
| Release build / safe tests | PASS | Local zero-warning/error Release build; 382 passed, 0 failed/skipped; ten scripts parse |
| Hosted Windows CI | Verify per final SHA | Exact runs/results in Task 06 report; do not substitute an earlier commit's success |
| Complete ZIP and checksums | Verify per candidate | Fresh 0.6.0-rc.1, hashes and source equality in Task 06 report |
| Complete packaged-app acceptance | BLOCKED | Startup/read-only observations recorded per exact hash; launch alone does not certify elevated workflows |
| Complete interactive acceptance | BLOCKED | Shared helper returned unrelated Chrome screenshot for HolmesKit; input attempts stopped; construction/rendered checks are not a full PASS |
| Hosted candidate workflow | NOT EXECUTED | Dispatch manually if authorized tools/permissions permit; verify artifact |
| Native Windows 10/11 recovery | NOT EXECUTED | Authorized disposable VMs with checkpoint and before/after/reversion evidence |
| Alternate user, locale, policy, adapters | NOT EXECUTED | Complete matrix in WINDOWS_VM_VERIFICATION.md |
| Desktop DPI / screen reader / high contrast | NOT EXECUTED | No global settings changed; isolated actual DPI, keyboard, Narrator and high-contrast review remains required |
| Elevation-on-demand | DEFERRED | Startup elevation retained; authenticated helper/account/storage design required; see handbook |
| Runtime servicing | BLOCKED for public distribution | Local pinned SDK/runtime is 10.0.100 / 10.0.0; rebuild with currently serviced runtime and rerun checks before distribution |
| Project licence | BLOCKED | Owner selects approved terms; no tracked licence file exists |
| Signing | BLOCKED for signed distribution | Candidates unsigned; disclose warnings; do not fabricate certificate |
| Safety documentation | Review per candidate | Ensure actual scope/reset limits and known failures are explicit |
| Release-blocking defects | Review per candidate | No unresolved safety regression; record independent review |
| Public release publication | BLOCKED | Owner approval after preceding gates; no automated publishing |

Record each executed scenario with environment, checkpoint, candidate hash, expected/actual outcome, diagnostics and checkpoint reversion result. NOT EXECUTED is not PASS. Preserve evidence privately; only sanitized summaries should be committed. Never publish machine-specific journals.

Current hashes, limitations and commit evidence are in the [Task 06 reviewer report](https://github.com/shikhar-sahay/holmes-kit/blob/master/HOLMESKIT_TASK_06_REPORT.md). The report remains outside the archive to avoid self-referential hashes. Distinguish direct packaged observations, mutation-disconnected fixture interaction, rendered captures, automated tests and unexecuted manual cases. Native Windows 10/11 recovery, full interactive/accessibility review, runtime servicing, licensing and owner distribution approval remain release blockers. These gates do not authorize publication.

Feature connectivity is source/inert-audited across ten pages and 20 operation identifiers; see feature-parity.md. Windows 11 read-only metadata/formula checks passed on the current workstation. This is not a Windows 10/11 native compatibility matrix; hosted Server CI is not desktop acceptance. Unsupported OS releases are not promised merely because a manifest contains a compatibility GUID.

Recommendation: authorize a disposable checkpointed Windows VM, record the exact candidate SHA, and start with the narrowest reversible operation. Complete conflict/interruption/account and safe management scenarios, then stable keyboard/Narrator/DPI/high-contrast acceptance. Retained recovery remains scoped and non-transactional: network/TCP globals, NTFS and hibernation are partial/reset-only; file deletion, unsaved work and uninstalled applications are irreversible. Checksums do not authenticate mutable portable scripts or journal data against an attacker. Do not begin with Apply All or publish on the strength of fixture tests.
