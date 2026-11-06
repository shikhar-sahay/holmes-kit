# HolmesKit Task 05 — acceptance and engineering handoff

## 1. Executive summary

Task 05 fixes an observed confirmation-contrast defect, restores explicit shared styling to derived windows, improves Home wording, and corrects the Activity header's stretched Clear view action. A separate non-elevated acceptance executable reuses production WPF views while disconnecting native mutations. No optimization, restoration, startup change, uninstaller, network reset or Windows setting change was executed on the workstation.

Safe engineering verification is complete locally: **Release build: zero warnings/errors; 342 tests passed, 0 failed, 0 skipped; all ten PowerShell scripts parse**. Hosted CI, final packaging and launch observations are recorded below as they are verified. Full interactive/public-release acceptance remains **BLOCKED** by incomplete keyboard/accessibility/DPI/native-VM coverage, licensing and owner approval. Safe engineering completion is not permission to publish.

## 2. Starting Git state

Repository `shikhar-sahay/holmes-kit`, branch `master`, starting HEAD `cc5bbf751c6f93222b11e0e9840b7296d825c324`. Fetch confirmed local/remote equality. On continuation, Task 05 source/test/harness changes were uncommitted. No branch, stash, reset, rebase, clean, force-push or PR was used. The historical audit remained untracked; its SHA-256 stayed `AAF6E90C82757B59D889E694FE5842FC2D7ABC045C7039FC24F1426B8409AC3C`. Historical Task 01–04 reports are unchanged.

## 3. Interrupted-session work preserved

Retained: the explicit Window styles, dialog focus/Escape handling, Home OS/unknown-memory wording, compact Clear view DockPanel, acceptance project and mutation-isolation tests, plus private rendered evidence. Continuation reviewed the full diff and strengthened layout/dialog assertions, repaired a QA list-mode control, completed documentation and package evidence, and prepared logical commits. Existing review captures/private files were inspected rather than deleted or staged wholesale.

## 4. Confirmation defect and correction

Direct fixture interaction showed a **white confirmation window with near-white text**. An implicit style keyed for Window did not style the derived ConfirmationWindow as intended. MainWindow and ConfirmationWindow now explicitly reference the shared Window style. This also makes the base FontSize of 13 device-independent units intentional and consistent.

The corrected dialog was directly observed with a dark background, readable scope/tradeoff/restart/recovery warnings, and a visible Cancel outline. FocusManager identifies Cancel; keyboard focus is set after content rendering; Escape has an explicit preview-key decline path. Cancel remains both default and cancel action; closing/declining cannot satisfy the existing `ShowDialog() == true` authorization callback. Long details retain a read-only, scrollable text area. Native dispatch/approval semantics were not rewritten.

Automated checks assert actual derived-window background/font, Cancel/default flags, production taskbar behavior, read-only details and automatic vertical scrolling. Complete manual Escape/Enter/close/confirm interaction could not be certified because modal targeting/input became unreliable; it is not marked PASS merely because the code exists.

## 5. Dashboard wording and metric review

Home displays Windows edition concisely; full version/build/architecture remains in System Info and the Home tooltip. The system-summary column has a little more width. Unknown memory now reads “Physical memory unavailable” / “Unavailable,” replacing phrases such as “Unavailable used / Unavailable” and “Unavailable available.” The tests retain honest unknown values rather than substituting zero.

Task 04's actual `GetSystemTimes`, `GlobalMemoryStatusEx` and `GetTickCount64` sampling remains unchanged: two-second background reads, at most 31 real samples over 60 seconds, fixed percentage axes, fresh CPU baselines after pauses, nullable readings and broken long/unknown segments. Direct Home observations showed values/graphs changing. No fake history or overall health score was added.

Read-only CIM corroborated 15.6 GiB usable physical memory and the storage snapshot's 475.8 GiB capacity / about 37.3 GiB free / 92% used. Memory availability changed with workload between observations; CPU readings were not independently compared over an identical interval. Counter/formula correctness is covered by the preserved automated tests, not inferred from screenshots alone.

## 6. Activity/Logs layout

Rendered review showed Clear view filling the remaining session-header width. The cause was DockPanel.LastChildFill; explicitly disabling it keeps the action compact and right-aligned. The corrected rendered capture was inspected. Tests find the actual button, require the parent DockPanel setting, check a nonzero compact width and execute Clear on inert session output.

The new width assertion initially failed at zero because an unshown Window has no HWND and need not arrange its children. The test now explicitly measures/arranges the real content root, preserving the size assertion rather than weakening it. Existing audit-tail bounding, one-way log binding, reload/copy commands, sticky errors/partial status and mutation cancellation guards remain. A full interactive Copy/Reload/Clear workflow was not completed, and clipboard behavior is not certified.

## 7. Direct packaged-app observations

The previous Task 04 ZIP was independently verified before extraction: **18 files, 17 payload checksums**, archive SHA-256 `44BF4A7187DB0F724781BE6E44EBC8A646A306BFE5C1173F4D9ABE546A97F07A`. It was extracted into a fresh ordinary folder containing spaces. The executable launched; Home appeared, real system/power/storage data loaded, CPU/memory graphs updated, and no startup error dialog appeared.

The packaged application requests administrator privileges. The review helper could observe its elevated window but could not reliably deliver input across that integrity boundary. No UAC/security workaround was introduced. This establishes startup/Home evidence for **0.4.0-rc.3**, not full packaged-app interaction or final Task 05 launch. Final candidate evidence is recorded separately below.

## 8. Non-elevated acceptance harness

`tests/HolmesKit.Desktop.Acceptance` is a small WPF test executable, included in solution builds and excluded from product publishing. It loads the real styles/MainWindow/ConfirmationWindow and native read-only telemetry. `AcceptanceService` delegates only system-info, startup-list and application-list reads; example management lists are the default. Every modifying service method returns an explicitly labelled inert result without invoking its native counterpart.

Fixture controls select sizes, example/real read lists, slow/failing reads, inert failure/partial outcomes and UI-only baseline illustrations. F12 hides controls. List mode changes require Refresh on the selected page. Test logs/captures/journals are separate private QA state. The illustrative journals are not valid recovery-engine baselines and must never be copied to production backup directories. Fixture dialogs expose a taskbar window for QA-tool targeting; production dialogs remain owned/taskbar-free.

An initial harness-only Owner assignment before showing the owner window caused startup failure; the Owner assignment was moved to Loaded. Subsequent fixture startup succeeded. This was not a production startup failure.

## 9. Isolation and functional evidence

Ten new test cases verify that all three mutation methods (operation/restore, startup toggle, uninstall), under success/failure/partial fixture results, never delegate to a rejecting native service, and that real mode delegates only the three reads. Existing confirmation/backup-gating, conflict/recovery, filtering/sorting identity and command-boundary tests remain enabled. No destructive leaf is used for review.

Direct fixture observations established Home/Core navigation, dark confirmation rendering, visible focus outline, and Startup rows with protected actions disabled, long commands trimmed and full values in tooltips. The shared desktop helper subsequently reported active requests, lost observation/screenshot state and foreground changes. Repeated input retries were stopped. Search typing, sorting clicks, every refresh, dialog keyboard/close outcomes, actual row actions, Copy and full error/partial interaction remain incomplete. Automated fixture checks do not convert these into manual PASS results.

## 10. Page-by-page visual findings

All ten pages were inspected as real WPF rendered captures; these are distinct from click-by-click acceptance. Private evidence lives under ignored `artifacts/task05-rendered*`.

| Page | Observed review / disposition |
|---|---|
| Home | Direct packaged/fixture and rendered review; live samples, unknown first CPU, labelled capacity, custom-plan details. OS text shortened; metadata still available. Recent activity may require scrolling at compact size. |
| Core | Direct fixture/rendered review; clear separated rows, risks visible, Review accessible. Confirmation contrast fixed. Compact capture wraps descriptions and scrolls remaining operations. |
| Advanced | Rendered review; six actions and details retained, vertical scrolling needed; no optimization executed. |
| Gaming | Rendered review; three existing workflows and tradeoffs readable; no added claims or actions. |
| Apply All | Rendered scope/order and disruptive-change warning remain explicit; no action executed. |
| Startup | Direct fixture/rendered review; example rows, protected disabled action, long-command trimming/tooltips. Full manual filtering/sorting remains open. |
| Applications | Rendered fixture review; publisher/version/unknown size and deliberate uninstall controls. No native uninstaller invoked. |
| System Info | Rendered default/wide review; grouped hardware, raw-data-derived units, custom-plan details and capacity table. Private machine identity captures not committed. |
| Restore | Rendered missing-baseline state with disabled managed actions and explicit reset/conflict limits. Ready/interrupted illustrations exist for follow-up, not native recovery evidence. |
| Activity & Logs | Rendered empty/audit state; stretched Clear view corrected and checked. Output remains bounded; interactive clipboard/error/partial acceptance open. |

Some transient capture frames appeared top-cropped; measured title positions were consistently 24 DIP, and live Startup showed the proper inset. This was not treated as a proven production margin defect. No speculative redesign was made.

## 11. Screenshot evidence and privacy

`docs/screenshots/desktop-core-task05.png` is an inspected, current capture of the actual WPF Core content rendered in the inert harness, not a fabricated/mock UI or proof of native operation execution. README captions identify that evidence class. It contains no machine name, user path, installed-app data, journal or credential. The older screenshot is preserved. Home/System Info/raw desktop captures and identity-bearing QA state are not staged. A blank unshown-dialog bitmap was rejected as publication evidence; direct desktop observations support the dialog findings instead.

## 12. Accessibility, DPI and performance

Implemented/preserved: visible focus, named search/table/actions, protected disabled controls, chart text equivalents, default Cancel, read-only scrollable diagnostics and textual warning/error states. Actual Narrator/screen-reader testing, comprehensive keyboard order, OS high contrast and actual 100/125/150% DPI are **NOT EXECUTED**. No global display/accessibility setting was changed. Size checks at 900×620, 1120×760 and 1600×900 are not DPI acceptance; maximized interactive review remains incomplete.

One modest read-only performance observation used the packaged **Task 04** Home process, already showing live data: five consecutive roughly two-second samples of process CPU time and working set, with CPU normalized by elapsed wall time and logical processor count. CPU ranged **0–0.0649% of total CPU capacity**, mean approximately **0.0516%**; working set stayed **378.9 MiB** in that short window. Other desktop activity was present. This is not a controlled benchmark, memory-leak test, private-memory measurement or Task 05 improvement claim. Startup latency could not be separated from helper polling/initial queries. Long-run, resize/navigation and chart-redraw profiling remain open; no unsupported efficiency claim is made.

## 13. Native Windows validation

**NOT EXECUTED.** No specific disposable Windows VM, checkpoint, mutation permission or reversion procedure was supplied. Virtualization/cloud pages in another desktop session were not treated as authorization. Native apply/recovery/type/absence/service/power/conflict/interruption/lock/locale/account scenarios remain release blockers under the existing VM checklist.

## 14. Final automated verification

Local final implementation: **Release build PASS, 0 warnings/errors; full safe suite PASS, 342 passed / 0 failed / 0 skipped; PowerShell parser PASS for all ten module/tool scripts**. The rendered-review mode separately passed its construction/binding test in approximately 15–16 seconds and produced all-page, compact Home/Core and wide System Info captures. Assertions cover actual derived-window theme/font, dialog flags/details, dashboard unknown wording and compact Clear layout. Existing 332 tests were retained, with ten additional harness-isolation cases.

The final implementation did not suppress dispatcher exceptions, remove assertions or raise timeouts. The temporary zero-width test failure and harness Owner failure were diagnosed and corrected before committing the fixes. Native optimization/VM integration tests were not executed and are not included in the pass count.

## 15. Hosted CI

**PASS:** implementation SHA `4d9f0db46a15d3ec444d32810da23441ecbc3951`, [Windows verification run 42230418681](https://github.com/shikhar-sahay/holmes-kit/actions/runs/42230418681). Observed completed/success status and inspected Windows Server 2025 job logs: restore/build succeeded with **zero warnings/errors; 342 passed, 0 failed, 0 skipped**, test duration 42 seconds. This workflow builds the QA host but does not interactively run it or validate native recovery. Hosted server CI is not a Windows 10/11 desktop compatibility matrix.

## 16. Final portable candidate

**PASS:** final candidate `artifacts/packages/HolmesKit-0.5.0-rc.2-win-x64.zip`, **59,126,156 bytes**. Existing publishing/verifying tools passed, then the verifier was run independently again: **19 files, 18 internal checksums, archive sidecar verified**. All **16 source-backed payloads** matched the current engine/modules/documents/images byte-for-byte. The entry list contains only the product executable, Batch, seven PowerShell modules, allowlisted documentation/screenshots, version and checksum files. No backups, journals, logs, QA executable/state, PDBs, tests, SDK, secrets or machine-specific files are included.

- Archive SHA-256: `3A31F4EC139A6B076199E6C5BCE4C20A6618BC6B1829DE21DF6DE5AAEB21BB28`.
- EXE SHA-256: `42F955F7264E068A90802DF23431F2FB4E6267A9208B43F955FE9FAD914C1068`.
- ProductVersion: `0.5.0-rc.2+4d9f0db46a15d3ec444d32810da23441ecbc3951`; FileVersion `0.5.0.0`.
- Authenticode: **NotSigned**. Hashes establish integrity, not publisher identity.

The final ZIP was extracted to a fresh ordinary temporary folder outside the repository, containing spaces. A single supported launch/observation check opened the actual final executable and displayed the dark Home, navigation and initial loading/unknown states without a startup error dialog. A subsequent read-only snapshot showed loaded Windows/system identity, custom power-plan details, storage capacity, uptime, available-memory text and populated live CPU/memory values/histories. This is direct startup/Home evidence for the exact rc.2 EXE above. Full elevated input/confirmation interaction was not retried or inferred from the fixture. The helper chooses launch working-directory details; no specific CWD is claimed. Executable-relative resolution from an external extracted folder was observed. Private machine-specific launch screenshots were not committed.

The preliminary 0.5.0-rc.1 package passed integrity checks but is superseded by rc.2 with finalized documentation. Both remain ignored local artifacts, not GitHub Releases. Compiled WPF resources are in the product assembly; no new runtime UI dependency is added. Archive timestamps/SDK differences preclude bit-for-bit reproducibility claims. The source reviewer report is excluded from the archive to avoid a self-referential checksum and is linked from packaged release documentation.

## 17. Hosted packaging

**NOT EXECUTED.** No enabled direct workflow-dispatch operation or authenticated `gh` CLI was available. No permissions were bypassed or credentials extracted. HANDBOOK gives the exact operator path: Actions → Prepare unsigned portable candidate → Run workflow → master → fresh version, download `unsigned-portable-candidate`, verify its product ZIP and compare payloads to the run's source SHA. This creates an Actions artifact, not a GitHub Release. Local packaging does not establish hosted packaging success.

## 18. Documentation changes

README now explains the observed fixes, limited acceptance evidence, current screenshot and new candidate commands. HANDBOOK documents the isolated QA service/controls, private fixtures, style/focus/layout changes, offscreen root measurement and operator packaging steps. Feature parity records unchanged operations and evidence boundaries. The VM checklist records the remaining UI/keyboard/DPI/recovery work. RELEASE_READINESS separates package launch, fixture interaction, rendered review, safe tests and unexecuted gates. Historical Task 01–04 reports are unchanged.

## 19. Release-readiness assessment

| Gate | Status | Evidence | Remaining action |
|---|---|---|---|
| Release build / safe tests | PASS | Local 342/0/0, zero build warnings/errors | Review final hosted evidence |
| Hosted CI | PASS | Implementation run above; 342/0/0, zero-warning/error build | Monitor final documentation push as well |
| Final package integrity/layout | PASS | rc.2, 19 files / 18 checksums, 16 source comparisons | Independent recipient verification |
| Packaged startup/Home | PASS | Exact final rc.2 opened externally, loaded real metadata and live charts without error dialog | Does not certify full elevated interaction |
| Complete packaged interaction | BLOCKED | Elevated input boundary preserved | Isolated operator acceptance without security bypass |
| Fixture / rendered visual review | PASS | Limited stated direct scope and all ten rendered pages | Complete remaining click/keyboard scenarios |
| Full keyboard, screen reader, actual DPI/high contrast | NOT EXECUTED | No global settings changed | Authorized isolated desktop matrix |
| Native Windows recovery/compatibility | NOT EXECUTED | No authorized disposable VM | Checkpointed Windows 10/11 matrix |
| Hosted candidate workflow | NOT EXECUTED | Dispatch tooling unavailable | Operator steps in handbook |
| Licence | BLOCKED | No owner-selected licence | Owner decision; do not infer reuse rights |
| Signing | BLOCKED | NotSigned; no signed-distribution claim | Actual certificate/policy or approved unsigned disclosure |
| Public release / website | BLOCKED | No release/tag/site published | Owner approval after preceding gates |

Recommendation: **do not publish a public release yet**. The safe UI engineering work can be handed off while these manual/native/owner gates remain explicit.

## 20. Modified files

- `src/HolmesKit.Desktop/{MainWindow.xaml,ConfirmationWindow.xaml,ConfirmationWindow.xaml.cs,ViewModels/DashboardViewModel.cs}`: focused presentation/focus/wording corrections; no backend changes.
- `tests/HolmesKit.Desktop.Acceptance/{HolmesKit.Desktop.Acceptance.csproj,Program.cs,AcceptanceService.cs}`: separate inert QA host.
- `tests/HolmesKit.Desktop.Tests/{AcceptanceSafetyTests.cs,MainWindowConstructionTests.cs,DashboardTests.cs,HolmesKit.Desktop.Tests.csproj}` and `HolmesKit.slnx`: guard/layout/theme tests and build integration.
- `tools/Publish-Portable.ps1`, `docs/screenshots/desktop-core-task05.png`: explicitly included, inspected documentation image.
- `README.md`, `docs/{HANDBOOK.md,feature-parity.md,WINDOWS_VM_VERIFICATION.md,RELEASE_READINESS.md}` and this report: verified scope/results and remaining gates.

## 21. Commits and push

1. `0f0ba3f` — `test(gui): add mutation-disconnected desktop acceptance harness`.
2. `4d9f0db` — `fix(gui): correct confirmation contrast and compact utility layout`.

Implementation commits were pushed directly to origin/master, without force. The documentation/report commit follows them; its own SHA is available in Git history/final handoff rather than self-embedded. Final local/remote equality and working-tree state are checked after that push. Expected only untracked file: the unchanged historical audit. No private evidence, journal, log, generated package, SDK or secret is staged.

## 22. Outstanding risks and next task

Complete desktop acceptance in a single, stable authorized session: keyboard/default-focus/Escape/close/confirm with inert actions; management search/sort/refresh; copy/reload/clear; error/partial/empty/loading states; normal/minimum/maximized windows; actual DPI, high contrast and Narrator. Then run the separately authorized disposable-VM native recovery matrix with recorded candidate hash and checkpoint reversion. Do not add optimizations or start another redesign before closing those gates. Existing non-transactional/partial/reset-only recovery and signing/licensing limitations remain; Task 05 does not solve them or authorize public distribution.
