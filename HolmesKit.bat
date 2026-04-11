@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"
title HolmesKit
color 0A

:: -----------------------------------------------------------------
:: HolmesKit - Safe Windows optimization toolkit
:: Focus: general responsiveness, cleanup, and optional gaming tweaks
:: -----------------------------------------------------------------

call :require_admin
call :init_paths
call :startup_notice

:main_menu
cls
echo ================================================================
echo HolmesKit
echo ================================================================
echo  [1] Core
echo  [2] Advanced
echo  [3] Gaming
echo  [4] Restore
echo  [5] Exit
echo.
set /p HK_MAIN=Select an option: 
if "%HK_MAIN%"=="1" goto core_menu
if "%HK_MAIN%"=="2" goto advanced_menu
if "%HK_MAIN%"=="3" goto gaming_menu
if "%HK_MAIN%"=="4" goto restore_menu
if "%HK_MAIN%"=="5" exit /b 0
goto main_menu

:core_menu
cls
echo ===================== CORE =====================
echo  [1] Run full core optimization
echo  [2] Cleanup temp and cache files
echo  [3] Apply power plan optimization
echo  [4] Run safe background cleanup
echo  [5] Back
echo.
set /p HK_CORE=Select an option: 
if "%HK_CORE%"=="1" call :run_full_core & goto pause_return
if "%HK_CORE%"=="2" call :ensure_backup & call :cleanup_temp & goto pause_return
if "%HK_CORE%"=="3" call :ensure_backup & call :apply_power_plan & goto pause_return
if "%HK_CORE%"=="4" call :ensure_backup & call :cleanup_background & goto pause_return
if "%HK_CORE%"=="5" goto main_menu
goto core_menu

:advanced_menu
cls
echo ==================== ADVANCED ===================
echo  [1] UI responsiveness tweaks
echo  [2] Visual effects performance mode
echo  [3] Startup pruning (safe allowlist)
echo  [4] Network maintenance
echo  [5] Disable hibernation
echo  [6] Back
echo.
set /p HK_ADV=Select an option: 
if "%HK_ADV%"=="1" call :ensure_backup & call :ui_responsiveness_tweaks & goto pause_return
if "%HK_ADV%"=="2" call :ensure_backup & call :visual_performance_mode & goto pause_return
if "%HK_ADV%"=="3" call :ensure_backup & call :startup_pruning & goto pause_return
if "%HK_ADV%"=="4" call :ensure_backup & call :network_maintenance & goto pause_return
if "%HK_ADV%"=="5" call :ensure_backup & call :disable_hibernation & goto pause_return
if "%HK_ADV%"=="6" goto main_menu
goto advanced_menu

:gaming_menu
cls
echo ===================== GAMING ====================
echo  [1] FPS tweaks
echo  [2] Latency maintenance
echo  [3] Full gaming prep
echo  [4] Back
echo.
set /p HK_GAME=Select an option: 
if "%HK_GAME%"=="1" call :ensure_backup & call :gaming_fps_tweaks & goto pause_return
if "%HK_GAME%"=="2" call :ensure_backup & call :gaming_latency_maintenance & goto pause_return
if "%HK_GAME%"=="3" call :ensure_backup & call :gaming_full_prep & goto pause_return
if "%HK_GAME%"=="4" goto main_menu
goto gaming_menu

:restore_menu
cls
echo ===================== RESTORE ===================
echo  [1] Restore latest registry backups
echo  [2] Restore default power schemes ^(removes custom schemes^)
echo  [3] Re-enable hibernation
echo  [4] Reset network stack
echo  [5] Restart Explorer
echo  [6] Back
echo.
set /p HK_RESTORE=Select an option: 
if "%HK_RESTORE%"=="1" call :restore_latest_registry & goto pause_return
if "%HK_RESTORE%"=="2" call :restore_power_defaults & goto pause_return
if "%HK_RESTORE%"=="3" call :enable_hibernation & goto pause_return
if "%HK_RESTORE%"=="4" call :restore_network_defaults & goto pause_return
if "%HK_RESTORE%"=="5" call :restart_explorer & goto pause_return
if "%HK_RESTORE%"=="6" goto main_menu
goto restore_menu

:pause_return
echo.
pause
goto main_menu

:require_admin
net session >nul 2>&1
if %errorlevel%==0 exit /b 0
echo HolmesKit requires Administrator privileges.
echo Right-click the batch file and choose "Run as administrator".
echo.
pause
exit /b 1

:init_paths
set "HK_ROOT=%~dp0"
if "%HK_ROOT:~-1%"=="\" set "HK_ROOT=%HK_ROOT:~0,-1%"
set "HK_STATE=%HK_ROOT%\HolmesKit_Backups"
set "HK_LATEST=%HK_STATE%\latest"
if not exist "%HK_STATE%" md "%HK_STATE%" >nul 2>&1
set "HK_BACKUP_READY=0"
exit /b 0

:startup_notice
cls
echo ================================================================
echo HolmesKit will make system-level changes.
echo.
echo It can:
echo  - delete temporary files and cache folders
echo  - change power settings
echo  - apply reversible registry tweaks
echo  - run optional gaming-focused changes
echo.
echo Strong recommendation: create a restore point before proceeding.
echo ================================================================
echo.
set /p HK_RP=Create a restore point now? [Y/N]: 
if /I "%HK_RP%"=="Y" call :create_restore_point
exit /b 0

:ensure_backup
if "%HK_BACKUP_READY%"=="1" exit /b 0
if exist "%HK_LATEST%" rd /s /q "%HK_LATEST%" >nul 2>&1
md "%HK_LATEST%" >nul 2>&1
call :export_key "HKCU\Control Panel\Desktop" "desktop.reg"
call :export_key "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" "visualeffects.reg"
call :export_key "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "explorer_advanced.reg"
call :export_key "HKCU\Control Panel\Desktop\WindowMetrics" "windowmetrics.reg"
call :export_key "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" "hkcu_run.reg"
call :export_key "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" "hklm_run.reg"
call :export_key "HKCU\System\GameConfigStore" "gameconfigstore.reg"
call :export_key "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" "gamedvr.reg"
call :export_key "HKLM\Software\Policies\Microsoft\Windows\GameDVR" "gamedvr_policy.reg"
set "HK_BACKUP_READY=1"
echo Backup folder prepared at:
echo %HK_LATEST%
exit /b 0

:export_key
reg export "%~1" "%HK_LATEST%\%~2" /y >nul 2>&1
exit /b 0

:create_restore_point
echo Attempting to create a restore point...
powershell -NoProfile -ExecutionPolicy Bypass -Command "try { $d = $env:SystemDrive + '\\'; Enable-ComputerRestore -Drive $d -ErrorAction SilentlyContinue; Checkpoint-Computer -Description 'HolmesKit Pre-Change' -RestorePointType 'MODIFY_SETTINGS'; exit 0 } catch { exit 1 }" >nul 2>&1
if %errorlevel%==0 (
  echo Restore point created successfully.
) else (
  echo Restore point could not be created automatically.
  echo This can happen if System Restore is disabled on the system.
)
exit /b 0

:run_full_core
call :cleanup_temp
call :apply_power_plan
call :cleanup_background
call :restart_explorer
echo Full core optimization completed.
exit /b 0

:cleanup_temp
echo [*] Cleaning temp and cache folders...
call :purge_dir "%TEMP%"
call :purge_dir "%LOCALAPPDATA%\Temp"
call :purge_dir "%SystemRoot%\Temp"
if exist "%LOCALAPPDATA%\Microsoft\Windows\INetCache" call :purge_dir "%LOCALAPPDATA%\Microsoft\Windows\INetCache"
if exist "%LOCALAPPDATA%\D3DSCache" call :purge_dir "%LOCALAPPDATA%\D3DSCache"
if exist "%LOCALAPPDATA%\NVIDIA\DXCache" call :purge_dir "%LOCALAPPDATA%\NVIDIA\DXCache"
if exist "%LOCALAPPDATA%\NVIDIA\GLCache" call :purge_dir "%LOCALAPPDATA%\NVIDIA\GLCache"
ipconfig /flushdns >nul 2>&1
echo Temp cleanup completed.
exit /b 0

:purge_dir
if not exist "%~1" exit /b 0
del /f /s /q "%~1\*" >nul 2>&1
for /d %%D in ("%~1\*") do rd /s /q "%%~fD" >nul 2>&1
exit /b 0

:apply_power_plan
echo [*] Applying High Performance power plan...
powercfg /setactive SCHEME_MIN >nul 2>&1
if %errorlevel%==0 (
  echo High Performance plan activated.
) else (
  echo Could not activate High Performance using alias. Attempting fallback...
  for /f "tokens=3" %%G in ('powercfg -list ^| findstr /i "High performance"') do set "HK_POWER_GUID=%%G"
  if defined HK_POWER_GUID powercfg /setactive !HK_POWER_GUID! >nul 2>&1
)
exit /b 0

:cleanup_background
echo [*] Terminating safe background apps...
for %%P in (
  OneDrive.exe
  Teams.exe
  ms-teams.exe
  Spotify.exe
  Discord.exe
  EpicGamesLauncher.exe
  EpicWebHelper.exe
  Battle.net.exe
  AdobeIPCBroker.exe
  CCXProcess.exe
  AdobeGCClient.exe
  msedge.exe
  chrome.exe
  firefox.exe
) do taskkill /f /im "%%P" >nul 2>&1
echo Background cleanup completed.
exit /b 0

:ui_responsiveness_tweaks
echo [*] Applying UI responsiveness tweaks...
reg add "HKCU\Control Panel\Desktop" /v MenuShowDelay /t REG_SZ /d 100 /f >nul
reg add "HKCU\Control Panel\Desktop" /v HungAppTimeout /t REG_SZ /d 4000 /f >nul
reg add "HKCU\Control Panel\Desktop" /v WaitToKillAppTimeout /t REG_SZ /d 5000 /f >nul
reg add "HKCU\Control Panel\Desktop" /v ForegroundLockTimeout /t REG_DWORD /d 0 /f >nul
call :restart_explorer
echo UI responsiveness tweaks applied.
exit /b 0

:visual_performance_mode
echo [*] Applying visual effects performance mode...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f >nul
reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v MinAnimate /t REG_SZ /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarAnimations /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ListviewAlphaSelect /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ListviewShadow /t REG_DWORD /d 0 /f >nul
call :restart_explorer
echo Visual effects performance mode applied.
exit /b 0

:startup_pruning
echo [*] Removing selected startup entries from Run keys...
call :delete_run_value "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" "OneDrive"
call :delete_run_value "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" "Discord"
call :delete_run_value "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" "Spotify"
call :delete_run_value "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" "Skype"
call :delete_run_value "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" "Zoom"
call :delete_run_value "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" "EpicGamesLauncher"
call :delete_run_value "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" "com.squirrel.Teams.Teams"
call :delete_run_value "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" "OneDrive"
call :delete_run_value "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" "TeamsMachineInstaller"
echo Startup pruning completed for the allowlist.
exit /b 0

:delete_run_value
reg delete "%~1" /v "%~2" /f >nul 2>&1
exit /b 0

:network_maintenance
echo [*] Running network maintenance...
ipconfig /flushdns >nul 2>&1
ipconfig /release >nul 2>&1
ipconfig /renew >nul 2>&1
netsh winsock reset >nul 2>&1
netsh int ip reset >nul 2>&1
echo Network maintenance completed. A restart is recommended.
exit /b 0

:disable_hibernation
echo [*] Disabling hibernation...
powercfg /h off >nul 2>&1
echo Hibernation disabled.
exit /b 0

:gaming_fps_tweaks
echo [*] Applying FPS-oriented tweaks...
call :apply_power_plan
reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v AppCaptureEnabled /t REG_DWORD /d 0 /f >nul
reg add "HKLM\Software\Policies\Microsoft\Windows\GameDVR" /v AllowGameDVR /t REG_DWORD /d 0 /f >nul
call :visual_performance_mode
call :cleanup_background
echo FPS tweaks applied.
exit /b 0

:gaming_latency_maintenance
echo [*] Applying latency-oriented maintenance...
ipconfig /flushdns >nul 2>&1
netsh winsock reset >nul 2>&1
for %%S in (DoSvc BITS) do net stop %%S >nul 2>&1
call :cleanup_background
echo Latency maintenance applied. A restart may improve effect.
exit /b 0

:gaming_full_prep
call :gaming_fps_tweaks
call :gaming_latency_maintenance
echo Full gaming prep completed.
exit /b 0

:restore_latest_registry
if not exist "%HK_LATEST%" (
  echo No backup folder was found at %HK_LATEST%
  exit /b 0
)
echo [*] Restoring latest exported registry backups...
for %%F in (
  "%HK_LATEST%\desktop.reg"
  "%HK_LATEST%\visualeffects.reg"
  "%HK_LATEST%\explorer_advanced.reg"
  "%HK_LATEST%\windowmetrics.reg"
  "%HK_LATEST%\hkcu_run.reg"
  "%HK_LATEST%\hklm_run.reg"
  "%HK_LATEST%\gameconfigstore.reg"
  "%HK_LATEST%\gamedvr.reg"
  "%HK_LATEST%\gamedvr_policy.reg"
) do (
  if exist %%~F reg import %%~F >nul 2>&1
)
call :restart_explorer
echo Registry restoration completed.
exit /b 0

:restore_power_defaults
echo [*] Restoring default power schemes...
powercfg /restoredefaultschemes >nul 2>&1
echo Default power schemes restored.
exit /b 0

:enable_hibernation
echo [*] Re-enabling hibernation...
powercfg /h on >nul 2>&1
echo Hibernation enabled.
exit /b 0

:restore_network_defaults
echo [*] Resetting network stack to defaults...
netsh winsock reset >nul 2>&1
netsh int ip reset >nul 2>&1
ipconfig /flushdns >nul 2>&1
echo Network defaults restoration queued. A restart is recommended.
exit /b 0

:restart_explorer
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe >nul 2>&1
exit /b 0
