# HolmesKit

HolmesKit is a Windows-focused optimization toolkit built around one idea: most sluggish systems are not underpowered, they are under-managed.

Instead of promising fake benchmark miracles, HolmesKit focuses on practical cleanup, safer system tuning, and reversible changes that improve responsiveness and reduce waste.

## Features

- Menu-based batch script
- Administrator check before execution
- Restore point prompt on launch
- Registry backup export before tweaks
- Core cleanup tools for temp files, caches, DNS, and background apps
- Advanced tweaks for UI responsiveness, startup pruning, visual effects, network maintenance, and hibernation control
- Gaming section split into FPS tweaks and latency maintenance
- Restore menu for registry imports, power defaults, hibernation, network reset, and Explorer restart

## Sections

### Core
- Full core optimization
- Temp and cache cleanup
- High Performance power plan activation
- Safe background app cleanup

### Advanced
- UI responsiveness tweaks
- Visual effects performance mode
- Startup pruning for a small allowlist
- Network maintenance
- Disable hibernation

### Gaming
- FPS tweaks
- Latency maintenance
- Full gaming prep

### Restore
- Restore latest registry backups
- Restore default power schemes
- Re-enable hibernation
- Reset network stack
- Restart Explorer

## How to run

1. Download `HolmesKit.bat`
2. Right-click it
3. Choose **Run as administrator**
4. Allow it to create a restore point if prompted
5. Choose the section you want from the menu

## Important notes

- This tool is intentionally conservative compared to many public tweak packs.
- It does not apply undocumented TCP or memory “magic” values.
- It avoids aggressive service disabling by default.
- The restore menu relies on the latest exported registry backup in `HolmesKit_Backups\latest`.
- Some network actions recommend a restart to fully apply.

## Suggested repository structure

```text
HolmesKit/
├─ HolmesKit.bat
├─ README.md
├─ LICENSE
├─ .gitignore
└─ screenshots/
```

## Suggested .gitignore

```gitignore
HolmesKit_Backups/
*.tmp
*.log
Thumbs.db
Desktop.ini
```

## License suggestion

MIT License is a good fit if you want people to use and remix it freely with attribution.
