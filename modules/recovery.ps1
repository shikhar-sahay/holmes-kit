param([ValidateSet('Execute','Validate')][string]$Action='Validate',[string]$Operation='')
$Operation=$Operation.ToLowerInvariant()
$ErrorActionPreference='Stop'
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)
. "$PSScriptRoot\recovery_core.ps1"
$root=Split-Path -Parent $PSScriptRoot
$directory=Join-Path $root 'HolmesKit_Backups\recovery'
$operations=@('core-full','cleanup-temp','power-high','cleanup-background','ui-responsive','visual-performance','startup-prune','network-maintenance','services-cleanup','hibernation-disable','gaming-fps','gaming-latency','gaming-full','apply-all','restore-registry','restore-power','restore-services','restore-hibernation','restore-network','restart-explorer')
$lock=$null
try {
    if ($Action -eq 'Execute' -and $Operation -notin $operations) { throw 'Unknown operation.' }
    $scope=@(Get-HolmesRegistryScope)
    $machine=[string](Get-ItemPropertyValue -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Cryptography' -Name MachineGuid)
    $user=[Security.Principal.WindowsIdentity]::GetCurrent().User.Value
    if ($Action -eq 'Validate') {
        $journal=Read-HolmesJournalFile (Join-Path $directory 'baseline.json')
        Assert-HolmesJournal $journal $scope $machine $user
        if ($env:HK_RECOVERY_CHILD -eq '1' -and ($journal.Status -ne 'Running' -or $journal.Operation -ne $Operation)) { throw 'Engine entry does not match the active journal operation.' }
        if ($journal.Status -ne 'Ready' -and $env:HK_RECOVERY_CHILD -ne '1') { throw 'Recovery journal has an interrupted operation.' }
        exit 0
    }
    $null=New-Item -ItemType Directory -Path $directory -Force
    $lock=[IO.File]::Open((Join-Path $directory 'operation.lock'),[IO.FileMode]::OpenOrCreate,[IO.FileAccess]::ReadWrite,[IO.FileShare]::None)
    if ($Operation -in @('restore-hibernation','restore-network','restart-explorer')) {
        Write-Output 'RESET/SESSION action: no exact-state rollback is promised.'
        try {
            $env:HK_RECOVERY_CHILD='1'
            & $env:ComSpec /d /s /c ('""'+(Join-Path $root 'HolmesKit.bat')+'" --engine '+$Operation+'"')
            $code=$LASTEXITCODE
        } finally { Remove-Item Env:\HK_RECOVERY_CHILD -ErrorAction SilentlyContinue }
        exit $code
    }
    $path=Join-Path $directory 'baseline.json'
    $isRecovery=$Operation.StartsWith('restore-')
    if ([IO.File]::Exists($path)) {
        $journal=Read-HolmesJournalFile $path
        Assert-HolmesJournal $journal $scope $machine $user
        if ($journal.Status -ne 'Ready') { throw 'An earlier operation was interrupted. Preserve the journal and obtain manual review.' }
    } elseif ($isRecovery) { throw 'No validated recovery journal. Legacy backups are preserved but cannot be imported automatically; review them manually.' }
    else {
        $journal=New-HolmesJournal $scope $machine $user
        Assert-HolmesJournal $journal $scope $machine $user
        Save-HolmesJournal $directory $journal
    }
    if ($Operation -in @('restore-registry','restore-power','restore-services')) {
        $category=@{ 'restore-registry'='Registry'; 'restore-power'='Power'; 'restore-services'='Services' }[$Operation]
        $results=@(Restore-HolmesJournal $journal $scope $category)
        $failed=[int]$results[-1]
        $results | Select-Object -SkipLast 1 | Write-Output
        foreach ($entry in $journal.Entries) {
            $item=$scope | Where-Object Id -eq $entry.Id | Select-Object -First 1
            if ($item.Category -eq $category -and (Test-HolmesEqual (Read-HolmesState $item) $entry.Before)) { $entry.After=$entry.Before }
        }
        Save-HolmesJournal $directory $journal
        if ($failed) { exit 4 }; exit 0
    }
    # Do not silently overwrite a changed external configuration or refresh its baseline.
    $managed=@(Get-HolmesOperationScope $scope $Operation | Select-Object -ExpandProperty Id)
    foreach ($entry in @($journal.Entries | Where-Object { $_.Id -in $managed })) {
        $item=$scope | Where-Object Id -eq $entry.Id | Select-Object -First 1
        if (-not (Test-HolmesEqual (Read-HolmesState $item) $entry.After)) { throw "Configuration conflict: $($entry.Id). No engine operation was started." }
    }
    $journal.Status='Running'; $journal.Operation=$Operation
    Save-HolmesJournal $directory $journal
    $log=Join-Path $root 'HolmesKit_Backups\holmeskit.log'
    Add-Content -LiteralPath $log -Value "[$([DateTime]::UtcNow.ToString('o'))] BEGIN operation=$Operation baseline=$($journal.Id)" -Encoding UTF8
    $exitCode=1
    try {
        $env:HK_RECOVERY_CHILD='1'
        & $env:ComSpec /d /s /c ('""'+(Join-Path $root 'HolmesKit.bat')+'" --engine '+$Operation+'"')
        $exitCode=$LASTEXITCODE
    } finally {
        Remove-Item Env:\HK_RECOVERY_CHILD -ErrorAction SilentlyContinue
        foreach ($entry in @($journal.Entries | Where-Object { $_.Id -in $managed })) {
            $item=$scope | Where-Object Id -eq $entry.Id | Select-Object -First 1
            $entry.After=Read-HolmesState $item
        }
        $journal.Status='Ready'
        Save-HolmesJournal $directory $journal
    }
    Write-Output "RESULT: operation=$Operation exit=$exitCode; prior completed changes may remain."
    Add-Content -LiteralPath $log -Value "[$([DateTime]::UtcNow.ToString('o'))] END operation=$Operation exit=$exitCode" -Encoding UTF8
    exit $exitCode
} catch {
    [Console]::Error.WriteLine("Recovery prerequisite/operation failed: $($_.Exception.Message)")
    exit 1
} finally { if ($lock) { $lock.Dispose() } }
