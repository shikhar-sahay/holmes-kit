function Show-Header {
    Write-Host ""
    Write-Host "  ----------------------------- APPS MANAGER -----------------------------" -ForegroundColor DarkGray
    Write-Host "  Lists installed apps. Enter a number to launch its uninstaller." -ForegroundColor DarkGray
    Write-Host "  ------------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host ""
}

function Get-InstalledApps {
    $paths = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    $apps = foreach ($path in $paths) {
        Get-ItemProperty $path -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -and $_.UninstallString }
    }
    return $apps | Sort-Object DisplayName | Group-Object DisplayName | ForEach-Object { $_.Group[0] }
}

$running = $true
while ($running) {
    Clear-Host
    Show-Header
    Write-Host "  Loading installed apps..." -ForegroundColor DarkGray
    $apps = @(Get-InstalledApps)
    Clear-Host
    Show-Header
    if ($apps.Count -eq 0) {
        Write-Host "  No applications found." -ForegroundColor DarkGray
    } else {
        $i = 1
        foreach ($app in $apps) {
            $name   = $app.DisplayName.Substring(0, [Math]::Min($app.DisplayName.Length, 46)).PadRight(46)
            $ver    = if ($app.DisplayVersion) { $app.DisplayVersion.Substring(0, [Math]::Min($app.DisplayVersion.Length, 14)).PadRight(14) } else { "".PadRight(14) }
            $sizeMB = if ($app.EstimatedSize) { "$([Math]::Round($app.EstimatedSize / 1024, 1)) MB" } else { "     " }
            Write-Host "  [" -ForegroundColor DarkGray -NoNewline
            Write-Host ("{0,3}" -f $i) -ForegroundColor Cyan -NoNewline
            Write-Host "]  " -ForegroundColor DarkGray -NoNewline
            Write-Host "$name  " -ForegroundColor White -NoNewline
            Write-Host "$ver  " -ForegroundColor DarkGray -NoNewline
            Write-Host "$sizeMB" -ForegroundColor DarkGray
            $i++
        }
    }
    Write-Host ""
    Write-Host "  ------------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "  Enter a number to launch uninstaller, or 0 to go back." -ForegroundColor DarkGray
    Write-Host ""
    $choice = Read-Host "  > "
    if ($choice -eq "0" -or $choice -eq "") { $running = $false; break }
    $idx = $null
    if ([int]::TryParse($choice, [ref]$idx)) {
        if ($idx -ge 1 -and $idx -le $apps.Count) {
            $app = $apps[$idx - 1]
            $approval = Read-Host "  Launch the uninstaller for $($app.DisplayName)? [Y/N]"
            if ($approval -ine 'Y') { Write-Host '  Cancelled.'; continue }
            Write-Host ""
            Write-Host "  Launching uninstaller for: $($app.DisplayName)" -ForegroundColor Yellow
            Write-Host "  The uninstaller may open a separate window." -ForegroundColor DarkGray
            try {
                # Share identity revalidation, conservative executable parsing and exit handling
                # with Desktop; this remains a standalone PowerShell CLI with no .NET GUI dependency.
                $encodedCommand = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes([string]$app.UninstallString))
                $encodedName = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes([string]$app.DisplayName))
                & powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'gui_bridge.ps1') -Action app-uninstall -Data $encodedCommand -NameData $encodedName
                if ($LASTEXITCODE -eq 3) { Write-Host '  Uninstaller cancelled.' -ForegroundColor Yellow }
                elseif ($LASTEXITCODE -ne 0) { throw "Uninstaller did not complete (exit $LASTEXITCODE). Review the diagnostic above." }
            } catch {
                Write-Host "  Could not launch uninstaller: $_" -ForegroundColor Red
            }
            Write-Host ""
            Write-Host "  Press any key to refresh..." -ForegroundColor DarkGray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        } else {
            Write-Host "  Invalid selection." -ForegroundColor Red
            Start-Sleep -Milliseconds 700
        }
    }
}
Write-Host ""
