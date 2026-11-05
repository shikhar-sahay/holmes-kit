@echo off
chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"
if /I not "%~1"=="--engine" set "HK_RECOVERY_CHILD="
if /I "%~1"=="--run" set "HK_NONINTERACTIVE=1"
if /I "%~1"=="--engine" (
    if not defined HK_RECOVERY_CHILD exit /b 2
    set "HK_NONINTERACTIVE=1"
)
title HolmesKit
if not defined HK_NONINTERACTIVE mode con: cols=110 lines=42

call :require_admin
if errorlevel 1 exit /b 1
call :init_paths
if /I "%~1"=="--run" goto command_dispatch
if /I "%~1"=="--engine" goto command_dispatch
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
set "HK_MAIN="
set /p HK_MAIN=  ^> 
if errorlevel 1 exit /b 3
if "!HK_MAIN!"=="0" goto apply_all
if "!HK_MAIN!"=="1" goto core_menu
if "!HK_MAIN!"=="2" goto advanced_menu
if "!HK_MAIN!"=="3" goto gaming_menu
if "!HK_MAIN!"=="4" goto restore_menu
if "!HK_MAIN!"=="5" goto system_info
if "!HK_MAIN!"=="6" goto startup_manager
if "!HK_MAIN!"=="7" goto apps_manager
if "!HK_MAIN!"=="8" exit /b 0
goto main_menu

:: non-interactive entry point used by the desktop frontend
:: Usage: HolmesKit.bat --run <operation-id>
:command_dispatch
set "HK_COMMAND=%~2"
goto dispatch_selected

:dispatch_selected
if defined HK_RECOVERY_CHILD goto dispatch_engine
powershell -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "%~dp0modules\recovery.ps1" -Action Execute -Operation "!HK_COMMAND!"
exit /b %errorlevel%

:dispatch_engine
if not defined HK_COMMAND (
    echo ERROR: Missing operation id.
    exit /b 2
)
if /I "!HK_COMMAND!"=="core-full" goto dispatch_core_full
if /I "!HK_COMMAND!"=="cleanup-temp" goto dispatch_cleanup_temp
if /I "!HK_COMMAND!"=="power-high" goto dispatch_power_high
if /I "!HK_COMMAND!"=="cleanup-background" goto dispatch_cleanup_background
if /I "!HK_COMMAND!"=="ui-responsive" goto dispatch_ui_responsive
if /I "!HK_COMMAND!"=="visual-performance" goto dispatch_visual_performance
if /I "!HK_COMMAND!"=="startup-prune" goto dispatch_startup_prune
if /I "!HK_COMMAND!"=="network-maintenance" goto dispatch_network_maintenance
if /I "!HK_COMMAND!"=="services-cleanup" goto dispatch_services_cleanup
if /I "!HK_COMMAND!"=="hibernation-disable" goto dispatch_hibernation_disable
if /I "!HK_COMMAND!"=="gaming-fps" goto dispatch_gaming_fps
if /I "!HK_COMMAND!"=="gaming-latency" goto dispatch_gaming_latency
if /I "!HK_COMMAND!"=="gaming-full" goto dispatch_gaming_full
if /I "!HK_COMMAND!"=="apply-all" goto dispatch_apply_all
if /I "!HK_COMMAND!"=="restore-registry" goto dispatch_restore_registry
if /I "!HK_COMMAND!"=="restore-power" goto dispatch_restore_power
if /I "!HK_COMMAND!"=="restore-services" goto dispatch_restore_services
if /I "!HK_COMMAND!"=="restore-hibernation" goto dispatch_restore_hibernation
if /I "!HK_COMMAND!"=="restore-network" goto dispatch_restore_network
if /I "!HK_COMMAND!"=="restart-explorer" goto dispatch_restart_explorer
echo ERROR: Unknown operation id "!HK_COMMAND!".
exit /b 2

:dispatch_core_full
call :run_full_core
exit /b !errorlevel!
:dispatch_cleanup_temp
call :ensure_backup
if errorlevel 1 exit /b 1
call :cleanup_temp
exit /b !errorlevel!
:dispatch_power_high
call :ensure_backup
if errorlevel 1 exit /b 1
call :apply_power_plan
exit /b !errorlevel!
:dispatch_cleanup_background
call :ensure_backup
if errorlevel 1 exit /b 1
call :cleanup_background
exit /b !errorlevel!
:dispatch_ui_responsive
call :ensure_backup
if errorlevel 1 exit /b 1
call :ui_responsiveness_tweaks
exit /b !errorlevel!
:dispatch_visual_performance
call :ensure_backup
if errorlevel 1 exit /b 1
call :visual_performance_mode
exit /b !errorlevel!
:dispatch_startup_prune
call :ensure_backup
if errorlevel 1 exit /b 1
call :startup_pruning
exit /b !errorlevel!
:dispatch_network_maintenance
call :ensure_backup
if errorlevel 1 exit /b 1
call :network_maintenance
exit /b !errorlevel!
:dispatch_services_cleanup
call :ensure_backup
if errorlevel 1 exit /b 1
call :services_cleanup
exit /b !errorlevel!
:dispatch_hibernation_disable
call :ensure_backup
if errorlevel 1 exit /b 1
call :disable_hibernation
exit /b !errorlevel!
:dispatch_gaming_fps
call :ensure_backup
if errorlevel 1 exit /b 1
call :gaming_fps_tweaks
exit /b !errorlevel!
:dispatch_gaming_latency
call :ensure_backup
if errorlevel 1 exit /b 1
call :gaming_latency_maintenance
exit /b !errorlevel!
:dispatch_gaming_full
call :ensure_backup
if errorlevel 1 exit /b 1
call :gaming_full_prep
exit /b !errorlevel!
:dispatch_apply_all
call :run_apply_all
exit /b !errorlevel!
:dispatch_restore_registry
call :restore_latest_registry
exit /b !errorlevel!
:dispatch_restore_power
call :restore_power_defaults
exit /b !errorlevel!
:dispatch_restore_services
call :restore_services
exit /b !errorlevel!
:dispatch_restore_hibernation
call :enable_hibernation
exit /b !errorlevel!
:dispatch_restore_network
call :restore_network_defaults
exit /b !errorlevel!
:dispatch_restart_explorer
call :restart_explorer
exit /b !errorlevel!

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
set "HK_CORE="
set /p HK_CORE=  ^> 
if errorlevel 1 exit /b 3
set "HK_RETURN_MENU=core"
if "!HK_CORE!"=="1" (
  call :confirm_open "Run Full Core Optimization"
  powershell -NoProfile -Command ^
    "Write-Host '  What this does:' -ForegroundColor White;" ^
    "Write-Host '  Runs all core steps in sequence: temp cleanup, High Performance' -ForegroundColor DarkGray;" ^
    "Write-Host '  power plan, background app termination, and Explorer restart.' -ForegroundColor DarkGray;" ^
    "Write-Host '';" ^
    "Write-Host '  Deleted files and unsaved application work cannot be recovered.' -ForegroundColor Yellow; Write-Host '  Affected: Temp folders, Power Plan, Background Processes, Explorer' -ForegroundColor Yellow;"
  call :confirm_close
  call :run_confirmed core-full
  goto pause_return
)
if "!HK_CORE!"=="2" (
  call :confirm_open "Cleanup Temp And Cache Files"
  powershell -NoProfile -Command ^
    "Write-Host '  What this does:' -ForegroundColor White;" ^
    "Write-Host '  Deletes contents of %%TEMP%%, Windows Temp, INetCache, and GPU shader' -ForegroundColor DarkGray;" ^
    "Write-Host '  caches (NVIDIA DXCache, GLCache, D3DSCache). Also flushes the DNS' -ForegroundColor DarkGray;" ^
    "Write-Host '  resolver cache.' -ForegroundColor DarkGray;" ^
    "Write-Host '';" ^
    "Write-Host '  Deleted files cannot be restored from the registry backup.' -ForegroundColor Yellow; Write-Host '  Affected: Temp folders, DNS Cache, GPU Shader Caches' -ForegroundColor Yellow;"
  call :confirm_close
  call :run_confirmed cleanup-temp
  goto pause_return
)
if "!HK_CORE!"=="3" (
  call :confirm_open "Apply Power Plan Optimization"
  powershell -NoProfile -Command ^
    "Write-Host '  What this does:' -ForegroundColor White;" ^
    "Write-Host '  Switches your active power plan to High Performance. This prevents' -ForegroundColor DarkGray;" ^
    "Write-Host '  the CPU from throttling down during load and removes artificial' -ForegroundColor DarkGray;" ^
    "Write-Host '  frequency limits.' -ForegroundColor DarkGray;" ^
    "Write-Host '';" ^
    "Write-Host '  Recovery selects the original captured plan if it remains available.' -ForegroundColor Yellow; Write-Host '  Affected: Windows Power Plan' -ForegroundColor Yellow;"
  call :confirm_close
  call :run_confirmed power-high
  goto pause_return
)
if "!HK_CORE!"=="4" (
  call :confirm_open "Safe Background Cleanup"
  powershell -NoProfile -Command ^
    "Write-Host '  What this does:' -ForegroundColor White;" ^
    "Write-Host '  Force-closes common background apps that consume RAM and CPU:' -ForegroundColor DarkGray;" ^
    "Write-Host '  OneDrive, Teams, Spotify, Discord, Epic Games, Battle.net, Adobe' -ForegroundColor DarkGray;" ^
    "Write-Host '  background services, and open browsers.' -ForegroundColor DarkGray;" ^
    "Write-Host '';" ^
    "Write-Host '  Unsaved application work may be lost permanently.' -ForegroundColor Yellow; Write-Host '  Affected: Running processes (apps can be reopened normally)' -ForegroundColor Yellow;"
  call :confirm_close
  call :run_confirmed cleanup-background
  goto pause_return
)
if "!HK_CORE!"=="5" goto main_menu
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
set "HK_ADV="
set /p HK_ADV=  ^> 
if errorlevel 1 exit /b 3
set "HK_RETURN_MENU=advanced"
if "!HK_ADV!"=="1" (
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
  call :run_confirmed ui-responsive
  goto pause_return
)
if "!HK_ADV!"=="2" (
  call :confirm_open "Visual Effects Performance Mode"
  powershell -NoProfile -Command ^
    "Write-Host '  What this does:' -ForegroundColor White;" ^
    "Write-Host '  Disables window animations, taskbar animations, list-view shadows,' -ForegroundColor DarkGray;" ^
    "Write-Host '  and alpha selection effects. Sets Windows to Performance mode for' -ForegroundColor DarkGray;" ^
    "Write-Host '  visual effects. Noticeable on lower-end hardware.' -ForegroundColor DarkGray;" ^
    "Write-Host '';" ^
    "Write-Host '  Affected: Registry (HKCU Explorer\VisualEffects, WindowMetrics)' -ForegroundColor Yellow;"
  call :confirm_close
  call :run_confirmed visual-performance
  goto pause_return
)
if "!HK_ADV!"=="3" (
  call :confirm_open "Startup Pruning"
  powershell -NoProfile -Command ^
    "Write-Host '  What this does:' -ForegroundColor White;" ^
    "Write-Host '  Removes startup registry entries for: OneDrive, Discord, Spotify,' -ForegroundColor DarkGray;" ^
    "Write-Host '  Skype, Zoom, Epic Games Launcher, Teams. These apps will no longer' -ForegroundColor DarkGray;" ^
    "Write-Host '  auto-launch at login. You can still open them manually.' -ForegroundColor DarkGray;" ^
    "Write-Host '';" ^
    "Write-Host '  Affected: Registry (HKCU\Run and HKLM\Run startup keys)' -ForegroundColor Yellow;"
  call :confirm_close
  call :run_confirmed startup-prune
  goto pause_return
)
if "!HK_ADV!"=="4" (
  call :confirm_open "Network Maintenance"
  powershell -NoProfile -Command ^
    "Write-Host '  What this does:' -ForegroundColor White;" ^
    "Write-Host '  Flushes DNS cache, releases and renews your IP address, resets the' -ForegroundColor DarkGray;" ^
    "Write-Host '  Winsock catalog, and resets the TCP/IP stack. Useful if you are' -ForegroundColor DarkGray;" ^
    "Write-Host '  experiencing degraded network performance.' -ForegroundColor DarkGray;" ^
    "Write-Host '';" ^
    "Write-Host '  Affected: DNS Cache, IP Lease, Winsock, TCP/IP Stack (restart rec.)' -ForegroundColor Yellow;"
  call :confirm_close
  call :run_confirmed network-maintenance
  goto pause_return
)
if "!HK_ADV!"=="5" (
  call :confirm_open "Background Services Cleanup"
  powershell -NoProfile -Command ^
    "Write-Host '  What this does:' -ForegroundColor White;" ^
    "Write-Host '  Stops and disables three high-overhead background services: SysMain' -ForegroundColor DarkGray;" ^
    "Write-Host '  (Superfetch memory preloader), WSearch (Windows Search Indexer),' -ForegroundColor DarkGray;" ^
    "Write-Host '  and DiagTrack (Telemetry). Service states are saved for restore.' -ForegroundColor DarkGray;" ^
    "Write-Host '';" ^
    "Write-Host '  Affected: SysMain, WSearch, DiagTrack services (restorable)' -ForegroundColor Yellow;"
  call :confirm_close
  call :run_confirmed services-cleanup
  goto pause_return
)
if "!HK_ADV!"=="6" (
  call :confirm_open "Disable Hibernation"
  powershell -NoProfile -Command ^
    "Write-Host '  What this does:' -ForegroundColor White;" ^
    "Write-Host '  Disables Windows hibernation and removes the hiberfil.sys file,' -ForegroundColor DarkGray;" ^
    "Write-Host '  which can be several GB on your system drive. Sleep mode is' -ForegroundColor DarkGray;" ^
    "Write-Host '  unaffected.' -ForegroundColor DarkGray;" ^
    "Write-Host '';" ^
    "Write-Host '  Affected: Hibernation state, hiberfil.sys (frees disk space)' -ForegroundColor Yellow;"
  call :confirm_close
  call :run_confirmed hibernation-disable
  goto pause_return
)
if "!HK_ADV!"=="7" goto main_menu
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
set "HK_GAME="
set /p HK_GAME=  ^> 
if errorlevel 1 exit /b 3
set "HK_RETURN_MENU=gaming"
if "!HK_GAME!"=="1" (
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
  call :run_confirmed gaming-fps
  goto pause_return
)
if "!HK_GAME!"=="2" (
  call :confirm_open "Latency Maintenance"
  powershell -NoProfile -Command ^
    "Write-Host '  What this does:' -ForegroundColor White;" ^
    "Write-Host '  Flushes DNS, resets Winsock, enables TCP Fast Open and RSS (Receive' -ForegroundColor DarkGray;" ^
    "Write-Host '  Side Scaling), disables Nagle algorithm for lower latency, and' -ForegroundColor DarkGray;" ^
    "Write-Host '  pauses Windows Update delivery (BITS and DoSvc) during your session.' -ForegroundColor DarkGray;" ^
    "Write-Host '';" ^
    "Write-Host '  Affected: TCP/IP stack, Winsock, Windows Update delivery services' -ForegroundColor Yellow;"
  call :confirm_close
  call :run_confirmed gaming-latency
  goto pause_return
)
if "!HK_GAME!"=="3" (
  call :confirm_open "Full Gaming Prep"
  powershell -NoProfile -Command ^
    "Write-Host '  What this does:' -ForegroundColor White;" ^
    "Write-Host '  Runs FPS Tweaks and Latency Maintenance in sequence. Applies all' -ForegroundColor DarkGray;" ^
    "Write-Host '  gaming optimizations in one step.' -ForegroundColor DarkGray;" ^
    "Write-Host '';" ^
    "Write-Host '  Affected: All of the above combined' -ForegroundColor Yellow;"
  call :confirm_close
  call :run_confirmed gaming-full
  goto pause_return
)
if "!HK_GAME!"=="4" goto main_menu
goto gaming_menu

:restore_menu
cls
call :print_header
powershell -NoProfile -Command ^
  "Write-Host '  --------------------------- RESTORE DEFAULTS ---------------------------' -ForegroundColor DarkGray;" ^
  "Write-Host '';" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '1' -ForegroundColor Cyan -NoNewline; Write-Host ']  Restore Managed Registry Values' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '2' -ForegroundColor Cyan -NoNewline; Write-Host ']  Restore Previous Power Plan' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '3' -ForegroundColor Cyan -NoNewline; Write-Host ']  Restore Managed Service States' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '4' -ForegroundColor Cyan -NoNewline; Write-Host ']  Re-Enable Hibernation' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '5' -ForegroundColor Cyan -NoNewline; Write-Host ']  Reset Network Stack' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '6' -ForegroundColor Cyan -NoNewline; Write-Host ']  Restart Explorer' -ForegroundColor White;" ^
  "Write-Host '  [' -ForegroundColor DarkGray -NoNewline; Write-Host '7' -ForegroundColor Red -NoNewline; Write-Host ']  Back' -ForegroundColor White;" ^
  "Write-Host '';" ^
  "Write-Host '  ------------------------------------------------------------------------' -ForegroundColor DarkGray;"
echo.
set "HK_RETURN_MENU=restore"
set "HK_RESTORE="
set /p HK_RESTORE=  ^> 
if errorlevel 1 exit /b 3
if "!HK_RESTORE!"=="1" (
    call :confirm_open "Restore and Recovery"
    echo   This changes Windows configuration. Recovery may apply defaults,
    echo   skip conflicts, or reset network/hibernation defaults as labelled.
    call :confirm_close
    call :run_confirmed restore-registry
    goto pause_return
)
if "!HK_RESTORE!"=="2" (
    call :confirm_open "Restore and Recovery"
    echo   This changes Windows configuration. Recovery may apply defaults,
    echo   skip conflicts, or reset network/hibernation defaults as labelled.
    call :confirm_close
    call :run_confirmed restore-power
    goto pause_return
)
if "!HK_RESTORE!"=="3" (
    call :confirm_open "Restore and Recovery"
    echo   This changes Windows configuration. Recovery may apply defaults,
    echo   skip conflicts, or reset network/hibernation defaults as labelled.
    call :confirm_close
    call :run_confirmed restore-services
    goto pause_return
)
if "!HK_RESTORE!"=="4" (
    call :confirm_open "Restore and Recovery"
    echo   This changes Windows configuration. Recovery may apply defaults,
    echo   skip conflicts, or reset network/hibernation defaults as labelled.
    call :confirm_close
    call :run_confirmed restore-hibernation
    goto pause_return
)
if "!HK_RESTORE!"=="5" (
    call :confirm_open "Restore and Recovery"
    echo   This changes Windows configuration. Recovery may apply defaults,
    echo   skip conflicts, or reset network/hibernation defaults as labelled.
    call :confirm_close
    call :run_confirmed restore-network
    goto pause_return
)
if "!HK_RESTORE!"=="6" (
    call :confirm_open "Restore and Recovery"
    echo   This changes Windows configuration. Recovery may apply defaults,
    echo   skip conflicts, or reset network/hibernation defaults as labelled.
    call :confirm_close
    call :run_confirmed restart-explorer
    goto pause_return
)
if "!HK_RESTORE!"=="7" goto main_menu
goto restore_menu

:pause_return
set "HK_CONFIRMED=0"
echo.
powershell -NoProfile -Command "Write-Host '  Press any key to return to the menu...' -ForegroundColor Green"
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
set "HK_CONFIRMED=0"
set "HK_CONFIRM="
echo.
powershell -NoProfile -Command "Write-Host '  ------------------------------------------------------------------------' -ForegroundColor DarkGray"
echo.
set /p HK_CONFIRM=  Proceed? [Y/N]:  
if errorlevel 1 (
    echo   Cancelled: blank or unavailable confirmation input.
    exit /b 3
)
if /I "!HK_CONFIRM!"=="Y" set "HK_CONFIRMED=1"
if /I "!HK_CONFIRM!"=="N" (
    echo   Declined. No operation was started.
) else if "!HK_CONFIRMED!"=="0" (
    echo   Invalid confirmation. No operation was started.
)
echo.
exit /b 0

:: Consume authorization once; GUI calls the dispatcher after its own dialog.
:run_confirmed
if not "!HK_CONFIRMED!"=="1" (
    echo   Cancelled. No operation was started.
    exit /b 3
)
set "HK_CONFIRMED=0"
set "HK_COMMAND=%~1"
call :dispatch_selected
set "HK_RESULT=!errorlevel!"
if "!HK_RESULT!"=="0" (
    echo   Operation completed successfully.
) else (
    echo   Operation failed. Some changes may already have been made; review the log.
)
exit /b %HK_RESULT%

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
if defined HK_NONINTERACTIVE exit /b 1
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
echo     - Apply managed registry tweaks with scoped recovery
echo     - Run optional gaming-focused optimizations
echo.
powershell -NoProfile -Command "Write-Host '  A restore point is strongly recommended before continuing.' -ForegroundColor Yellow"
echo.
powershell -NoProfile -Command "Write-Host '  ------------------------------------------------------------------------' -ForegroundColor DarkGray"
echo.
set "HK_RP="
set /p HK_RP=  Create a restore point now? [Y/N]:  
if /I "!HK_RP!"=="Y" call :create_restore_point
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
powershell -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "%~dp0modules\recovery.ps1" -Action Validate -Operation "!HK_COMMAND!"
if errorlevel 1 (
    echo ERROR: Required recovery baseline validation failed. No protected operation started.
    exit /b 1
)
exit /b 0

:export_key
reg query "%~1" >nul 2>&1
if errorlevel 1 (
    powershell -NoProfile -Command "try { $p='%~1' -replace '^HKCU','HKCU:' -replace '^HKLM','HKLM:'; Get-Item -LiteralPath $p -EA Stop | Out-Null; exit 1 } catch [System.Management.Automation.ItemNotFoundException] { exit 0 } catch { Write-Error $_; exit 1 }"
    if errorlevel 1 (
        set "HK_BACKUP_FAILED=1"
        exit /b 1
    )
    echo %~1^|%~2>>"%HK_LATEST%\absent_keys.txt"
    if errorlevel 1 set "HK_BACKUP_FAILED=1"
    exit /b 0
)
reg export "%~1" "%HK_LATEST%\%~2" /y >nul 2>&1
if errorlevel 1 set "HK_BACKUP_FAILED=1"
if not exist "%HK_LATEST%\%~2" set "HK_BACKUP_FAILED=1"
exit /b 0

:: core: runs all four steps in sequence
:run_full_core
call :ensure_backup
if errorlevel 1 exit /b 1
call :cleanup_temp
if errorlevel 1 exit /b 1
call :apply_power_plan
if errorlevel 1 exit /b 1
call :cleanup_background
if errorlevel 1 exit /b 1
call :restart_explorer
if errorlevel 1 exit /b 1
call :log "Full core optimization completed"
powershell -NoProfile -Command "Write-Host '  Full Core Optimization Completed.' -ForegroundColor Green"
echo.
exit /b 0

:: core: wipe temp folders and flush dns
:cleanup_temp
call :log "Starting temp/cache cleanup"
powershell -NoProfile -Command "Write-Host '  [*] Cleaning Temp And Cache Folders...' -ForegroundColor Cyan"
echo.
set "HK_CLEAN_FAILED=0"
call :purge_dir "%TEMP%" || set "HK_CLEAN_FAILED=1"
call :purge_dir "%LOCALAPPDATA%\Temp" || set "HK_CLEAN_FAILED=1"
call :purge_dir "%SystemRoot%\Temp" || set "HK_CLEAN_FAILED=1"
if exist "%LOCALAPPDATA%\Microsoft\Windows\INetCache" (
    call :purge_dir "%LOCALAPPDATA%\Microsoft\Windows\INetCache"
    if errorlevel 1 set "HK_CLEAN_FAILED=1"
)
if exist "%LOCALAPPDATA%\D3DSCache" (
    call :purge_dir "%LOCALAPPDATA%\D3DSCache"
    if errorlevel 1 set "HK_CLEAN_FAILED=1"
)
if exist "%LOCALAPPDATA%\NVIDIA\DXCache" (
    call :purge_dir "%LOCALAPPDATA%\NVIDIA\DXCache"
    if errorlevel 1 set "HK_CLEAN_FAILED=1"
)
if exist "%LOCALAPPDATA%\NVIDIA\GLCache" (
    call :purge_dir "%LOCALAPPDATA%\NVIDIA\GLCache"
    if errorlevel 1 set "HK_CLEAN_FAILED=1"
)
ipconfig /flushdns || set "HK_CLEAN_FAILED=1"
if "!HK_CLEAN_FAILED!"=="1" (
    echo WARNING: Cleanup partially failed. In-use or inaccessible files may remain.
    call :log "Temp cleanup partially failed"
    exit /b 1
)
call :log "Temp/cache cleanup complete"
powershell -NoProfile -Command "Write-Host '  Temp Cleanup Completed.' -ForegroundColor Green"
echo.
exit /b 0

:purge_dir
if not exist "%~1" exit /b 0
set "HK_PURGE_FAILED=0"
del /f /s /q "%~1\*" >nul 2>&1 || set "HK_PURGE_FAILED=1"
for /d %%D in ("%~1\*") do (
    rd /s /q "%%~fD" >nul 2>&1
    if exist "%%~fD" set "HK_PURGE_FAILED=1"
)
exit /b %HK_PURGE_FAILED%

:: core: switch to high performance plan
:apply_power_plan
call :log "Applying High Performance power plan"
powershell -NoProfile -Command "Write-Host '  [*] Applying High Performance Power Plan...' -ForegroundColor Cyan"
echo.
powercfg /setactive SCHEME_MIN
if %errorlevel%==0 (
    powershell -NoProfile -Command "Write-Host '  High Performance Plan Activated.' -ForegroundColor Green"
    call :log "High Performance plan activated"
) else (
    for /f "tokens=4 delims=: " %%G in ('powercfg /list ^| findstr /i "High performance"') do set "HK_POWER_GUID=%%G"
    if defined HK_POWER_GUID (
        powercfg /setactive !HK_POWER_GUID! >nul 2>&1
        if errorlevel 1 (
            powershell -NoProfile -Command "Write-Host '  Could Not Activate High Performance Plan.' -ForegroundColor Red"
            call :log "Failed to activate High Performance plan via GUID"
            exit /b 1
        ) else (
            powershell -NoProfile -Command "Write-Host '  High Performance Plan Activated.' -ForegroundColor Green"
            call :log "High Performance plan activated via GUID"
        )
    ) else (
        powershell -NoProfile -Command "Write-Host '  Could Not Activate High Performance Plan.' -ForegroundColor Red"
        call :log "Failed to activate High Performance plan"
        exit /b 1
    )
)
echo.
exit /b 0

:: core: kill common background apps
:cleanup_background
call :log "Terminating background processes"
powershell -NoProfile -Command "Write-Host '  [*] Terminating Background Apps...' -ForegroundColor Cyan"
echo.
set "HK_PROCESS_FAILED=0"
for %%P in (
    OneDrive.exe Teams.exe ms-teams.exe Spotify.exe Discord.exe
    EpicGamesLauncher.exe EpicWebHelper.exe Battle.net.exe
    AdobeIPCBroker.exe CCXProcess.exe AdobeGCClient.exe
    msedge.exe chrome.exe firefox.exe
) do (
    taskkill /f /im "%%P" >nul 2>&1
    if errorlevel 1 if not "!errorlevel!"=="128" set "HK_PROCESS_FAILED=1"
)
if "!HK_PROCESS_FAILED!"=="1" (
    echo ERROR: Some background processes could not be closed.
    exit /b 1
)
call :log "Background cleanup complete"
powershell -NoProfile -Command "Write-Host '  Background Cleanup Completed.' -ForegroundColor Green"
echo.
exit /b 0

:: advanced: registry tweaks for snappier ui and lower disk i/o
:ui_responsiveness_tweaks
call :log "Applying UI responsiveness tweaks"
powershell -NoProfile -Command "Write-Host '  [*] Applying UI Responsiveness Tweaks...' -ForegroundColor Cyan"
echo.
set "HK_STEP_FAILED=0"
reg add "HKCU\Control Panel\Desktop" /v MenuShowDelay /t REG_SZ /d "100" /f || set "HK_STEP_FAILED=1"
reg add "HKCU\Control Panel\Desktop" /v HungAppTimeout /t REG_SZ /d "4000" /f || set "HK_STEP_FAILED=1"
reg add "HKCU\Control Panel\Desktop" /v WaitToKillAppTimeout /t REG_SZ /d "5000" /f || set "HK_STEP_FAILED=1"
reg add "HKCU\Control Panel\Desktop" /v ForegroundLockTimeout /t REG_DWORD /d "0" /f || set "HK_STEP_FAILED=1"
reg add "HKCU\Control Panel\Desktop" /v AutoEndTasks /t REG_SZ /d "1" /f || set "HK_STEP_FAILED=1"
:: foreground apps get longer cpu slices
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d "26" /f || set "HK_STEP_FAILED=1"
:: skip writing last-access timestamps on file reads
fsutil behavior set disablelastaccess 1 >nul 2>&1 || set "HK_STEP_FAILED=1"
if "!HK_STEP_FAILED!"=="1" (
    call :log "UI responsiveness tweaks failed"
    exit /b 1
)
call :restart_explorer
if errorlevel 1 exit /b 1
call :log "UI responsiveness tweaks applied"
powershell -NoProfile -Command "Write-Host '  UI Responsiveness Tweaks Applied.' -ForegroundColor Green"
echo.
exit /b 0

:: advanced: strip animations and visual fluff
:visual_performance_mode
call :log "Applying visual effects performance mode"
powershell -NoProfile -Command "Write-Host '  [*] Applying Visual Effects Performance Mode...' -ForegroundColor Cyan"
echo.
set "HK_STEP_FAILED=0"
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d "2" /f || set "HK_STEP_FAILED=1"
reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v MinAnimate /t REG_SZ /d "0" /f || set "HK_STEP_FAILED=1"
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarAnimations /t REG_DWORD /d "0" /f || set "HK_STEP_FAILED=1"
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ListviewAlphaSelect /t REG_DWORD /d "0" /f || set "HK_STEP_FAILED=1"
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ListviewShadow /t REG_DWORD /d "0" /f || set "HK_STEP_FAILED=1"
if "!HK_STEP_FAILED!"=="1" (
    call :log "Visual effects performance mode failed"
    exit /b 1
)
call :restart_explorer
if errorlevel 1 exit /b 1
call :log "Visual effects performance mode applied"
powershell -NoProfile -Command "Write-Host '  Visual Effects Performance Mode Applied.' -ForegroundColor Green"
echo.
exit /b 0

:: advanced: remove common startup registry entries
:startup_pruning
call :log "Running startup pruning"
powershell -NoProfile -Command "Write-Host '  [*] Removing Startup Entries...' -ForegroundColor Cyan"
echo.
set "HK_PRUNE_FAILED=0"
call :del_run "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" "OneDrive" || set "HK_PRUNE_FAILED=1"
call :del_run "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" "Discord" || set "HK_PRUNE_FAILED=1"
call :del_run "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" "Spotify" || set "HK_PRUNE_FAILED=1"
call :del_run "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" "Skype" || set "HK_PRUNE_FAILED=1"
call :del_run "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" "Zoom" || set "HK_PRUNE_FAILED=1"
call :del_run "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" "EpicGamesLauncher" || set "HK_PRUNE_FAILED=1"
call :del_run "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" "com.squirrel.Teams.Teams" || set "HK_PRUNE_FAILED=1"
call :del_run "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" "OneDrive" || set "HK_PRUNE_FAILED=1"
call :del_run "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" "TeamsMachineInstaller" || set "HK_PRUNE_FAILED=1"
if "!HK_PRUNE_FAILED!"=="1" (
    echo ERROR: Some startup entries could not be removed.
    exit /b 1
)
call :log "Startup pruning complete"
powershell -NoProfile -Command "Write-Host '  Startup Pruning Completed.' -ForegroundColor Green"
echo.
exit /b 0

:del_run
powershell -NoProfile -Command "try { $p='%~1' -replace '^HKCU','HKCU:' -replace '^HKLM','HKLM:'; $k=Get-Item -LiteralPath $p -EA Stop; if ($k.GetValueNames() -contains '%~2') { Remove-ItemProperty -LiteralPath $p -Name '%~2' -EA Stop }; exit 0 } catch [System.Management.Automation.ItemNotFoundException] { exit 0 } catch { Write-Error $_; exit 1 }"
exit /b %errorlevel%

:: advanced: flush/reset network stack
:network_maintenance
call :log "Running network maintenance"
powershell -NoProfile -Command "Write-Host '  [*] Running Network Maintenance...' -ForegroundColor Cyan"
echo.
set "HK_STEP_FAILED=0"
ipconfig /flushdns || set "HK_STEP_FAILED=1"
ipconfig /release || set "HK_STEP_FAILED=1"
ipconfig /renew || set "HK_STEP_FAILED=1"
netsh winsock reset || set "HK_STEP_FAILED=1"
netsh int ip reset || set "HK_STEP_FAILED=1"
if "!HK_STEP_FAILED!"=="1" (
    call :log "Network maintenance failed"
    exit /b 1
)
call :log "Network maintenance complete"
powershell -NoProfile -Command "Write-Host '  Network Maintenance Completed. A Restart Is Recommended.' -ForegroundColor Green"
echo.
exit /b 0

:: advanced: stop and disable high-overhead background services
:services_cleanup
call :log "Running background services cleanup"
powershell -NoProfile -Command "Write-Host '  [*] Stopping And Disabling Background Services...' -ForegroundColor Cyan"
echo.
set "HK_STEP_FAILED=0"
sc stop SysMain
if errorlevel 1 if not "!errorlevel!"=="1062" set "HK_STEP_FAILED=1"
sc config SysMain start= disabled || set "HK_STEP_FAILED=1"
powershell -NoProfile -Command "Write-Host '    [-] SysMain (Superfetch) stopped and disabled' -ForegroundColor DarkGray"
sc stop WSearch
if errorlevel 1 if not "!errorlevel!"=="1062" set "HK_STEP_FAILED=1"
sc config WSearch start= disabled || set "HK_STEP_FAILED=1"
powershell -NoProfile -Command "Write-Host '    [-] WSearch (Search Indexer) stopped and disabled' -ForegroundColor DarkGray"
sc stop DiagTrack
if errorlevel 1 if not "!errorlevel!"=="1062" set "HK_STEP_FAILED=1"
sc config DiagTrack start= disabled || set "HK_STEP_FAILED=1"
powershell -NoProfile -Command "Write-Host '    [-] DiagTrack (Telemetry) stopped and disabled' -ForegroundColor DarkGray"
if "!HK_STEP_FAILED!"=="1" (
    call :log "Background services cleanup failed"
    exit /b 1
)
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
powercfg /h off || exit /b 1
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
if errorlevel 1 exit /b 1
set "HK_STEP_FAILED=0"
reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d "0" /f || set "HK_STEP_FAILED=1"
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v AppCaptureEnabled /t REG_DWORD /d "0" /f || set "HK_STEP_FAILED=1"
reg add "HKLM\Software\Policies\Microsoft\Windows\GameDVR" /v AllowGameDVR /t REG_DWORD /d "0" /f || set "HK_STEP_FAILED=1"
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d "8" /f || set "HK_STEP_FAILED=1"
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d "6" /f || set "HK_STEP_FAILED=1"
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d "High" /f || set "HK_STEP_FAILED=1"
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "SFIO Priority" /t REG_SZ /d "High" /f || set "HK_STEP_FAILED=1"
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /t REG_DWORD /d "0" /f || set "HK_STEP_FAILED=1"
if "!HK_STEP_FAILED!"=="1" exit /b 1
call :visual_performance_mode
if errorlevel 1 exit /b 1
call :cleanup_background
if errorlevel 1 exit /b 1
call :log "Gaming FPS tweaks applied"
powershell -NoProfile -Command "Write-Host '  FPS Tweaks Applied.' -ForegroundColor Green"
echo.
exit /b 0

:: gaming: tcp stack cleanup, nagle off, pause windows update delivery
:gaming_latency_maintenance
call :log "Applying gaming latency maintenance"
powershell -NoProfile -Command "Write-Host '  [*] Applying Latency Maintenance...' -ForegroundColor Cyan"
echo.
set "HK_STEP_FAILED=0"
ipconfig /flushdns || set "HK_STEP_FAILED=1"
netsh winsock reset || set "HK_STEP_FAILED=1"
netsh int tcp set global fastopen=enabled || set "HK_STEP_FAILED=1"
netsh int tcp set global rss=enabled || set "HK_STEP_FAILED=1"
netsh int tcp set global autotuninglevel=disabled || set "HK_STEP_FAILED=1"
powershell -NoProfile -Command "Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces' | ForEach-Object { Set-ItemProperty -Path $_.PSPath -Name 'TcpAckFrequency' -Value 1 -Type DWord -Force -EA Stop; Set-ItemProperty -Path $_.PSPath -Name 'TCPNoDelay' -Value 1 -Type DWord -Force -EA Stop }" >nul 2>&1 || set "HK_STEP_FAILED=1"
if "!HK_STEP_FAILED!"=="1" exit /b 1
powershell -NoProfile -Command "try { foreach($name in @('DoSvc','BITS')) { $s=Get-Service -Name $name -EA Stop; if($s.Status -eq 'Running'){ Stop-Service -Name $name -EA Stop } }; exit 0 } catch { Write-Error $_; exit 1 }"
if errorlevel 1 exit /b 1
call :cleanup_background
if errorlevel 1 exit /b 1
call :log "Gaming latency maintenance applied"
powershell -NoProfile -Command "Write-Host '  Latency Maintenance Applied. A Restart May Improve Effect.' -ForegroundColor Green"
echo.
exit /b 0

:: gaming: fps + latency in one shot
:gaming_full_prep
call :gaming_fps_tweaks
if errorlevel 1 exit /b 1
call :gaming_latency_maintenance
if errorlevel 1 exit /b 1
call :log "Full gaming prep completed"
powershell -NoProfile -Command "Write-Host '  Full Gaming Prep Completed.' -ForegroundColor Green"
echo.
exit /b 0

:: restore: reimport all saved .reg files
:restore_latest_registry
powershell -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "%~dp0modules\recovery.ps1" -Action Execute -Operation restore-registry
exit /b %errorlevel%

:restore_services
powershell -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "%~dp0modules\recovery.ps1" -Action Execute -Operation restore-services
exit /b %errorlevel%

:restore_power_defaults
powershell -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "%~dp0modules\recovery.ps1" -Action Execute -Operation restore-power
exit /b %errorlevel%

:enable_hibernation
call :log "Re-enabling hibernation"
powershell -NoProfile -Command "Write-Host '  [*] Re-Enabling Hibernation...' -ForegroundColor Cyan"
echo.
powercfg /h on || exit /b 1
call :log "Hibernation enabled"
powershell -NoProfile -Command "Write-Host '  Hibernation Enabled.' -ForegroundColor Green"
echo.
exit /b 0

:: restore: undo network tweaks
:restore_network_defaults
call :log "Resetting network stack"
powershell -NoProfile -Command "Write-Host '  [*] Resetting Network Stack...' -ForegroundColor Cyan"
echo.
set "HK_STEP_FAILED=0"
netsh winsock reset || set "HK_STEP_FAILED=1"
netsh int ip reset || set "HK_STEP_FAILED=1"
netsh int tcp set global autotuninglevel=normal || set "HK_STEP_FAILED=1"
netsh int tcp set global fastopen=disabled || set "HK_STEP_FAILED=1"
ipconfig /flushdns || set "HK_STEP_FAILED=1"
powershell -NoProfile -Command "Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces' | ForEach-Object { Remove-ItemProperty -Path $_.PSPath -Name 'TcpAckFrequency' -Force -EA SilentlyContinue; Remove-ItemProperty -Path $_.PSPath -Name 'TCPNoDelay' -Force -EA SilentlyContinue }" >nul 2>&1 || set "HK_STEP_FAILED=1"
if "!HK_STEP_FAILED!"=="1" exit /b 1
call :log "Network stack reset"
powershell -NoProfile -Command "Write-Host '  Network Reset Complete. A Restart Is Recommended.' -ForegroundColor Green"
echo.
exit /b 0

:: restart explorer to apply registry changes
:restart_explorer
call :log "Restarting Explorer"
taskkill /f /im explorer.exe
if errorlevel 1 if not "!errorlevel!"=="128" exit /b 1
start "" explorer.exe
exit /b %errorlevel%

:: shared non-interactive implementation of Apply All
:run_apply_all
call :ensure_backup
if errorlevel 1 exit /b 1
call :cleanup_temp
if errorlevel 1 exit /b 1
call :apply_power_plan
if errorlevel 1 exit /b 1
call :cleanup_background
if errorlevel 1 exit /b 1
call :ui_responsiveness_tweaks
if errorlevel 1 exit /b 1
call :visual_performance_mode
if errorlevel 1 exit /b 1
call :startup_pruning
if errorlevel 1 exit /b 1
call :services_cleanup
if errorlevel 1 exit /b 1
call :disable_hibernation
if errorlevel 1 exit /b 1
call :gaming_fps_tweaks
if errorlevel 1 exit /b 1
call :gaming_latency_maintenance
if errorlevel 1 exit /b 1
call :log "Apply All completed"
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
  "Write-Host '  Required registry backup must succeed first. Recovery is limited.' -ForegroundColor Yellow;" ^
  "Write-Host '  Deleted files and unsaved work cannot be restored.' -ForegroundColor Yellow; Write-Host '  A restart is recommended after this completes.' -ForegroundColor Yellow;" ^
  "Write-Host '';" ^
  "Write-Host '  ------------------------------------------------------------------------' -ForegroundColor DarkGray;"
echo.
call :confirm_close
if not "!HK_CONFIRMED!"=="1" goto main_menu
echo.
call :run_confirmed apply-all
if errorlevel 1 (
    powershell -NoProfile -Command "Write-Host '  Apply All stopped because a step failed.' -ForegroundColor Red"
    goto pause_return
)
echo.
powershell -NoProfile -Command "Write-Host '  ------------------------------------------------------------------------' -ForegroundColor DarkGray"
powershell -NoProfile -Command "Write-Host '  All tweaks applied. Restart when ready.' -ForegroundColor Green"
powershell -NoProfile -Command "Write-Host '  Log: HolmesKit_Backups\holmeskit.log' -ForegroundColor DarkGray"
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
