# Source-audited feature parity

This inventory comes from `HolmesKit.bat` and every script under `modules/`, not only README claims.

| Capability | Existing command/effect | Admin | Backup / reversal | Restart | GUI |
|---|---|---:|---|---|---:|
| Full Core | temp cleanup, High Performance, process cleanup, Explorer restart | Yes | Component paths | Explorer | Yes |
| Temp/cache cleanup | user/Windows temp, INetCache, D3DSCache, NVIDIA DX/GL caches, DNS | Yes | Cache rebuilt; deletion not reversible | No | Yes |
| Power optimization | `powercfg /setactive SCHEME_MIN`, GUID fallback | Yes | Restore power schemes | No | Yes |
| Background cleanup | terminates the established common-app list | Yes | Reopen apps | No | Yes |
| UI responsiveness | Desktop timeouts/delay, priority separation, NTFS last-access | Yes | Registry import and explicit resets | Explorer | Yes |
| Visual performance | visual mode, animations, selection/shadow settings | Yes | Registry import | Explorer | Yes |
| Startup pruning | named common-app HKCU/HKLM Run values | Yes | Run-key exports | Sign-in | Yes |
| Network maintenance | DNS, IP lease, Winsock, TCP/IP reset | Yes | Network reset | Recommended | Yes |
| Service cleanup | SysMain, WSearch, DiagTrack | Yes | Service restore | No | Yes |
| Hibernation | `powercfg /h off` | Yes | `powercfg /h on` | No | Yes |
| FPS tweaks | power, Game DVR, MMCSS, visuals, process cleanup | Yes | Registry/power restore | Explorer | Yes |
| Latency maintenance | Fast Open/RSS/autotuning/Nagle, DNS/Winsock, DoSvc/BITS | Yes | Registry/network paths | Recommended | Yes |
| Full Gaming Prep | FPS + latency | Yes | Combined paths | Recommended | Yes |
| Apply All | the complete established optimization sequence | Yes | Backup before sequence | Recommended | Yes |
| Registry restore | latest twelve key exports plus priority/NTFS/TCP resets | Yes | Latest backup | Explorer | Yes |
| Power/service/hibernation/network restore | existing CLI restore labels | Yes | Windows/HolmesKit defaults | Varies | Yes |
| System information | OS, CPU, RAM, disk, power, uptime, startups and CLI live details | Read | N/A | N/A | Yes, on demand |
| Startup Manager | Run/RunOnce + logon/boot tasks, StartupApproved, protected paths | Often | Toggle again; no deletion | Varies | Yes |
| Applications Manager | three uninstall hives; MSI/EXE registered uninstall | Often | App-specific | App-specific | Yes |
| Logging | shared timestamped text log | No | N/A | N/A | Yes |

## Failure modes handled at the desktop boundary

- missing executable, Batch file, PowerShell, or bridge script;
- access denied, policy rejection, or UAC cancellation at app launch;
- non-zero Batch, PowerShell, or uninstaller exit;
- malformed structured output;
- safe cancellation or unexpected process termination;
- missing backup during registry restore;
- protected startup entries;
- missing or invalid registered uninstaller.

Tests deliberately avoid privileged mutations. They cover the catalog, command construction, process output/exit capture, path discovery, and validation.
