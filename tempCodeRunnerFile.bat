@echo off
chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"
title HolmesKit
mode con: cols=100 lines=35

:: -----------------------------------------------------------------
:: HolmesKit - Safe Windows optimization toolkit
:: Focus: general responsiveness, cleanup, and optional gaming tweaks
:: -----------------------------------------------------------------

call :require_admin
call :init_paths
call :startup_notice

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
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '1' -ForegroundColor Cyan -NoNewline; Write-Host ']  Run full core optimization' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '2' -ForegroundColor Cyan -NoNewline; Write-Host ']  Cleanup temp and cache files' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '3' -ForegroundColor Cyan -NoNewline; Write-Host ']  Apply power plan optimization' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '4' -ForegroundColor Cyan -NoNewline; Write-Host ']  Safe background cleanup' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '5' -ForegroundColor Red -NoNewline; Write-Host ']  Back' -ForegroundColor White;" ^
  "Write-Host '';" ^
  "Write-Host '  ===========================================================' -ForegroundColor DarkGray;"
echo.
set /p HK_CORE=  ^> 
if "%HK_CORE%"=="1" call :run_full_core & goto pause_return
if "%HK_CORE%"=="2" call :ensure_backup & call :cleanup_temp & goto pause_return
if "%HK_CORE%"=="3" call :ensure_backup & call :apply_power_plan & goto pause_return
if "%HK_CORE%"=="4" call :ensure_backup & call :cleanup_background & goto pause_return
if "%HK_CORE%"=="5" goto main_menu
goto core_menu

:: ================================================================
:advanced_menu
cls
call :print_header
powershell -NoProfile -Command ^
  "Write-Host '  ===================== ADVANCED TWEAKS =====================' -ForegroundColor DarkGray;" ^
  "Write-Host '';" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '1' -ForegroundColor Cyan -NoNewline; Write-Host ']  UI responsiveness tweaks' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '2' -ForegroundColor Cyan -NoNewline; Write-Host ']  Visual effects performance mode' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '3' -ForegroundColor Cyan -NoNewline; Write-Host ']  Startup pruning' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '4' -ForegroundColor Cyan -NoNewline; Write-Host ']  Network maintenance' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '5' -ForegroundColor Cyan -NoNewline; Write-Host ']  Disable hibernation' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '6' -ForegroundColor Red -NoNewline; Write-Host ']  Back' -ForegroundColor White;" ^
  "Write-Host '';" ^
  "Write-Host '  ===========================================================' -ForegroundColor DarkGray;"
echo.
set /p HK_ADV=  ^> 
if "%HK_ADV%"=="1" call :ensure_backup & call :ui_responsiveness_tweaks & goto pause_return
if "%HK_ADV%"=="2" call :ensure_backup & call :visual_performance_mode & goto pause_return
if "%HK_ADV%"=="3" call :ensure_backup & call :startup_pruning & goto pause_return
if "%HK_ADV%"=="4" call :ensure_backup & call :network_maintenance & goto pause_return
if "%HK_ADV%"=="5" call :ensure_backup & call :disable_hibernation & goto pause_return
if "%HK_ADV%"=="6" goto main_menu
goto advanced_menu

:: ================================================================
:gaming_menu
cls
call :print_header
powershell -NoProfile -Command ^
  "Write-Host '  ======================= GAMING MODE =======================' -ForegroundColor DarkGray;" ^
  "Write-Host '';" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '1' -ForegroundColor Cyan -NoNewline; Write-Host ']  FPS tweaks' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '2' -ForegroundColor Cyan -NoNewline; Write-Host ']  Latency maintenance' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '3' -ForegroundColor Cyan -NoNewline; Write-Host ']  Full gaming prep' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '4' -ForegroundColor Red -NoNewline; Write-Host ']  Back' -ForegroundColor White;" ^
  "Write-Host '';" ^
  "Write-Host '  ===========================================================' -ForegroundColor DarkGray;"
echo.
set /p HK_GAME=  ^> 
if "%HK_GAME%"=="1" call :ensure_backup & call :gaming_fps_tweaks & goto pause_return
if "%HK_GAME%"=="2" call :ensure_backup & call :gaming_latency_maintenance & goto pause_return
if "%HK_GAME%"=="3" call :ensure_backup & call :gaming_full_prep & goto pause_return
if "%HK_GAME%"=="4" goto main_menu
goto gaming_menu

:: ================================================================
:restore_menu
cls
call :print_header
powershell -NoProfile -Command ^
  "Write-Host '  ===================== RESTORE DEFAULTS ====================' -ForegroundColor DarkGray;" ^
  "Write-Host '';" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '1' -ForegroundColor Cyan -NoNewline; Write-Host ']  Restore latest registry backups' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '2' -ForegroundColor Cyan -NoNewline; Write-Host ']  Restore default power schemes' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '3' -ForegroundColor Cyan -NoNewline; Write-Host ']  Re-enable hibernation' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '4' -ForegroundColor Cyan -NoNewline; Write-Host ']  Reset network stack' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '5' -ForegroundColor Cyan -NoNewline; Write-Host ']  Restart Explorer' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '6' -ForegroundColor Red -NoNewline; Write-Host ']  Back' -ForegroundColor White;" ^
  "Write-Host '';" ^
  "Write-Host '  ===========================================================' -ForegroundColor DarkGray;"
echo.
set /p HK_RESTORE=  ^> 
if "%HK_RESTORE%"=="1" call :restore_latest_registry & goto pause_return
if "%HK_RESTORE%"=="2" call :restore_power_defaults & goto pause_return
if "%HK_RESTORE%"=="3" call :enable_hibernation & goto pause_return
if "%HK_RESTORE%"=="4" call :restore_network_defaults & goto pause_return
if "%HK_RESTORE%"=="5" call :restart_explorer & goto pause_return
if "%HK_RESTORE%"=="6" goto main_menu
goto restore_menu

:pause_return
echo.
powershell -NoProfile -Command "Write-Host '  Done. Press any key to return to the menu...' -ForegroundColor Green"
echo.
pause >nul
goto main_menu

:: ================================================================
:: UTILITY: Colored text output (no newline)
:: Usage: call :ctext COLOR "text"
:: Colors: Gray Cyan Green Yellow Red White
:: Internally maps to PowerShell color names
:: ================================================================
:ctext
set "CT_COLOR=%~1"
set "CT_TEXT=%~2"
if "%CT_COLOR%"=="08" set "CT_PSCOLOR=DarkGray"
if "%CT_COLOR%"=="0A" set "CT_PSCOLOR=Green"
if "%CT_COLOR%"=="0B" set "CT_PSCOLOR=Cyan"
if "%CT_COLOR%"=="0C" set "CT_PSCOLOR=Red"
if "%CT_COLOR%"=="0E" set "CT_PSCOLOR=Yellow"
if "%CT_COLOR%"=="0F" set "CT_PSCOLOR=White"
if not defined CT_PSCOLOR set "CT_PSCOLOR=White"
powershell -NoProfile -Command "Write-Host '%CT_TEXT%' -ForegroundColor %CT_PSCOLOR% -NoNewline"
set "CT_PSCOLOR="
exit /b 0

:: ================================================================
:: HEADER: ASCII logo
:: ================================================================
:: ================================================================
:: HEADER: HOLMESKIT LOGO
:: ================================================================
:print_header
powershell -NoProfile -Command ^
  "Write-Host '';" ^
  "Write-Host '  ██╗  ██╗ ██████╗ ██╗     ███╗   ███╗███████╗███████╗██╗  ██╗██╗████████╗' -ForegroundColor Cyan;" ^
  "Write-Host '  ██║  ██║██╔═══██╗██║     ████╗ ████║██╔════╝██╔════╝██║ ██╔╝██║╚══██╔══╝' -ForegroundColor Cyan;" ^
  "Write-Host '  ███████║██║   ██║██║     ██╔████╔██║█████╗  ███████╗█████╔╝ ██║   ██║   ' -ForegroundColor Cyan;" ^
  "Write-Host '  ██╔══██║██║   ██║██║     ██║╚██╔╝██║██╔══╝  ╚════██║██╔═██╗ ██║   ██║   ' -ForegroundColor Cyan;" ^
  "Write-Host '  ██║  ██║╚██████╔╝███████╗██║ ╚═╝ ██║███████╗███████║██║  ██╗██║   ██║   ' -ForegroundColor Cyan;" ^
  "Write-Host '  ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝     ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝   ╚═╝   ' -ForegroundColor DarkCyan;" ^
  "Write-Host '';" ^
  "Write-Host '                    Safe Windows Optimization Toolkit' -ForegroundColor DarkGray;" ^
  "Write-Host '';"
exit /b 0

:: ================================================================
:: LOGGING
:: ================================================================
:log
set "LG_MSG=%~1"
set "LG_TS="
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
call :log "=== HolmesKit session started ==="
exit /b 0

:: ================================================================
:: STARTUP NOTICE + RESTORE POINT
:: ================================================================
:startup_notice
cls
call :print_header
echo.
powershell -NoProfile -Command "Write-Host '  NOTICE: HolmesKit will make system-level changes.' -ForegroundColor Yellow"
echo.
echo.
echo   It can:
echo     - Delete temporary files and cache folders
echo     - Change power settings
echo     - Apply reversible registry tweaks
echo     - Run optional gaming-focused changes
echo.
powershell -NoProfile -Command "Write-Host '  A restore point is strongly recommended before continuing.' -ForegroundColor Yellow"
echo.
powershell -NoProfile -Command "Write-Host '  ===========================================================' -ForegroundColor DarkGray"
echo.
set /p HK_RP=  Create a restore point now? [Y/N]:  
if /I "%HK_RP%"=="Y" call :create_restore_point
exit /b 0

:: ================================================================
:: RESTORE POINT (fixed)
:: ================================================================
:create_restore_point
echo.
powershell -NoProfile -Command "Write-Host '  Creating restore point - this may take a moment...' -ForegroundColor Yellow"
echo.
call :log "Attempting to create system restore point"

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$drive = $env:SystemDrive + '\'; " ^
  "Enable-ComputerRestore -Drive $drive -ErrorAction SilentlyContinue; " ^
  "$lastRP = Get-ComputerRestorePoint | Select-Object -Last 1; " ^
  "$skip = $false; " ^
  "if ($lastRP) { " ^
    "$created = $lastRP.ConvertToDateTime($lastRP.CreationTime); " ^
    "$age = ((Get-Date) - $created).TotalMinutes; " ^
    "if ($age -lt 1440) { $skip = $true } " ^
  "} " ^
  "if (-not $skip) { " ^
    "Checkpoint-Computer -Description 'HolmesKit Pre-Change' -RestorePointType APPLICATION_INSTALL -ErrorAction Stop; " ^
    "exit 0 " ^
  "} else { exit 2 }" 2>nul

if %errorlevel%==0 (
    powershell -NoProfile -Command "Write-Host '  Restore point created successfully.' -ForegroundColor Green"
    call :log "Restore point created successfully"
) else if %errorlevel%==2 (
    powershell -NoProfile -Command "Write-Host '  Skipped - a restore point was already created recently.' -ForegroundColor Yellow"
    call :log "Restore point skipped - recent one exists"
) else (
    powershell -NoProfile -Command "Write-Host '  Could not create restore point automatically.' -ForegroundColor Red"
    echo.
    echo   This can happen if System Restore is disabled on your drive.
    echo   You can enable it via: Control Panel ^> System ^> System Protection
    call :log "Restore point creation failed"
)
echo.
exit /b 0

:: ================================================================
:: BACKUP REGISTRY BEFORE CHANGES
:: ================================================================
:ensure_backup
if "%HK_BACKUP_READY%"=="1" exit /b 0
if exist "%HK_LATEST%" rd /s /q "%HK_LATEST%" >nul 2>&1
md "%HK_LATEST%" >nul 2>&1
call :log "Creating registry backups in %HK_LATEST%"
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
set "HK_BACKUP_READY=1"
call :log "Registry backups complete"
powershell -NoProfile -Command "Write-Host '  Registry backed up.' -ForegroundColor Green"
echo.
exit /b 0

:export_key
reg export "%~1" "%HK_LATEST%\%~2" /y >nul 2>&1
exit /b 0

:: ================================================================
:: CORE: Full core run
:: ================================================================
:run_full_core
call :ensure_backup
call :cleanup_temp
call :apply_power_plan
call :cleanup_background
call :restart_explorer
call :log "Full core optimization completed"
powershell -NoProfile -Command "Write-Host '  Full core optimization completed.' -ForegroundColor Green"
echo.
exit /b 0

:: ================================================================
:: CORE: Temp cleanup
:: ================================================================
:cleanup_temp
call :log "Starting temp/cache cleanup"
powershell -NoProfile -Command "Write-Host '  [*] Cleaning temp and cache folders...' -ForegroundColor Cyan"
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
powershell -NoProfile -Command "Write-Host '  Temp cleanup completed.' -ForegroundColor Green"
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
powershell -NoProfile -Command "Write-Host '  [*] Applying High Performance power plan...' -ForegroundColor Cyan"
echo.
powercfg /setactive SCHEME_MIN >nul 2>&1
if %errorlevel%==0 (
    powershell -NoProfile -Command "Write-Host '  High Performance plan activated.' -ForegroundColor Green"
    call :log "High Performance plan activated via alias"
) else (
    for /f "tokens=4" %%G in ('powercfg /list ^| findstr /i "High performance"') do set "HK_POWER_GUID=%%G"
    if defined HK_POWER_GUID (
        powercfg /setactive !HK_POWER_GUID! >nul 2>&1
        powershell -NoProfile -Command "Write-Host '  High Performance plan activated via GUID.' -ForegroundColor Green"
        call :log "High Performance plan activated via GUID: !HK_POWER_GUID!"
    ) else (
        powershell -NoProfile -Command "Write-Host '  Could not activate High Performance plan.' -ForegroundColor Red"
        call :log "Failed to activate High Performance plan"
    )
)
echo.
exit /b 0

:: ================================================================
:: CORE: Background cleanup
:: ================================================================
:cleanup_background
call :log "Terminating safe background processes"
powershell -NoProfile -Command "Write-Host '  [*] Terminating background apps...' -ForegroundColor Cyan"
echo.
for %%P in (
    OneDrive.exe Teams.exe ms-teams.exe Spotify.exe Discord.exe
    EpicGamesLauncher.exe EpicWebHelper.exe Battle.net.exe
    AdobeIPCBroker.exe CCXProcess.exe AdobeGCClient.exe
    msedge.exe chrome.exe firefox.exe
) do taskkill /f /im "%%P" >nul 2>&1
call :log "Background cleanup complete"
powershell -NoProfile -Command "Write-Host '  Background cleanup completed.' -ForegroundColor Green"
echo.
exit /b 0

:: ================================================================
:: ADVANCED: UI responsiveness tweaks
:: ================================================================
:ui_responsiveness_tweaks
call :log "Applying UI responsiveness tweaks"
powershell -NoProfile -Command "Write-Host '  [*] Applying UI responsiveness tweaks...' -ForegroundColor Cyan"
echo.
reg add "HKCU\Control Panel\Desktop" /v MenuShowDelay /t REG_SZ /d "100" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v HungAppTimeout /t REG_SZ /d "4000" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v WaitToKillAppTimeout /t REG_SZ /d "5000" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v ForegroundLockTimeout /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v AutoEndTasks /t REG_SZ /d "1" /f >nul 2>&1
call :restart_explorer
call :log "UI responsiveness tweaks applied"
powershell -NoProfile -Command "Write-Host '  UI responsiveness tweaks applied.' -ForegroundColor Green"
echo.
exit /b 0

:: ================================================================
:: ADVANCED: Visual effects performance mode
:: ================================================================
:visual_performance_mode
call :log "Applying visual effects performance mode"
powershell -NoProfile -Command "Write-Host '  [*] Applying visual effects performance mode...' -ForegroundColor Cyan"
echo.
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v MinAnimate /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarAnimations /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ListviewAlphaSelect /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ListviewShadow /t REG_DWORD /d "0" /f >nul 2>&1
call :restart_explorer
call :log "Visual effects performance mode applied"
powershell -NoProfile -Command "Write-Host '  Visual effects performance mode applied.' -ForegroundColor Green"
echo.
exit /b 0

:: ================================================================
:: ADVANCED: Startup pruning
:: ================================================================
:startup_pruning
call :log "Running startup pruning"
powershell -NoProfile -Command "Write-Host '  [*] Removing selected startup entries...' -ForegroundColor Cyan"
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
powershell -NoProfile -Command "Write-Host '  Startup pruning completed.' -ForegroundColor Green"
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
powershell -NoProfile -Command "Write-Host '  [*] Running network maintenance...' -ForegroundColor Cyan"
echo.
ipconfig /flushdns >nul 2>&1
ipconfig /release >nul 2>&1
ipconfig /renew >nul 2>&1
netsh winsock reset >nul 2>&1
netsh int ip reset >nul 2>&1
call :log "Network maintenance complete"
powershell -NoProfile -Command "Write-Host '  Network maintenance completed. A restart is recommended.' -ForegroundColor Green"
echo.
exit /b 0

:: ================================================================
:: ADVANCED: Disable hibernation
:: ================================================================
:disable_hibernation
call :log "Disabling hibernation"
powershell -NoProfile -Command "Write-Host '  [*] Disabling hibernation...' -ForegroundColor Cyan"
echo.
powercfg /h off >nul 2>&1
call :log "Hibernation disabled"
powershell -NoProfile -Command "Write-Host '  Hibernation disabled.' -ForegroundColor Green"
echo.
exit /b 0

:: ================================================================
:: GAMING: FPS tweaks
:: ================================================================
:gaming_fps_tweaks
call :log "Applying gaming FPS tweaks"
powershell -NoProfile -Command "Write-Host '  [*] Applying FPS tweaks...' -ForegroundColor Cyan"
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
powershell -NoProfile -Command "Write-Host '  FPS tweaks applied.' -ForegroundColor Green"
echo.
exit /b 0

:: ================================================================
:: GAMING: Latency maintenance
:: ================================================================
:gaming_latency_maintenance
call :log "Applying gaming latency maintenance"
powershell -NoProfile -Command "Write-Host '  [*] Applying latency maintenance...' -ForegroundColor Cyan"
echo.
ipconfig /flushdns >nul 2>&1
netsh winsock reset >nul 2>&1
netsh int tcp set global autotuninglevel=normal >nul 2>&1
netsh int tcp set global fastopen=enabled >nul 2>&1
netsh int tcp set global rss=enabled >nul 2>&1
for %%S in (DoSvc BITS) do net stop %%S >nul 2>&1
call :cleanup_background
call :log "Gaming latency maintenance applied"
powershell -NoProfile -Command "Write-Host '  Latency maintenance applied. A restart may improve effect.' -ForegroundColor Green"
echo.
exit /b 0

:: ================================================================
:: GAMING: Full prep
:: ================================================================
:gaming_full_prep
call :gaming_fps_tweaks
call :gaming_latency_maintenance
call :log "Full gaming prep completed"
powershell -NoProfile -Command "Write-Host '  Full gaming prep completed.' -ForegroundColor Green"
echo.
exit /b 0

:: ================================================================
:: RESTORE: Registry
:: ================================================================
:restore_latest_registry
if not exist "%HK_LATEST%" (
    powershell -NoProfile -Command "Write-Host '  No backup folder found. Run an optimization first.' -ForegroundColor Red"
    echo.
    exit /b 0
)
call :log "Restoring latest registry backups"
powershell -NoProfile -Command "Write-Host '  [*] Restoring registry backups...' -ForegroundColor Cyan"
echo.
for %%F in (
    "desktop.reg" "visualeffects.reg" "explorer_advanced.reg"
    "windowmetrics.reg" "hkcu_run.reg" "hklm_run.reg"
    "gameconfigstore.reg" "gamedvr.reg" "gamedvr_policy.reg"
    "mm_games.reg"
) do (
    if exist "%HK_LATEST%\%%~F" reg import "%HK_LATEST%\%%~F" >nul 2>&1
)
call :restart_explorer
call :log "Registry restoration completed"
powershell -NoProfile -Command "Write-Host '  Registry restoration completed.' -ForegroundColor Green"
echo.
exit /b 0

:: ================================================================
:: RESTORE: Power defaults
:: ================================================================
:restore_power_defaults
call :log "Restoring default power schemes"
powershell -NoProfile -Command "Write-Host '  [*] Restoring default power schemes...' -ForegroundColor Cyan"
echo.
powercfg /restoredefaultschemes >nul 2>&1
call :log "Default power schemes restored"
powershell -NoProfile -Command "Write-Host '  Default power schemes restored.' -ForegroundColor Green"
echo.
exit /b 0

:: ================================================================
:: RESTORE: Hibernation
:: ================================================================
:enable_hibernation
call :log "Re-enabling hibernation"
powershell -NoProfile -Command "Write-Host '  [*] Re-enabling hibernation...' -ForegroundColor Cyan"
echo.
powercfg /h on >nul 2>&1
call :log "Hibernation enabled"
powershell -NoProfile -Command "Write-Host '  Hibernation enabled.' -ForegroundColor Green"
echo.
exit /b 0

:: ================================================================
:: RESTORE: Network defaults
:: ================================================================
:restore_network_defaults
call :log "Resetting network stack to defaults"
powershell -NoProfile -Command "Write-Host '  [*] Resetting network stack...' -ForegroundColor Cyan"
echo.
netsh winsock reset >nul 2>&1
netsh int ip reset >nul 2>&1
netsh int tcp set global autotuninglevel=normal >nul 2>&1
ipconfig /flushdns >nul 2>&1
call :log "Network stack reset complete"
powershell -NoProfile -Command "Write-Host '  Network reset complete. A restart is recommended.' -ForegroundColor Green"
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