@echo off
chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"
title HolmesKit
mode con: cols=100 lines=40

call :require_admin
call :init_paths
call :startup_notice

:: ================================================================
:main_menu
cls
call :print_header
powershell -NoProfile -Command ^
  "Write-Host '  ================================================================' -ForegroundColor DarkGray;" ^
  "Write-Host '';" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '1' -ForegroundColor Cyan -NoNewline; Write-Host ']  Core Optimization' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '2' -ForegroundColor Cyan -NoNewline; Write-Host ']  Advanced Tweaks' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '3' -ForegroundColor Cyan -NoNewline; Write-Host ']  Gaming Mode' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '4' -ForegroundColor Cyan -NoNewline; Write-Host ']  Restore Defaults' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '5' -ForegroundColor Red -NoNewline; Write-Host ']  Exit' -ForegroundColor White;" ^
  "Write-Host '';" ^
  "Write-Host '  ================================================================' -ForegroundColor DarkGray;"
echo.
set /p HK_MAIN=  ^> 
if "%HK_MAIN%"=="1" goto core_menu
if "%HK_MAIN%"=="2" goto advanced_menu
if "%HK_MAIN%"=="3" goto gaming_menu
if "%HK_MAIN%"=="4" goto restore_menu
if "%HK_MAIN%"=="5" exit /b 0
goto main_menu

:: ================================================================
:core_menu
cls
call :print_header
powershell -NoProfile -Command ^
  "Write-Host '  ==================== CORE OPTIMIZATION ====================' -ForegroundColor DarkGray;" ^
  "Write-Host '';" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '1' -ForegroundColor Cyan -NoNewline; Write-Host ']  Run Full Core Optimization' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '2' -ForegroundColor Cyan -NoNewline; Write-Host ']  Cleanup Temp And Cache Files' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '3' -ForegroundColor Cyan -NoNewline; Write-Host ']  Apply Power Plan Optimization' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '4' -ForegroundColor Cyan -NoNewline; Write-Host ']  Safe Background Cleanup' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '5' -ForegroundColor Red -NoNewline; Write-Host ']  Back' -ForegroundColor White;" ^
  "Write-Host '';" ^
  "Write-Host '  ===========================================================' -ForegroundColor DarkGray;"
echo.
set /p HK_CORE=  ^> 
if "%HK_CORE%"=="1" call :confirm_run "Run Full Core Optimization" "Runs all core steps in sequence: temp cleanup, High Performance power plan, background app termination, and Explorer restart." "Affected: Temp folders, Power Plan, Background Processes, Explorer" & if "!HK_CONFIRMED!"=="1" call :run_full_core & goto pause_return
if "%HK_CORE%"=="2" call :confirm_run "Cleanup Temp And Cache Files" "Deletes contents of %%TEMP%%, Windows Temp, INetCache, and GPU shader caches (NVIDIA DXCache, GLCache, D3DSCache). Also flushes the DNS resolver cache." "Affected: Temp folders, DNS Cache, GPU Shader Caches" & if "!HK_CONFIRMED!"=="1" call :ensure_backup & call :cleanup_temp & goto pause_return
if "%HK_CORE%"=="3" call :confirm_run "Apply Power Plan Optimization" "Switches your active power plan to High Performance. This prevents the CPU from throttling down during load and removes artificial frequency limits." "Affected: Windows Power Plan (reversible via Restore menu)" & if "!HK_CONFIRMED!"=="1" call :ensure_backup & call :apply_power_plan & goto pause_return
if "%HK_CORE%"=="4" call :confirm_run "Safe Background Cleanup" "Force-closes common background apps that consume RAM and CPU: OneDrive, Teams, Spotify, Discord, Epic Games, Battle.net, Adobe background services, and open browsers." "Affected: Running processes (apps can be reopened normally)" & if "!HK_CONFIRMED!"=="1" call :ensure_backup & call :cleanup_background & goto pause_return
if "%HK_CORE%"=="5" goto main_menu
goto core_menu

:: ================================================================
:advanced_menu
cls
call :print_header
powershell -NoProfile -Command ^
  "Write-Host '  ===================== ADVANCED TWEAKS =====================' -ForegroundColor DarkGray;" ^
  "Write-Host '';" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '1' -ForegroundColor Cyan -NoNewline; Write-Host ']  UI Responsiveness Tweaks' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '2' -ForegroundColor Cyan -NoNewline; Write-Host ']  Visual Effects Performance Mode' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '3' -ForegroundColor Cyan -NoNewline; Write-Host ']  Startup Pruning' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '4' -ForegroundColor Cyan -NoNewline; Write-Host ']  Network Maintenance' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '5' -ForegroundColor Cyan -NoNewline; Write-Host ']  Background Services Cleanup' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '6' -ForegroundColor Cyan -NoNewline; Write-Host ']  Disable Hibernation' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '7' -ForegroundColor Red -NoNewline; Write-Host ']  Back' -ForegroundColor White;" ^
  "Write-Host '';" ^
  "Write-Host '  ===========================================================' -ForegroundColor DarkGray;"
echo.
set /p HK_ADV=  ^> 
if "%HK_ADV%"=="1" call :confirm_run "UI Responsiveness Tweaks" "Reduces menu animation delay (100ms), lowers app hang timeout, sets foreground apps to receive longer CPU time slices (Win32PrioritySeparation), and disables NTFS Last Access timestamps to cut background disk I/O." "Affected: Registry (HKCU\Control Panel\Desktop), NTFS filesystem flags" & if "!HK_CONFIRMED!"=="1" call :ensure_backup & call :ui_responsiveness_tweaks & goto pause_return
if "%HK_ADV%"=="2" call :confirm_run "Visual Effects Performance Mode" "Disables window animations, taskbar animations, list-view shadows, and alpha selection effects. Sets Windows to Performance mode for visual effects. Noticeable on lower-end hardware." "Affected: Registry (HKCU Explorer\VisualEffects, WindowMetrics)" & if "!HK_CONFIRMED!"=="1" call :ensure_backup & call :visual_performance_mode & goto pause_return
if "%HK_ADV%"=="3" call :confirm_run "Startup Pruning" "Removes startup registry entries for: OneDrive, Discord, Spotify, Skype, Zoom, Epic Games Launcher, Teams. These apps will no longer auto-launch at login. You can still open them manually." "Affected: Registry (HKCU\Run and HKLM\Run startup keys)" & if "!HK_CONFIRMED!"=="1" call :ensure_backup & call :startup_pruning & goto pause_return
if "%HK_ADV%"=="4" call :confirm_run "Network Maintenance" "Flushes DNS cache, releases and renews your IP address, resets the Winsock catalog, and resets the TCP/IP stack. Useful if you are experiencing degraded network performance." "Affected: DNS Cache, IP Lease, Winsock, TCP/IP Stack (restart recommended)" & if "!HK_CONFIRMED!"=="1" call :ensure_backup & call :network_maintenance & goto pause_return
if "%HK_ADV%"=="5" call :confirm_run "Background Services Cleanup" "Stops and disables three high-overhead background services: SysMain (Superfetch memory preloader), WSearch (Windows Search Indexer), and DiagTrack (Telemetry). Original service states are saved for restore." "Affected: SysMain, WSearch, DiagTrack services (restorable)" & if "!HK_CONFIRMED!"=="1" call :ensure_backup & call :services_cleanup & goto pause_return
if "%HK_ADV%"=="6" call :confirm_run "Disable Hibernation" "Disables Windows hibernation and removes the hiberfil.sys file, which can be several GB on your system drive. Sleep mode is unaffected." "Affected: Hibernation state, hiberfil.sys (frees disk space)" & if "!HK_CONFIRMED!"=="1" call :ensure_backup & call :disable_hibernation & goto pause_return
if "%HK_ADV%"=="7" goto main_menu
goto advanced_menu

:: ================================================================
:gaming_menu
cls
call :print_header
powershell -NoProfile -Command ^
  "Write-Host '  ======================= GAMING MODE =======================' -ForegroundColor DarkGray;" ^
  "Write-Host '';" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '1' -ForegroundColor Cyan -NoNewline; Write-Host ']  FPS Tweaks' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '2' -ForegroundColor Cyan -NoNewline; Write-Host ']  Latency Maintenance' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '3' -ForegroundColor Cyan -NoNewline; Write-Host ']  Full Gaming Prep' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '4' -ForegroundColor Red -NoNewline; Write-Host ']  Back' -ForegroundColor White;" ^
  "Write-Host '';" ^
  "Write-Host '  ===========================================================' -ForegroundColor DarkGray;"
echo.
set /p HK_GAME=  ^> 
if "%HK_GAME%"=="1" call :confirm_run "FPS Tweaks" "Disables Xbox Game DVR/capture overlay, sets GPU and I/O scheduling priority to High for game processes, sets SystemResponsiveness to 0 (dedicates multimedia scheduler fully to games), and applies High Performance power plan." "Affected: GameDVR registry keys, Multimedia Scheduler (MMCSS), Power Plan" & if "!HK_CONFIRMED!"=="1" call :ensure_backup & call :gaming_fps_tweaks & goto pause_return
if "%HK_GAME%"=="2" call :confirm_run "Latency Maintenance" "Flushes DNS, resets Winsock, enables TCP Fast Open and RSS (Receive Side Scaling), disables Nagle algorithm for lower latency, and pauses Windows Update delivery (BITS and DoSvc) during your session." "Affected: TCP/IP stack, Winsock, Windows Update delivery services" & if "!HK_CONFIRMED!"=="1" call :ensure_backup & call :gaming_latency_maintenance & goto pause_return
if "%HK_GAME%"=="3" call :confirm_run "Full Gaming Prep" "Runs FPS Tweaks and Latency Maintenance in sequence. Applies all gaming optimizations in one step." "Affected: All of the above combined" & if "!HK_CONFIRMED!"=="1" call :ensure_backup & call :gaming_full_prep & goto pause_return
if "%HK_GAME%"=="4" goto main_menu
goto gaming_menu

:: ================================================================
:restore_menu
cls
call :print_header
powershell -NoProfile -Command ^
  "Write-Host '  ===================== RESTORE DEFAULTS ====================' -ForegroundColor DarkGray;" ^
  "Write-Host '';" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '1' -ForegroundColor Cyan -NoNewline; Write-Host ']  Restore Latest Registry Backups' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '2' -ForegroundColor Cyan -NoNewline; Write-Host ']  Restore Default Power Schemes' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '3' -ForegroundColor Cyan -NoNewline; Write-Host ']  Re-Enable Background Services' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '4' -ForegroundColor Cyan -NoNewline; Write-Host ']  Re-Enable Hibernation' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '5' -ForegroundColor Cyan -NoNewline; Write-Host ']  Reset Network Stack' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '6' -ForegroundColor Cyan -NoNewline; Write-Host ']  Restart Explorer' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '7' -ForegroundColor Red -NoNewline; Write-Host ']  Back' -ForegroundColor White;" ^
  "Write-Host '';" ^
  "Write-Host '  ===========================================================' -ForegroundColor DarkGray;"
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

:: ================================================================
:pause_return
set "HK_CONFIRMED=0"
echo.
powershell -NoProfile -Command "Write-Host '  Done. Press any key to return to the menu...' -ForegroundColor Green"
echo.
pause >nul
goto main_menu

:: ================================================================
:: CONFIRM SCREEN
:: Usage: call :confirm_run "Title" "Description" "Affected"
:: Sets HK_CONFIRMED=1 if user says Y
:: ================================================================
:confirm_run
set "HK_CONFIRMED=0"
cls
call :print_header
powershell -NoProfile -Command ^
  "Write-Host '  --------------------------------------------------------' -ForegroundColor DarkGray;" ^
  "Write-Host '  %~1' -ForegroundColor Cyan;" ^
  "Write-Host '  --------------------------------------------------------' -ForegroundColor DarkGray;"
echo.
echo   What this does:
echo   %~2
echo.
powershell -NoProfile -Command "Write-Host '  %~3' -ForegroundColor Yellow"
echo.
powershell -NoProfile -Command "Write-Host '  --------------------------------------------------------' -ForegroundColor DarkGray"
echo.
set /p HK_CONFIRM=  Proceed? [Y/N]:  
if /I "!HK_CONFIRM!"=="Y" set "HK_CONFIRMED=1"
echo.
exit /b 0

:: ================================================================
:: HEADER
:: ================================================================
:print_header
powershell -NoProfile -Command ^
  "Write-Host '';" ^
  "Write-Host '  ██╗  ██╗ ██████╗ ██╗     ███╗   ███╗███████╗███████╗██╗  ██╗██╗████████╗' -ForegroundColor Cyan;" ^
  "Write-Host '  ██║  ██║██╔═══██╗██║     ████╗ ████║██╔════╝██╔════╝██║ ██╔╝██║╚══██╔══╝' -ForegroundColor Cyan;" ^
  "Write-Host '  ███████║██║   ██║██║     ██╔████╔██║█████╗  ███████╗█████╔╝ ██║   ██║   ' -ForegroundColor Cyan;" ^
  "Write-Host '  ██╔══██║██║   ██║██║     ██║╚██╔╝██║██╔══╝  ╚════██║██╔═██╗ ██║   ██║   ' -ForegroundColor Cyan;" ^
  "Write-Host '  ██║  ██║╚██████╔╝███████╗██║ ╚═╝ ██║███████╗███████║██║  ██╗██║   ██║   ' -ForegroundColor Cyan;" ^
  "Write-Host '  ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝     ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝   ╚═╝  ' -ForegroundColor DarkCyan;" ^
  "Write-Host '';" ^
  "Write-Host '                    Safe Windows Optimization Toolkit' -ForegroundColor DarkGray;" ^
  "Write-Host '';"
exit /b 0

:: ================================================================
:: LOGGING
:: ================================================================
:log
set "LG_MSG=%~1"
for /f "tokens=1-3 delims=/ " %%a in ('date /t') do set "LG_DATE=%%a/%%b/%%c"
for /f "tokens=1-2 delims=: " %%a in ('time /t') do set "LG_TIME=%%a:%%b"
echo [%LG_DATE% %LG_TIME%] %LG_MSG% >> "%HK_LOG%" 2>nul
exit /b 0

:: ================================================================
:: ADMIN CHECK
:: ================================================================
:require_admin
net session >nul 2>&1
if %errorlevel%==0 exit /b 0
echo.
echo  HolmesKit requires Administrator privileges.
echo  Right-click the script and choose "Run as administrator".
echo.
pause
exit /b 1

:: ================================================================
:: INIT PATHS
:: ================================================================
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

:: ================================================================
:: STARTUP NOTICE
:: ================================================================
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
powershell -NoProfile -Command "Write-Host '  ===========================================================' -ForegroundColor DarkGray"
echo.
set /p HK_RP=  Create a restore point now? [Y/N]:  
if /I "%HK_RP%"=="Y" call :create_restore_point
exit /b 0

:: ================================================================
:: RESTORE POINT
:: ================================================================
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

:: ================================================================
:: REGISTRY BACKUP
:: ================================================================
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

:: ================================================================
:: CORE: Full run
:: ================================================================
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

:: ================================================================
:: CORE: Temp cleanup
:: ================================================================
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

:: ================================================================
:: CORE: Power plan
:: ================================================================
:apply_power_plan
call :log "Applying High Performance power plan"
powershell -NoProfile -Command "Write-Host '  [*] Applying High Performance Power Plan...' -ForegroundColor Cyan"
echo.
powercfg /setactive SCHEME_MIN >nul 2>&1
if %errorlevel%==0 (
    powershell -NoProfile -Command "Write-Host '  High Performance Plan Activated.' -ForegroundColor Green"
    call :log "High Performance plan activated"
) else (
    for /f "tokens=4" %%G in ('powercfg /list ^| findstr /i "High performance"') do set "HK_POWER_GUID=%%G"
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

:: ================================================================
:: CORE: Background app cleanup
:: ================================================================
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

:: ================================================================
:: ADVANCED: UI responsiveness
:: ================================================================
:ui_responsiveness_tweaks
call :log "Applying UI responsiveness tweaks"
powershell -NoProfile -Command "Write-Host '  [*] Applying UI Responsiveness Tweaks...' -ForegroundColor Cyan"
echo.
reg add "HKCU\Control Panel\Desktop" /v MenuShowDelay /t REG_SZ /d "100" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v HungAppTimeout /t REG_SZ /d "4000" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v WaitToKillAppTimeout /t REG_SZ /d "5000" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v ForegroundLockTimeout /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v AutoEndTasks /t REG_SZ /d "1" /f >nul 2>&1
:: Give foreground apps longer CPU time slices (value 26 = short variable quanta, foreground boost)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d "26" /f >nul 2>&1
:: Disable NTFS Last Access timestamp updates - reduces I/O on every file read
fsutil behavior set disablelastaccess 1 >nul 2>&1
call :restart_explorer
call :log "UI responsiveness tweaks applied"
powershell -NoProfile -Command "Write-Host '  UI Responsiveness Tweaks Applied.' -ForegroundColor Green"
echo.
exit /b 0

:: ================================================================
:: ADVANCED: Visual effects
:: ================================================================
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

:: ================================================================
:: ADVANCED: Startup pruning
:: ================================================================
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

:: ================================================================
:: ADVANCED: Network maintenance
:: ================================================================
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

:: ================================================================
:: ADVANCED: Background services cleanup (new - real gains)
:: ================================================================
:services_cleanup
call :log "Running background services cleanup"
powershell -NoProfile -Command "Write-Host '  [*] Stopping And Disabling Background Services...' -ForegroundColor Cyan"
echo.

:: Save current service start types before changing anything
set "HK_SVC_FILE=%HK_LATEST%\service_states.txt"
echo SysMain > "%HK_SVC_FILE%"
sc qc SysMain 2>nul | findstr "START_TYPE" >> "%HK_SVC_FILE%"
echo WSearch >> "%HK_SVC_FILE%"
sc qc WSearch 2>nul | findstr "START_TYPE" >> "%HK_SVC_FILE%"
echo DiagTrack >> "%HK_SVC_FILE%"
sc qc DiagTrack 2>nul | findstr "START_TYPE" >> "%HK_SVC_FILE%"

:: SysMain (Superfetch) - preloads apps into RAM, causes heavy disk I/O on HDDs and older SSDs
sc stop SysMain >nul 2>&1
sc config SysMain start= disabled >nul 2>&1
powershell -NoProfile -Command "Write-Host '    [-] SysMain (Superfetch) stopped and disabled' -ForegroundColor DarkGray"

:: WSearch (Windows Search Indexer) - constantly indexes files in background, hammers disk I/O
sc stop WSearch >nul 2>&1
sc config WSearch start= disabled >nul 2>&1
powershell -NoProfile -Command "Write-Host '    [-] WSearch (Search Indexer) stopped and disabled' -ForegroundColor DarkGray"

:: DiagTrack (Connected User Experiences / Telemetry) - sends usage data to Microsoft, pure overhead
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

:: ================================================================
:: ADVANCED: Disable hibernation
:: ================================================================
:disable_hibernation
call :log "Disabling hibernation"
powershell -NoProfile -Command "Write-Host '  [*] Disabling Hibernation...' -ForegroundColor Cyan"
echo.
powercfg /h off >nul 2>&1
call :log "Hibernation disabled"
powershell -NoProfile -Command "Write-Host '  Hibernation Disabled.' -ForegroundColor Green"
echo.
exit /b 0

:: ================================================================
:: GAMING: FPS tweaks
:: ================================================================
:gaming_fps_tweaks
call :log "Applying gaming FPS tweaks"
powershell -NoProfile -Command "Write-Host '  [*] Applying FPS Tweaks...' -ForegroundColor Cyan"
echo.
call :apply_power_plan
:: Disable Xbox Game DVR - background capture overlay
reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v AppCaptureEnabled /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\Software\Policies\Microsoft\Windows\GameDVR" /v AllowGameDVR /t REG_DWORD /d "0" /f >nul 2>&1
:: MMCSS game thread scheduling - GPU and I/O priority for tagged game processes
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d "8" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d "6" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d "High" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "SFIO Priority" /t REG_SZ /d "High" /f >nul 2>&1
:: SystemResponsiveness=0: dedicate multimedia scheduler fully to games (no background CPU reservation)
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /t REG_DWORD /d "0" /f >nul 2>&1
call :visual_performance_mode
call :cleanup_background
call :log "Gaming FPS tweaks applied"
powershell -NoProfile -Command "Write-Host '  FPS Tweaks Applied.' -ForegroundColor Green"
echo.
exit /b 0

:: ================================================================
:: GAMING: Latency maintenance
:: ================================================================
:gaming_latency_maintenance
call :log "Applying gaming latency maintenance"
powershell -NoProfile -Command "Write-Host '  [*] Applying Latency Maintenance...' -ForegroundColor Cyan"
echo.
ipconfig /flushdns >nul 2>&1
netsh winsock reset >nul 2>&1
:: TCP Fast Open - reduces handshake overhead on repeated connections
netsh int tcp set global fastopen=enabled >nul 2>&1
:: RSS (Receive Side Scaling) - distributes network receive load across CPU cores
netsh int tcp set global rss=enabled >nul 2>&1
:: Disable TCP autotuning - fixes receive buffer at smaller size, reduces latency at cost of throughput
netsh int tcp set global autotuninglevel=disabled >nul 2>&1
:: Disable Nagle algorithm - sends packets immediately instead of batching (lower latency, slightly more packets)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" /v TcpAckFrequency /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TCPNoDelay /t REG_DWORD /d "1" /f >nul 2>&1
:: Pause Windows Update delivery and Background Intelligent Transfer during session
for %%S in (DoSvc BITS) do net stop %%S >nul 2>&1
call :cleanup_background
call :log "Gaming latency maintenance applied"
powershell -NoProfile -Command "Write-Host '  Latency Maintenance Applied. A Restart May Improve Effect.' -ForegroundColor Green"
echo.
exit /b 0

:: ================================================================
:: GAMING: Full prep
:: ================================================================
:gaming_full_prep
call :gaming_fps_tweaks
call :gaming_latency_maintenance
call :log "Full gaming prep completed"
powershell -NoProfile -Command "Write-Host '  Full Gaming Prep Completed.' -ForegroundColor Green"
echo.
exit /b 0

:: ================================================================
:: RESTORE: Registry
:: ================================================================
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
:: Restore NTFS last access and Win32PrioritySeparation
fsutil behavior set disablelastaccess 0 >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d "2" /f >nul 2>&1
:: Re-enable TCP autotuning to Windows default
netsh int tcp set global autotuninglevel=normal >nul 2>&1
call :restart_explorer
call :log "Registry restoration completed"
powershell -NoProfile -Command "Write-Host '  Registry Restoration Completed.' -ForegroundColor Green"
echo.
exit /b 0

:: ================================================================
:: RESTORE: Background services
:: ================================================================
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

:: ================================================================
:: RESTORE: Power defaults
:: ================================================================
:restore_power_defaults
call :log "Restoring default power schemes"
powershell -NoProfile -Command "Write-Host '  [*] Restoring Default Power Schemes...' -ForegroundColor Cyan"
echo.
powercfg /restoredefaultschemes >nul 2>&1
call :log "Default power schemes restored"
powershell -NoProfile -Command "Write-Host '  Default Power Schemes Restored.' -ForegroundColor Green"
echo.
exit /b 0

:: ================================================================
:: RESTORE: Hibernation
:: ================================================================
:enable_hibernation
call :log "Re-enabling hibernation"
powershell -NoProfile -Command "Write-Host '  [*] Re-Enabling Hibernation...' -ForegroundColor Cyan"
echo.
powercfg /h on >nul 2>&1
call :log "Hibernation enabled"
powershell -NoProfile -Command "Write-Host '  Hibernation Enabled.' -ForegroundColor Green"
echo.
exit /b 0

:: ================================================================
:: RESTORE: Network defaults
:: ================================================================
:restore_network_defaults
call :log "Resetting network stack"
powershell -NoProfile -Command "Write-Host '  [*] Resetting Network Stack...' -ForegroundColor Cyan"
echo.
netsh winsock reset >nul 2>&1
netsh int ip reset >nul 2>&1
netsh int tcp set global autotuninglevel=normal >nul 2>&1
netsh int tcp set global fastopen=disabled >nul 2>&1
ipconfig /flushdns >nul 2>&1
call :log "Network stack reset"
powershell -NoProfile -Command "Write-Host '  Network Reset Complete. A Restart Is Recommended.' -ForegroundColor Green"
echo.
exit /b 0

:: ================================================================
:: UTILITY: Restart Explorer
:: ================================================================
:restart_explorer
call :log "Restarting Explorer"
taskkill /f /im explorer.exe >nul 2>&1
start "" explorer.exe
exit /b 0
