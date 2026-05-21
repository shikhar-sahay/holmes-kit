
function Show-Header {
    Write-Host ""
    Write-Host "  --------------------------- STARTUP MANAGER ----------------------------" -ForegroundColor DarkGray
    Write-Host "  Registry Run Keys + Task Scheduler (logon/boot triggers)" -ForegroundColor DarkGray
    Write-Host "  [LOCK] = protected by Windows, cannot be toggled here." -ForegroundColor DarkGray
    Write-Host "  ------------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host ""
}

# Protected task paths - Windows won't let even admins disable these via cmdlets
$ProtectedPaths = @(
    "\Microsoft\Windows\AppID\",
    "\Microsoft\Windows\AppxDeploymentClient\",
    "\Microsoft\Windows\CertificateServicesClient\",
    "\Microsoft\Windows\MUI\",
    "\Microsoft\Windows\PushToInstall\",
    "\Microsoft\Windows\Shell\",
    "\Microsoft\Windows\SideShow\",
    "\Microsoft\Windows\UNP\",
    "\Microsoft\Windows\WaaSMedic\",
    "\Microsoft\Windows\WindowsUpdate\",
    "\Microsoft\Windows\UpdateOrchestrator\",
    "\Microsoft\Windows\Winlogon\",
    "\Microsoft\Windows\Workplace Join\"
)

function Is-ProtectedTask($taskPath) {
    foreach ($p in $ProtectedPaths) {
        if ($taskPath -like "*$p*") { return $true }
    }
    return $false
}

function Get-RegistryStartups {
    $entries = @()
    $paths = @(
        @{ Hive="HKCU"; Path="Software\Microsoft\Windows\CurrentVersion\Run" },
        @{ Hive="HKLM"; Path="Software\Microsoft\Windows\CurrentVersion\Run" },
        @{ Hive="HKCU"; Path="Software\Microsoft\Windows\CurrentVersion\RunOnce" }
    )
    foreach ($p in $paths) {
        $regPath = "$($p.Hive):\$($p.Path)"
        try {
            $key = Get-ItemProperty -Path $regPath -ErrorAction Stop
            foreach ($prop in $key.PSObject.Properties) {
                if ($prop.Name -match "^PS" -or $prop.Name -eq "(default)") { continue }
                $approvedBase = if ($p.Hive -eq "HKCU") {
                    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run"
                } else {
                    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run"
                }
                $status = "Enabled"
                try {
                    $val = (Get-ItemProperty -Path $approvedBase -Name $prop.Name -ErrorAction Stop).($prop.Name)
                    if ($val -and $val[0] -eq 3) { $status = "Disabled" }
                } catch {}

                # Test write access to the approved path
                $canWrite = $true
                try {
                    $acl = Get-Acl -Path $approvedBase -ErrorAction Stop
                    # Quick test: try to open the key with write access
                    $testKey = [Microsoft.Win32.Registry]::LocalMachine
                    if ($p.Hive -eq "HKCU") { $testKey = [Microsoft.Win32.Registry]::CurrentUser }
                    $approvedRelPath = $approvedBase -replace "^HK[CL][MU]:\\",""
                    $opened = $testKey.OpenSubKey($approvedRelPath, $true)
                    if ($opened -eq $null) { $canWrite = $false } else { $opened.Close() }
                } catch { $canWrite = $false }

                $entries += [PSCustomObject]@{
                    Type         = "Registry"
                    Hive         = $p.Hive
                    RegPath      = $p.Path
                    ApprovedPath = $approvedBase
                    Name         = $prop.Name
                    Command      = [string]$prop.Value
                    Status       = $status
                    Locked       = -not $canWrite
                }
            }
        } catch {}
    }
    return $entries
}

function Get-SchedulerStartups {
    $entries = @()
    try {
        $allTasks = Get-ScheduledTask -ErrorAction Stop
        foreach ($t in $allTasks) {
            $hasLoginTrigger = $false
            foreach ($trigger in $t.Triggers) {
                $cn = $trigger.CimClass.CimClassName
                if ($cn -match "Logon" -or $cn -match "Boot") { $hasLoginTrigger = $true; break }
            }
            if (-not $hasLoginTrigger) { continue }

            $isProtected = Is-ProtectedTask $t.TaskPath

            $action = $t.Actions | Select-Object -First 1
            $cmd = if ($action -and $action.Execute) { $action.Execute } else { "(no action)" }
            $entries += [PSCustomObject]@{
                Type         = "Scheduler"
                Hive         = $t.TaskPath
                ApprovedPath = ""
                RegPath      = ""
                Name         = $t.TaskName
                Command      = $cmd
                Status       = if ($t.State -eq "Ready" -or $t.State -eq "Running") { "Enabled" } else { "Disabled" }
                Locked       = $isProtected
            }
        }
    } catch {}
    return $entries
}

function Show-Entries($entries) {
    $i = 1
    foreach ($e in $entries) {
        if ($e.Locked) {
            $statusTag = "[LOCK]"
            $statusColor = "DarkGray"
            $nameColor = "DarkGray"
        } else {
            $statusTag = if ($e.Status -eq "Enabled") { "[ON] " } else { "[OFF]" }
            $statusColor = if ($e.Status -eq "Enabled") { "Green" } else { "DarkGray" }
            $nameColor = "White"
        }
        $typeTag = if ($e.Type -eq "Registry") { "REG " } else { "TASK" }
        $name = $e.Name.Substring(0, [Math]::Min($e.Name.Length, 32)).PadRight(32)
        $cmd  = $e.Command.Substring(0, [Math]::Min($e.Command.Length, 34))

        Write-Host "  [" -ForegroundColor DarkGray -NoNewline
        Write-Host ("{0,2}" -f $i) -ForegroundColor Cyan -NoNewline
        Write-Host "] " -ForegroundColor DarkGray -NoNewline
        Write-Host "$statusTag " -ForegroundColor $statusColor -NoNewline
        Write-Host "$typeTag  " -ForegroundColor DarkGray -NoNewline
        Write-Host "$name  " -ForegroundColor $nameColor -NoNewline
        Write-Host "$cmd" -ForegroundColor DarkGray
        $i++
    }
}

function Toggle-RegistryEntry($entry) {
    if ($entry.Locked) {
        Write-Host "  This entry is protected and cannot be toggled." -ForegroundColor DarkGray
        Write-Host "  You can remove it manually via Task Manager > Startup." -ForegroundColor DarkGray
        return
    }
    $approvedPath = $entry.ApprovedPath
    try {
        if (-not (Test-Path $approvedPath)) {
            New-Item -Path $approvedPath -Force | Out-Null
        }
        $bytes = if ($entry.Status -eq "Enabled") { [byte[]](@(3) + (@(0) * 15)) } else { [byte[]](@(2) + (@(0) * 15)) }
        Set-ItemProperty -Path $approvedPath -Name $entry.Name -Value $bytes -Type Binary -ErrorAction Stop
        $msg = if ($entry.Status -eq "Enabled") { "Disabled" } else { "Enabled" }
        $col = if ($entry.Status -eq "Enabled") { "Yellow" } else { "Green" }
        Write-Host "  $msg`: $($entry.Name)" -ForegroundColor $col
    } catch {
        Write-Host "  Could not toggle $($entry.Name)." -ForegroundColor Red
        Write-Host "  Try disabling it via Task Manager > Startup tab instead." -ForegroundColor DarkGray
    }
}

function Toggle-SchedulerEntry($entry) {
    if ($entry.Locked) {
        Write-Host "  This task is protected by Windows and cannot be toggled here." -ForegroundColor DarkGray
        Write-Host "  Path: $($entry.Hive)" -ForegroundColor DarkGray
        return
    }
    try {
        $taskPath = $entry.Hive
        if (-not $taskPath.EndsWith("\")) { $taskPath = $taskPath + "\" }
        if ($entry.Status -eq "Enabled") {
            Disable-ScheduledTask -TaskName $entry.Name -TaskPath $taskPath -ErrorAction Stop | Out-Null
            Write-Host "  Disabled: $($entry.Name)" -ForegroundColor Yellow
        } else {
            Enable-ScheduledTask -TaskName $entry.Name -TaskPath $taskPath -ErrorAction Stop | Out-Null
            Write-Host "  Enabled: $($entry.Name)" -ForegroundColor Green
        }
    } catch {
        Write-Host "  Could not toggle: $($entry.Name)" -ForegroundColor Red
        Write-Host "  $($_.Exception.Message)" -ForegroundColor DarkGray
        Write-Host "  You can manage this via Task Scheduler (taskschd.msc)." -ForegroundColor DarkGray
    }
}

$running = $true
while ($running) {
    Clear-Host
    Show-Header
    Write-Host "  Scanning entries..." -ForegroundColor DarkGray
    $allEntries = @()
    $allEntries += Get-RegistryStartups
    $allEntries += Get-SchedulerStartups
    Clear-Host
    Show-Header
    if ($allEntries.Count -eq 0) {
        Write-Host "  No startup entries found." -ForegroundColor DarkGray
    } else {
        Show-Entries $allEntries
    }
    Write-Host ""
    Write-Host "  ------------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "  Enter a number to toggle. [LOCK] entries are read-only." -ForegroundColor DarkGray
    Write-Host "  0 = back." -ForegroundColor DarkGray
    Write-Host ""
    $choice = Read-Host "  > "
    if ($choice -eq "0" -or $choice -eq "") { $running = $false; break }
    $idx = $null
    if ([int]::TryParse($choice, [ref]$idx)) {
        if ($idx -ge 1 -and $idx -le $allEntries.Count) {
            $entry = $allEntries[$idx - 1]
            Write-Host ""
            if ($entry.Type -eq "Registry") { Toggle-RegistryEntry $entry } else { Toggle-SchedulerEntry $entry }
            Start-Sleep -Milliseconds 1200
        } else {
            Write-Host "  Invalid number." -ForegroundColor Red
            Start-Sleep -Milliseconds 700
        }
    }
}
Write-Host ""
