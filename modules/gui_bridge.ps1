param(
    [Parameter(Mandatory = $true)][ValidateSet('system-info','startup-list','startup-toggle','apps-list','app-uninstall')][string]$Action,
    [string[]]$Data = @()
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$root = Split-Path -Parent $PSScriptRoot
$logPath = Join-Path $root 'HolmesKit_Backups\holmeskit.log'

function Write-HolmesLog([string]$Message) {
    try {
        $folder = Split-Path -Parent $logPath
        if (-not (Test-Path -LiteralPath $folder)) { New-Item -ItemType Directory -Path $folder -Force | Out-Null }
        Add-Content -LiteralPath $logPath -Value "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] GUI: $Message" -Encoding UTF8
    } catch { }
}

function ConvertFrom-HolmesData([string]$Value) {
    return [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($Value))
}

$protectedPaths = @(
    '\Microsoft\Windows\AppID\', '\Microsoft\Windows\AppxDeploymentClient\',
    '\Microsoft\Windows\CertificateServicesClient\', '\Microsoft\Windows\MUI\',
    '\Microsoft\Windows\PushToInstall\', '\Microsoft\Windows\Shell\',
    '\Microsoft\Windows\SideShow\', '\Microsoft\Windows\UNP\',
    '\Microsoft\Windows\WaaSMedic\', '\Microsoft\Windows\WindowsUpdate\',
    '\Microsoft\Windows\UpdateOrchestrator\', '\Microsoft\Windows\Winlogon\',
    '\Microsoft\Windows\Workplace Join\'
)

function Test-ProtectedTask([string]$TaskPath) {
    foreach ($path in $protectedPaths) { if ($TaskPath -like "*$path*") { return $true } }
    return $false
}

function Get-RegistryStartups {
    $entries = @()
    $locations = @(
        @{ Hive='HKCU'; Path='Software\Microsoft\Windows\CurrentVersion\Run' },
        @{ Hive='HKLM'; Path='Software\Microsoft\Windows\CurrentVersion\Run' },
        @{ Hive='HKCU'; Path='Software\Microsoft\Windows\CurrentVersion\RunOnce' }
    )
    foreach ($location in $locations) {
        $regPath = "$($location.Hive):\$($location.Path)"
        $key = Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue
        if (-not $key) { continue }
        foreach ($property in $key.PSObject.Properties) {
            if ($property.Name -match '^PS' -or $property.Name -eq '(default)') { continue }
            $approvedPath = if ($location.Hive -eq 'HKCU') {
                'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run'
            } else {
                'HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run'
            }
            $status = 'Enabled'
            try {
                $value = (Get-ItemProperty -Path $approvedPath -Name $property.Name -ErrorAction Stop).($property.Name)
                if ($value -and $value[0] -eq 3) { $status = 'Disabled' }
            } catch { }
            $locked = $false
            try {
                $base = if ($location.Hive -eq 'HKCU') { [Microsoft.Win32.Registry]::CurrentUser } else { [Microsoft.Win32.Registry]::LocalMachine }
                $relative = $approvedPath -replace '^HK[CL][MU]:\\', ''
                $opened = $base.OpenSubKey($relative, $true)
                if ($null -eq $opened) { $locked = $true } else { $opened.Close() }
            } catch { $locked = $true }
            $entries += [pscustomobject]@{
                Type='Registry'; Hive=$location.Hive; RegPath=$location.Path; ApprovedPath=$approvedPath
                Name=$property.Name; Command=[string]$property.Value; Status=$status; Locked=$locked
            }
        }
    }
    return $entries
}

function Get-SchedulerStartups {
    $entries = @()
    foreach ($task in @(Get-ScheduledTask -ErrorAction SilentlyContinue)) {
        $isStartup = $false
        foreach ($trigger in @($task.Triggers)) {
            if ($trigger.CimClass.CimClassName -match 'Logon|Boot') { $isStartup = $true; break }
        }
        if (-not $isStartup) { continue }
        $taskAction = $task.Actions | Select-Object -First 1
        $entries += [pscustomobject]@{
            Type='Scheduler'; Hive=$task.TaskPath; RegPath=''; ApprovedPath=''; Name=$task.TaskName
            Command=if ($taskAction.Execute) { $taskAction.Execute } else { '(no action)' }
            Status=if ($task.State -in @('Ready','Running')) { 'Enabled' } else { 'Disabled' }
            Locked=(Test-ProtectedTask $task.TaskPath)
        }
    }
    return $entries
}

try {
    switch ($Action) {
        'system-info' {
            $os = Get-CimInstance Win32_OperatingSystem
            $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
            try { $cpuPercent = [Math]::Round((Get-Counter '\Processor(_Total)\% Processor Time' -SampleInterval 1 -MaxSamples 1).CounterSamples.CookedValue, 0) } catch { $cpuPercent = 0 }
            $ramTotal = [Math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
            $ramUsed = [Math]::Round($ramTotal - ($os.FreePhysicalMemory / 1MB), 1)
            $power = 'Unknown'
            try { $line = powercfg /getactivescheme 2>$null; if ($line -match '\((.+)\)') { $power = $Matches[1].Trim() } } catch { }
            $network = 'Unavailable'
            try {
                $activeAdapters = @(Get-NetAdapter -ErrorAction Stop | Where-Object Status -eq 'Up' | Select-Object -ExpandProperty Name)
                if ($activeAdapters.Count -gt 0) { $network = $activeAdapters -join ', ' }
            } catch { }
            $disks = foreach ($drive in Get-PSDrive -PSProvider FileSystem -ErrorAction SilentlyContinue) {
                if ($null -ne $drive.Used -and ($drive.Used + $drive.Free) -gt 0) {
                    $total = $drive.Used + $drive.Free
                    [pscustomobject]@{ Name="$($drive.Name):"; UsedGb=[Math]::Round($drive.Used/1GB,1); TotalGb=[Math]::Round($total/1GB,1); Percent=[Math]::Round($drive.Used/$total*100) }
                }
            }
            $uptime = (Get-Date) - $os.LastBootUpTime
            $snapshot = [pscustomobject]@{
                ComputerName=$env:COMPUTERNAME; Windows=$os.Caption; Cpu=($cpu.Name -replace '\s+',' ').Trim(); CpuPercent=$cpuPercent
                RamUsedGb=$ramUsed; RamTotalGb=$ramTotal; RamPercent=if ($ramTotal) { [Math]::Round($ramUsed/$ramTotal*100) } else { 0 }
                Uptime="$($uptime.Days)d $($uptime.Hours)h $($uptime.Minutes)m"; PowerPlan=$power; Network=$network
                StartupCount=@(Get-RegistryStartups).Count; Disks=@($disks)
            }
            ConvertTo-Json -InputObject $snapshot -Compress -Depth 5
        }
        'startup-list' {
            $items = @(); $items += Get-RegistryStartups; $items += Get-SchedulerStartups
            ConvertTo-Json -InputObject @($items) -Compress -Depth 5
        }
        'startup-toggle' {
            if ($Data.Count -lt 1) { throw 'Startup entry data is missing.' }
            $entry = (ConvertFrom-HolmesData $Data[0]) | ConvertFrom-Json
            if ($entry.Locked) { throw 'This startup entry is protected and cannot be changed.' }
            if ($entry.Type -eq 'Registry') {
                if (-not (Test-Path $entry.ApprovedPath)) { New-Item -Path $entry.ApprovedPath -Force | Out-Null }
                $bytes = if ($entry.Status -eq 'Enabled') { [byte[]](@(3) + (@(0) * 15)) } else { [byte[]](@(2) + (@(0) * 15)) }
                Set-ItemProperty -Path $entry.ApprovedPath -Name $entry.Name -Value $bytes -Type Binary -ErrorAction Stop
            } elseif ($entry.Type -eq 'Scheduler') {
                if (Test-ProtectedTask $entry.Hive) { throw 'This scheduled task is protected by Windows.' }
                $taskPath = $entry.Hive; if (-not $taskPath.EndsWith('\')) { $taskPath += '\' }
                if ($entry.Status -eq 'Enabled') { Disable-ScheduledTask -TaskName $entry.Name -TaskPath $taskPath -ErrorAction Stop | Out-Null }
                else { Enable-ScheduledTask -TaskName $entry.Name -TaskPath $taskPath -ErrorAction Stop | Out-Null }
            } else { throw 'Unknown startup entry type.' }
            Write-HolmesLog "Startup entry toggled: $($entry.Name)"
            Write-Output "Startup entry updated: $($entry.Name)"
        }
        'apps-list' {
            $paths = @(
                'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
                'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
                'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
            )
            $apps = foreach ($path in $paths) {
                Get-ItemProperty $path -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -and $_.UninstallString }
            }
            $result = $apps | Sort-Object DisplayName | Group-Object DisplayName | ForEach-Object {
                $app = $_.Group[0]
                [pscustomobject]@{
                    Name=[string]$app.DisplayName; Publisher=[string]$app.Publisher; Version=[string]$app.DisplayVersion
                    Size=if ($app.EstimatedSize) { "$([Math]::Round($app.EstimatedSize/1024,1)) MB" } else { '' }
                    UninstallData=[Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes([string]$app.UninstallString))
                }
            }
            ConvertTo-Json -InputObject @($result) -Compress -Depth 4
        }
        'app-uninstall' {
            if ($Data.Count -lt 2) { throw 'Application uninstall data is missing.' }
            $uninstall = ConvertFrom-HolmesData $Data[0]
            $name = ConvertFrom-HolmesData $Data[1]
            if ($uninstall -match '(?i)MsiExec') {
                $guid = [regex]::Match($uninstall, '\{[^}]+\}').Value
                if ($guid) { $process = Start-Process msiexec.exe -ArgumentList @('/x', $guid, '/qb') -Wait -PassThru }
                else { $process = Start-Process msiexec.exe -ArgumentList ($uninstall -replace '(?i)^.*?MsiExec(?:\.exe)?\s*','') -Wait -PassThru }
            } elseif ($uninstall -match '^"([^"]+)"(.*)$') {
                $process = Start-Process $Matches[1] -ArgumentList $Matches[2].Trim() -Wait -PassThru
            } else {
                $parts = $uninstall -split ' ', 2
                $process = Start-Process $parts[0] -ArgumentList $(if ($parts.Count -gt 1) { $parts[1] } else { '' }) -Wait -PassThru
            }
            if ($process.ExitCode -notin @(0,1602,3010)) { throw "Uninstaller exited with code $($process.ExitCode)." }
            Write-HolmesLog "Uninstaller completed for: $name (exit $($process.ExitCode))"
            Write-Output "Uninstaller completed for $name."
        }
    }
} catch {
    [Console]::Error.WriteLine($_.Exception.Message)
    exit 1
}
