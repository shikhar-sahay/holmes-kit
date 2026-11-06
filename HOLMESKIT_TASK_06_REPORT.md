# HolmesKit Task 06 — functional hardening and release handoff

## 1. Executive summary

Task 06 audited the existing ten-page WPF application, all 20 optimization/recovery IDs, CLI menus, management scripts, process/JSON boundary and recovery lifecycle. Focused fixes address genuine broken uninstall transport, argument-free uninstallers, stale startup authorization, empty/malformed management data, deferred page loading, cancellation classification and missing diagnostics. The matte-black design, confirmations, allowlisted engine, retained recovery baseline and standalone CLI are preserved. No new optimization or generic elevated execution channel was introduced.

Safe engineering verification passes locally: Release build **0 warnings / 0 errors**, full suite **382 passed / 0 failed / 0 skipped**, ten PowerShell scripts parse. This is 40 additional cases above the 342-test Task 05 baseline. Native system changes were **NOT EXECUTED**. No authorized disposable VM/checkpoint was available. Full interactive/accessibility, runtime servicing, owner licensing/signing/distribution and native recovery gates remain open. This is a validation candidate, **not production certification**.

## 2. Starting repository and preserved work

Started on `master` at `47466a7fed0d394bae4e5eb44b58d97e2da2268d`; origin is `https://github.com/shikhar-sahay/holmes-kit.git`. Fetch confirmed local/remote equality, with no tracked modifications. The sole untracked historical audit was preserved byte-for-byte (SHA-256 `AAF6E90C82757B59D889E694FE5842FC2D7ABC045C7039FC24F1426B8409AC3C`). No branch/PR, reset, clean, stash, rebase, force push or history rewrite was used. Task 01–05 reports remain historical evidence.

## 3. Feature audit and execution trace

The detailed inventory in `docs/feature-parity.md` records every exact ID/Batch label and all ten pages. Common operation route: Review → `MainViewModel.RunOperationCommand` → affirmative owned dialog → `HolmesKitCommandService.RunOperationAsync` → `ProcessRunner` → Batch `--run` allowlist → `recovery.ps1 Execute` → protected engine label. CLI menus require fresh Y/y before the same route. Tests stub native leaves; a connected button is not proof of native behavior.

| Area | Actual capability and audit result | Validation boundary |
|---|---|---|
| Home | Real kernel CPU/memory, bounded histories, system/power/storage snapshot, navigation and baseline summary | Read observations, formula/lifecycle fixtures; full interaction blocked |
| Core | Full Core, temp/cache cleanup, High Performance, closing established background-app list | Four IDs mapped; confirmation/backup/exit fixtures; native NOT EXECUTED |
| Advanced | UI/NTFS, visual effects, startup pruning, networking, three services, hibernation | Six IDs mapped; checked failures/scoped recovery; native NOT EXECUTED |
| Gaming | FPS, latency, combined prep | Three IDs mapped; composite/restart/reset tradeoffs preserved; native NOT EXECUTED |
| Apply All | Existing ordered component sequence, one confirmation and prerequisite gate | Inert decline/backup/partial-failure tests; no native Apply All |
| Startup | Registry/RunOnce and logon/boot tasks; filter/sort/refresh/protection; confirmed row identity | Fresh state check fixed; inert exact-target/protection/CLI tests; no native toggle |
| Applications | Registered MSI/EXE uninstall entries, metadata/filter/sort/refresh, confirmed registered identity | Transport/no-argument defects fixed; inert process/exit fixtures; no real uninstaller |
| System Info | CIM hardware/OS/memory/storage, structured power GUID/name, active adapter filtering | Current Windows 11 read-only comparisons PASS; other builds unverified |
| Restore | Three managed categories plus hibernation/network resets and Explorer restart | Missing/legacy/invalid/interrupted/conflict/partial fixtures; native NOT EXECUTED |
| Activity & Logs | Bounded audit tail/session output, reload/copy/open folder/clear view | Construction/tail fixtures and source audit; full interactive clipboard NOT EXECUTED |

Apply All keeps its existing order: cleanup, power, close apps, UI/NTFS, visuals, startup pruning, services, hibernation, FPS, latency. Some components repeat inside FPS. It does not secretly invoke the separate network-maintenance IP lease sequence. All engine paths require admin and backup/journal prerequisites, except the documented independent reset/session actions. Error exits stop checked dependent steps; earlier changes can remain. Normal mutation cancellation/close remains disabled.

## 4. Defects found and corrected

| Severity | Confirmed defect | Correction / evidence |
|---|---|---|
| P1 | Desktop uninstall sent `-Data encodedCommand encodedName`; native Windows PowerShell `-File` bound only the first value, so required name was absent | Named scalar `-NameData`; direct PowerShell array callers remain compatible. Real process test uses the actual bridge parameter block plus an inert body; Unicode/quotes/spaces preserved |
| P1 | Bridge re-enumerated startup state and then toggled it, potentially reversing the user's reviewed action after an external state change | `Resolve-HolmesStartup` requires unique identity, current protection and the reviewed Enabled/Disabled state; stale requests fail before writes |
| P2 | Valid EXE uninstall registrations without arguments passed empty `ArgumentList`, rejected by Start-Process | Validated helper omits empty arguments; actual dispatch tested with stubbed process for EXE/MSI/cancellation/restart/failure |
| P2 | CLI management used divergent, less conservative native paths | Existing confirmed CLI actions now call the shared bridge; menus and standalone PowerShell use preserved; unsupported registrations require Windows Settings |
| P2 | Empty application enumeration could serialize `[null]`; null identities/optional strings could break filtering or create unusable rows | Emit `[]`; reject malformed/null identities and storage rows, normalize optional search text without inventing an action target |
| P2 | Selecting a lazy management page while another query was busy could leave it unloaded until navigation away/back | Queue selected-page loading on busy completion, after command running flags release; actual WPF Loaded/selection/busy regression for both pages |
| P2 | Cancelled read bridge result became generic failure; slow reads had no deadline | Preserve cancellation category; 60-second read deadline, distinct timeout failure; no timeout/cancellation imposed on mutations |
| P2 | Startup/uninstall stdout-only errors lost details; opening log folder could throw out of command handler | Preserve stdout/stderr and diagnostic-free exit fallback in Activity; handle shell/access failures |

No new P0 bypass was confirmed in the reviewed engine paths. This is a scoped engineering review, not proof of absence of security defects. The parameter-binding defect was missed by earlier fixtures because they set `$Data` inside PowerShell rather than crossing the native `-File` boundary. New coverage specifically crosses that boundary without executing the action switch.

## 5. Privilege architecture decision

**Elevation-on-demand DEFERRED; startup elevation retained.** `app.manifest` still uses `requireAdministrator`, `uiAccess=false`; CLI checks/relaunches for admin. Kernel metrics/CIM/user reads generally do not need elevation. HKLM/task/service/network operations do; enumeration may be restricted unelevated. Declining startup UAC prevents startup; no in-app denial flow is claimed. Alternate credentials target the elevated account's HKCU and journal identity, not automatically the original interactive user.

Simply changing the manifest or adding `runas` would lose reliable stdout/error transport and leave account/storage security unresolved. A bounded next design needs authenticated same-user IPC, explicit allowlisted operation IDs, request correlation/replay rejection, trusted helper and adjacent-script validation, protected journal/result ACLs, correct lock/lifetime ownership, denial reporting and conservative alternate-account rejection. No arbitrary command endpoint, credential extraction, UAC bypass or environment-marker trust was added. Existing engine markers coordinate internal children; they are not a security API against code already running as the same/elevated user. The portable directory remains trusted executable content.

## 6. Recovery and safety review

The unchanged `modules/recovery_core.ps1` stores value existence/type/data, supported service startup/delayed/running states and active power GUID. Original Before states persist across repeat operations. Staged same-volume publication and preceding envelopes prevent replacing the baseline with an unverified write. Checksums detect corruption, not malicious rewriting. Full scope/machine/elevated-user validation, exclusive engine lock, active-operation matching and conservative interrupted-state blocking remain intact. Existing orchestrator fixtures replace native adapters and cover retention, corrupt data, locking, failed staging and child coordination.

Recovery skips external conflicts and verifies supported writes; exit 4 means partial recovery. Legacy exports remain preserved and cannot be silently imported. Missing/legacy/invalid/interrupted UI states disable managed restore; ready UI is preliminary and the engine revalidates. Network/TCP globals, NTFS and hibernation are partial/reset-only. File deletion, app uninstall, terminated unsaved work and all Windows configuration are not generally recoverable. Services do not capture every dependency/ACL/trigger/paused-state detail; missing power schemes cannot be recreated. Another program can race validation/write. Copies of the portable folder have independent lock/state; there is no machine-wide transaction or authenticated recovery store. Forced termination/power loss is not rollback. No native recovery correctness was inferred from fixtures.

## 7. Desktop, dashboard and data evidence

The current read-only bridge was compared with CIM and the active power registry value: Windows edition/build/architecture, CPU physical core sum, power GUID and memory total matched; memory used/percent and every returned disk used/percent formula were correct; diagnostics count was zero. The current plan remains legitimately Custom, with its exact name available; it was not replaced or special-cased. C# formatting retains rounded percentages, sensible binary-size units, compact uptime and nullable unavailable states. Culture, malformed-data and telemetry tests remain enabled. This is one Windows 11 workstation observation, not a population benchmark.

The non-elevated, mutation-disconnected harness launched with the real views/styles and read-only data. Its accessibility tree showed current metadata, real CPU/memory values and named chart equivalents. The shared helper simultaneously returned an unrelated Chrome screenshot. Input attempts stopped; no focus/security workaround or unrelated app interaction followed. A first framework-dependent harness launch requested a missing global runtime; no installation was performed. A separately built self-contained QA host launched successfully. This harness is excluded from product packaging.

All ten current pages and minimum/default/wide variants were generated through the existing rendered-review mode and inspected as real WPF content: Core/Advanced/Gaming operation rows, Apply All disclosure, Startup protected rows/long paths, Applications unknown metadata, System Info capacity, missing-baseline Restore and compact Activity header remained present. Some captures show composition/cropping artifacts despite recorded 24-DIP title offsets; no speculative product-layout fix was made from those frames. The unshown confirmation bitmap is blank and rejected as visual evidence. Actual dialog dark style/font/default Cancel/scrolling/bindings remain tested; Task 05's direct dialog observations remain historical, not a new interactive PASS.

No new screenshots were committed: current Home/System Info/private QA captures contain machine identifiers. The existing privacy-reviewed Core image remains. Search/sort/row identity, empty views and failures have automated inert coverage; complete click/keyboard, Enter/Escape/window-close, Copy, maximize and scrolling acceptance remains incomplete. Construction and binding tests cannot prove visual or accessibility quality.

## 8. Accessibility and Windows compatibility

Actual Narrator/screen-reader, complete keyboard order, OS high contrast and 100/125/150% DPI: **NOT EXECUTED**. No global display/accessibility settings changed. Existing automation names, focus styles, chart text equivalents, warning labels and Cancel-default behavior remain. Resizing to 900×620/1120×760/1600×900 is layout evidence, not DPI acceptance.

Windows 10/11 x64 remain target families, restricted to supported editions/builds and current .NET servicing; the Microsoft OS matrix is linked in the handbook. Current read-only Windows 11 data worked. Windows 10/native compatibility, alternate-account, managed-policy, locale and adapter changes are **NOT EXECUTED** natively. Hosted Windows Server CI establishes safe build/test compatibility only. No x86/ARM-native or universal Windows support claim is made.

## 9. Performance and reliability

No controlled Task 06 startup/CPU/memory/long-run benchmark was performed. Source/test evidence: one background 2-second Home sampler; bounded 31-point/60-second history; pause on inactive/minimized/busy and disposal on close; bounded off-thread log tail; asynchronous process reads. No third-party UI framework, animation or polling expansion was added. Read deadlines stop hung query children only. Mutations may wait indefinitely for an unresponsive native tool/uninstaller; automatic termination would be unsafe. Measure startup separately from UAC/query time, query latency, idle/active CPU, working set, chart redraw and large-table responsiveness before optimizing or claiming gains.

## 10. Automated verification

Final local implementation: **Release build PASS, 0 warnings / 0 errors; full safe suite PASS, 382 passed / 0 failed / 0 skipped; PowerShell parser PASS, all ten scripts**. Rendered-review construction/binding mode separately passed (one test, about 12 seconds). New coverage adds malformed/null data, empty enumeration, stale startup state, CLI shared dispatch, no-argument uninstall, MSI/EXE exit outcomes, actual native parameter binding, missing executables, pre-cancelled reads, query deadline and management diagnostics. The existing WPF test adds deferred-page event assertions; no assertions removed or timeout increased.

During development one empty-list regression initially failed because its test helper combined PowerShell first-use progress CLIXML with JSON. The helper now mirrors production's `ProgressPreference=SilentlyContinue`; the exact `[]` assertion remains. Subsequent complete runs passed. No native registry/service/network/power/startup/uninstaller operation was used by tests. A sleeping child is the only real process timeout target. These results do not include VM mutation tests.

## 11. Hosted CI and candidate verification

Implementation commit: `1a17531b1d58fc7da2d19d904840b30dd2cb66af` — `fix: complete management dispatch and read-only reliability`. Hosted run: https://github.com/shikhar-sahay/holmes-kit/actions/runs/42236550582. Final observed result and candidate checksums are recorded in the verification addendum below; an in-progress run is not counted as PASS.

Hosted packaging is **NOT EXECUTED**: enabled GitHub tools were inspected and provide observation/rerun but no dispatch operation; authenticated `gh` is absent. No credentials or permissions were bypassed. HANDBOOK gives operator steps for the existing manual candidate workflow. It creates an Actions artifact only, not a public Release. No duplicate verification run was started.

## 12. Licensing, servicing and release readiness

No owner licence selected; no licence file inserted. MIT, Apache-2.0, GPLv3 and proprietary decision consequences/source terms are linked in HANDBOOK. Candidate remains unsigned; hashes establish integrity, not publisher identity. No SmartScreen bypass, fabricated signature, installer/updater, public Release/tag or website was created. Local pinned SDK/runtime is **10.0.100 / 10.0.0**; this is an additional public-distribution servicing gate. Rebuild with a currently serviced SDK/runtime and rerun candidate/native validation before approval; no specific vulnerability or vulnerability-free claim is made.

Safe engineering can be handed off with explicit external blockers. Native VM, full desktop/accessibility, supported Windows matrix, runtime servicing, licensing and owner approval remain **BLOCKED / NOT EXECUTED** as itemized in RELEASE_READINESS. Do not call HolmesKit production-ready merely because CI passes.

## 13. Changed files and final Git handoff

- `modules/gui_bridge.ps1`: scalar uninstall transport, safe empty arguments, fresh startup-state resolver, empty JSON array.
- `modules/{apps_mgr.ps1,startup_mgr.ps1}`: confirmed CLI actions reuse shared validation/exit handling.
- `src/HolmesKit.Desktop/{MainWindow.xaml.cs,Services/HolmesKitCommandService.cs,Services/ProcessRunner.cs,ViewModels/MainViewModel.cs}`: deferred loading, data validation, read cancellation/deadline and diagnostics/shell error handling.
- `tests/HolmesKit.Desktop.Tests/{FunctionalCompletionTests.cs,CommandServiceTests.cs,DesktopHardeningTests.cs,MainWindowConstructionTests.cs}`: 40 added cases plus actual WPF lifecycle assertions.
- `README.md`, `docs/{HANDBOOK.md,feature-parity.md,WINDOWS_VM_VERIFICATION.md,RELEASE_READINESS.md}` and this report: behavior, exhaustive trace, privilege decision, evidence and remaining release gates.

Implementation pushed directly to origin/master. Final documentation/report commit is identified in Git history and final response rather than embedding its own hash. Final local/remote equality and unchanged-audit status are checked after push. Generated packages, QA output, journals/logs, SDK and private captures are ignored and not staged.

## 14. Recommended next milestone

Authorize a disposable Windows VM/checkpoint and complete the native matrix with the exact serviced candidate hash, starting with one narrow reversible operation. Validate repeated baseline retention, absent/type restoration, conflicts/interruption/locking/account boundaries and safe startup/uninstall fixtures with checkpoint reversion. Complete stable operator-driven keyboard/Narrator/DPI/high-contrast acceptance. This evidence is more valuable than new optimizations, another redesign or public packaging infrastructure. Elevation-on-demand should be separately designed/reviewed against the concrete account/transport/storage requirements before implementation.

## Verification addendum

**Hosted implementation CI PASS:** [Windows verification 42236550582](https://github.com/shikhar-sahay/holmes-kit/actions/runs/42236550582), job `127955552509`, commit `1a17531b1d58fc7da2d19d904840b30dd2cb66af`. Observed completed/success and inspected logs: Windows Server 2025, zero build warnings/errors, **382 passed / 0 failed / 0 skipped**, 37-second test duration. This does not execute native optimizations, interactive QA or packaging.

**Local candidate packaging PASS:** `HolmesKit-0.6.0-rc.1-win-x64.zip`, **59,134,276 bytes**, 19 files, 18 internal checksums; independent verifier rerun passed and **16 source-backed payloads** matched the engine/modules/docs/images. EXE ProductVersion `0.6.0-rc.1+1a17531b1d58fc7da2d19d904840b30dd2cb66af`, FileVersion `0.6.0.0`, Authenticode **NotSigned**. Compiled UI resources reside in the executable; the separate QA host/state is excluded. The ZIP contains no backups, recovery journals, private logs, PDBs, SDK, test executables or private screenshots. Exact hashes:

- ZIP SHA-256: `27F4754817D3FC6713F3AA74DB6FECE9CACFAB594156B580279BFDB41516FCDD`.
- EXE SHA-256: `BE43F4E5ED0ACDFAFCE016B349F0FE1C2CCA0BFA3540B6BA1740AFB698FA5F38`.

The archive was extracted into a fresh temporary folder outside the repository with spaces in its path. **Final packaged launch BLOCKED:** the supported Computer Use launch request returned `computer-use request budget exhausted`. Its launch outcome was not observed and is not counted as PASS. No alternate UI-control/security workaround was used. Earlier Task 05 packaged launch and current self-contained acceptance-host observations do not establish launch of this exact EXE. Full packaged read-only interaction is likewise unverified. Build/archive timestamps and SDK differences preclude bit-for-bit reproducibility claims. The report is excluded from the ZIP; packaged documentation links to it online.

**Documentation CI PASS:** commit `eb49699f00182deb0e0001048ac4144f99fc29a4` — `docs: record Task 06 functional audit and release gates`; [run 42237600741](https://github.com/shikhar-sahay/holmes-kit/actions/runs/42237600741), job `127959202173`, completed successfully. Build and safe-test steps passed. Local HEAD and the remote master ref matched after push; tracked working tree was clean and only the unchanged historical audit remained untracked. This evidence-only report update follows that commit; its own hash and final CI are supplied in the final handoff/Git history rather than self-embedded. It changes no packaged payload or executable. No public release was published.
