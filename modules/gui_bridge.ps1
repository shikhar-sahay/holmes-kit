param(
    [Parameter(Mandatory = $true)][ValidateSet('system-info','startup-list','startup-toggle','apps-list','app-uninstall')][string]$Action,
    [string[]]$Data = @()
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$WarningPreference = 'SilentlyContinue'
$InformationPreference = 'SilentlyContinue'
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

function Get-HolmesPowerPlan {
    $standardPlans = @{
        '381b4222-f694-41f0-9685-ff5bb260df2e' = 'Balanced'
        '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c' = 'High performance'
        'a1841308-3541-4fab-bc81-f71556f20b4a' = 'Power saver'
        'e9a42b02-d5df-448d-aa00-03f14749eb61' = 'Ultimate Performance'
    }
    try {
        $guid = [string](Get-ItemPropertyValue -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes' -Name ActivePowerScheme -ErrorAction Stop)
        $guid = $guid.Trim('{}').ToLowerInvariant()
        $parsedGuid = [Guid]::Empty
        if (-not [Guid]::TryParse($guid, [ref]$parsedGuid)) { throw 'The active power-plan GUID is malformed.' }
        if ($standardPlans.ContainsKey($guid)) {
            return [pscustomobject]@{ Name=$standardPlans[$guid]; Kind='Standard'; Guid=$guid }
        }
        $schemePath = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes\$guid"
        $name = [string](Get-ItemPropertyValue -LiteralPath $schemePath -Name FriendlyName -ErrorAction SilentlyContinue)
        if ([string]::IsNullOrWhiteSpace($name) -or $name.StartsWith('@')) { $name = 'Unnamed custom plan' }
        return [pscustomobject]@{ Name=$name.Trim(); Kind='Custom'; Guid=$guid }
    } catch {
        return [pscustomobject]@{ Name='Unknown'; Kind='Unknown'; Guid=''; Error=$_.Exception.Message }
    }
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
                Source=if ($location.Path.EndsWith('RunOnce')) { "$($location.Hive) - RunOnce" } else { "$($location.Hive) - Run" }
                Name=$property.Name; Command=[string]$property.Value; Status=$status; Locked=($locked -or $location.Path.EndsWith('RunOnce'))
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
            Source='Scheduled task'
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
            $processors = @(Get-CimInstance Win32_Processor)
            $cpu = $processors | Select-Object -First 1
            $diagnostics = [Collections.Generic.List[string]]::new()
            $cpuPercent = $null
            try {
                $loads = @($processors | Where-Object { $null -ne $_.LoadPercentage } | Select-Object -ExpandProperty LoadPercentage)
                if ($loads.Count -gt 0) { $cpuPercent = [Math]::Round(($loads | Measure-Object -Average).Average, 0) }
                else { $diagnostics.Add('CPU utilization was not reported by Win32_Processor.') }
            } catch { $diagnostics.Add("CPU utilization: $($_.Exception.Message)") }
            $ramTotal = [int64]$os.TotalVisibleMemorySize * 1KB
            $ramAvailable = [int64]$os.FreePhysicalMemory * 1KB
            $ramUsed = [Math]::Max([int64]0, $ramTotal - $ramAvailable)
            $power = Get-HolmesPowerPlan
            if ($power.Error) { $diagnostics.Add("Power plan: $($power.Error)") }
            $activeAdapters = @()
            try {
                $activeAdapters = @(Get-NetIPConfiguration -ErrorAction Stop | Where-Object {
                    $_.NetAdapter.Status -eq 'Up' -and ($null -ne $_.IPv4DefaultGateway -or $_.NetAdapter.HardwareInterface)
                } | Select-Object -ExpandProperty InterfaceAlias -Unique)
            } catch { $diagnostics.Add("Network adapters: $($_.Exception.Message)") }
            $disks = @()
            try {
                $disks = @(Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' -ErrorAction Stop | Where-Object { $_.Size -gt 0 } | ForEach-Object {
                    $total = [int64]$_.Size; $free = [int64]$_.FreeSpace; $used = [Math]::Max([int64]0, $total - $free)
                    [pscustomobject]@{ Name=$_.DeviceID; UsedBytes=$used; FreeBytes=$free; TotalBytes=$total; Percent=($used * 100.0 / $total) }
                })
            } catch { $diagnostics.Add("Storage: $($_.Exception.Message)") }
            $uptimeSeconds = $null
            try { $uptimeSeconds = [int64]((Get-Date) - $os.LastBootUpTime).TotalSeconds } catch { $diagnostics.Add("Uptime: $($_.Exception.Message)") }
            $memoryPercent = if ($ramTotal -gt 0) { $ramUsed * 100.0 / $ramTotal } else { $null }
            $snapshot = [pscustomobject]@{
                ComputerName=$env:COMPUTERNAME; WindowsEdition=[string]$os.Caption; WindowsVersion=[string]$os.Version
                WindowsBuild=[string]$os.BuildNumber; Architecture=[string]$os.OSArchitecture
                CpuName=if ($cpu) { ($cpu.Name -replace '\s+',' ').Trim() } else { 'Unknown' }
                CpuCores=if ($processors.Count) { [int](($processors | Measure-Object NumberOfCores -Sum).Sum) } else { $null }
                CpuLogicalProcessors=if ($processors.Count) { [int](($processors | Measure-Object NumberOfLogicalProcessors -Sum).Sum) } else { $null }
                CpuPercent=$cpuPercent; MemoryUsedBytes=$ramUsed; MemoryAvailableBytes=$ramAvailable; MemoryTotalBytes=$ramTotal; MemoryPercent=$memoryPercent
                UptimeSeconds=$uptimeSeconds; PowerPlanName=$power.Name; PowerPlanKind=$power.Kind; PowerPlanGuid=$power.Guid
                ActiveAdapters=@($activeAdapters); Disks=@($disks); Diagnostics=@($diagnostics)
            }
            ConvertTo-Json -InputObject $snapshot -Compress -Depth 6
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
            $result = $apps | Sort-Object DisplayName, DisplayVersion | Group-Object { "$($_.DisplayName)|$($_.DisplayVersion)|$($_.Publisher)|$($_.UninstallString)" } | ForEach-Object {
                $app = $_.Group[0]
                $uninstall = [string]$app.UninstallString
                [pscustomobject]@{
                    Name=[string]$app.DisplayName; Publisher=[string]$app.Publisher; Version=[string]$app.DisplayVersion
                    SizeBytes=if ($app.EstimatedSize -and [int64]$app.EstimatedSize -gt 0) { [int64]$app.EstimatedSize * 1KB } else { $null }
                    InstallerType=if ($uninstall -match '(?i)MsiExec') { 'MSI' } else { 'Application' }
                    UninstallData=[Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($uninstall))
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
