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

Task 02 adds pure recovery-policy fixtures and actual-orchestrator lifecycle tests with all native adapters replaced. The retained baseline is shared by CLI and desktop, serialized with an exclusive file lock and atomically published with corruption checks. This is not a full-system backup. Interrupted journals, identity/scope changes and corruption fail closed for manual review. Native apply/recover behavior still requires the disposable-VM matrix in `WINDOWS_VM_VERIFICATION.md`.
