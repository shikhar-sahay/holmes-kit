param(
    [Parameter(Mandatory=$true)][string]$CandidateZip,
    [Parameter(Mandatory=$true)][string]$EnvironmentLabel,
    [Parameter(Mandatory=$true)][string]$CheckpointId,
    [Parameter(Mandatory=$true)][string]$OutputPath,
    [ValidateSet('Before','After','Reverted')][string]$Phase='Before',
    [switch]$IncludeManagedState
)
$ErrorActionPreference='Stop'
if(Test-Path -LiteralPath $OutputPath){throw 'Evidence output already exists; choose a new path.'}
$candidate=Get-Item -LiteralPath $CandidateZip -ErrorAction Stop
if($candidate.Extension -ine '.zip'){throw 'Candidate must be a ZIP archive.'}
$root=Split-Path -Parent $PSScriptRoot
$stream=[IO.File]::OpenRead($candidate.FullName);$sha=[Security.Cryptography.SHA256]::Create()
try{$candidateHash=[BitConverter]::ToString($sha.ComputeHash($stream)).Replace('-','')}finally{$stream.Dispose();$sha.Dispose()}
$os=Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
$evidence=[ordered]@{
    EvidenceVersion=1; CollectedUtc=[DateTime]::UtcNow.ToString('o'); Phase=$Phase
    EnvironmentLabel=$EnvironmentLabel; CheckpointId=$CheckpointId
    WindowsEdition=$os.Caption; WindowsVersion=$os.Version; WindowsBuild=$os.BuildNumber
    PowerShell=$PSVersionTable.PSVersion.ToString(); Runtime=[Environment]::Version.ToString()
    CandidateFile=$candidate.Name; CandidateSha256=$candidateHash
    SourceCommit=(& git -C $root rev-parse HEAD 2>$null)
    Authorization='Collector grants no authorization for native modifications; operator must confirm disposable VM/checkpoint separately.'
    Scenarios=@('consent','baseline-retention','journal-failure','scope-types','service-recovery','power-recovery','external-conflict','partial-recovery','interruption','locking','locale-policy','alternate-user','desktop-dpi-accessibility','reversion' | ForEach-Object {
        [ordered]@{ Scenario=$_; Status='NOT EXECUTED'; Expected='See WINDOWS_VM_VERIFICATION.md'; Actual=''; Diagnostics=''; Reversion='' }
    })
}
if($IncludeManagedState){
    . (Join-Path $root 'modules\recovery_core.ps1')
    $evidence.ManagedState=@(Get-HolmesRegistryScope | ForEach-Object { [ordered]@{ Id=$_.Id; State=(Read-HolmesState $_) } })
}
$json=$evidence | ConvertTo-Json -Depth 16
$path=[IO.Path]::GetFullPath($OutputPath)
$stream=[IO.File]::Open($path,[IO.FileMode]::CreateNew,[IO.FileAccess]::Write,[IO.FileShare]::None)
try{$bytes=[Text.Encoding]::UTF8.GetBytes($json);$stream.Write($bytes,0,$bytes.Length)}finally{$stream.Dispose()}
Write-Output "Read-only evidence written to $path. No scenario is marked passed. Keep this machine-specific file private."
