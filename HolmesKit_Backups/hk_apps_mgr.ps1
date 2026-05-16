
function Show-Header {
    Write-Host ""
    Write-Host "                 ======================== APPS MANAGER ========================" -ForegroundColor DarkGray
    Write-Host "                 Lists installed apps. Enter a number to launch its uninstaller." -ForegroundColor DarkGray
    Write-Host "                 ==============================================================" -ForegroundColor DarkGray
    Write-Host ""
}

function Get-InstalledApps {
    $paths = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    $seen = @{}
    $apps = foreach ($path in $paths) {
        Get-ItemProperty $path -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -and $_.UninstallString } |
        Select-Object DisplayName, DisplayVersion, Publisher, EstimatedSize, UninstallString
    }
    $unique = $apps | Sort-Object DisplayName | Group-Object DisplayName | ForEach-Object { $_.Group[0] }
    return $unique
}

$running = $true
while ($running) {
    Clear-Host
    Show-Header
    $apps = @(Get-InstalledApps)
    if ($apps.Count -eq 0) {
        Write-Host "                 No applications found." -ForegroundColor DarkGray
    } else {
        $i = 1
        foreach ($app in $apps) {
            $name = $app.DisplayName.Substring(0, [Math]::Min($app.DisplayName.Length, 45)).PadRight(45)
            $ver  = if ($app.DisplayVersion) { $app.DisplayVersion.Substring(0, [Math]::Min($app.DisplayVersion.Length, 14)).PadRight(14) } else { "".PadRight(14) }
            $sizeMB = if ($app.EstimatedSize) { "$([Math]::Round($app.EstimatedSize / 1024, 1)) MB" } else { "" }
            Write-Host "                 [" -ForegroundColor DarkGray -NoNewline
            Write-Host ("{0,3}" -f $i) -ForegroundColor Cyan -NoNewline
            Write-Host "]  " -ForegroundColor DarkGray -NoNewline
            Write-Host "$name  " -ForegroundColor White -NoNewline
            Write-Host "$ver  " -ForegroundColor DarkGray -NoNewline
            Write-Host "$sizeMB" -ForegroundColor DarkGray
            $i++
        }
    }
    Write-Host ""
    Write-Host "                 ==============================================================" -ForegroundColor DarkGray
    Write-Host "                 Enter a number to launch uninstaller, or 0 to go back." -ForegroundColor DarkGray
    Write-Host ""
    $choice = Read-Host "                 > "
    if ($choice -eq "0" -or $choice -eq "") { $running = $false; break }
    $idx = $null
    if ([int]::TryParse($choice, [ref]$idx)) {
        if ($idx -ge 1 -and $idx -le $apps.Count) {
            $app = $apps[$idx - 1]
            Write-Host ""
            Write-Host "                 Launching uninstaller for: $($app.DisplayName)" -ForegroundColor Yellow
            Write-Host "                 The uninstaller may open a separate window." -ForegroundColor DarkGray
            Write-Host ""
            try {
                $uninstStr = $app.UninstallString
                if ($uninstStr -match "MsiExec") {
                    $guid = [regex]::Match($uninstStr, "\{[^}]+\}").Value
                    if ($guid) {
                        Start-Process "msiexec.exe" -ArgumentList "/x $guid /qb" -Wait
                    } else {
                        Start-Process "msiexec.exe" -ArgumentList $uninstStr.Replace("MsiExec.exe ","") -Wait
                    }
                } else {
                    Start-Process "cmd.exe" -ArgumentList "/c `"$uninstStr`"" -Wait
                }
            } catch {
                Write-Host "                 Could not launch uninstaller: $_" -ForegroundColor Red
            }
            Write-Host ""
            Write-Host "                 Done. Press any key to refresh the list..." -ForegroundColor Green
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        } else {
            Write-Host "                 Invalid selection." -ForegroundColor Red
            Start-Sleep -Milliseconds 700
        }
    }
}
Write-Host ""
