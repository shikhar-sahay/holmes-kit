# Source-audited feature parity

This inventory comes from `HolmesKit.bat` and every script under `modules/`, not only README claims.

| Capability | Existing command/effect | Admin | Backup / reversal | Restart | GUI |
|---|---|---:|---|---|---:|
| Full Core | temp cleanup, High Performance, process cleanup, Explorer restart | Yes | Component paths | Explorer | Yes |
| Temp/cache cleanup | user/Windows temp, INetCache, D3DSCache, NVIDIA DX/GL caches, DNS | Yes | Cache rebuilt; deletion not reversible | No | Yes |
| Power optimization | `powercfg /setactive SCHEME_MIN`, GUID fallback | Yes | Select captured original GUID if still available; skip conflicts | No | Yes |
| Background cleanup | terminates the established common-app list | Yes | Reopen apps | No | Yes |
| UI responsiveness | Desktop timeouts/delay, priority separation, NTFS last-access | Yes | Scoped value journal; NTFS is not exact recovery | Explorer | Yes |
| Visual performance | visual mode, animations, selection/shadow settings | Yes | Scoped existence/type/data journal; skip conflicts | Explorer | Yes |
| Startup pruning | named common-app HKCU/HKLM Run values | Yes | Scoped value journal, no whole-key replay | Sign-in | Yes |
| Network maintenance | DNS, IP lease, Winsock, TCP/IP reset | Yes | Network reset | Recommended | Yes |
| Service cleanup | SysMain, WSearch, DiagTrack | Yes | Service restore | No | Yes |
| Hibernation | `powercfg /h off` | Yes | `powercfg /h on` | No | Yes |
| FPS tweaks | power, Game DVR, MMCSS, visuals, process cleanup | Yes | Registry/power restore | Explorer | Yes |
| Latency maintenance | Fast Open/RSS/autotuning/Nagle, DNS/Winsock, DoSvc/BITS | Yes | Registry/network paths | Recommended | Yes |
| Full Gaming Prep | FPS + latency | Yes | Combined paths | Recommended | Yes |
| Apply All | the complete established optimization sequence | Yes | Backup before sequence | Recommended | Yes |
| Registry restore | validated retained journal of managed values only | Yes | Skip external conflicts; legacy exports manual only | Sign-out may be required | Yes |
| Power/service recovery | captured active plan and managed service modes/running state | Yes | Validated baseline; conflicts/unavailable state reported | Varies | Yes |
| Hibernation/network recovery | explicit enable/reset actions | Yes | Reset-only, not prior-state restoration | Varies | Yes |
| System information | OS, CPU, RAM, disk, power, uptime, startups and CLI live details | Read | N/A | N/A | Yes, on demand |
| Startup Manager | Run/RunOnce + logon/boot tasks, StartupApproved, protected paths | Often | Toggle again; no deletion | Varies | Yes |
| Applications Manager | three uninstall hives; MSI/EXE registered uninstall | Often | App-specific | App-specific | Yes |
| Logging | shared timestamped text log | No | N/A | N/A | Yes |
| Live desktop dashboard | read-only GetSystemTimes / GlobalMemoryStatusEx / GetTickCount64 | No additional privilege | No Windows writes; in-memory history only | N/A | Home, 2 s sampling; pauses inactive/minimized/busy |

## Failure modes handled at the desktop boundary

- missing executable, Batch file, PowerShell, or bridge script;
- access denied, policy rejection, or UAC cancellation at app launch;
- non-zero Batch, PowerShell, or uninstaller exit;
- malformed structured output;
- cancellation of read-only queries; native mutation cancellation is disabled and window closure blocked;
- missing backup during registry restore;
- protected startup entries;
- missing or invalid registered uninstaller.

Tests deliberately avoid privileged mutations. They cover the catalog, command construction, process output/exit capture, path discovery, and validation.

Task 04 preserves all dispatcher identifiers and CLI/bridge behavior. Presentation changes include neutral matte-black resources, expandable scope/recovery details, Cancel-default confirmation, management empty/loading states and full-value tooltips. Live charts contain at most 31 real samples from the last 60 seconds; storage is capacity, not disk activity. System Info remains an on-demand snapshot. Missing/legacy/interrupted/invalid/ready recovery states are distinct; readiness is preliminary and never bypasses engine validation. No native restore guarantee is added. Full interactive review was not resumed after the operator stopped Computer Use; offscreen construction is not visual certification.

Task 02 adds pure recovery-policy fixtures and actual-orchestrator lifecycle tests with all native adapters replaced. The retained baseline is shared by CLI and desktop, serialized with an exclusive file lock and atomically published with corruption checks. This is not a full-system backup. Interrupted journals, identity/scope changes and corruption fail closed for manual review. Native apply/recover behavior still requires the disposable-VM matrix in `WINDOWS_VM_VERIFICATION.md`.

Task 03 tightens numeric/binary/multi-string validation and compares state independently of JSON property ordering while preserving array order and value type differences. Conversion, conflict, package-verification and read-only evidence fixtures do not establish native adapter correctness. See [the handbook](HANDBOOK.md) and [release gates](RELEASE_READINESS.md) for current limitations.

Task 05 preserves every operation identifier and the unchanged CLI/bridge/recovery engine. It fixes derived-window styling (including confirmation contrast), default focus/Escape handling, Home wording and the Clear view layout. A separate acceptance executable reuses real WPF views but disconnects all modifying service methods; its example lists, simulated outcomes and UI-only baseline illustrations are fixtures. Packaged launch, fixture interaction and rendered-page checks do not establish native recovery or full accessibility/DPI acceptance.

## Task 06 end-to-end trace

All 20 catalog operations are implemented and connected. **Implemented is not native-verified.** The common desktop route is the operation's Review button → `RunOperationCommand` → affirmative `Confirm` → `HolmesKitCommandService.RunOperationAsync(id)` → non-interactive Batch `--run id` → `recovery.ps1 Execute` → allowlisted engine label. CLI menus obtain fresh Y/y before entering that shared route. All engine operations require administrator access. Mutation cancellation/window close are blocked; exit 0 completes, exit 4 is partial managed recovery, other non-zero results fail with output retained. There is no automatic rollback or unsafe retry. `CliSafetyTests`, `BatchContractTests`, `GuiAuthorizationTests`, recovery fixtures and WPF construction/binding tests cover these routes with native leaves disconnected.

| Page | Exact IDs → Batch implementation labels | Preconditions and recovery | Native validation |
|---|---|---|---|
| Core | `core-full` → `run_full_core`; `cleanup-temp` → `cleanup_temp`; `power-high` → `apply_power_plan`; `cleanup-background` → `cleanup_background` | Confirm; journal prerequisite; scoped power recovery, irreversible deletion/process effects | NOT EXECUTED |
| Advanced | `ui-responsive` → `ui_responsiveness_tweaks`; `visual-performance` → `visual_performance_mode`; `startup-prune` → `startup_pruning`; `network-maintenance` → `network_maintenance`; `services-cleanup` → `services_cleanup`; `hibernation-disable` → `disable_hibernation` | Confirm; journal validation; captured registry/services; NTFS/network/hibernation partial or reset-only | NOT EXECUTED |
| Gaming | `gaming-fps` → `gaming_fps_tweaks`; `gaming-latency` → `gaming_latency_maintenance`; `gaming-full` → `gaming_full_prep` | Confirm; journal validation; composite limitations and restart guidance in catalog | NOT EXECUTED |
| Apply All | `apply-all` → `run_apply_all` | One explicit review; prerequisite succeeds before changes; checked failures stop later steps; earlier writes may remain | NOT EXECUTED |
| Restore | `restore-registry`, `restore-power`, `restore-services` → journal category recovery; `restore-hibernation` → `enable_hibernation`; `restore-network` → `restore_network_defaults`; `restart-explorer` → `restart_explorer` | Confirm; first three disabled without preliminary valid baseline, engine revalidates scope/account/conflicts; other three independent reset/session actions | NOT EXECUTED |

Apply All order remains cleanup → power → close apps → UI/NTFS → visual → startup pruning → services → hibernation → FPS sequence → latency sequence. FPS repeats some existing component operations. It does not run the separate IP-release/renew network-maintenance sequence; its network changes are those of gaming latency. No hidden new optimization was added.

| Other page | UI → ViewModel → service/implementation | Permissions, outcomes, evidence |
|---|---|---|
| Home | shortcuts → `NavigateCommand`; native `DesktopMonitor`/`DashboardViewModel`; initial system read | Read-only kernel samples every 2 s; bounded 31/60 s history; lifecycle/math tests and current Windows read observations; no duplicate sampler intended |
| Startup | search/sort/Refresh → `RefreshStartupCommand` → `GetStartupEntriesAsync` → `startup-list`; row Toggle → confirmed `ToggleStartupCommand` → `startup-toggle` | Fresh identity/protection/state validation; RunOnce/protected entries disabled. Both CLI toggle helpers now use bridge. Query cancellable/60 s deadline; action non-cancellable. Filter/sort/approval and stale-state fixtures PASS; native toggle NOT EXECUTED |
| Applications | search/sort/Refresh → `RefreshApplicationsCommand` → `GetApplicationsAsync` → `apps-list`; row Uninstall → confirmed `UninstallCommand` → `app-uninstall` | Registered name/command revalidated; named scalar identity transport fixed; empty args omitted. MSI/EXE exit fixtures and actual inert `-File` transport PASS; real uninstall NOT EXECUTED. No app recovery; unknown metadata stays unavailable |
| System Info | Refresh → `RefreshSystemCommand` → `GetSystemInfoAsync` → `system-info` JSON | CIM, structured power registry, active adapter reads; raw values formatted in C#. Read-only source/formula comparison PASS on current Windows 11 only; missing optional fields honest; cancellation and timeout distinct |
| Activity & Logs | session output; Reload → `RefreshLogsAsync`; Copy/Open folder/Clear view commands | Tail read off UI thread, max 500 lines/bounded bytes; session max 1000 rows; clear changes session view only. Clipboard/shell errors handled; management stdout/stderr preserved. Full interactive clipboard acceptance NOT EXECUTED |

`FunctionalCompletionTests` adds malformed-identity, empty enumeration, stale-state, CLI shared-dispatch and inert uninstaller outcome checks. `CommandServiceTests` crosses the real Windows PowerShell `-File` boundary using only the real parameter block and an inert output body; this caught the formerly missing application name. The actual construction test now exercises Loaded/selection/busy transitions for both management pages. No visible operation button was treated as proof of native correctness. Recovery engine format, locking, baseline retention and allowlists are unchanged in Task 06.
