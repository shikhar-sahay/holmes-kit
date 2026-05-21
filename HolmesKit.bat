@echo off
chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"
title HolmesKit
mode con: cols=110 lines=42

call :require_admin
call :init_paths
call :startup_notice

:main_menu
cls
call :print_header
powershell -NoProfile -Command ^
  "Write-Host '  ------------------------------------------------------------------------' -ForegroundColor DarkGray;" ^
  "Write-Host '';" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '0' -ForegroundColor Yellow -NoNewline; Write-Host ']  Apply All Tweaks' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '1' -ForegroundColor Cyan -NoNewline; Write-Host ']  Core Optimization' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '2' -ForegroundColor Cyan -NoNewline; Write-Host ']  Advanced Tweaks' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '3' -ForegroundColor Cyan -NoNewline; Write-Host ']  Gaming Mode' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '4' -ForegroundColor Cyan -NoNewline; Write-Host ']  Restore Defaults' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '5' -ForegroundColor Cyan -NoNewline; Write-Host ']  System Info' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '6' -ForegroundColor Cyan -NoNewline; Write-Host ']  Startup Manager' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '7' -ForegroundColor Cyan -NoNewline; Write-Host ']  Apps Manager' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '8' -ForegroundColor Red -NoNewline; Write-Host ']  Exit' -ForegroundColor White;" ^
  "Write-Host '';" ^
  "Write-Host '  ------------------------------------------------------------------------' -ForegroundColor DarkGray;"
echo.
set /p HK_MAIN=  ^> 
if "%HK_MAIN%"=="0" goto apply_all
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
  "Write-Host '  -------------------------- CORE OPTIMIZATION ---------------------------' -ForegroundColor DarkGray;" ^
  "Write-Host '';" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '1' -ForegroundColor Cyan -NoNewline; Write-Host ']  Run Full Core Optimization' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '2' -ForegroundColor Cyan -NoNewline; Write-Host ']  Cleanup Temp And Cache Files' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '3' -ForegroundColor Cyan -NoNewline; Write-Host ']  Apply Power Plan Optimization' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '4' -ForegroundColor Cyan -NoNewline; Write-Host ']  Safe Background Cleanup' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '5' -ForegroundColor Red -NoNewline; Write-Host ']  Back' -ForegroundColor White;" ^
  "Write-Host '';" ^
  "Write-Host '  ------------------------------------------------------------------------' -ForegroundColor DarkGray;"
echo.
set /p HK_CORE=  ^> 
set "HK_RETURN_MENU=core"
if "%HK_CORE%"=="1" (
  call :confirm_open "Run Full Core Optimization"
  powershell -NoProfile -Command ^
    "Write-Host '  What this does:' -ForegroundColor White;" ^
    "Write-Host '  Runs all core steps in sequence: temp cleanup, High Performance' -ForegroundColor DarkGray;" ^
    "Write-Host '  power plan, background app termination, and Explorer restart.' -ForegroundColor DarkGray;" ^
    "Write-Host '';" ^
    "Write-Host '  Affected: Temp folders, Power Plan, Background Processes, Explorer' -ForegroundColor Yellow;"
  call :confirm_close
  if "!HK_CONFIRMED!"=="1" call :run_full_core & goto pause_return
  goto core_menu
)
if "%HK_CORE%"=="2" (
  call :confirm_open "Cleanup Temp And Cache Files"
  powershell -NoProfile -Command ^
    "Write-Host '  What this does:' -ForegroundColor White;" ^
    "Write-Host '  Deletes contents of %%TEMP%%, Windows Temp, INetCache, and GPU shader' -ForegroundColor DarkGray;" ^
    "Write-Host '  caches (NVIDIA DXCache, GLCache, D3DSCache). Also flushes the DNS' -ForegroundColor DarkGray;" ^
    "Write-Host '  resolver cache.' -ForegroundColor DarkGray;" ^
    "Write-Host '';" ^
    "Write-Host '  Affected: Temp folders, DNS Cache, GPU Shader Caches' -ForegroundColor Yellow;"
  call :confirm_close
  if "!HK_CONFIRMED!"=="1" call :ensure_backup & call :cleanup_temp & goto pause_return
  goto core_menu
)
if "%HK_CORE%"=="3" (
  call :confirm_open "Apply Power Plan Optimization"
  powershell -NoProfile -Command ^
    "Write-Host '  What this does:' -ForegroundColor White;" ^
    "Write-Host '  Switches your active power plan to High Performance. This prevents' -ForegroundColor DarkGray;" ^
    "Write-Host '  the CPU from throttling down during load and removes artificial' -ForegroundColor DarkGray;" ^
    "Write-Host '  frequency limits.' -ForegroundColor DarkGray;" ^
    "Write-Host '';" ^
    "Write-Host '  Affected: Windows Power Plan (reversible via Restore menu)' -ForegroundColor Yellow;"
  call :confirm_close
  if "!HK_CONFIRMED!"=="1" call :ensure_backup & call :apply_power_plan & goto pause_return
  goto core_menu
)
if "%HK_CORE%"=="4" (
  call :confirm_open "Safe Background Cleanup"
  powershell -NoProfile -Command ^
    "Write-Host '  What this does:' -ForegroundColor White;" ^
    "Write-Host '  Force-closes common background apps that consume RAM and CPU:' -ForegroundColor DarkGray;" ^
    "Write-Host '  OneDrive, Teams, Spotify, Discord, Epic Games, Battle.net, Adobe' -ForegroundColor DarkGray;" ^
    "Write-Host '  background services, and open browsers.' -ForegroundColor DarkGray;" ^
    "Write-Host '';" ^
    "Write-Host '  Affected: Running processes (apps can be reopened normally)' -ForegroundColor Yellow;"
  call :confirm_close
  if "!HK_CONFIRMED!"=="1" call :ensure_backup & call :cleanup_background & goto pause_return
  goto core_menu
)
if "%HK_CORE%"=="5" goto main_menu
goto core_menu

:advanced_menu
cls
call :print_header
powershell -NoProfile -Command ^
  "Write-Host '  --------------------------- ADVANCED TWEAKS ----------------------------' -ForegroundColor DarkGray;" ^
  "Write-Host '';" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '1' -ForegroundColor Cyan -NoNewline; Write-Host ']  UI Responsiveness Tweaks' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '2' -ForegroundColor Cyan -NoNewline; Write-Host ']  Visual Effects Performance Mode' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '3' -ForegroundColor Cyan -NoNewline; Write-Host ']  Startup Pruning' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '4' -ForegroundColor Cyan -NoNewline; Write-Host ']  Network Maintenance' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '5' -ForegroundColor Cyan -NoNewline; Write-Host ']  Background Services Cleanup' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '6' -ForegroundColor Cyan -NoNewline; Write-Host ']  Disable Hibernation' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '7' -ForegroundColor Red -NoNewline; Write-Host ']  Back' -ForegroundColor White;" ^
  "Write-Host '';" ^
  "Write-Host '  ------------------------------------------------------------------------' -ForegroundColor DarkGray;"
echo.
set /p HK_ADV=  ^> 
set "HK_RETURN_MENU=advanced"
if "%HK_ADV%"=="1" (
  call :confirm_open "UI Responsiveness Tweaks"
  powershell -NoProfile -Command ^
    "Write-Host '  What this does:' -ForegroundColor White;" ^
    "Write-Host '  Reduces menu animation delay (100ms), lowers app hang timeout, sets' -ForegroundColor DarkGray;" ^
    "Write-Host '  foreground apps to receive longer CPU time slices' -ForegroundColor DarkGray;" ^
    "Write-Host '  (Win32PrioritySeparation), and disables NTFS Last Access timestamps' -ForegroundColor DarkGray;" ^
    "Write-Host '  to cut background disk I/O.' -ForegroundColor DarkGray;" ^
    "Write-Host '';" ^
    "Write-Host '  Affected: Registry (HKCU\Control Panel\Desktop), NTFS flags' -ForegroundColor Yellow;"
  call :confirm_close
  if "!HK_CONFIRMED!"=="1" call :ensure_backup & call :ui_responsiveness_tweaks & goto pause_return
  goto advanced_menu
)
if "%HK_ADV%"=="2" (
  call :confirm_open "Visual Effects Performance Mode"
  powershell -NoProfile -Command ^
    "Write-Host '  What this does:' -ForegroundColor White;" ^
    "Write-Host '  Disables window animations, taskbar animations, list-view shadows,' -ForegroundColor DarkGray;" ^
    "Write-Host '  and alpha selection effects. Sets Windows to Performance mode for' -ForegroundColor DarkGray;" ^
    "Write-Host '  visual effects. Noticeable on lower-end hardware.' -ForegroundColor DarkGray;" ^
    "Write-Host '';" ^
    "Write-Host '  Affected: Registry (HKCU Explorer\VisualEffects, WindowMetrics)' -ForegroundColor Yellow;"
  call :confirm_close
  if "!HK_CONFIRMED!"=="1" call :ensure_backup & call :visual_performance_mode & goto pause_return
  goto advanced_menu
)
if "%HK_ADV%"=="3" (
  call :confirm_open "Startup Pruning"
  powershell -NoProfile -Command ^
    "Write-Host '  What this does:' -ForegroundColor White;" ^
    "Write-Host '  Removes startup registry entries for: OneDrive, Discord, Spotify,' -ForegroundColor DarkGray;" ^
    "Write-Host '  Skype, Zoom, Epic Games Launcher, Teams. These apps will no longer' -ForegroundColor DarkGray;" ^
    "Write-Host '  auto-launch at login. You can still open them manually.' -ForegroundColor DarkGray;" ^
    "Write-Host '';" ^
    "Write-Host '  Affected: Registry (HKCU\Run and HKLM\Run startup keys)' -ForegroundColor Yellow;"
  call :confirm_close
  if "!HK_CONFIRMED!"=="1" call :ensure_backup & call :startup_pruning & goto pause_return
  goto advanced_menu
)
if "%HK_ADV%"=="4" (
  call :confirm_open "Network Maintenance"
  powershell -NoProfile -Command ^
    "Write-Host '  What this does:' -ForegroundColor White;" ^
    "Write-Host '  Flushes DNS cache, releases and renews your IP address, resets the' -ForegroundColor DarkGray;" ^
    "Write-Host '  Winsock catalog, and resets the TCP/IP stack. Useful if you are' -ForegroundColor DarkGray;" ^
    "Write-Host '  experiencing degraded network performance.' -ForegroundColor DarkGray;" ^
    "Write-Host '';" ^
    "Write-Host '  Affected: DNS Cache, IP Lease, Winsock, TCP/IP Stack (restart rec.)' -ForegroundColor Yellow;"
  call :confirm_close
  if "!HK_CONFIRMED!"=="1" call :ensure_backup & call :network_maintenance & goto pause_return
  goto advanced_menu
)
if "%HK_ADV%"=="5" (
  call :confirm_open "Background Services Cleanup"
  powershell -NoProfile -Command ^
    "Write-Host '  What this does:' -ForegroundColor White;" ^
    "Write-Host '  Stops and disables three high-overhead background services: SysMain' -ForegroundColor DarkGray;" ^
    "Write-Host '  (Superfetch memory preloader), WSearch (Windows Search Indexer),' -ForegroundColor DarkGray;" ^
    "Write-Host '  and DiagTrack (Telemetry). Service states are saved for restore.' -ForegroundColor DarkGray;" ^
    "Write-Host '';" ^
    "Write-Host '  Affected: SysMain, WSearch, DiagTrack services (restorable)' -ForegroundColor Yellow;"
  call :confirm_close
  if "!HK_CONFIRMED!"=="1" call :ensure_backup & call :services_cleanup & goto pause_return
  goto advanced_menu
)
if "%HK_ADV%"=="6" (
  call :confirm_open "Disable Hibernation"
  powershell -NoProfile -Command ^
    "Write-Host '  What this does:' -ForegroundColor White;" ^
    "Write-Host '  Disables Windows hibernation and removes the hiberfil.sys file,' -ForegroundColor DarkGray;" ^
    "Write-Host '  which can be several GB on your system drive. Sleep mode is' -ForegroundColor DarkGray;" ^
    "Write-Host '  unaffected.' -ForegroundColor DarkGray;" ^
    "Write-Host '';" ^
    "Write-Host '  Affected: Hibernation state, hiberfil.sys (frees disk space)' -ForegroundColor Yellow;"
  call :confirm_close
  if "!HK_CONFIRMED!"=="1" call :ensure_backup & call :disable_hibernation & goto pause_return
  goto advanced_menu
)
if "%HK_ADV%"=="7" goto main_menu
goto advanced_menu

:gaming_menu
cls
call :print_header
powershell -NoProfile -Command ^
  "Write-Host '  ----------------------------- GAMING MODE ------------------------------' -ForegroundColor DarkGray;" ^
  "Write-Host '';" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '1' -ForegroundColor Cyan -NoNewline; Write-Host ']  FPS Tweaks' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '2' -ForegroundColor Cyan -NoNewline; Write-Host ']  Latency Maintenance' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '3' -ForegroundColor Cyan -NoNewline; Write-Host ']  Full Gaming Prep' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '4' -ForegroundColor Red -NoNewline; Write-Host ']  Back' -ForegroundColor White;" ^
  "Write-Host '';" ^
  "Write-Host '  ------------------------------------------------------------------------' -ForegroundColor DarkGray;"
echo.
set /p HK_GAME=  ^> 
set "HK_RETURN_MENU=gaming"
if "%HK_GAME%"=="1" (
  call :confirm_open "FPS Tweaks"
  powershell -NoProfile -Command ^
    "Write-Host '  What this does:' -ForegroundColor White;" ^
    "Write-Host '  Disables Xbox Game DVR/capture overlay, sets GPU and I/O scheduling' -ForegroundColor DarkGray;" ^
    "Write-Host '  priority to High for game processes, sets SystemResponsiveness to 0' -ForegroundColor DarkGray;" ^
    "Write-Host '  (dedicates multimedia scheduler fully to games), and applies High' -ForegroundColor DarkGray;" ^
    "Write-Host '  Performance power plan.' -ForegroundColor DarkGray;" ^
    "Write-Host '';" ^
    "Write-Host '  Affected: GameDVR keys, Multimedia Scheduler (MMCSS), Power Plan' -ForegroundColor Yellow;"
  call :confirm_close
  if "!HK_CONFIRMED!"=="1" call :ensure_backup & call :gaming_fps_tweaks & goto pause_return
  goto gaming_menu
)
if "%HK_GAME%"=="2" (
  call :confirm_open "Latency Maintenance"
  powershell -NoProfile -Command ^
    "Write-Host '  What this does:' -ForegroundColor White;" ^
    "Write-Host '  Flushes DNS, resets Winsock, enables TCP Fast Open and RSS (Receive' -ForegroundColor DarkGray;" ^
    "Write-Host '  Side Scaling), disables Nagle algorithm for lower latency, and' -ForegroundColor DarkGray;" ^
    "Write-Host '  pauses Windows Update delivery (BITS and DoSvc) during your session.' -ForegroundColor DarkGray;" ^
    "Write-Host '';" ^
    "Write-Host '  Affected: TCP/IP stack, Winsock, Windows Update delivery services' -ForegroundColor Yellow;"
  call :confirm_close
  if "!HK_CONFIRMED!"=="1" call :ensure_backup & call :gaming_latency_maintenance & goto pause_return
  goto gaming_menu
)
if "%HK_GAME%"=="3" (
  call :confirm_open "Full Gaming Prep"
  powershell -NoProfile -Command ^
    "Write-Host '  What this does:' -ForegroundColor White;" ^
    "Write-Host '  Runs FPS Tweaks and Latency Maintenance in sequence. Applies all' -ForegroundColor DarkGray;" ^
    "Write-Host '  gaming optimizations in one step.' -ForegroundColor DarkGray;" ^
    "Write-Host '';" ^
    "Write-Host '  Affected: All of the above combined' -ForegroundColor Yellow;"
  call :confirm_close
  if "!HK_CONFIRMED!"=="1" call :ensure_backup & call :gaming_full_prep & goto pause_return
  goto gaming_menu
)
if "%HK_GAME%"=="4" goto main_menu
goto gaming_menu

:restore_menu
cls
call :print_header
powershell -NoProfile -Command ^
  "Write-Host '  --------------------------- RESTORE DEFAULTS ---------------------------' -ForegroundColor DarkGray;" ^
  "Write-Host '';" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '1' -ForegroundColor Cyan -NoNewline; Write-Host ']  Restore Latest Registry Backups' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '2' -ForegroundColor Cyan -NoNewline; Write-Host ']  Restore Default Power Schemes' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '3' -ForegroundColor Cyan -NoNewline; Write-Host ']  Re-Enable Background Services' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '4' -ForegroundColor Cyan -NoNewline; Write-Host ']  Re-Enable Hibernation' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '5' -ForegroundColor Cyan -NoNewline; Write-Host ']  Reset Network Stack' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '6' -ForegroundColor Cyan -NoNewline; Write-Host ']  Restart Explorer' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '7' -ForegroundColor Red -NoNewline; Write-Host ']  Back' -ForegroundColor White;" ^
  "Write-Host '';" ^
  "Write-Host '  ------------------------------------------------------------------------' -ForegroundColor DarkGray;"
echo.
set /p HK_RESTORE=  ^> 
if "%HK_RESTORE%"=="1" call :restore_latest_registry & goto pause_return
if "%HK_RESTORE%"=="2" call :restore_power_defaults & goto pause_return
if "%HK_RESTORE%"=="3" call :restore_services & goto pause_return
if "%HK_RESTORE%"=="4" call :enable_hibernation & goto pause_return
if "%HK_RESTORE%"=="5" call :restore_network_defaults & goto pause_return
if "%HK_RESTORE%"=="6" call :restart_explorer & goto pause_return
if "%HK_RESTORE%"=="7" goto main_menu
goto restore_menu

:pause_return
set "HK_CONFIRMED=0"
echo.
powershell -NoProfile -Command "Write-Host '  Done. Press any key to return to the menu...' -ForegroundColor Green"
echo.
pause >nul
if "!HK_RETURN_MENU!"=="core"     goto core_menu
if "!HK_RETURN_MENU!"=="advanced" goto advanced_menu
if "!HK_RETURN_MENU!"=="gaming"   goto gaming_menu
if "!HK_RETURN_MENU!"=="restore"  goto restore_menu
goto main_menu

:: draws the confirm screen header for a given option title
:: call :confirm_open "Title"
:confirm_open
set "HK_CONFIRMED=0"
cls
call :print_header
powershell -NoProfile -Command ^
  "Write-Host '  ------------------------------------------------------------------------' -ForegroundColor DarkGray;" ^
  "Write-Host '  %~1' -ForegroundColor Cyan;" ^
  "Write-Host '  ------------------------------------------------------------------------' -ForegroundColor DarkGray;"
echo.
exit /b 0

:: draws the bottom divider, prompt, and sets HK_CONFIRMED
:confirm_close
echo.
powershell -NoProfile -Command "Write-Host '  ------------------------------------------------------------------------' -ForegroundColor DarkGray"
echo.
set /p HK_CONFIRM=  Proceed? [Y/N]:  
if /I "!HK_CONFIRM!"=="Y" set "HK_CONFIRMED=1"
echo.
exit /b 0

:: logo
:print_header
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0modules\logo.ps1"
exit /b 0

:: simple timestamped log
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
powershell -NoProfile -Command "Write-Host '  ------------------------------------------------------------------------' -ForegroundColor DarkGray"
echo.
set /p HK_RP=  Create a restore point now? [Y/N]:  
if /I "%HK_RP%"=="Y" call :create_restore_point
exit /b 0

:: open system protection window for user to create restore point manually
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
set "HK_SVC_FILE=%HK_LATEST%\service_states.txt"
echo SysMain > "%HK_SVC_FILE%"
sc qc SysMain 2>nul | findstr "START_TYPE" >> "%HK_SVC_FILE%"
echo WSearch >> "%HK_SVC_FILE%"
sc qc WSearch 2>nul | findstr "START_TYPE" >> "%HK_SVC_FILE%"
echo DiagTrack >> "%HK_SVC_FILE%"
sc qc DiagTrack 2>nul | findstr "START_TYPE" >> "%HK_SVC_FILE%"
sc stop SysMain >nul 2>&1
sc config SysMain start= disabled >nul 2>&1
powershell -NoProfile -Command "Write-Host '    [-] SysMain (Superfetch) stopped and disabled' -ForegroundColor DarkGray"
sc stop WSearch >nul 2>&1
sc config WSearch start= disabled >nul 2>&1
powershell -NoProfile -Command "Write-Host '    [-] WSearch (Search Indexer) stopped and disabled' -ForegroundColor DarkGray"
sc stop DiagTrack >nul 2>&1
sc config DiagTrack start= disabled >nul 2>&1
powershell -NoProfile -Command "Write-Host '    [-] DiagTrack (Telemetry) stopped and disabled' -ForegroundColor DarkGray"
echo.
call :log "Background services cleanup complete"
powershell -NoProfile -Command "Write-Host '  Background Services Cleanup Completed.' -ForegroundColor Green"
powershell -NoProfile -Command "Write-Host '  Note: Windows Search will no longer index files.' -ForegroundColor DarkGray"
powershell -NoProfile -Command "Write-Host '  Re-enable via the Restore menu.' -ForegroundColor DarkGray"
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
reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v AppCaptureEnabled /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\Software\Policies\Microsoft\Windows\GameDVR" /v AllowGameDVR /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d "8" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d "6" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d "High" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "SFIO Priority" /t REG_SZ /d "High" /f >nul 2>&1
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
netsh int tcp set global fastopen=enabled >nul 2>&1
netsh int tcp set global rss=enabled >nul 2>&1
netsh int tcp set global autotuninglevel=disabled >nul 2>&1
powershell -NoProfile -Command "Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces' | ForEach-Object { Set-ItemProperty -Path $_.PSPath -Name 'TcpAckFrequency' -Value 1 -Type DWord -Force -EA SilentlyContinue; Set-ItemProperty -Path $_.PSPath -Name 'TCPNoDelay' -Value 1 -Type DWord -Force -EA SilentlyContinue }" >nul 2>&1
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
fsutil behavior set disablelastaccess 0 >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d "2" /f >nul 2>&1
netsh int tcp set global autotuninglevel=normal >nul 2>&1
powershell -NoProfile -Command "Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces' | ForEach-Object { Remove-ItemProperty -Path $_.PSPath -Name 'TcpAckFrequency' -Force -EA SilentlyContinue; Remove-ItemProperty -Path $_.PSPath -Name 'TCPNoDelay' -Force -EA SilentlyContinue }" >nul 2>&1
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

:: apply all: every meaningful tweak in one confirmed pass
:apply_all
cls
call :print_header
powershell -NoProfile -Command ^
  "Write-Host '  --------------------------- APPLY ALL TWEAKS ---------------------------' -ForegroundColor DarkGray;" ^
  "Write-Host '';" ^
  "Write-Host '  Everything below runs in sequence. Read before continuing.' -ForegroundColor White;" ^
  "Write-Host '';" ^
  "Write-Host '  TEMP CLEANUP' -ForegroundColor Cyan;" ^
  "Write-Host '    Deletes %TEMP%, Windows\Temp, INetCache, and GPU shader' -ForegroundColor DarkGray;" ^
  "Write-Host '    caches (NVIDIA DXCache, GLCache, D3DSCache). Flushes DNS.' -ForegroundColor DarkGray;" ^
  "Write-Host '';" ^
  "Write-Host '  POWER PLAN' -ForegroundColor Cyan;" ^
  "Write-Host '    Switches to High Performance. Prevents CPU frequency' -ForegroundColor DarkGray;" ^
  "Write-Host '    throttling under load. Increases power draw on laptops.' -ForegroundColor DarkGray;" ^
  "Write-Host '';" ^
  "Write-Host '  BACKGROUND APPS' -ForegroundColor Cyan;" ^
  "Write-Host '    Force-closes: OneDrive, Teams, Spotify, Discord, Epic,' -ForegroundColor DarkGray;" ^
  "Write-Host '    Battle.net, Adobe helpers, Chrome, Edge, Firefox.' -ForegroundColor DarkGray;" ^
  "Write-Host '';" ^
  "Write-Host '  UI RESPONSIVENESS' -ForegroundColor Cyan;" ^
  "Write-Host '    Menu delay 100ms. App hang timeout 4s. Foreground apps' -ForegroundColor DarkGray;" ^
  "Write-Host '    get longer CPU slices (Win32PrioritySeparation=26).' -ForegroundColor DarkGray;" ^
  "Write-Host '    NTFS last-access timestamps disabled (less disk I/O).' -ForegroundColor DarkGray;" ^
  "Write-Host '';" ^
  "Write-Host '  VISUAL EFFECTS' -ForegroundColor Cyan;" ^
  "Write-Host '    Disables window/taskbar animations, list shadows, alpha' -ForegroundColor DarkGray;" ^
  "Write-Host '    selection. Sets VisualFXSetting to Performance mode.' -ForegroundColor DarkGray;" ^
  "Write-Host '';" ^
  "Write-Host '  STARTUP PRUNING' -ForegroundColor Cyan;" ^
  "Write-Host '    Removes Run key entries for OneDrive, Discord, Spotify,' -ForegroundColor DarkGray;" ^
  "Write-Host '    Skype, Zoom, Epic, Teams. Apps still work manually.' -ForegroundColor DarkGray;" ^
  "Write-Host '';" ^
  "Write-Host '  BACKGROUND SERVICES' -ForegroundColor Cyan;" ^
  "Write-Host '    Stops + disables SysMain (Superfetch memory preloader),' -ForegroundColor DarkGray;" ^
  "Write-Host '    WSearch (file indexer), DiagTrack (telemetry).' -ForegroundColor DarkGray;" ^
  "Write-Host '    Restorable from Restore menu.' -ForegroundColor DarkGray;" ^
  "Write-Host '';" ^
  "Write-Host '  HIBERNATION' -ForegroundColor Cyan;" ^
  "Write-Host '    Disabled. Removes hiberfil.sys (can be several GB).' -ForegroundColor DarkGray;" ^
  "Write-Host '    Sleep mode is unaffected.' -ForegroundColor DarkGray;" ^
  "Write-Host '';" ^
  "Write-Host '  GAMING - FPS' -ForegroundColor Cyan;" ^
  "Write-Host '    Xbox Game DVR/capture off. MMCSS game thread priority' -ForegroundColor DarkGray;" ^
  "Write-Host '    set to High. SystemResponsiveness=0. GPU Priority=8.' -ForegroundColor DarkGray;" ^
  "Write-Host '';" ^
  "Write-Host '  GAMING - LATENCY' -ForegroundColor Cyan;" ^
  "Write-Host '    TCP Fast Open on. Nagle off per adapter. RSS on.' -ForegroundColor DarkGray;" ^
  "Write-Host '    TCP autotuning disabled. Windows Update delivery paused.' -ForegroundColor DarkGray;" ^
  "Write-Host '';" ^
  "Write-Host '  Registry backed up before anything runs. All reversible.' -ForegroundColor Yellow;" ^
  "Write-Host '  A restart is recommended after this completes.' -ForegroundColor Yellow;" ^
  "Write-Host '';" ^
  "Write-Host '  ------------------------------------------------------------------------' -ForegroundColor DarkGray;"
echo.
set /p HK_APPLYALL=  Proceed? [Y/N]:  
if /I "!HK_APPLYALL!" NEQ "Y" goto main_menu
echo.
call :ensure_backup
call :cleanup_temp
call :apply_power_plan
call :cleanup_background
call :ui_responsiveness_tweaks
call :visual_performance_mode
call :startup_pruning
call :services_cleanup
call :disable_hibernation
call :gaming_fps_tweaks
call :gaming_latency_maintenance
echo.
powershell -NoProfile -Command "Write-Host '  ------------------------------------------------------------------------' -ForegroundColor DarkGray"
powershell -NoProfile -Command "Write-Host '  All tweaks applied. Restart when ready.' -ForegroundColor Green"
powershell -NoProfile -Command "Write-Host '  Log: HolmesKit_Backups\holmeskit.log' -ForegroundColor DarkGray"
call :log "Apply All completed"
goto pause_return

:: system info: real-time dashboard, refreshes every 5s
:system_info
call :log "Opened System Info Panel"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0modules\sysinfo.ps1"
call :log "System Info Panel closed"
goto pause_return

:: startup manager: toggle run keys and scheduled tasks
:startup_manager
call :log "Opened Startup Manager"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0modules\startup_mgr.ps1"
call :log "Startup Manager session ended"
goto pause_return

:: apps manager: list installed apps and launch their uninstallers
:apps_manager
call :log "Opened Apps Manager"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0modules\apps_mgr.ps1"
call :log "Apps Manager session ended"
goto pause_return