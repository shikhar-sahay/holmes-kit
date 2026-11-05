# Recovery policy and storage. Native access is isolated in Read/Write-HolmesState.
function Get-HolmesRegistryScope {
    $scope = @()
    $groups = @{
        'HKCU\Control Panel\Desktop' = @('MenuShowDelay','HungAppTimeout','WaitToKillAppTimeout','ForegroundLockTimeout','AutoEndTasks')
        'HKCU\Control Panel\Desktop\WindowMetrics' = @('MinAnimate')
        'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' = @('VisualFXSetting')
        'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' = @('TaskbarAnimations','ListviewAlphaSelect','ListviewShadow')
        'HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl' = @('Win32PrioritySeparation')
        'HKCU\System\GameConfigStore' = @('GameDVR_Enabled')
        'HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR' = @('AppCaptureEnabled')
        'HKLM\Software\Policies\Microsoft\Windows\GameDVR' = @('AllowGameDVR')
        'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games' = @('GPU Priority','Priority','Scheduling Category','SFIO Priority')
        'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile' = @('SystemResponsiveness')
        'HKCU\Software\Microsoft\Windows\CurrentVersion\Run' = @('OneDrive','Discord','Spotify','Skype','Zoom','EpicGamesLauncher','com.squirrel.Teams.Teams')
        'HKLM\Software\Microsoft\Windows\CurrentVersion\Run' = @('OneDrive','TeamsMachineInstaller')
    }
    foreach ($path in ($groups.Keys | Sort-Object)) {
        foreach ($name in $groups[$path]) { $scope += [pscustomobject]@{ Id="Registry|$path|$name"; Path=$path; Name=$name; Category='Registry' } }
    }
    $interfaces = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces'
    foreach ($key in @(Get-ChildItem -LiteralPath $interfaces -ErrorAction Stop)) {
        foreach ($name in @('TcpAckFrequency','TCPNoDelay')) {
            $path = "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$($key.PSChildName)"
            $scope += [pscustomobject]@{ Id="Registry|$path|$name"; Path=$path; Name=$name; Category='Registry' }
        }
    }
    foreach ($name in @('SysMain','WSearch','DiagTrack','BITS','DoSvc')) { $scope += [pscustomobject]@{ Id="Service|$name"; Name=$name; Category='Services' } }
    $scope += [pscustomobject]@{ Id='Power|Active'; Category='Power'; Name='Active' }
    return $scope
}

function Get-HolmesOperationScope($Scope,[string]$Operation) {
    $ids = switch ($Operation) {
        'core-full' { @('Power') }
        'power-high' { @('Power') }
        'ui-responsive' { @('Desktop|','PriorityControl|') }
        'visual-performance' { @('VisualEffects','WindowMetrics','Explorer\Advanced') }
        'startup-prune' { @('CurrentVersion\Run') }
        'services-cleanup' { @('Service|SysMain','Service|WSearch','Service|DiagTrack') }
        'gaming-fps' { @('Power','GameDVR','GameConfigStore','SystemProfile','VisualEffects','WindowMetrics','Explorer\Advanced') }
        'gaming-latency' { @('Interfaces','Service|BITS','Service|DoSvc') }
        'gaming-full' { @('Power','GameDVR','GameConfigStore','SystemProfile','VisualEffects','WindowMetrics','Explorer\Advanced','Interfaces','Service|BITS','Service|DoSvc') }
        'apply-all' { @('') }
        default { @() }
    }
    return @($Scope | Where-Object { $item=$_; @($ids | Where-Object { $item.Id.Contains($_) }).Count -gt 0 })
}

function Read-HolmesState($Item) {
    switch ($Item.Category) {
        'Registry' {
            $hive = if ($Item.Path.StartsWith('HKCU\')) { [Microsoft.Win32.Registry]::CurrentUser } else { [Microsoft.Win32.Registry]::LocalMachine }
            $key = $hive.OpenSubKey($Item.Path.Substring(5), $false)
            try {
                if ($null -eq $key -or $key.GetValueNames() -notcontains $Item.Name) { return [pscustomobject]@{ Exists=$false; Kind='None'; Data=$null } }
                return [pscustomobject]@{ Exists=$true; Kind=$key.GetValueKind($Item.Name).ToString(); Data=$key.GetValue($Item.Name,$null,[Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames) }
            } finally { if ($key) { $key.Dispose() } }
        }
        'Services' {
            $s = Get-CimInstance Win32_Service -Filter "Name='$($Item.Name)'" -ErrorAction Stop
            if (-not $s) { return [pscustomobject]@{ Exists=$false } }
            $delay = Get-ItemPropertyValue -LiteralPath "HKLM:\SYSTEM\CurrentControlSet\Services\$($Item.Name)" -Name DelayedAutoStart -ErrorAction SilentlyContinue
            return [pscustomobject]@{ Exists=$true; StartMode=$s.StartMode; Running=($s.State -eq 'Running'); Delayed=[bool]$delay }
        }
        'Power' {
            $guid = Get-ItemPropertyValue -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes' -Name ActivePowerScheme -ErrorAction Stop
            return [pscustomobject]@{ Guid=([guid]$guid).ToString() }
        }
        default { throw 'Unsupported recovery category.' }
    }
}

function Convert-HolmesRegistryData($State) {
    switch ($State.Kind) {
        'Binary' { return ,([byte[]]$State.Data) }
        'MultiString' { return ,([string[]]$State.Data) }
        'DWord' { return [int]$State.Data }
        'QWord' { return [long]$State.Data }
        default { return [string]$State.Data }
    }
}

function Write-HolmesState($Item, $State) {
    switch ($Item.Category) {
        'Registry' {
            $hive = if ($Item.Path.StartsWith('HKCU\')) { [Microsoft.Win32.Registry]::CurrentUser } else { [Microsoft.Win32.Registry]::LocalMachine }
            # Never delete a key/subtree. Only the allowlisted value can be removed.
            $key = if ($State.Exists) { $hive.CreateSubKey($Item.Path.Substring(5)) } else { $hive.OpenSubKey($Item.Path.Substring(5),$true) }
            try {
                if ($State.Exists) {
                    $kind = [Enum]::Parse([Microsoft.Win32.RegistryValueKind],$State.Kind)
                    $data = Convert-HolmesRegistryData $State
                    $key.SetValue($Item.Name,$data,$kind)
                } elseif ($key) { $key.DeleteValue($Item.Name,$false) }
            } finally { if ($key) { $key.Dispose() } }
        }
        'Services' {
            if (-not $State.Exists) { throw 'Service was unavailable at baseline; cannot recreate it.' }
            $mode = @{ Auto='Automatic'; Manual='Manual'; Disabled='Disabled' }[$State.StartMode]
            if (-not $mode) { throw 'Invalid service mode.' }
            Set-Service -Name $Item.Name -StartupType $mode -ErrorAction Stop
            Set-ItemProperty -LiteralPath "HKLM:\SYSTEM\CurrentControlSet\Services\$($Item.Name)" -Name DelayedAutoStart -Type DWord -Value ([int][bool]$State.Delayed) -ErrorAction Stop
            if ($State.Running) { Start-Service $Item.Name -ErrorAction Stop } else { Stop-Service $Item.Name -ErrorAction Stop }
        }
        'Power' {
            & "$env:SystemRoot\System32\powercfg.exe" /setactive ([guid]$State.Guid).ToString()
            if ($LASTEXITCODE -ne 0) { throw 'The original power plan is unavailable or policy-managed.' }
        }
    }
}

function Test-HolmesEqual($A,$B) { return (ConvertTo-Json -InputObject $A -Compress -Depth 12) -ceq (ConvertTo-Json -InputObject $B -Compress -Depth 12) }

function Assert-HolmesJournal($Journal,$Scope,[string]$Machine,[string]$User) {
    if ($Journal.Version -ne 1 -or $Journal.Machine -ne $Machine -or $Journal.User -ne $User) { throw 'Recovery journal version or machine/user identity mismatch.' }
    $null=[guid]$Journal.Id
    $null=[DateTime]::Parse($Journal.CreatedUtc,[Globalization.CultureInfo]::InvariantCulture,[Globalization.DateTimeStyles]::RoundtripKind)
    if ($Journal.Status -notin @('Ready','Running')) { throw 'Invalid recovery status.' }
    if (@($Journal.Entries).Count -ne @($Scope).Count) { throw 'Recovery scope changed; manual review is required.' }
    $ids = @{}
    foreach ($entry in $Journal.Entries) {
        $item = @($Scope | Where-Object Id -eq $entry.Id)
        if ($item.Count -ne 1 -or $ids.ContainsKey($entry.Id)) { throw 'Unexpected or duplicate recovery scope.' }
        $ids[$entry.Id]=$true
        foreach ($state in @($entry.Before,$entry.After)) {
            if ($null -eq $state) { throw 'Missing recovery state.' }
            switch ($item[0].Category) {
                'Registry' {
                    if ($state.Exists -isnot [bool] -or $state.Kind -notin @('None','String','ExpandString','Binary','DWord','QWord','MultiString')) { throw 'Invalid registry state.' }
                    if ($state.Exists -and $state.Kind -eq 'None') { throw 'Missing registry type.' }
                    if ($state.Exists) {
                        switch ($state.Kind) {
                            'DWord' { $null=[int]$state.Data }
                            'QWord' { $null=[long]$state.Data }
                            'Binary' { $null=[byte[]]$state.Data }
                            'MultiString' { if ($state.Data -is [string] -or $null -eq $state.Data) { throw 'Invalid multi-string data.' } }
                            default { if ($state.Data -isnot [string]) { throw 'Invalid registry string data.' } }
                        }
                    }
                }
                'Services' {
                    if ($state.Exists -isnot [bool] -or ($state.Exists -and ($state.StartMode -notin @('Auto','Manual','Disabled') -or $state.Running -isnot [bool] -or $state.Delayed -isnot [bool]))) { throw 'Invalid service state.' }
                }
                'Power' { $null = [guid]$state.Guid }
            }
        }
    }
}

function Save-HolmesJournal([string]$Directory,$Journal) {
    # A single envelope holds payload and checksum; publish with an atomic same-volume rename.
    $json = ConvertTo-Json -InputObject $Journal -Depth 16 -Compress
    $bytes = [Text.Encoding]::UTF8.GetBytes($json)
    $sha = [Security.Cryptography.SHA256]::Create()
    try { $hash = [Convert]::ToBase64String($sha.ComputeHash($bytes)) } finally { $sha.Dispose() }
    $envelope = @{ Payload=$json; Sha256=$hash } | ConvertTo-Json -Compress
    $path = Join-Path $Directory 'baseline.json'
    $stage = Join-Path $Directory ([guid]::NewGuid().ToString('N') + '.staging')
    try {
        $file=[IO.FileStream]::new($stage,[IO.FileMode]::CreateNew,[IO.FileAccess]::Write,[IO.FileShare]::None,4096,[IO.FileOptions]::WriteThrough)
        try { $content=[Text.Encoding]::UTF8.GetBytes($envelope); $file.Write($content,0,$content.Length); $file.Flush($true) } finally { $file.Dispose() }
        $null = Read-HolmesJournalFile $stage
        if ([IO.File]::Exists($path)) { [IO.File]::Replace($stage,$path,(Join-Path $Directory 'baseline.previous.json')) }
        else { [IO.File]::Move($stage,$path) }
    } finally { if ([IO.File]::Exists($stage)) { [IO.File]::Delete($stage) } }
}

function Read-HolmesJournalFile([string]$Path) {
    if ((Get-Item -LiteralPath $Path -ErrorAction Stop).Length -gt 4MB) { throw 'Recovery file is too large.' }
    $envelope = [IO.File]::ReadAllText($Path) | ConvertFrom-Json -ErrorAction Stop
    $sha = [Security.Cryptography.SHA256]::Create()
    try { $hash=[Convert]::ToBase64String($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes([string]$envelope.Payload))) } finally { $sha.Dispose() }
    if ($hash -cne $envelope.Sha256) { throw 'Recovery integrity check failed. Checksums detect corruption, not malicious tampering.' }
    return $envelope.Payload | ConvertFrom-Json -ErrorAction Stop
}

function New-HolmesJournal($Scope,[string]$Machine,[string]$User) {
    $entries = @($Scope | ForEach-Object { $state=Read-HolmesState $_; [pscustomobject]@{ Id=$_.Id; Before=$state; After=$state } })
    return [pscustomobject]@{ Version=1; Id=[guid]::NewGuid().ToString(); CreatedUtc=[DateTime]::UtcNow.ToString('o'); Machine=$Machine; User=$User; Status='Ready'; Operation=''; Entries=$entries }
}

function Restore-HolmesJournal($Journal,$Scope,[string]$Category) {
    if ($Journal.Status -ne 'Ready') { throw 'An interrupted operation has ambiguous state. Recovery requires manual review; no automatic restore was started.' }
    $failed=0
    foreach ($entry in $Journal.Entries) {
        $item = $Scope | Where-Object Id -eq $entry.Id | Select-Object -First 1
        if ($item.Category -ne $Category -or (Test-HolmesEqual $entry.Before $entry.After)) { continue }
        try {
            $current = Read-HolmesState $item
            if (Test-HolmesEqual $current $entry.Before) { continue }
            if (-not (Test-HolmesEqual $current $entry.After)) { Write-Output "CONFLICT: $($entry.Id) skipped; current state changed outside HolmesKit."; $failed++; continue }
            Write-HolmesState $item $entry.Before
            if (-not (Test-HolmesEqual (Read-HolmesState $item) $entry.Before)) { throw 'Restored state did not verify.' }
            Write-Output "RESTORED: $($entry.Id)"
        } catch { Write-Output "FAILED: $($entry.Id): $($_.Exception.Message)"; $failed++ }
    }
    return $failed
}
