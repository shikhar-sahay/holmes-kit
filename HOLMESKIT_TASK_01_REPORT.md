# HolmesKit Engineering Task 01 — Reviewer Handoff

Date: 5 November 2026. Branch: `master`.

## Implementation summary

Task 01 repairs confirmation enforcement and checked prerequisite propagation while retaining the Batch engine, allowlisted dispatcher, PowerShell management scripts and WPF interface. It does not redesign backup retention or restoration.

Implementation and regression commit: **`e65a5a6a83f9ab74334aba8108fb34285bfd138d` — `fix: enforce confirmation and backup gates`**. This handoff and README are delivered in the subsequent `docs: clarify operation safety and recovery limits` commit. Its hash can be obtained with `git log -1 --format=%H -- HOLMESKIT_TASK_01_REPORT.md` after checkout; a report cannot include its own commit hash without a circular reference.

The starting checkout matched `origin/master` at `1f9a217`. Remote references were fetched before editing and before committing; no fast-forward was needed. The existing untracked `HOLMESKIT_AUDIT_SUMMARY.md` was preserved without modification or staging. No branch, pull request, packaging or Windows configuration changes were made.

## Root causes and resulting behavior

1. **Ungrouped confirmation chains:** CMD applied `IF` only to the first command before `&`. Later modification calls and menu jumps executed outside that condition. Every Core, Advanced and Gaming menu action now calls a small authorization-consuming helper. It checks a fresh affirmative flag, clears it before dispatch and uses the existing operation allowlist. Restore actions obtain confirmation through the same path. Apply All retains a single confirmation.
2. **Stale/failed input:** confirmation and menu input variables are cleared before reading. Only exactly `Y` or `y` authorizes a change. Declined, invalid, blank and unavailable input fail closed; EOF cannot reuse a previous answer. Menu EOF exits rather than looping on a stale selection.
3. **Backup/failure propagation:** expressions such as `call :step || exit /b !errorlevel!` could expand the previous exit code before the step ran. Explicit subsequent `IF ERRORLEVEL 1` checks now stop dispatch/composite sequences. Failed backup creation never enters their protected operation bodies. Existing backup format/location and intended Apply All order remain intact.
4. **Backup helper:** inability to remove/replace the existing backup directory fails closed. Registry query failures are checked through an error-aware, locale-independent provider lookup before recording an absent key; access errors cannot silently become absence. Export failures and absence-manifest write failures mark the prerequisite failed. This remains the existing limited registry backup, not exact-state protection.
5. **Related results:** temp cleanup aggregates failures while attempting independent paths, startup pruning distinguishes missing values from access/deletion failures, background cleanup treats absent processes separately from other termination failures, and Explorer/composite failures propagate. The unconditional generic CLI “Done” success wording was removed. Partial operation errors do not trigger automatic rollback.
6. **Management entry points:** CLI startup toggles and uninstaller launches now require an explicit fresh affirmative answer. Protected startup entries remain blocked.
7. **Desktop compatibility:** WPF retains its own dialog and Batch `--run` never reads console confirmation. Failure exit codes reach the existing GUI failure path. A real process-boundary test exposed incorrect generic argv escaping for CMD commands containing quoted paths; an optional raw command-line field now preserves CMD's `/d /s /c` quoting. PowerShell continues to use `ArgumentList`. GUI wording distinguishes recovery from backup prerequisites and discloses limited recovery.

`--run` is an automation interface for an already-authorized caller, not a security boundary proving that a human approved a dialog. Direct CLI users should use the interactive menus.

## Changed files

| File | Purpose |
|---|---|
| `HolmesKit.bat` | Confirmation/input gates, restore approval, shared dispatch, prerequisite checks, narrowly related error/result handling and safety wording |
| `modules/apps_mgr.ps1` | Confirm uninstaller launch; avoid unconditional success wording |
| `modules/startup_mgr.ps1` | Confirm independently selected startup changes |
| `src/HolmesKit.Desktop/Services/HolmesKitCommandService.cs` | Construct CMD-specific command line |
| `src/HolmesKit.Desktop/Services/ProcessRunner.cs` | Optional raw arguments for CMD; preserve ordinary argv handling |
| `src/HolmesKit.Desktop/ViewModels/MainViewModel.cs` | Accurate confirmation/prerequisite messages |
| `tests/HolmesKit.Desktop.Tests/CliSafetyTests.cs` | Behavioral CMD menu/dispatcher/backup/sequence tests |
| `tests/HolmesKit.Desktop.Tests/GuiAuthorizationTests.cs` | GUI declined/approved failure paths with fake execution |
| `tests/HolmesKit.Desktop.Tests/ManagementConfirmationTests.cs` | Actual approval and registry-error fragments with mocked input/cmdlets |
| `tests/HolmesKit.Desktop.Tests/CommandServiceTests.cs` | Real process service against a harmless temporary Batch failure stub |
| `README.md` | Behavior, safe test command and recovery limitations |
| `HOLMESKIT_TASK_01_REPORT.md` | This reviewer handoff |

## Verification and isolation

Final Release build succeeded with **zero warnings and zero errors**. Final complete suite: **260 passed, zero failed, zero skipped** (36 existing cases plus 224 added cases). Commands:

```powershell
dotnet build HolmesKit.slnx -c Release
dotnet test HolmesKit.slnx -c Release --no-build
```

Verification used the repository-local .NET SDK. The optional visual-review environment variable was cleared. No privileged integration test or real modification was performed.

The CMD fixture copies explicitly selected real control-flow labels, removes presentation commands and replaces every native operation body with inert marker/exit stubs. It asserts that prohibited native commands cannot remain in the copied control flow. Menu cases cover all twenty initiating paths with Y/y, N/n, blank, invalid, hostile characters and EOF while preloading stale answers. Positive paths assert the intended operation marker. The authorization-consumption test rejects a second independent dispatch. Backup failure is exercised through both interactive and GUI dispatch paths; Apply All partial failure prevents later steps and returns failure.

Two tests retain actual backup orchestration but point its directory at a unique temporary fixture and replace exports with success/failure stubs. They do not export registry data. PowerShell fragment tests replace Get-Item and Remove-ItemProperty with mocks to check exists/missing/access-denied behavior. Management prompt tests execute only the selection/approval fragment with mocked Read-Host; native mutation code is excluded. GUI tests use a fake process runner; the real process test runs an echo/exit-only Batch file in a temporary path containing spaces.

Intermediate test failures exposed fixture presentation filtering, CMD quoting and pipe-input handling; these were corrected. The real CMD boundary test initially failed against production quoting, then passed after the launch fix. All final verification passed. Diff checks used `core.whitespace=cr-at-eol` to respect the existing CRLF Batch file and its `-text` attribute. No generated binaries, temporary fixtures or machine-specific state are included in the commits.

## Unresolved risks and review focus

- Later Batch sessions still replace `HolmesKit_Backups/latest`, including successive desktop operations. A failed replacement can lose the earlier baseline. Snapshot retention, atomic replacement and concurrency locking are deferred.
- Registry imports merge values; restore may leave added values or overwrite later user changes. Absent-key handling and restore-data integrity still need broader hardening. Power/network/hibernation recovery applies defaults and may remove custom configuration.
- Deleted files and unsaved application state cannot be recovered from registry backups. Network resets and service operations remain disruptive.
- Cancellation still terminates a process tree rather than providing transactional rollback. Earlier successful steps may remain applied after failure or cancellation.
- This task does not comprehensively validate every native operation's outcome, startup approval format, uninstaller parser, or Windows-policy variation. Some existing native errors remain suppressed outside the targeted helpers.
- Stubbed tests establish gate behavior and failure propagation, not real Windows modification correctness. Real apply/restore and compatibility verification belongs on disposable snapshot VMs.

Independent review should inspect `run_confirmed`, the dispatcher/composite `IF ERRORLEVEL` checks, confirmation input clearing, backup error/absence handling, CMD quoting, and the test fixture's isolation boundary before approving wider release work.
