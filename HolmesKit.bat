@echo off
chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"
title HolmesKit
mode con: cols=110 lines=42

call :require_admin
call :init_paths
call :startup_notice

:: ================================================================
:main_menu
cls
call :print_header
powershell -NoProfile -Command ^
  "Write-Host '                 ==============================================================' -ForegroundColor DarkGray;" ^
  "Write-Host '';" ^
  "Write-Host '                 [' -ForegroundColor DarkGray -NoNewline; Write-Host '1' -ForegroundColor Cyan -NoNewline; Write-Host ']  Core Optimization' -ForegroundColor White;" ^
  "Write-Host '                 [' -ForegroundColor DarkGray -NoNewline; Write-Host '2' -ForegroundColor Cyan -NoNewline; Write-Host ']  Advanced Tweaks' -ForegroundColor White;" ^
  "Write-Host '                 [' -ForegroundColor DarkGray -NoNewline; Write-Host '3' -ForegroundColor Cyan -NoNewline; Write-Host ']  Gaming Mode' -ForegroundColor White;" ^
  "Write-Host '                 [' -ForegroundColor DarkGray -NoNewline; Write-Host '4' -ForegroundColor Cyan -NoNewline; Write-Host ']  Restore Defaults' -ForegroundColor White;" ^
  "Write-Host '                 [' -ForegroundColor DarkGray -NoNewline; Write-Host '5' -ForegroundColor Cyan -NoNewline; Write-Host ']  System Info' -ForegroundColor White;" ^
  "Write-Host '                 [' -ForegroundColor DarkGray -NoNewline; Write-Host '6' -ForegroundColor Cyan -NoNewline; Write-Host ']  Startup Manager' -ForegroundColor White;" ^
  "Write-Host '                 [' -ForegroundColor DarkGray -NoNewline; Write-Host '7' -ForegroundColor Cyan -NoNewline; Write-Host ']  Apps Manager' -ForegroundColor White;" ^
  "Write-Host '                 [' -ForegroundColor DarkGray -NoNewline; Write-Host '8' -ForegroundColor Red -NoNewline; Write-Host ']  Exit' -ForegroundColor White;" ^
  "Write-Host '';" ^
  "Write-Host '                 ==============================================================' -ForegroundColor DarkGray;"
echo.
set /p HK_MAIN=                   ^> 
if "%HK_MAIN%"=="1" goto core_menu
if "%HK_MAIN%"=="2" goto advanced_menu
if "%HK_MAIN%"=="3" goto gaming_menu
if "%HK_MAIN%"=="4" goto restore_menu
if "%HK_MAIN%"=="5" goto system_info
if "%HK_MAIN%"=="6" goto startup_manager
if "%HK_MAIN%"=="7" goto apps_manager
if "%HK_MAIN%"=="8" exit /b 0
goto main_menu

:core_menu
cls
call :print_header
powershell -NoProfile -Command ^
  "Write-Host '                 ================== CORE OPTIMIZATION ====================' -ForegroundColor DarkGray;" ^
  "Write-Host '';" ^
  "Write-Host '                 [' -ForegroundColor DarkGray -NoNewline; Write-Host '1' -ForegroundColor Cyan -NoNewline; Write-Host ']  Run Full Core Optimization' -ForegroundColor White;" ^
  "Write-Host '                 [' -ForegroundColor DarkGray -NoNewline; Write-Host '2' -ForegroundColor Cyan -NoNewline; Write-Host ']  Cleanup Temp And Cache Files' -ForegroundColor White;" ^
  "Write-Host '                 [' -ForegroundColor DarkGray -NoNewline; Write-Host '3' -ForegroundColor Cyan -NoNewline; Write-Host ']  Apply Power Plan Optimization' -ForegroundColor White;" ^
  "Write-Host '                 [' -ForegroundColor DarkGray -NoNewline; Write-Host '4' -ForegroundColor Cyan -NoNewline; Write-Host ']  Safe Background Cleanup' -ForegroundColor White;" ^
  "Write-Host '                 [' -ForegroundColor DarkGray -NoNewline; Write-Host '5' -ForegroundColor Red -NoNewline; Write-Host ']  Back' -ForegroundColor White;" ^
  "Write-Host '';" ^
  "Write-Host '                 =========================================================' -ForegroundColor DarkGray;"
echo.
set /p HK_CORE=                   ^> 
if "%HK_CORE%"=="1" call :confirm_run "Run Full Core Optimization" "Runs all core steps in sequence: temp cleanup, High Performance power plan, background app termination, and Explorer restart." "Affected: Temp folders, Power Plan, Background Processes, Explorer" & if "!HK_CONFIRMED!"=="1" call :run_full_core & goto pause_return
if "%HK_CORE%"=="2" call :confirm_run "Cleanup Temp And Cache Files" "Deletes contents of %%TEMP%%, Windows Temp, INetCache, and GPU shader caches (NVIDIA DXCache, GLCache, D3DSCache). Also flushes the DNS resolver cache." "Affected: Temp folders, DNS Cache, GPU Shader Caches" & if "!HK_CONFIRMED!"=="1" call :ensure_backup & call :cleanup_temp & goto pause_return
if "%HK_CORE%"=="3" call :confirm_run "Apply Power Plan Optimization" "Switches your active power plan to High Performance. This prevents the CPU from throttling down during load and removes artificial frequency limits." "Affected: Windows Power Plan (reversible via Restore menu)" & if "!HK_CONFIRMED!"=="1" call :ensure_backup & call :apply_power_plan & goto pause_return
if "%HK_CORE%"=="4" call :confirm_run "Safe Background Cleanup" "Force-closes common background apps that consume RAM and CPU: OneDrive, Teams, Spotify, Discord, Epic Games, Battle.net, Adobe background services, and open browsers." "Affected: Running processes (apps can be reopened normally)" & if "!HK_CONFIRMED!"=="1" call :ensure_backup & call :cleanup_background & goto pause_return
if "%HK_CORE%"=="5" goto main_menu
goto core_menu

:advanced_menu
cls
call :print_header
powershell -NoProfile -Command ^
  "Write-Host '                 =================== ADVANCED TWEAKS =====================' -ForegroundColor DarkGray;" ^
  "Write-Host '';" ^
  "Write-Host '                 [' -ForegroundColor DarkGray -NoNewline; Write-Host '1' -ForegroundColor Cyan -NoNewline; Write-Host ']  UI Responsiveness Tweaks' -ForegroundColor White;" ^
  "Write-Host '                 [' -ForegroundColor DarkGray -NoNewline; Write-Host '2' -ForegroundColor Cyan -NoNewline; Write-Host ']  Visual Effects Performance Mode' -ForegroundColor White;" ^
  "Write-Host '                 [' -ForegroundColor DarkGray -NoNewline; Write-Host '3' -ForegroundColor Cyan -NoNewline; Write-Host ']  Startup Pruning' -ForegroundColor White;" ^
  "Write-Host '                 [' -ForegroundColor DarkGray -NoNewline; Write-Host '4' -ForegroundColor Cyan -NoNewline; Write-Host ']  Network Maintenance' -ForegroundColor White;" ^
  "Write-Host '                 [' -ForegroundColor DarkGray -NoNewline; Write-Host '5' -ForegroundColor Cyan -NoNewline; Write-Host ']  Background Services Cleanup' -ForegroundColor White;" ^
  "Write-Host '                 [' -ForegroundColor DarkGray -NoNewline; Write-Host '6' -ForegroundColor Cyan -NoNewline; Write-Host ']  Disable Hibernation' -ForegroundColor White;" ^
  "Write-Host '                 [' -ForegroundColor DarkGray -NoNewline; Write-Host '7' -ForegroundColor Red -NoNewline; Write-Host ']  Back' -ForegroundColor White;" ^
  "Write-Host '';" ^
  "Write-Host '                 =========================================================' -ForegroundColor DarkGray;"
echo.
set /p HK_ADV=                    ^> 
if "%HK_ADV%"=="1" call :confirm_run "UI Responsiveness Tweaks" "Reduces menu animation delay (100ms), lowers app hang timeout, sets foreground apps to receive longer CPU time slices (Win32PrioritySeparation), and disables NTFS Last Access timestamps to cut background disk I/O." "Affected: Registry (HKCU\Control Panel\Desktop), NTFS filesystem flags" & if "!HK_CONFIRMED!"=="1" call :ensure_backup & call :ui_responsiveness_tweaks & goto pause_return
if "%HK_ADV%"=="2" call :confirm_run "Visual Effects Performance Mode" "Disables window animations, taskbar animations, list-view shadows, and alpha selection effects. Sets Windows to Performance mode for visual effects. Noticeable on lower-end hardware." "Affected: Registry (HKCU Explorer\VisualEffects, WindowMetrics)" & if "!HK_CONFIRMED!"=="1" call :ensure_backup & call :visual_performance_mode & goto pause_return
if "%HK_ADV%"=="3" call :confirm_run "Startup Pruning" "Removes startup registry entries for: OneDrive, Discord, Spotify, Skype, Zoom, Epic Games Launcher, Teams. These apps will no longer auto-launch at login. You can still open them manually." "Affected: Registry (HKCU\Run and HKLM\Run startup keys)" & if "!HK_CONFIRMED!"=="1" call :ensure_backup & call :startup_pruning & goto pause_return
if "%HK_ADV%"=="4" call :confirm_run "Network Maintenance" "Flushes DNS cache, releases and renews your IP address, resets the Winsock catalog, and resets the TCP/IP stack. Useful if you are experiencing degraded network performance." "Affected: DNS Cache, IP Lease, Winsock, TCP/IP Stack (restart recommended)" & if "!HK_CONFIRMED!"=="1" call :ensure_backup & call :network_maintenance & goto pause_return
if "%HK_ADV%"=="5" call :confirm_run "Background Services Cleanup" "Stops and disables three high-overhead background services: SysMain (Superfetch memory preloader), WSearch (Windows Search Indexer), and DiagTrack (Telemetry). Original service states are saved for restore." "Affected: SysMain, WSearch, DiagTrack services (restorable)" & if "!HK_CONFIRMED!"=="1" call :ensure_backup & call :services_cleanup & goto pause_return
if "%HK_ADV%"=="6" call :confirm_run "Disable Hibernation" "Disables Windows hibernation and removes the hiberfil.sys file, which can be several GB on your system drive. Sleep mode is unaffected." "Affected: Hibernation state, hiberfil.sys (frees disk space)" & if "!HK_CONFIRMED!"=="1" call :ensure_backup & call :disable_hibernation & goto pause_return
if "%HK_ADV%"=="7" goto main_menu
goto advanced_menu

:gaming_menu
cls
call :print_header
powershell -NoProfile -Command ^
  "Write-Host '                 ===================== GAMING MODE =======================' -ForegroundColor DarkGray;" ^
  "Write-Host '';" ^
  "Write-Host '                 [' -ForegroundColor DarkGray -NoNewline; Write-Host '1' -ForegroundColor Cyan -NoNewline; Write-Host ']  FPS Tweaks' -ForegroundColor White;" ^
  "Write-Host '                 [' -ForegroundColor DarkGray -NoNewline; Write-Host '2' -ForegroundColor Cyan -NoNewline; Write-Host ']  Latency Maintenance' -ForegroundColor White;" ^
  "Write-Host '                 [' -ForegroundColor DarkGray -NoNewline; Write-Host '3' -ForegroundColor Cyan -NoNewline; Write-Host ']  Full Gaming Prep' -ForegroundColor White;" ^
  "Write-Host '                 [' -ForegroundColor DarkGray -NoNewline; Write-Host '4' -ForegroundColor Red -NoNewline; Write-Host ']  Back' -ForegroundColor White;" ^
  "Write-Host '';" ^
  "Write-Host '                 =========================================================' -ForegroundColor DarkGray;"
echo.
set /p HK_GAME=                   ^> 
if "%HK_GAME%"=="1" call :confirm_run "FPS Tweaks" "Disables Xbox Game DVR/capture overlay, sets GPU and I/O scheduling priority to High for game processes, sets SystemResponsiveness to 0 (dedicates multimedia scheduler fully to games), and applies High Performance power plan." "Affected: GameDVR registry keys, Multimedia Scheduler (MMCSS), Power Plan" & if "!HK_CONFIRMED!"=="1" call :ensure_backup & call :gaming_fps_tweaks & goto pause_return
if "%HK_GAME%"=="2" call :confirm_run "Latency Maintenance" "Flushes DNS, resets Winsock, enables TCP Fast Open and RSS (Receive Side Scaling), disables Nagle algorithm for lower latency, and pauses Windows Update delivery (BITS and DoSvc) during your session." "Affected: TCP/IP stack, Winsock, Windows Update delivery services" & if "!HK_CONFIRMED!"=="1" call :ensure_backup & call :gaming_latency_maintenance & goto pause_return
if "%HK_GAME%"=="3" call :confirm_run "Full Gaming Prep" "Runs FPS Tweaks and Latency Maintenance in sequence. Applies all gaming optimizations in one step." "Affected: All of the above combined" & if "!HK_CONFIRMED!"=="1" call :ensure_backup & call :gaming_full_prep & goto pause_return
if "%HK_GAME%"=="4" goto main_menu
goto gaming_menu

:restore_menu
cls
call :print_header
powershell -NoProfile -Command ^
  "Write-Host '                 =================== RESTORE DEFAULTS ====================' -ForegroundColor DarkGray;" ^
  "Write-Host '';" ^
  "Write-Host '                 [' -ForegroundColor DarkGray -NoNewline; Write-Host '1' -ForegroundColor Cyan -NoNewline; Write-Host ']  Restore Latest Registry Backups' -ForegroundColor White;" ^
  "Write-Host '                 [' -ForegroundColor DarkGray -NoNewline; Write-Host '2' -ForegroundColor Cyan -NoNewline; Write-Host ']  Restore Default Power Schemes' -ForegroundColor White;" ^
  "Write-Host '                 [' -ForegroundColor DarkGray -NoNewline; Write-Host '3' -ForegroundColor Cyan -NoNewline; Write-Host ']  Re-Enable Background Services' -ForegroundColor White;" ^
  "Write-Host '                 [' -ForegroundColor DarkGray -NoNewline; Write-Host '4' -ForegroundColor Cyan -NoNewline; Write-Host ']  Re-Enable Hibernation' -ForegroundColor White;" ^
  "Write-Host '                 [' -ForegroundColor DarkGray -NoNewline; Write-Host '5' -ForegroundColor Cyan -NoNewline; Write-Host ']  Reset Network Stack' -ForegroundColor White;" ^
  "Write-Host '                 [' -ForegroundColor DarkGray -NoNewline; Write-Host '6' -ForegroundColor Cyan -NoNewline; Write-Host ']  Restart Explorer' -ForegroundColor White;" ^
  "Write-Host '                 [' -ForegroundColor DarkGray -NoNewline; Write-Host '7' -ForegroundColor Red -NoNewline; Write-Host ']  Back' -ForegroundColor White;" ^
  "Write-Host '';" ^
  "Write-Host '                 =========================================================' -ForegroundColor DarkGray;"
echo.
set /p HK_RESTORE=                ^> 
if "%HK_RESTORE%"=="1" call :restore_latest_registry & goto pause_return
if "%HK_RESTORE%"=="2" call :restore_power_defaults & goto pause_return
if "%HK_RESTORE%"=="3" call :restore_services & goto pause_return
if "%HK_RESTORE%"=="4" call :enable_hibernation & goto pause_return
if "%HK_RESTORE%"=="5" call :restore_network_defaults & goto pause_return
if "%HK_RESTORE%"=="6" call :restart_explorer & goto pause_return
if "%HK_RESTORE%"=="7" goto main_menu
goto restore_menu

:: ================================================================
:pause_return
set "HK_CONFIRMED=0"
echo.
powershell -NoProfile -Command "Write-Host '  Done. Press any key to return to the menu...' -ForegroundColor Green"
echo.
pause >nul
goto main_menu

:: show what an option does and ask before running it
:: sets HK_CONFIRMED=1 if user says Y
:confirm_run
set "HK_CONFIRMED=0"
cls
call :print_header
powershell -NoProfile -Command ^
  "Write-Host '                 ------------------------------------------------------' -ForegroundColor DarkGray;" ^
  "Write-Host '  %~1' -ForegroundColor Cyan;" ^
  "Write-Host '                 ------------------------------------------------------' -ForegroundColor DarkGray;"
echo.
echo   What this does:
echo   %~2
echo.
powershell -NoProfile -Command "Write-Host '  %~3' -ForegroundColor Yellow"
echo.
powershell -NoProfile -Command "Write-Host '                 ------------------------------------------------------' -ForegroundColor DarkGray"
echo.
set /p HK_CONFIRM=                   Proceed? [Y/N]:  
if /I "!HK_CONFIRM!"=="Y" set "HK_CONFIRMED=1"
echo.
exit /b 0

:: ================================================================
:: HEADER
:: ================================================================
:print_header
powershell -NoProfile -Command ^
  "Write-Host '';" ^
  "Write-Host '                 ██╗  ██╗ ██████╗ ██╗     ███╗   ███╗███████╗███████╗██╗  ██╗██╗████████╗' -ForegroundColor Cyan;" ^
  "Write-Host '                 ██║  ██║██╔═══██╗██║     ████╗ ████║██╔════╝██╔════╝██║ ██╔╝██║╚══██╔══╝' -ForegroundColor Cyan;" ^
  "Write-Host '                 ███████║██║   ██║██║     ██╔████╔██║█████╗  ███████╗█████╔╝ ██║   ██║   ' -ForegroundColor Cyan;" ^
  "Write-Host '                 ██╔══██║██║   ██║██║     ██║╚██╔╝██║██╔══╝  ╚════██║██╔═██╗ ██║   ██║   ' -ForegroundColor Cyan;" ^
  "Write-Host '                 ██║  ██║╚██████╔╝███████╗██║ ╚═╝ ██║███████╗███████║██║  ██╗██║   ██║   ' -ForegroundColor Cyan;" ^
  "Write-Host '                 ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝     ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝   ╚═╝  ' -ForegroundColor DarkCyan;" ^
  "Write-Host '';" ^
  "Write-Host '                          Safe Windows Optimization Toolkit' -ForegroundColor DarkGray;" ^
  "Write-Host '';"
exit /b 0

:: simple timestamped log - writes to HolmesKit_Backups/holmeskit.log
:log
set "LG_MSG=%~1"
for /f "tokens=1-3 delims=/ " %%a in ('date /t') do set "LG_DATE=%%a/%%b/%%c"
for /f "tokens=1-2 delims=: " %%a in ('time /t') do set "LG_TIME=%%a:%%b"
echo [%LG_DATE% %LG_TIME%] %LG_MSG% >> "%HK_LOG%" 2>nul
exit /b 0

:: bail early if not running as admin
:require_admin
net session >nul 2>&1
if %errorlevel%==0 exit /b 0
echo.
echo  HolmesKit requires Administrator privileges.
echo  Right-click the script and choose "Run as administrator".
echo.
pause
exit /b 1

:: set up folder paths and start the log
:init_paths
set "HK_ROOT=%~dp0"
if "%HK_ROOT:~-1%"=="\" set "HK_ROOT=%HK_ROOT:~0,-1%"
set "HK_STATE=%HK_ROOT%\HolmesKit_Backups"
set "HK_LATEST=%HK_STATE%\latest"
set "HK_LOG=%HK_STATE%\holmeskit.log"
if not exist "%HK_STATE%" md "%HK_STATE%" >nul 2>&1
set "HK_BACKUP_READY=0"
set "HK_CONFIRMED=0"
call :log "=== HolmesKit session started ==="
exit /b 0

:: show disclaimer and offer to open system restore before anything runs
:startup_notice
cls
call :print_header
echo.
powershell -NoProfile -Command "Write-Host '  NOTICE: HolmesKit will make system-level changes.' -ForegroundColor Yellow"
echo.
echo   It can:
echo     - Delete temporary files and cache folders
echo     - Change power settings and disable unused services
echo     - Apply reversible registry tweaks
echo     - Run optional gaming-focused optimizations
echo.
powershell -NoProfile -Command "Write-Host '  A restore point is strongly recommended before continuing.' -ForegroundColor Yellow"
echo.
powershell -NoProfile -Command "Write-Host '                 =========================================================' -ForegroundColor DarkGray"
echo.
set /p HK_RP=                   Create a restore point now? [Y/N]:  
if /I "%HK_RP%"=="Y" call :create_restore_point
exit /b 0

:: just open the system protection window - simpler than scripting it
:create_restore_point
echo.
powershell -NoProfile -Command "Write-Host '  Opening System Protection window...' -ForegroundColor Yellow"
call :log "Opened System Protection window for user"
start "" SystemPropertiesProtection.exe
echo.
echo   Create a restore point in the window that just opened,
echo   then return here and press any key to continue.
echo.
pause >nul
exit /b 0

:: export affected registry keys before making any changes
:ensure_backup
if "%HK_BACKUP_READY%"=="1" exit /b 0
if exist "%HK_LATEST%" rd /s /q "%HK_LATEST%" >nul 2>&1
md "%HK_LATEST%" >nul 2>&1
call :log "Creating registry backups"
call :export_key "HKCU\Control Panel\Desktop" "desktop.reg"
call :export_key "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" "visualeffects.reg"
call :export_key "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "explorer_advanced.reg"
call :export_key "HKCU\Control Panel\Desktop\WindowMetrics" "windowmetrics.reg"
call :export_key "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" "hkcu_run.reg"
call :export_key "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" "hklm_run.reg"
call :export_key "HKCU\System\GameConfigStore" "gameconfigstore.reg"
call :export_key "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" "gamedvr.reg"
call :export_key "HKLM\Software\Policies\Microsoft\Windows\GameDVR" "gamedvr_policy.reg"
call :export_key "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" "mm_games.reg"
call :export_key "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" "mm_profile.reg"
call :export_key "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "tcpip_params.reg"
set "HK_BACKUP_READY=1"
call :log "Registry backups complete"
powershell -NoProfile -Command "Write-Host '  Registry backed up.' -ForegroundColor Green"
echo.
exit /b 0

:export_key
reg export "%~1" "%HK_LATEST%\%~2" /y >nul 2>&1
exit /b 0

:: core: runs all four steps in sequence
:run_full_core
call :ensure_backup
call :cleanup_temp
call :apply_power_plan
call :cleanup_background
call :restart_explorer
call :log "Full core optimization completed"
powershell -NoProfile -Command "Write-Host '  Full Core Optimization Completed.' -ForegroundColor Green"
echo.
exit /b 0

:: core: wipe temp folders and flush dns
:cleanup_temp
call :log "Starting temp/cache cleanup"
powershell -NoProfile -Command "Write-Host '  [*] Cleaning Temp And Cache Folders...' -ForegroundColor Cyan"
echo.
call :purge_dir "%TEMP%"
call :purge_dir "%LOCALAPPDATA%\Temp"
call :purge_dir "%SystemRoot%\Temp"
if exist "%LOCALAPPDATA%\Microsoft\Windows\INetCache" call :purge_dir "%LOCALAPPDATA%\Microsoft\Windows\INetCache"
if exist "%LOCALAPPDATA%\D3DSCache" call :purge_dir "%LOCALAPPDATA%\D3DSCache"
if exist "%LOCALAPPDATA%\NVIDIA\DXCache" call :purge_dir "%LOCALAPPDATA%\NVIDIA\DXCache"
if exist "%LOCALAPPDATA%\NVIDIA\GLCache" call :purge_dir "%LOCALAPPDATA%\NVIDIA\GLCache"
ipconfig /flushdns >nul 2>&1
call :log "Temp/cache cleanup complete"
powershell -NoProfile -Command "Write-Host '  Temp Cleanup Completed.' -ForegroundColor Green"
echo.
exit /b 0

:purge_dir
if not exist "%~1" exit /b 0
del /f /s /q "%~1\*" >nul 2>&1
for /d %%D in ("%~1\*") do rd /s /q "%%~fD" >nul 2>&1
exit /b 0

:: core: switch to high performance plan
:apply_power_plan
call :log "Applying High Performance power plan"
powershell -NoProfile -Command "Write-Host '  [*] Applying High Performance Power Plan...' -ForegroundColor Cyan"
echo.
powercfg /setactive SCHEME_MIN >nul 2>&1
if %errorlevel%==0 (
    powershell -NoProfile -Command "Write-Host '  High Performance Plan Activated.' -ForegroundColor Green"
    call :log "High Performance plan activated"
) else (
    for /f "tokens=4 delims=: " %%G in ('powercfg /list ^| findstr /i "High performance"') do set "HK_POWER_GUID=%%G"
    if defined HK_POWER_GUID (
        powercfg /setactive !HK_POWER_GUID! >nul 2>&1
        powershell -NoProfile -Command "Write-Host '  High Performance Plan Activated.' -ForegroundColor Green"
        call :log "High Performance plan activated via GUID"
    ) else (
        powershell -NoProfile -Command "Write-Host '  Could Not Activate High Performance Plan.' -ForegroundColor Red"
        call :log "Failed to activate High Performance plan"
    )
)
echo.
exit /b 0

:: core: kill common background apps
:cleanup_background
call :log "Terminating background processes"
powershell -NoProfile -Command "Write-Host '  [*] Terminating Background Apps...' -ForegroundColor Cyan"
echo.
for %%P in (
    OneDrive.exe Teams.exe ms-teams.exe Spotify.exe Discord.exe
    EpicGamesLauncher.exe EpicWebHelper.exe Battle.net.exe
    AdobeIPCBroker.exe CCXProcess.exe AdobeGCClient.exe
    msedge.exe chrome.exe firefox.exe
) do taskkill /f /im "%%P" >nul 2>&1
call :log "Background cleanup complete"
powershell -NoProfile -Command "Write-Host '  Background Cleanup Completed.' -ForegroundColor Green"
echo.
exit /b 0

:: advanced: registry tweaks for snappier ui and lower disk i/o
:ui_responsiveness_tweaks
call :log "Applying UI responsiveness tweaks"
powershell -NoProfile -Command "Write-Host '  [*] Applying UI Responsiveness Tweaks...' -ForegroundColor Cyan"
echo.
reg add "HKCU\Control Panel\Desktop" /v MenuShowDelay /t REG_SZ /d "100" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v HungAppTimeout /t REG_SZ /d "4000" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v WaitToKillAppTimeout /t REG_SZ /d "5000" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v ForegroundLockTimeout /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v AutoEndTasks /t REG_SZ /d "1" /f >nul 2>&1
:: foreground apps get longer cpu slices
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d "26" /f >nul 2>&1
:: skip writing last-access timestamps on file reads
fsutil behavior set disablelastaccess 1 >nul 2>&1
call :restart_explorer
call :log "UI responsiveness tweaks applied"
powershell -NoProfile -Command "Write-Host '  UI Responsiveness Tweaks Applied.' -ForegroundColor Green"
echo.
exit /b 0

:: advanced: strip animations and visual fluff
:visual_performance_mode
call :log "Applying visual effects performance mode"
powershell -NoProfile -Command "Write-Host '  [*] Applying Visual Effects Performance Mode...' -ForegroundColor Cyan"
echo.
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v MinAnimate /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarAnimations /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ListviewAlphaSelect /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ListviewShadow /t REG_DWORD /d "0" /f >nul 2>&1
call :restart_explorer
call :log "Visual effects performance mode applied"
powershell -NoProfile -Command "Write-Host '  Visual Effects Performance Mode Applied.' -ForegroundColor Green"
echo.
exit /b 0

:: advanced: remove common startup registry entries
:startup_pruning
call :log "Running startup pruning"
powershell -NoProfile -Command "Write-Host '  [*] Removing Startup Entries...' -ForegroundColor Cyan"
echo.
call :del_run "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" "OneDrive"
call :del_run "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" "Discord"
call :del_run "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" "Spotify"
call :del_run "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" "Skype"
call :del_run "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" "Zoom"
call :del_run "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" "EpicGamesLauncher"
call :del_run "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" "com.squirrel.Teams.Teams"
call :del_run "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" "OneDrive"
call :del_run "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" "TeamsMachineInstaller"
call :log "Startup pruning complete"
powershell -NoProfile -Command "Write-Host '  Startup Pruning Completed.' -ForegroundColor Green"
echo.
exit /b 0

:del_run
reg delete "%~1" /v "%~2" /f >nul 2>&1
exit /b 0

:: advanced: flush/reset network stack
:network_maintenance
call :log "Running network maintenance"
powershell -NoProfile -Command "Write-Host '  [*] Running Network Maintenance...' -ForegroundColor Cyan"
echo.
ipconfig /flushdns >nul 2>&1
ipconfig /release >nul 2>&1
ipconfig /renew >nul 2>&1
netsh winsock reset >nul 2>&1
netsh int ip reset >nul 2>&1
call :log "Network maintenance complete"
powershell -NoProfile -Command "Write-Host '  Network Maintenance Completed. A Restart Is Recommended.' -ForegroundColor Green"
echo.
exit /b 0

:: advanced: stop and disable high-overhead background services
:services_cleanup
call :log "Running background services cleanup"
powershell -NoProfile -Command "Write-Host '  [*] Stopping And Disabling Background Services...' -ForegroundColor Cyan"
echo.

:: save current state so restore works
set "HK_SVC_FILE=%HK_LATEST%\service_states.txt"
echo SysMain > "%HK_SVC_FILE%"
sc qc SysMain 2>nul | findstr "START_TYPE" >> "%HK_SVC_FILE%"
echo WSearch >> "%HK_SVC_FILE%"
sc qc WSearch 2>nul | findstr "START_TYPE" >> "%HK_SVC_FILE%"
echo DiagTrack >> "%HK_SVC_FILE%"
sc qc DiagTrack 2>nul | findstr "START_TYPE" >> "%HK_SVC_FILE%"

:: SysMain/Superfetch - heavy disk I/O, most noticeable on HDDs
sc stop SysMain >nul 2>&1
sc config SysMain start= disabled >nul 2>&1
powershell -NoProfile -Command "Write-Host '    [-] SysMain (Superfetch) stopped and disabled' -ForegroundColor DarkGray"

:: WSearch - background file indexing hammers disk
sc stop WSearch >nul 2>&1
sc config WSearch start= disabled >nul 2>&1
powershell -NoProfile -Command "Write-Host '    [-] WSearch (Search Indexer) stopped and disabled' -ForegroundColor DarkGray"

:: DiagTrack/Telemetry - pure overhead, nothing user-facing
sc stop DiagTrack >nul 2>&1
sc config DiagTrack start= disabled >nul 2>&1
powershell -NoProfile -Command "Write-Host '    [-] DiagTrack (Telemetry) stopped and disabled' -ForegroundColor DarkGray"

echo.
call :log "Background services cleanup complete"
powershell -NoProfile -Command "Write-Host '  Background Services Cleanup Completed.' -ForegroundColor Green"
powershell -NoProfile -Command "Write-Host '  Note: Windows Search will no longer index files. Use Everything or' -ForegroundColor DarkGray"
powershell -NoProfile -Command "Write-Host '  the Restore menu to re-enable if needed.' -ForegroundColor DarkGray"
echo.
exit /b 0

:: advanced: turn off hibernation and reclaim hiberfil.sys space
:disable_hibernation
call :log "Disabling hibernation"
powershell -NoProfile -Command "Write-Host '  [*] Disabling Hibernation...' -ForegroundColor Cyan"
echo.
powercfg /h off >nul 2>&1
call :log "Hibernation disabled"
powershell -NoProfile -Command "Write-Host '  Hibernation Disabled.' -ForegroundColor Green"
echo.
exit /b 0

:: gaming: dvr off, mmcss priority, power plan
:gaming_fps_tweaks
call :log "Applying gaming FPS tweaks"
powershell -NoProfile -Command "Write-Host '  [*] Applying FPS Tweaks...' -ForegroundColor Cyan"
echo.
call :apply_power_plan
:: game dvr capture overlay
reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v AppCaptureEnabled /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\Software\Policies\Microsoft\Windows\GameDVR" /v AllowGameDVR /t REG_DWORD /d "0" /f >nul 2>&1
:: mmcss scheduling for game threads
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d "8" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d "6" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d "High" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "SFIO Priority" /t REG_SZ /d "High" /f >nul 2>&1
:: give games the full multimedia scheduler budget
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /t REG_DWORD /d "0" /f >nul 2>&1
call :visual_performance_mode
call :cleanup_background
call :log "Gaming FPS tweaks applied"
powershell -NoProfile -Command "Write-Host '  FPS Tweaks Applied.' -ForegroundColor Green"
echo.
exit /b 0

:: gaming: tcp stack cleanup, nagle off, pause windows update delivery
:gaming_latency_maintenance
call :log "Applying gaming latency maintenance"
powershell -NoProfile -Command "Write-Host '  [*] Applying Latency Maintenance...' -ForegroundColor Cyan"
echo.
ipconfig /flushdns >nul 2>&1
netsh winsock reset >nul 2>&1
:: tcp fast open - less handshake overhead
netsh int tcp set global fastopen=enabled >nul 2>&1
:: rss - spread network load across cores
netsh int tcp set global rss=enabled >nul 2>&1
:: smaller fixed receive buffer = lower latency, less throughput (fine for gaming)
netsh int tcp set global autotuninglevel=disabled >nul 2>&1
:: Disable Nagle algorithm - sends packets immediately instead of batching (lower latency, slightly more packets)
:: disable nagle - send packets immediately instead of batching
powershell -NoProfile -Command "Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces' | ForEach-Object { Set-ItemProperty -Path $_.PSPath -Name 'TcpAckFrequency' -Value 1 -Type DWord -Force -EA SilentlyContinue; Set-ItemProperty -Path $_.PSPath -Name 'TCPNoDelay' -Value 1 -Type DWord -Force -EA SilentlyContinue }" >nul 2>&1
:: pause windows update delivery for the session
for %%S in (DoSvc BITS) do net stop %%S >nul 2>&1
call :cleanup_background
call :log "Gaming latency maintenance applied"
powershell -NoProfile -Command "Write-Host '  Latency Maintenance Applied. A Restart May Improve Effect.' -ForegroundColor Green"
echo.
exit /b 0

:: gaming: fps + latency in one shot
:gaming_full_prep
call :gaming_fps_tweaks
call :gaming_latency_maintenance
call :log "Full gaming prep completed"
powershell -NoProfile -Command "Write-Host '  Full Gaming Prep Completed.' -ForegroundColor Green"
echo.
exit /b 0

:: restore: reimport all saved .reg files
:restore_latest_registry
if not exist "%HK_LATEST%" (
    powershell -NoProfile -Command "Write-Host '  No Backup Found. Run An Optimization First.' -ForegroundColor Red"
    echo.
    exit /b 0
)
call :log "Restoring registry backups"
powershell -NoProfile -Command "Write-Host '  [*] Restoring Registry Backups...' -ForegroundColor Cyan"
echo.
for %%F in (
    "desktop.reg" "visualeffects.reg" "explorer_advanced.reg"
    "windowmetrics.reg" "hkcu_run.reg" "hklm_run.reg"
    "gameconfigstore.reg" "gamedvr.reg" "gamedvr_policy.reg"
    "mm_games.reg" "mm_profile.reg" "tcpip_params.reg"
) do (
    if exist "%HK_LATEST%\%%~F" reg import "%HK_LATEST%\%%~F" >nul 2>&1
)
:: restore ntfs and cpu priority settings
fsutil behavior set disablelastaccess 0 >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d "2" /f >nul 2>&1
:: restore tcp autotuning
netsh int tcp set global autotuninglevel=normal >nul 2>&1
call :restart_explorer
call :log "Registry restoration completed"
powershell -NoProfile -Command "Write-Host '  Registry Restoration Completed.' -ForegroundColor Green"
echo.
exit /b 0

:: restore: bring back the services we stopped
:restore_services
call :log "Re-enabling background services"
powershell -NoProfile -Command "Write-Host '  [*] Re-Enabling Background Services...' -ForegroundColor Cyan"
echo.
sc config SysMain start= auto >nul 2>&1
sc start SysMain >nul 2>&1
powershell -NoProfile -Command "Write-Host '    [+] SysMain re-enabled' -ForegroundColor DarkGray"
sc config WSearch start= delayed-auto >nul 2>&1
sc start WSearch >nul 2>&1
powershell -NoProfile -Command "Write-Host '    [+] WSearch re-enabled' -ForegroundColor DarkGray"
sc config DiagTrack start= auto >nul 2>&1
sc start DiagTrack >nul 2>&1
powershell -NoProfile -Command "Write-Host '    [+] DiagTrack re-enabled' -ForegroundColor DarkGray"
echo.
call :log "Background services restored"
powershell -NoProfile -Command "Write-Host '  Background Services Re-Enabled.' -ForegroundColor Green"
echo.
exit /b 0

:: restore: reset to windows default power schemes
:restore_power_defaults
call :log "Restoring default power schemes"
powershell -NoProfile -Command "Write-Host '  [*] Restoring Default Power Schemes...' -ForegroundColor Cyan"
echo.
powercfg /restoredefaultschemes >nul 2>&1
call :log "Default power schemes restored"
powershell -NoProfile -Command "Write-Host '  Default Power Schemes Restored.' -ForegroundColor Green"
echo.
exit /b 0

:: restore: re-enable hibernation
:enable_hibernation
call :log "Re-enabling hibernation"
powershell -NoProfile -Command "Write-Host '  [*] Re-Enabling Hibernation...' -ForegroundColor Cyan"
echo.
powercfg /h on >nul 2>&1
call :log "Hibernation enabled"
powershell -NoProfile -Command "Write-Host '  Hibernation Enabled.' -ForegroundColor Green"
echo.
exit /b 0

:: restore: undo network tweaks
:restore_network_defaults
call :log "Resetting network stack"
powershell -NoProfile -Command "Write-Host '  [*] Resetting Network Stack...' -ForegroundColor Cyan"
echo.
netsh winsock reset >nul 2>&1
netsh int ip reset >nul 2>&1
netsh int tcp set global autotuninglevel=normal >nul 2>&1
netsh int tcp set global fastopen=disabled >nul 2>&1
ipconfig /flushdns >nul 2>&1
powershell -NoProfile -Command "Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces' | ForEach-Object { Remove-ItemProperty -Path $_.PSPath -Name 'TcpAckFrequency' -Force -EA SilentlyContinue; Remove-ItemProperty -Path $_.PSPath -Name 'TCPNoDelay' -Force -EA SilentlyContinue }" >nul 2>&1
call :log "Network stack reset"
powershell -NoProfile -Command "Write-Host '  Network Reset Complete. A Restart Is Recommended.' -ForegroundColor Green"
echo.
exit /b 0

:: restart explorer to apply registry changes
:restart_explorer
call :log "Restarting Explorer"
taskkill /f /im explorer.exe >nul 2>&1
start "" explorer.exe
exit /b 0

:: system info: real-time dashboard, refreshes every 5s
:system_info
call :log "Opened System Info Panel"
set "HK_PS_SI=%HK_STATE%\hk_sysinfo.ps1"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$b=[System.Convert]::FromBase64String('CiMgSG9sbWVzS2l0IFN5c3RlbSBJbmZvIFBhbmVsIC0gUmVhbC10aW1lIGRhc2hib2FyZAoKZnVuY3Rpb24gR2V0LUJhclN0cmluZygkdmFsdWUsICRtYXgsICR3aWR0aCkgewogICAgJGZpbGxlZCA9IFtNYXRoXTo6Um91bmQoKCR2YWx1ZSAvICRtYXgpICogJHdpZHRoKQogICAgJGZpbGxlZCA9IFtNYXRoXTo6TWF4KDAsIFtNYXRoXTo6TWluKCRmaWxsZWQsICR3aWR0aCkpCiAgICAkZW1wdHkgID0gJHdpZHRoIC0gJGZpbGxlZAogICAgJGNvbG9yICA9IGlmICgkdmFsdWUgLWd0IDg1KSB7ICJSZWQiIH0gZWxzZWlmICgkdmFsdWUgLWd0IDYwKSB7ICJZZWxsb3ciIH0gZWxzZSB7ICJHcmVlbiIgfQogICAgV3JpdGUtSG9zdCAiWyIgLU5vTmV3bGluZSAtRm9yZWdyb3VuZENvbG9yIERhcmtHcmF5CiAgICBXcml0ZS1Ib3N0ICgiJChbY2hhcl0weDI1ODgpIiAqICRmaWxsZWQpIC1Ob05ld2xpbmUgLUZvcmVncm91bmRDb2xvciAkY29sb3IKICAgIFdyaXRlLUhvc3QgKCIgIiAqICRlbXB0eSkgLU5vTmV3bGluZSAtRm9yZWdyb3VuZENvbG9yIERhcmtHcmF5CiAgICBXcml0ZS1Ib3N0ICJdICIgLU5vTmV3bGluZSAtRm9yZWdyb3VuZENvbG9yIERhcmtHcmF5Cn0KCmZ1bmN0aW9uIEdldC1Ub3BQcm9jZXNzZXMoJHR5cGUsICRjb3VudCkgewogICAgaWYgKCR0eXBlIC1lcSAiQ1BVIikgewogICAgICAgIHJldHVybiBHZXQtUHJvY2VzcyB8IFdoZXJlLU9iamVjdCB7ICRfLkNQVSAtZ3QgMCB9IHwKICAgICAgICAgICAgU29ydC1PYmplY3QgQ1BVIC1EZXNjZW5kaW5nIHwKICAgICAgICAgICAgU2VsZWN0LU9iamVjdCAtRmlyc3QgJGNvdW50IE5hbWUsCiAgICAgICAgICAgICAgICBAe049IlZhbHVlIjsgRT17IFtNYXRoXTo6Um91bmQoJF8uQ1BVLCAxKS5Ub1N0cmluZygpICsgInMgQ1BVIiB9fQogICAgfSBlbHNlIHsKICAgICAgICByZXR1cm4gR2V0LVByb2Nlc3MgfAogICAgICAgICAgICBTb3J0LU9iamVjdCBXb3JraW5nU2V0NjQgLURlc2NlbmRpbmcgfAogICAgICAgICAgICBTZWxlY3QtT2JqZWN0IC1GaXJzdCAkY291bnQgTmFtZSwKICAgICAgICAgICAgICAgIEB7Tj0iVmFsdWUiOyBFPXsgW01hdGhdOjpSb3VuZCgkXy5Xb3JraW5nU2V0NjQgLyAxTUIsIDApLlRvU3RyaW5nKCkgKyAiIE1CIiB9fQogICAgfQp9CgpmdW5jdGlvbiBHZXQtRGlza0luZm8gewogICAgJGRpc2tzID0gQCgpCiAgICBmb3JlYWNoICgkZCBpbiAoR2V0LVBTRHJpdmUgLVBTUHJvdmlkZXIgRmlsZVN5c3RlbSAtRXJyb3JBY3Rpb24gU2lsZW50bHlDb250aW51ZSkpIHsKICAgICAgICBpZiAoJGQuVXNlZCAtbmUgJG51bGwgLWFuZCAoJGQuVXNlZCArICRkLkZyZWUpIC1ndCAwKSB7CiAgICAgICAgICAgICR0b3RhbCA9ICRkLlVzZWQgKyAkZC5GcmVlCiAgICAgICAgICAgICRwY3QgICA9IFtNYXRoXTo6Um91bmQoKCRkLlVzZWQgLyAkdG90YWwpICogMTAwKQogICAgICAgICAgICAkZGlza3MgKz0gW1BTQ3VzdG9tT2JqZWN0XUB7CiAgICAgICAgICAgICAgICBOYW1lICA9ICRkLk5hbWUgKyAiOiIKICAgICAgICAgICAgICAgIFVzZWQgID0gW01hdGhdOjpSb3VuZCgkZC5Vc2VkIC8gMUdCLCAxKQogICAgICAgICAgICAgICAgVG90YWwgPSBbTWF0aF06OlJvdW5kKCR0b3RhbCAvIDFHQiwgMSkKICAgICAgICAgICAgICAgIFBjdCAgID0gJHBjdAogICAgICAgICAgICB9CiAgICAgICAgfQogICAgfQogICAgcmV0dXJuICRkaXNrcwp9CgpmdW5jdGlvbiBHZXQtTmV0U3RhdHMgewogICAgdHJ5IHsKICAgICAgICAkc3RhdHMgPSBHZXQtTmV0QWRhcHRlclN0YXRpc3RpY3MgLUVycm9yQWN0aW9uIFN0b3AgfAogICAgICAgICAgICBXaGVyZS1PYmplY3QgeyAkXy5SZWNlaXZlZEJ5dGVzIC1ndCAwIC1vciAkXy5TZW50Qnl0ZXMgLWd0IDAgfSB8CiAgICAgICAgICAgIFNlbGVjdC1PYmplY3QgLUZpcnN0IDEKICAgICAgICBpZiAoJHN0YXRzKSB7CiAgICAgICAgICAgIHJldHVybiBbUFNDdXN0b21PYmplY3RdQHsKICAgICAgICAgICAgICAgIFJlY3YgPSBbTWF0aF06OlJvdW5kKCRzdGF0cy5SZWNlaXZlZEJ5dGVzIC8gMU1CLCAxKQogICAgICAgICAgICAgICAgU2VudCA9IFtNYXRoXTo6Um91bmQoJHN0YXRzLlNlbnRCeXRlcyAvIDFNQiwgMSkKICAgICAgICAgICAgfQogICAgICAgIH0KICAgIH0gY2F0Y2gge30KICAgIHJldHVybiAkbnVsbAp9CgpmdW5jdGlvbiBHZXQtUG93ZXJQbGFuTmFtZSB7CiAgICB0cnkgewogICAgICAgICRsaW5lID0gcG93ZXJjZmcgL2dldGFjdGl2ZXNjaGVtZSAyPiRudWxsCiAgICAgICAgaWYgKCRsaW5lIC1tYXRjaCAiUG93ZXIgU2NoZW1lIEdVSUQuKlwoKC4rKVwpIikgeyByZXR1cm4gJE1hdGNoZXNbMV0uVHJpbSgpIH0KICAgIH0gY2F0Y2gge30KICAgIHJldHVybiAiVW5rbm93biIKfQoKZnVuY3Rpb24gR2V0LVVwdGltZVN0ciB7CiAgICAkdXAgPSAoR2V0LURhdGUpIC0gKGdjaW0gV2luMzJfT3BlcmF0aW5nU3lzdGVtKS5MYXN0Qm9vdFVwVGltZQogICAgcmV0dXJuICIkKCR1cC5EYXlzKWQgJCgkdXAuSG91cnMpaCAkKCR1cC5NaW51dGVzKW0iCn0KCmZ1bmN0aW9uIEdldC1TdGFydHVwQ291bnQgewogICAgJGNvdW50ID0gMAogICAgdHJ5IHsKICAgICAgICAkaGtjdSA9IEdldC1JdGVtUHJvcGVydHkgIkhLQ1U6XFNvZnR3YXJlXE1pY3Jvc29mdFxXaW5kb3dzXEN1cnJlbnRWZXJzaW9uXFJ1biIgLUVBIFN0b3AKICAgICAgICAkY291bnQgKz0gKCRoa2N1LlBTT2JqZWN0LlByb3BlcnRpZXMgfCBXaGVyZS1PYmplY3QgeyAkXy5OYW1lIC1ub3RtYXRjaCAiXlBTIiB9KS5Db3VudAogICAgfSBjYXRjaCB7fQogICAgdHJ5IHsKICAgICAgICAkaGtsbSA9IEdldC1JdGVtUHJvcGVydHkgIkhLTE06XFNvZnR3YXJlXE1pY3Jvc29mdFxXaW5kb3dzXEN1cnJlbnRWZXJzaW9uXFJ1biIgLUVBIFN0b3AKICAgICAgICAkY291bnQgKz0gKCRoa2xtLlBTT2JqZWN0LlByb3BlcnRpZXMgfCBXaGVyZS1PYmplY3QgeyAkXy5OYW1lIC1ub3RtYXRjaCAiXlBTIiB9KS5Db3VudAogICAgfSBjYXRjaCB7fQogICAgcmV0dXJuICRjb3VudAp9CgpmdW5jdGlvbiBTaG93LURhc2hib2FyZCB7CiAgICAkb3MgID0gZ2NpbSBXaW4zMl9PcGVyYXRpbmdTeXN0ZW0KICAgICRjcHUgPSBnY2ltIFdpbjMyX1Byb2Nlc3NvcgoKICAgIHRyeSB7CiAgICAgICAgJGNwdUxvYWQgPSBbTWF0aF06OlJvdW5kKChHZXQtQ291bnRlciAnXFByb2Nlc3NvcihfVG90YWwpXCUgUHJvY2Vzc29yIFRpbWUnIC1TYW1wbGVJbnRlcnZhbCAxIC1NYXhTYW1wbGVzIDEpLkNvdW50ZXJTYW1wbGVzLkNvb2tlZFZhbHVlKQogICAgfSBjYXRjaCB7ICRjcHVMb2FkID0gMCB9CgogICAgJHJhbVRvdGFsID0gW01hdGhdOjpSb3VuZCgkb3MuVG90YWxWaXNpYmxlTWVtb3J5U2l6ZSAvIDFNQiwgMSkKICAgICRyYW1GcmVlICA9IFtNYXRoXTo6Um91bmQoJG9zLkZyZWVQaHlzaWNhbE1lbW9yeSAvIDFNQiwgMSkKICAgICRyYW1Vc2VkICA9IFtNYXRoXTo6Um91bmQoJHJhbVRvdGFsIC0gJHJhbUZyZWUsIDEpCiAgICAkcmFtUGN0ICAgPSBbTWF0aF06OlJvdW5kKCgkcmFtVXNlZCAvICRyYW1Ub3RhbCkgKiAxMDApCgogICAgJGRpc2tzICAgICA9IEdldC1EaXNrSW5mbwogICAgJG5ldCAgICAgICA9IEdldC1OZXRTdGF0cwogICAgJHBvd2VyUGxhbiA9IEdldC1Qb3dlclBsYW5OYW1lCiAgICAkdXB0aW1lICAgID0gR2V0LVVwdGltZVN0cgogICAgJHN0YXJ0dXBzICA9IEdldC1TdGFydHVwQ291bnQKICAgICR0b3BDUFUgICAgPSBHZXQtVG9wUHJvY2Vzc2VzICJDUFUiIDUKICAgICR0b3BSQU0gICAgPSBHZXQtVG9wUHJvY2Vzc2VzICJSQU0iIDUKCiAgICBDbGVhci1Ib3N0CiAgICBXcml0ZS1Ib3N0ICIiCiAgICBXcml0ZS1Ib3N0ICIgICAgICAgICAgICAgICAgID09PT09PT09PT09PT09PT09PT09PT0gU1lTVEVNIElORk8gPT09PT09PT09PT09PT09PT09PT09PSIgLUZvcmVncm91bmRDb2xvciBEYXJrR3JheQogICAgV3JpdGUtSG9zdCAoIiAgICAgICAgICAgICAgICAgIiArIChHZXQtRGF0ZSAtRm9ybWF0ICJkZGRkLCBNTU1NIGRkIHl5eXkgIHwgIEhIOm1tOnNzIikpIC1Gb3JlZ3JvdW5kQ29sb3IgRGFya0dyYXkKICAgIFdyaXRlLUhvc3QgIiAgICAgICAgICAgICAgICAgPT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT0iIC1Gb3JlZ3JvdW5kQ29sb3IgRGFya0dyYXkKICAgIFdyaXRlLUhvc3QgIiIKCiAgICAkbWFjaGluZU5hbWUgPSAkZW52OkNPTVBVVEVSTkFNRQogICAgJG9zTmFtZSAgICAgID0gJG9zLkNhcHRpb24gLXJlcGxhY2UgIk1pY3Jvc29mdCBXaW5kb3dzICIsICJXaW4gIgogICAgJGNwdU5hbWUgICAgID0gKCRjcHUuTmFtZSAtcmVwbGFjZSAiXHMrIiwgIiAiKS5UcmltKCkKICAgIGlmICgkY3B1TmFtZS5MZW5ndGggLWd0IDQ4KSB7ICRjcHVOYW1lID0gJGNwdU5hbWUuU3Vic3RyaW5nKDAsNDgpICsgIi4uLiIgfQoKICAgIFdyaXRlLUhvc3QgIiAgICAgICAgICAgICAgICAgIiAtTm9OZXdsaW5lCiAgICBXcml0ZS1Ib3N0ICRtYWNoaW5lTmFtZSAtTm9OZXdsaW5lIC1Gb3JlZ3JvdW5kQ29sb3IgQ3lhbgogICAgV3JpdGUtSG9zdCAiICB8ICAiIC1Ob05ld2xpbmUgLUZvcmVncm91bmRDb2xvciBEYXJrR3JheQogICAgV3JpdGUtSG9zdCAkb3NOYW1lIC1Ob05ld2xpbmUgLUZvcmVncm91bmRDb2xvciBXaGl0ZQogICAgV3JpdGUtSG9zdCAiICB8ICBVcHRpbWU6ICIgLU5vTmV3bGluZSAtRm9yZWdyb3VuZENvbG9yIERhcmtHcmF5CiAgICBXcml0ZS1Ib3N0ICR1cHRpbWUgLUZvcmVncm91bmRDb2xvciBXaGl0ZQogICAgV3JpdGUtSG9zdCAiICAgICAgICAgICAgICAgICAkY3B1TmFtZSIgLUZvcmVncm91bmRDb2xvciBEYXJrR3JheQogICAgV3JpdGUtSG9zdCAiIgoKICAgIFdyaXRlLUhvc3QgIiAgICAgICAgICAgICAgICAgQ1BVICAiIC1Ob05ld2xpbmUgLUZvcmVncm91bmRDb2xvciBXaGl0ZQogICAgR2V0LUJhclN0cmluZyAkY3B1TG9hZCAxMDAgMzAKICAgIFdyaXRlLUhvc3QgIiRjcHVMb2FkJSIgLUZvcmVncm91bmRDb2xvciBXaGl0ZQogICAgV3JpdGUtSG9zdCAiIgoKICAgIFdyaXRlLUhvc3QgIiAgICAgICAgICAgICAgICAgUkFNICAiIC1Ob05ld2xpbmUgLUZvcmVncm91bmRDb2xvciBXaGl0ZQogICAgR2V0LUJhclN0cmluZyAkcmFtUGN0IDEwMCAzMAogICAgV3JpdGUtSG9zdCAiJHJhbVVzZWQgLyAkcmFtVG90YWwgR0IgICgkcmFtUGN0JSkiIC1Gb3JlZ3JvdW5kQ29sb3IgV2hpdGUKICAgIFdyaXRlLUhvc3QgIiIKCiAgICBmb3JlYWNoICgkZCBpbiAkZGlza3MpIHsKICAgICAgICAkbGFiZWwgPSAoIiAgJCgkZC5OYW1lKSAgIikuUGFkTGVmdCg4KQogICAgICAgIFdyaXRlLUhvc3QgIiAgICAgICAgICAgICAgICAkbGFiZWwiIC1Ob05ld2xpbmUgLUZvcmVncm91bmRDb2xvciBXaGl0ZQogICAgICAgIEdldC1CYXJTdHJpbmcgJGQuUGN0IDEwMCAzMAogICAgICAgIFdyaXRlLUhvc3QgIiQoJGQuVXNlZCkgLyAkKCRkLlRvdGFsKSBHQiAgKCQoJGQuUGN0KSUpIiAtRm9yZWdyb3VuZENvbG9yIFdoaXRlCiAgICB9CiAgICBXcml0ZS1Ib3N0ICIiCgogICAgV3JpdGUtSG9zdCAiICAgICAgICAgICAgICAgICBQb3dlciBQbGFuIDogIiAtTm9OZXdsaW5lIC1Gb3JlZ3JvdW5kQ29sb3IgRGFya0dyYXkKICAgICRwcENvbG9yID0gaWYgKCRwb3dlclBsYW4gLW1hdGNoICJIaWdoIikgeyAiR3JlZW4iIH0gZWxzZWlmICgkcG93ZXJQbGFuIC1tYXRjaCAiQmFsYW5jZWQiKSB7ICJZZWxsb3ciIH0gZWxzZSB7ICJEYXJrR3JheSIgfQogICAgV3JpdGUtSG9zdCAkcG93ZXJQbGFuIC1Gb3JlZ3JvdW5kQ29sb3IgJHBwQ29sb3IKCiAgICBpZiAoJG5ldCkgewogICAgICAgIFdyaXRlLUhvc3QgIiAgICAgICAgICAgICAgICAgTmV0d29yayAgICA6ICIgLU5vTmV3bGluZSAtRm9yZWdyb3VuZENvbG9yIERhcmtHcmF5CiAgICAgICAgV3JpdGUtSG9zdCAiUmVjdiAkKCRuZXQuUmVjdikgTUIgIHwgIFNlbnQgJCgkbmV0LlNlbnQpIE1CICAoc2Vzc2lvbiB0b3RhbHMpIiAtRm9yZWdyb3VuZENvbG9yIFdoaXRlCiAgICB9CgogICAgV3JpdGUtSG9zdCAiICAgICAgICAgICAgICAgICBTdGFydHVwcyAgIDogIiAtTm9OZXdsaW5lIC1Gb3JlZ3JvdW5kQ29sb3IgRGFya0dyYXkKICAgICRzY0NvbG9yID0gaWYgKCRzdGFydHVwcyAtZ3QgMTApIHsgIlJlZCIgfSBlbHNlaWYgKCRzdGFydHVwcyAtZ3QgNSkgeyAiWWVsbG93IiB9IGVsc2UgeyAiR3JlZW4iIH0KICAgIFdyaXRlLUhvc3QgIiRzdGFydHVwcyByZWdpc3RlcmVkIHN0YXJ0dXAgZW50cmllcyIgLUZvcmVncm91bmRDb2xvciAkc2NDb2xvcgoKICAgIFdyaXRlLUhvc3QgIiIKICAgIFdyaXRlLUhvc3QgIiAgICAgICAgICAgICAgICAgLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0iIC1Gb3JlZ3JvdW5kQ29sb3IgRGFya0dyYXkKICAgIFdyaXRlLUhvc3QgIiAgICAgICAgICAgICAgICAgVE9QIEJZIENQVSAgICAgICAgICAgICAgICAgICAgICAgICAgVE9QIEJZIFJBTSIgLUZvcmVncm91bmRDb2xvciBEYXJrR3JheQogICAgV3JpdGUtSG9zdCAiICAgICAgICAgICAgICAgICAtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLSIgLUZvcmVncm91bmRDb2xvciBEYXJrR3JheQoKICAgIGZvciAoJGkgPSAwOyAkaSAtbHQgNTsgJGkrKykgewogICAgICAgICRjUHJvYyAgID0gaWYgKCRpIC1sdCAkdG9wQ1BVLkNvdW50KSB7ICR0b3BDUFVbJGldIH0gZWxzZSB7ICRudWxsIH0KICAgICAgICAkclByb2MgICA9IGlmICgkaSAtbHQgJHRvcFJBTS5Db3VudCkgeyAkdG9wUkFNWyRpXSB9IGVsc2UgeyAkbnVsbCB9CiAgICAgICAgJGNOYW1lICAgPSBpZiAoJGNQcm9jKSB7ICRjUHJvYy5OYW1lLlN1YnN0cmluZygwLFtNYXRoXTo6TWluKCRjUHJvYy5OYW1lLkxlbmd0aCwxOCkpLlBhZFJpZ2h0KDE4KSB9IGVsc2UgeyAiIi5QYWRSaWdodCgxOCkgfQogICAgICAgICRjVmFsICAgID0gaWYgKCRjUHJvYykgeyAkY1Byb2MuVmFsdWUuUGFkTGVmdCgxMCkgfSBlbHNlIHsgIiIuUGFkTGVmdCgxMCkgfQogICAgICAgICRyTmFtZSAgID0gaWYgKCRyUHJvYykgeyAkclByb2MuTmFtZS5TdWJzdHJpbmcoMCxbTWF0aF06Ok1pbigkclByb2MuTmFtZS5MZW5ndGgsMTgpKS5QYWRSaWdodCgxOCkgfSBlbHNlIHsgIiIuUGFkUmlnaHQoMTgpIH0KICAgICAgICAkclZhbCAgICA9IGlmICgkclByb2MpIHsgJHJQcm9jLlZhbHVlLlBhZExlZnQoMTApIH0gZWxzZSB7ICIiLlBhZExlZnQoMTApIH0KCiAgICAgICAgV3JpdGUtSG9zdCAiICAgICAgICAgICAgICAgICAiIC1Ob05ld2xpbmUKICAgICAgICBXcml0ZS1Ib3N0ICRjTmFtZSAtTm9OZXdsaW5lIC1Gb3JlZ3JvdW5kQ29sb3IgV2hpdGUKICAgICAgICBXcml0ZS1Ib3N0ICRjVmFsICAtTm9OZXdsaW5lIC1Gb3JlZ3JvdW5kQ29sb3IgWWVsbG93CiAgICAgICAgV3JpdGUtSG9zdCAiICAgICIgIC1Ob05ld2xpbmUKICAgICAgICBXcml0ZS1Ib3N0ICRyTmFtZSAtTm9OZXdsaW5lIC1Gb3JlZ3JvdW5kQ29sb3IgV2hpdGUKICAgICAgICBXcml0ZS1Ib3N0ICRyVmFsICAtRm9yZWdyb3VuZENvbG9yIEN5YW4KICAgIH0KCiAgICBXcml0ZS1Ib3N0ICIiCiAgICBXcml0ZS1Ib3N0ICIgICAgICAgICAgICAgICAgID09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09IiAtRm9yZWdyb3VuZENvbG9yIERhcmtHcmF5CiAgICBXcml0ZS1Ib3N0ICIgICAgICAgICAgICAgICAgIFIgPSBSZWZyZXNoICAgIFEgPSBCYWNrIFRvIE1lbnUiIC1Gb3JlZ3JvdW5kQ29sb3IgRGFya0dyYXkKICAgIFdyaXRlLUhvc3QgIiIKfQoKJHJ1bm5pbmcgPSAkdHJ1ZQp3aGlsZSAoJHJ1bm5pbmcpIHsKICAgIFNob3ctRGFzaGJvYXJkCiAgICAkd2FpdGVkID0gMAogICAgJGtleSAgICA9ICRudWxsCiAgICB3aGlsZSAoJHdhaXRlZCAtbHQgNTAwMCkgewogICAgICAgIGlmIChbQ29uc29sZV06OktleUF2YWlsYWJsZSkgeyAka2V5ID0gW0NvbnNvbGVdOjpSZWFkS2V5KCR0cnVlKTsgYnJlYWsgfQogICAgICAgIFN0YXJ0LVNsZWVwIC1NaWxsaXNlY29uZHMgMTAwCiAgICAgICAgJHdhaXRlZCArPSAxMDAKICAgIH0KICAgIGlmICgka2V5KSB7CiAgICAgICAgaWYgKCRrZXkuS2V5Q2hhci5Ub1N0cmluZygpLlRvVXBwZXIoKSAtZXEgIlEiKSB7ICRydW5uaW5nID0gJGZhbHNlIH0KICAgIH0KfQpXcml0ZS1Ib3N0ICIiCg==');[System.IO.File]::WriteAllBytes('%HK_PS_SI%',$b)"
powershell -NoProfile -ExecutionPolicy Bypass -File "%HK_PS_SI%"
del "%HK_PS_SI%" >nul 2>&1
call :log "System Info Panel closed"
goto pause_return

:: startup manager: toggle run keys and scheduled tasks
:startup_manager
call :log "Opened Startup Manager"
set "HK_PS_TEMP=%HK_STATE%\hk_startup_mgr.ps1"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$b=[System.Convert]::FromBase64String('CmZ1bmN0aW9uIFNob3ctSGVhZGVyIHsKICAgIFdyaXRlLUhvc3QgIiIKICAgIFdyaXRlLUhvc3QgIiAgICAgICAgICAgICAgICAgPT09PT09PT09PT09PT09PT09PT09IFNUQVJUVVAgTUFOQUdFUiA9PT09PT09PT09PT09PT09PT09PT0iIC1Gb3JlZ3JvdW5kQ29sb3IgRGFya0dyYXkKICAgIFdyaXRlLUhvc3QgIiAgICAgICAgICAgICAgICAgU2hvd2luZyBzdGFydHVwIGVudHJpZXM6IFJlZ2lzdHJ5IFJ1biBLZXlzICsgVGFzayBTY2hlZHVsZXIiIC1Gb3JlZ3JvdW5kQ29sb3IgRGFya0dyYXkKICAgIFdyaXRlLUhvc3QgIiAgICAgICAgICAgICAgICAgPT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PSIgLUZvcmVncm91bmRDb2xvciBEYXJrR3JheQogICAgV3JpdGUtSG9zdCAiIgp9CgpmdW5jdGlvbiBHZXQtUmVnaXN0cnlTdGFydHVwcyB7CiAgICAkZW50cmllcyA9IEAoKQogICAgJHBhdGhzID0gQCgKICAgICAgICBAeyBIaXZlPSJIS0NVIjsgUGF0aD0iU29mdHdhcmVcTWljcm9zb2Z0XFdpbmRvd3NcQ3VycmVudFZlcnNpb25cUnVuIiB9LAogICAgICAgIEB7IEhpdmU9IkhLTE0iOyBQYXRoPSJTb2Z0d2FyZVxNaWNyb3NvZnRcV2luZG93c1xDdXJyZW50VmVyc2lvblxSdW4iIH0sCiAgICAgICAgQHsgSGl2ZT0iSEtDVSI7IFBhdGg9IlNvZnR3YXJlXE1pY3Jvc29mdFxXaW5kb3dzXEN1cnJlbnRWZXJzaW9uXFJ1bk9uY2UiIH0KICAgICkKICAgIGZvcmVhY2ggKCRwIGluICRwYXRocykgewogICAgICAgICRyZWdQYXRoID0gIiQoJHAuSGl2ZSk6XCQoJHAuUGF0aCkiCiAgICAgICAgdHJ5IHsKICAgICAgICAgICAgJGtleSA9IEdldC1JdGVtUHJvcGVydHkgLVBhdGggJHJlZ1BhdGggLUVycm9yQWN0aW9uIFN0b3AKICAgICAgICAgICAgZm9yZWFjaCAoJHByb3AgaW4gJGtleS5QU09iamVjdC5Qcm9wZXJ0aWVzKSB7CiAgICAgICAgICAgICAgICBpZiAoJHByb3AuTmFtZSAtbWF0Y2ggIl5QUyIgLW9yICRwcm9wLk5hbWUgLWVxICIoZGVmYXVsdCkiKSB7IGNvbnRpbnVlIH0KICAgICAgICAgICAgICAgICRhcHByb3ZlZEJhc2UgPSBpZiAoJHAuSGl2ZSAtZXEgIkhLQ1UiKSB7CiAgICAgICAgICAgICAgICAgICAgIkhLQ1U6XFNvZnR3YXJlXE1pY3Jvc29mdFxXaW5kb3dzXEN1cnJlbnRWZXJzaW9uXEV4cGxvcmVyXFN0YXJ0dXBBcHByb3ZlZFxSdW4iCiAgICAgICAgICAgICAgICB9IGVsc2UgewogICAgICAgICAgICAgICAgICAgICJIS0xNOlxTb2Z0d2FyZVxNaWNyb3NvZnRcV2luZG93c1xDdXJyZW50VmVyc2lvblxFeHBsb3JlclxTdGFydHVwQXBwcm92ZWRcUnVuIgogICAgICAgICAgICAgICAgfQogICAgICAgICAgICAgICAgJHN0YXR1cyA9ICJFbmFibGVkIgogICAgICAgICAgICAgICAgdHJ5IHsKICAgICAgICAgICAgICAgICAgICAkdmFsID0gKEdldC1JdGVtUHJvcGVydHkgLVBhdGggJGFwcHJvdmVkQmFzZSAtTmFtZSAkcHJvcC5OYW1lIC1FcnJvckFjdGlvbiBTdG9wKS4oJHByb3AuTmFtZSkKICAgICAgICAgICAgICAgICAgICBpZiAoJHZhbCAtYW5kICR2YWxbMF0gLWVxIDMpIHsgJHN0YXR1cyA9ICJEaXNhYmxlZCIgfQogICAgICAgICAgICAgICAgfSBjYXRjaCB7fQogICAgICAgICAgICAgICAgJGVudHJpZXMgKz0gW1BTQ3VzdG9tT2JqZWN0XUB7CiAgICAgICAgICAgICAgICAgICAgVHlwZSAgICAgICAgID0gIlJlZ2lzdHJ5IgogICAgICAgICAgICAgICAgICAgIEhpdmUgICAgICAgICA9ICRwLkhpdmUKICAgICAgICAgICAgICAgICAgICBSZWdQYXRoICAgICAgPSAkcC5QYXRoCiAgICAgICAgICAgICAgICAgICAgQXBwcm92ZWRQYXRoID0gJGFwcHJvdmVkQmFzZQogICAgICAgICAgICAgICAgICAgIE5hbWUgICAgICAgICA9ICRwcm9wLk5hbWUKICAgICAgICAgICAgICAgICAgICBDb21tYW5kICAgICAgPSBbc3RyaW5nXSRwcm9wLlZhbHVlCiAgICAgICAgICAgICAgICAgICAgU3RhdHVzICAgICAgID0gJHN0YXR1cwogICAgICAgICAgICAgICAgfQogICAgICAgICAgICB9CiAgICAgICAgfSBjYXRjaCB7fQogICAgfQogICAgcmV0dXJuICRlbnRyaWVzCn0KCmZ1bmN0aW9uIEdldC1TY2hlZHVsZXJTdGFydHVwcyB7CiAgICAkZW50cmllcyA9IEAoKQogICAgdHJ5IHsKICAgICAgICAkYWxsVGFza3MgPSBHZXQtU2NoZWR1bGVkVGFzayAtRXJyb3JBY3Rpb24gU3RvcAogICAgICAgIGZvcmVhY2ggKCR0IGluICRhbGxUYXNrcykgewogICAgICAgICAgICAkaGFzTG9naW5UcmlnZ2VyID0gJGZhbHNlCiAgICAgICAgICAgIGZvcmVhY2ggKCR0cmlnZ2VyIGluICR0LlRyaWdnZXJzKSB7CiAgICAgICAgICAgICAgICAkY24gPSAkdHJpZ2dlci5DaW1DbGFzcy5DaW1DbGFzc05hbWUKICAgICAgICAgICAgICAgIGlmICgkY24gLW1hdGNoICJMb2dvbiIgLW9yICRjbiAtbWF0Y2ggIkJvb3QiKSB7ICRoYXNMb2dpblRyaWdnZXIgPSAkdHJ1ZTsgYnJlYWsgfQogICAgICAgICAgICB9CiAgICAgICAgICAgIGlmICgtbm90ICRoYXNMb2dpblRyaWdnZXIpIHsgY29udGludWUgfQogICAgICAgICAgICAkc2tpcFBhdGhzID0gQCgiXE1pY3Jvc29mdFxXaW5kb3dzXFVwZGF0ZU9yY2hlc3RyYXRvclwiLCAiXE1pY3Jvc29mdFxXaW5kb3dzXFdpbmRvd3NVcGRhdGVcIiwgIlxNaWNyb3NvZnRcV2luZG93c1xEZWZyYWdcIikKICAgICAgICAgICAgJHNraXAgPSAkZmFsc2UKICAgICAgICAgICAgZm9yZWFjaCAoJHNwIGluICRza2lwUGF0aHMpIHsgaWYgKCR0LlRhc2tQYXRoIC1saWtlICIqJHNwKiIpIHsgJHNraXAgPSAkdHJ1ZTsgYnJlYWsgfSB9CiAgICAgICAgICAgIGlmICgkc2tpcCkgeyBjb250aW51ZSB9CiAgICAgICAgICAgICRhY3Rpb24gPSAkdC5BY3Rpb25zIHwgU2VsZWN0LU9iamVjdCAtRmlyc3QgMQogICAgICAgICAgICAkY21kID0gaWYgKCRhY3Rpb24gLWFuZCAkYWN0aW9uLkV4ZWN1dGUpIHsgJGFjdGlvbi5FeGVjdXRlIH0gZWxzZSB7ICIobm8gYWN0aW9uKSIgfQogICAgICAgICAgICAkZW50cmllcyArPSBbUFNDdXN0b21PYmplY3RdQHsKICAgICAgICAgICAgICAgIFR5cGUgICAgICAgICA9ICJTY2hlZHVsZXIiCiAgICAgICAgICAgICAgICBIaXZlICAgICAgICAgPSAkdC5UYXNrUGF0aAogICAgICAgICAgICAgICAgQXBwcm92ZWRQYXRoID0gIiIKICAgICAgICAgICAgICAgIFJlZ1BhdGggICAgICA9ICIiCiAgICAgICAgICAgICAgICBOYW1lICAgICAgICAgPSAkdC5UYXNrTmFtZQogICAgICAgICAgICAgICAgQ29tbWFuZCAgICAgID0gJGNtZAogICAgICAgICAgICAgICAgU3RhdHVzICAgICAgID0gaWYgKCR0LlN0YXRlIC1lcSAiUmVhZHkiIC1vciAkdC5TdGF0ZSAtZXEgIlJ1bm5pbmciKSB7ICJFbmFibGVkIiB9IGVsc2UgeyAiRGlzYWJsZWQiIH0KICAgICAgICAgICAgfQogICAgICAgIH0KICAgIH0gY2F0Y2gge30KICAgIHJldHVybiAkZW50cmllcwp9CgpmdW5jdGlvbiBTaG93LUVudHJpZXMoJGVudHJpZXMpIHsKICAgICRpID0gMQogICAgZm9yZWFjaCAoJGUgaW4gJGVudHJpZXMpIHsKICAgICAgICAkY29sb3IgICAgID0gaWYgKCRlLlN0YXR1cyAtZXEgIkVuYWJsZWQiKSB7ICJHcmVlbiIgfSBlbHNlIHsgIkRhcmtHcmF5IiB9CiAgICAgICAgJHN0YXR1c1RhZyA9IGlmICgkZS5TdGF0dXMgLWVxICJFbmFibGVkIikgeyAiW09OXSAiIH0gZWxzZSB7ICJbT0ZGXSIgfQogICAgICAgICR0eXBlVGFnICAgPSBpZiAoJGUuVHlwZSAtZXEgIlJlZ2lzdHJ5IikgIHsgIlJFRyAiIH0gZWxzZSB7ICJUQVNLIiB9CiAgICAgICAgJG5hbWUgPSAkZS5OYW1lLlN1YnN0cmluZygwLCBbTWF0aF06Ok1pbigkZS5OYW1lLkxlbmd0aCwgMzIpKS5QYWRSaWdodCgzMikKICAgICAgICAkY21kICA9ICRlLkNvbW1hbmQuU3Vic3RyaW5nKDAsIFtNYXRoXTo6TWluKCRlLkNvbW1hbmQuTGVuZ3RoLCAzNikpCiAgICAgICAgV3JpdGUtSG9zdCAiICAgICAgICAgICAgICAgICBbIiAtRm9yZWdyb3VuZENvbG9yIERhcmtHcmF5IC1Ob05ld2xpbmUKICAgICAgICBXcml0ZS1Ib3N0ICgiezAsMn0iIC1mICRpKSAtRm9yZWdyb3VuZENvbG9yIEN5YW4gLU5vTmV3bGluZQogICAgICAgIFdyaXRlLUhvc3QgIl0gIiAtRm9yZWdyb3VuZENvbG9yIERhcmtHcmF5IC1Ob05ld2xpbmUKICAgICAgICBXcml0ZS1Ib3N0ICIkc3RhdHVzVGFnICIgLUZvcmVncm91bmRDb2xvciAkY29sb3IgLU5vTmV3bGluZQogICAgICAgIFdyaXRlLUhvc3QgIiR0eXBlVGFnICAiIC1Gb3JlZ3JvdW5kQ29sb3IgRGFya0dyYXkgLU5vTmV3bGluZQogICAgICAgIFdyaXRlLUhvc3QgIiRuYW1lICAiIC1Gb3JlZ3JvdW5kQ29sb3IgV2hpdGUgLU5vTmV3bGluZQogICAgICAgIFdyaXRlLUhvc3QgIiRjbWQiIC1Gb3JlZ3JvdW5kQ29sb3IgRGFya0dyYXkKICAgICAgICAkaSsrCiAgICB9Cn0KCmZ1bmN0aW9uIFRvZ2dsZS1SZWdpc3RyeUVudHJ5KCRlbnRyeSkgewogICAgJGFwcHJvdmVkUGF0aCA9ICRlbnRyeS5BcHByb3ZlZFBhdGgKICAgIHRyeSB7CiAgICAgICAgaWYgKC1ub3QgKFRlc3QtUGF0aCAkYXBwcm92ZWRQYXRoKSkgewogICAgICAgICAgICBOZXctSXRlbSAtUGF0aCAkYXBwcm92ZWRQYXRoIC1Gb3JjZSB8IE91dC1OdWxsCiAgICAgICAgfQogICAgICAgICRieXRlcyA9IGlmICgkZW50cnkuU3RhdHVzIC1lcSAiRW5hYmxlZCIpIHsgW2J5dGVbXV0oQCgzKSArIChAKDApICogMTUpKSB9IGVsc2UgeyBbYnl0ZVtdXShAKDIpICsgKEAoMCkgKiAxNSkpIH0KICAgICAgICBTZXQtSXRlbVByb3BlcnR5IC1QYXRoICRhcHByb3ZlZFBhdGggLU5hbWUgJGVudHJ5Lk5hbWUgLVZhbHVlICRieXRlcyAtVHlwZSBCaW5hcnkgLUVycm9yQWN0aW9uIFN0b3AKICAgICAgICAkbXNnID0gaWYgKCRlbnRyeS5TdGF0dXMgLWVxICJFbmFibGVkIikgeyAiRGlzYWJsZWQiIH0gZWxzZSB7ICJFbmFibGVkIiB9CiAgICAgICAgJGNvbCA9IGlmICgkZW50cnkuU3RhdHVzIC1lcSAiRW5hYmxlZCIpIHsgIlllbGxvdyIgfSBlbHNlIHsgIkdyZWVuIiB9CiAgICAgICAgV3JpdGUtSG9zdCAiICAgICAgICAgICAgICAgICAkbXNnYDogJCgkZW50cnkuTmFtZSkiIC1Gb3JlZ3JvdW5kQ29sb3IgJGNvbAogICAgfSBjYXRjaCB7CiAgICAgICAgV3JpdGUtSG9zdCAiICAgICAgICAgICAgICAgICBGYWlsZWQ6ICQoJGVudHJ5Lk5hbWUpIC0gJF8iIC1Gb3JlZ3JvdW5kQ29sb3IgUmVkCiAgICB9Cn0KCmZ1bmN0aW9uIFRvZ2dsZS1TY2hlZHVsZXJFbnRyeSgkZW50cnkpIHsKICAgIHRyeSB7CiAgICAgICAgJHRhc2tQYXRoID0gJGVudHJ5LkhpdmUKICAgICAgICBpZiAoLW5vdCAkdGFza1BhdGguRW5kc1dpdGgoIlwiKSkgeyAkdGFza1BhdGggPSAkdGFza1BhdGggKyAiXCIgfQogICAgICAgIGlmICgkZW50cnkuU3RhdHVzIC1lcSAiRW5hYmxlZCIpIHsKICAgICAgICAgICAgRGlzYWJsZS1TY2hlZHVsZWRUYXNrIC1UYXNrTmFtZSAkZW50cnkuTmFtZSAtVGFza1BhdGggJHRhc2tQYXRoIC1FcnJvckFjdGlvbiBTdG9wIHwgT3V0LU51bGwKICAgICAgICAgICAgV3JpdGUtSG9zdCAiICAgICAgICAgICAgICAgICBEaXNhYmxlZCBUYXNrOiAkKCRlbnRyeS5OYW1lKSIgLUZvcmVncm91bmRDb2xvciBZZWxsb3cKICAgICAgICB9IGVsc2UgewogICAgICAgICAgICBFbmFibGUtU2NoZWR1bGVkVGFzayAtVGFza05hbWUgJGVudHJ5Lk5hbWUgLVRhc2tQYXRoICR0YXNrUGF0aCAtRXJyb3JBY3Rpb24gU3RvcCB8IE91dC1OdWxsCiAgICAgICAgICAgIFdyaXRlLUhvc3QgIiAgICAgICAgICAgICAgICAgRW5hYmxlZCBUYXNrOiAkKCRlbnRyeS5OYW1lKSIgLUZvcmVncm91bmRDb2xvciBHcmVlbgogICAgICAgIH0KICAgIH0gY2F0Y2ggewogICAgICAgIFdyaXRlLUhvc3QgIiAgICAgICAgICAgICAgICAgRmFpbGVkIHRvIHRvZ2dsZTogJCgkZW50cnkuTmFtZSkiIC1Gb3JlZ3JvdW5kQ29sb3IgUmVkCiAgICAgICAgV3JpdGUtSG9zdCAiICAgICAgICAgICAgICAgICAkKCRfLkV4Y2VwdGlvbi5NZXNzYWdlKSIgLUZvcmVncm91bmRDb2xvciBEYXJrR3JheQogICAgfQp9CgokcnVubmluZyA9ICR0cnVlCndoaWxlICgkcnVubmluZykgewogICAgQ2xlYXItSG9zdAogICAgU2hvdy1IZWFkZXIKICAgIFdyaXRlLUhvc3QgIiAgICAgICAgICAgICAgICAgU2Nhbm5pbmcgZW50cmllcy4uLiIgLUZvcmVncm91bmRDb2xvciBEYXJrR3JheQogICAgJGFsbEVudHJpZXMgPSBAKCkKICAgICRhbGxFbnRyaWVzICs9IEdldC1SZWdpc3RyeVN0YXJ0dXBzCiAgICAkYWxsRW50cmllcyArPSBHZXQtU2NoZWR1bGVyU3RhcnR1cHMKICAgIENsZWFyLUhvc3QKICAgIFNob3ctSGVhZGVyCiAgICBpZiAoJGFsbEVudHJpZXMuQ291bnQgLWVxIDApIHsKICAgICAgICBXcml0ZS1Ib3N0ICIgICAgICAgICAgICAgICAgIE5vIHN0YXJ0dXAgZW50cmllcyBmb3VuZC4iIC1Gb3JlZ3JvdW5kQ29sb3IgRGFya0dyYXkKICAgIH0gZWxzZSB7CiAgICAgICAgU2hvdy1FbnRyaWVzICRhbGxFbnRyaWVzCiAgICB9CiAgICBXcml0ZS1Ib3N0ICIiCiAgICBXcml0ZS1Ib3N0ICIgICAgICAgICAgICAgICAgID09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT0iIC1Gb3JlZ3JvdW5kQ29sb3IgRGFya0dyYXkKICAgIFdyaXRlLUhvc3QgIiAgICAgICAgICAgICAgICAgRW50ZXIgYSBudW1iZXIgdG8gdG9nZ2xlIE9OL09GRiwgb3IgMCB0byBnbyBiYWNrLiIgLUZvcmVncm91bmRDb2xvciBEYXJrR3JheQogICAgV3JpdGUtSG9zdCAiIgogICAgJGNob2ljZSA9IFJlYWQtSG9zdCAiICAgICAgICAgICAgICAgICA+ICIKICAgIGlmICgkY2hvaWNlIC1lcSAiMCIgLW9yICRjaG9pY2UgLWVxICIiKSB7ICRydW5uaW5nID0gJGZhbHNlOyBicmVhayB9CiAgICAkaWR4ID0gJG51bGwKICAgIGlmIChbaW50XTo6VHJ5UGFyc2UoJGNob2ljZSwgW3JlZl0kaWR4KSkgewogICAgICAgIGlmICgkaWR4IC1nZSAxIC1hbmQgJGlkeCAtbGUgJGFsbEVudHJpZXMuQ291bnQpIHsKICAgICAgICAgICAgJGVudHJ5ID0gJGFsbEVudHJpZXNbJGlkeCAtIDFdCiAgICAgICAgICAgIFdyaXRlLUhvc3QgIiIKICAgICAgICAgICAgaWYgKCRlbnRyeS5UeXBlIC1lcSAiUmVnaXN0cnkiKSB7IFRvZ2dsZS1SZWdpc3RyeUVudHJ5ICRlbnRyeSB9IGVsc2UgeyBUb2dnbGUtU2NoZWR1bGVyRW50cnkgJGVudHJ5IH0KICAgICAgICAgICAgU3RhcnQtU2xlZXAgLU1pbGxpc2Vjb25kcyAxMjAwCiAgICAgICAgfSBlbHNlIHsKICAgICAgICAgICAgV3JpdGUtSG9zdCAiICAgICAgICAgICAgICAgICBJbnZhbGlkIHNlbGVjdGlvbi4iIC1Gb3JlZ3JvdW5kQ29sb3IgUmVkCiAgICAgICAgICAgIFN0YXJ0LVNsZWVwIC1NaWxsaXNlY29uZHMgNzAwCiAgICAgICAgfQogICAgfQp9CldyaXRlLUhvc3QgIiIK');[System.IO.File]::WriteAllBytes('%HK_PS_TEMP%',$b)"
powershell -NoProfile -ExecutionPolicy Bypass -File "%HK_PS_TEMP%"
del "%HK_PS_TEMP%" >nul 2>&1
call :log "Startup Manager session ended"
goto pause_return

:: apps manager: list installed apps and launch their uninstallers
:apps_manager
call :log "Opened Apps Manager"
set "HK_PS_APPS=%HK_STATE%\hk_apps_mgr.ps1"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$b=[System.Convert]::FromBase64String('CmZ1bmN0aW9uIFNob3ctSGVhZGVyIHsKICAgIFdyaXRlLUhvc3QgIiIKICAgIFdyaXRlLUhvc3QgIiAgICAgICAgICAgICAgICAgPT09PT09PT09PT09PT09PT09PT09PT09IEFQUFMgTUFOQUdFUiA9PT09PT09PT09PT09PT09PT09PT09PT0iIC1Gb3JlZ3JvdW5kQ29sb3IgRGFya0dyYXkKICAgIFdyaXRlLUhvc3QgIiAgICAgICAgICAgICAgICAgTGlzdHMgaW5zdGFsbGVkIGFwcHMuIEVudGVyIGEgbnVtYmVyIHRvIGxhdW5jaCBpdHMgdW5pbnN0YWxsZXIuIiAtRm9yZWdyb3VuZENvbG9yIERhcmtHcmF5CiAgICBXcml0ZS1Ib3N0ICIgICAgICAgICAgICAgICAgID09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09IiAtRm9yZWdyb3VuZENvbG9yIERhcmtHcmF5CiAgICBXcml0ZS1Ib3N0ICIiCn0KCmZ1bmN0aW9uIEdldC1JbnN0YWxsZWRBcHBzIHsKICAgICRwYXRocyA9IEAoCiAgICAgICAgIkhLTE06XFNvZnR3YXJlXE1pY3Jvc29mdFxXaW5kb3dzXEN1cnJlbnRWZXJzaW9uXFVuaW5zdGFsbFwqIiwKICAgICAgICAiSEtMTTpcU29mdHdhcmVcV09XNjQzMk5vZGVcTWljcm9zb2Z0XFdpbmRvd3NcQ3VycmVudFZlcnNpb25cVW5pbnN0YWxsXCoiLAogICAgICAgICJIS0NVOlxTb2Z0d2FyZVxNaWNyb3NvZnRcV2luZG93c1xDdXJyZW50VmVyc2lvblxVbmluc3RhbGxcKiIKICAgICkKICAgICRhcHBzID0gZm9yZWFjaCAoJHBhdGggaW4gJHBhdGhzKSB7CiAgICAgICAgR2V0LUl0ZW1Qcm9wZXJ0eSAkcGF0aCAtRXJyb3JBY3Rpb24gU2lsZW50bHlDb250aW51ZSB8CiAgICAgICAgV2hlcmUtT2JqZWN0IHsgJF8uRGlzcGxheU5hbWUgLWFuZCAkXy5Vbmluc3RhbGxTdHJpbmcgfQogICAgfQogICAgcmV0dXJuICRhcHBzIHwgU29ydC1PYmplY3QgRGlzcGxheU5hbWUgfCBHcm91cC1PYmplY3QgRGlzcGxheU5hbWUgfCBGb3JFYWNoLU9iamVjdCB7ICRfLkdyb3VwWzBdIH0KfQoKJHJ1bm5pbmcgPSAkdHJ1ZQp3aGlsZSAoJHJ1bm5pbmcpIHsKICAgIENsZWFyLUhvc3QKICAgIFNob3ctSGVhZGVyCiAgICBXcml0ZS1Ib3N0ICIgICAgICAgICAgICAgICAgIExvYWRpbmcgaW5zdGFsbGVkIGFwcHMuLi4iIC1Gb3JlZ3JvdW5kQ29sb3IgRGFya0dyYXkKICAgICRhcHBzID0gQChHZXQtSW5zdGFsbGVkQXBwcykKICAgIENsZWFyLUhvc3QKICAgIFNob3ctSGVhZGVyCiAgICBpZiAoJGFwcHMuQ291bnQgLWVxIDApIHsKICAgICAgICBXcml0ZS1Ib3N0ICIgICAgICAgICAgICAgICAgIE5vIGFwcGxpY2F0aW9ucyBmb3VuZC4iIC1Gb3JlZ3JvdW5kQ29sb3IgRGFya0dyYXkKICAgIH0gZWxzZSB7CiAgICAgICAgJGkgPSAxCiAgICAgICAgZm9yZWFjaCAoJGFwcCBpbiAkYXBwcykgewogICAgICAgICAgICAkbmFtZSAgID0gJGFwcC5EaXNwbGF5TmFtZS5TdWJzdHJpbmcoMCwgW01hdGhdOjpNaW4oJGFwcC5EaXNwbGF5TmFtZS5MZW5ndGgsIDQ2KSkuUGFkUmlnaHQoNDYpCiAgICAgICAgICAgICR2ZXIgICAgPSBpZiAoJGFwcC5EaXNwbGF5VmVyc2lvbikgeyAkYXBwLkRpc3BsYXlWZXJzaW9uLlN1YnN0cmluZygwLCBbTWF0aF06Ok1pbigkYXBwLkRpc3BsYXlWZXJzaW9uLkxlbmd0aCwgMTQpKS5QYWRSaWdodCgxNCkgfSBlbHNlIHsgIiIuUGFkUmlnaHQoMTQpIH0KICAgICAgICAgICAgJHNpemVNQiA9IGlmICgkYXBwLkVzdGltYXRlZFNpemUpIHsgIiQoW01hdGhdOjpSb3VuZCgkYXBwLkVzdGltYXRlZFNpemUgLyAxMDI0LCAxKSkgTUIiIH0gZWxzZSB7ICIgICAgICIgfQogICAgICAgICAgICBXcml0ZS1Ib3N0ICIgICAgICAgICAgICAgICAgIFsiIC1Gb3JlZ3JvdW5kQ29sb3IgRGFya0dyYXkgLU5vTmV3bGluZQogICAgICAgICAgICBXcml0ZS1Ib3N0ICgiezAsM30iIC1mICRpKSAtRm9yZWdyb3VuZENvbG9yIEN5YW4gLU5vTmV3bGluZQogICAgICAgICAgICBXcml0ZS1Ib3N0ICJdICAiIC1Gb3JlZ3JvdW5kQ29sb3IgRGFya0dyYXkgLU5vTmV3bGluZQogICAgICAgICAgICBXcml0ZS1Ib3N0ICIkbmFtZSAgIiAtRm9yZWdyb3VuZENvbG9yIFdoaXRlIC1Ob05ld2xpbmUKICAgICAgICAgICAgV3JpdGUtSG9zdCAiJHZlciAgIiAtRm9yZWdyb3VuZENvbG9yIERhcmtHcmF5IC1Ob05ld2xpbmUKICAgICAgICAgICAgV3JpdGUtSG9zdCAiJHNpemVNQiIgLUZvcmVncm91bmRDb2xvciBEYXJrR3JheQogICAgICAgICAgICAkaSsrCiAgICAgICAgfQogICAgfQogICAgV3JpdGUtSG9zdCAiIgogICAgV3JpdGUtSG9zdCAiICAgICAgICAgICAgICAgICA9PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PSIgLUZvcmVncm91bmRDb2xvciBEYXJrR3JheQogICAgV3JpdGUtSG9zdCAiICAgICAgICAgICAgICAgICBFbnRlciBhIG51bWJlciB0byBsYXVuY2ggdW5pbnN0YWxsZXIsIG9yIDAgdG8gZ28gYmFjay4iIC1Gb3JlZ3JvdW5kQ29sb3IgRGFya0dyYXkKICAgIFdyaXRlLUhvc3QgIiIKICAgICRjaG9pY2UgPSBSZWFkLUhvc3QgIiAgICAgICAgICAgICAgICAgPiAiCiAgICBpZiAoJGNob2ljZSAtZXEgIjAiIC1vciAkY2hvaWNlIC1lcSAiIikgeyAkcnVubmluZyA9ICRmYWxzZTsgYnJlYWsgfQogICAgJGlkeCA9ICRudWxsCiAgICBpZiAoW2ludF06OlRyeVBhcnNlKCRjaG9pY2UsIFtyZWZdJGlkeCkpIHsKICAgICAgICBpZiAoJGlkeCAtZ2UgMSAtYW5kICRpZHggLWxlICRhcHBzLkNvdW50KSB7CiAgICAgICAgICAgICRhcHAgPSAkYXBwc1skaWR4IC0gMV0KICAgICAgICAgICAgV3JpdGUtSG9zdCAiIgogICAgICAgICAgICBXcml0ZS1Ib3N0ICIgICAgICAgICAgICAgICAgIExhdW5jaGluZyB1bmluc3RhbGxlciBmb3I6ICQoJGFwcC5EaXNwbGF5TmFtZSkiIC1Gb3JlZ3JvdW5kQ29sb3IgWWVsbG93CiAgICAgICAgICAgIFdyaXRlLUhvc3QgIiAgICAgICAgICAgICAgICAgVGhlIHVuaW5zdGFsbGVyIG1heSBvcGVuIGEgc2VwYXJhdGUgd2luZG93LiIgLUZvcmVncm91bmRDb2xvciBEYXJrR3JheQogICAgICAgICAgICB0cnkgewogICAgICAgICAgICAgICAgJHUgPSAkYXBwLlVuaW5zdGFsbFN0cmluZwogICAgICAgICAgICAgICAgaWYgKCR1IC1tYXRjaCAiTXNpRXhlYyIpIHsKICAgICAgICAgICAgICAgICAgICAkZ3VpZCA9IFtyZWdleF06Ok1hdGNoKCR1LCAiXHtbXn1dK1x9IikuVmFsdWUKICAgICAgICAgICAgICAgICAgICBpZiAoJGd1aWQpIHsgU3RhcnQtUHJvY2VzcyAibXNpZXhlYy5leGUiIC1Bcmd1bWVudExpc3QgIi94ICRndWlkIC9xYiIgLVdhaXQgfQogICAgICAgICAgICAgICAgICAgIGVsc2UgeyBTdGFydC1Qcm9jZXNzICJtc2lleGVjLmV4ZSIgLUFyZ3VtZW50TGlzdCAkdS5SZXBsYWNlKCJNc2lFeGVjLmV4ZSAiLCIiKSAtV2FpdCB9CiAgICAgICAgICAgICAgICB9IGVsc2UgewogICAgICAgICAgICAgICAgICAgICMgUGFyc2UgcXVvdGVkIHZzIHVucXVvdGVkIHVuaW5zdGFsbCBzdHJpbmdzIHNhZmVseQogICAgICAgICAgICAgICAgICAgIGlmICgkdSAtbWF0Y2ggJ14iKFteIl0rKSIoLiopJCcpIHsKICAgICAgICAgICAgICAgICAgICAgICAgU3RhcnQtUHJvY2VzcyAkTWF0Y2hlc1sxXSAtQXJndW1lbnRMaXN0ICRNYXRjaGVzWzJdLlRyaW0oKSAtV2FpdAogICAgICAgICAgICAgICAgICAgIH0gZWxzZSB7CiAgICAgICAgICAgICAgICAgICAgICAgICRwYXJ0cyA9ICR1IC1zcGxpdCAiICIsMgogICAgICAgICAgICAgICAgICAgICAgICBTdGFydC1Qcm9jZXNzICRwYXJ0c1swXSAtQXJndW1lbnRMaXN0ICgkcGFydHNbMV0gPz8gIiIpIC1XYWl0CiAgICAgICAgICAgICAgICAgICAgfQogICAgICAgICAgICAgICAgfQogICAgICAgICAgICB9IGNhdGNoIHsKICAgICAgICAgICAgICAgIFdyaXRlLUhvc3QgIiAgICAgICAgICAgICAgICAgQ291bGQgbm90IGxhdW5jaCB1bmluc3RhbGxlcjogJF8iIC1Gb3JlZ3JvdW5kQ29sb3IgUmVkCiAgICAgICAgICAgIH0KICAgICAgICAgICAgV3JpdGUtSG9zdCAiIgogICAgICAgICAgICBXcml0ZS1Ib3N0ICIgICAgICAgICAgICAgICAgIERvbmUuIFByZXNzIGFueSBrZXkgdG8gcmVmcmVzaC4uLiIgLUZvcmVncm91bmRDb2xvciBHcmVlbgogICAgICAgICAgICAkbnVsbCA9ICRIb3N0LlVJLlJhd1VJLlJlYWRLZXkoIk5vRWNobyxJbmNsdWRlS2V5RG93biIpCiAgICAgICAgfSBlbHNlIHsKICAgICAgICAgICAgV3JpdGUtSG9zdCAiICAgICAgICAgICAgICAgICBJbnZhbGlkIHNlbGVjdGlvbi4iIC1Gb3JlZ3JvdW5kQ29sb3IgUmVkCiAgICAgICAgICAgIFN0YXJ0LVNsZWVwIC1NaWxsaXNlY29uZHMgNzAwCiAgICAgICAgfQogICAgfQp9CldyaXRlLUhvc3QgIiIK');[System.IO.File]::WriteAllBytes('%HK_PS_APPS%',$b)"
powershell -NoProfile -ExecutionPolicy Bypass -File "%HK_PS_APPS%"
del "%HK_PS_APPS%" >nul 2>&1
call :log "Apps Manager session ended"
goto pause_return
