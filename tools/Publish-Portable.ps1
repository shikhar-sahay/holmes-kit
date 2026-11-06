param(
    [Parameter(Mandatory=$true)][ValidatePattern('^\d+\.\d+\.\d+(?:-[a-zA-Z0-9.]+)?$')][string]$Version,
    [string]$DotNet='dotnet'
)
$ErrorActionPreference='Stop'
$root=Split-Path -Parent $PSScriptRoot
$packages=Join-Path $root 'artifacts\packages'
$stage=Join-Path $root ('artifacts\candidate-'+[guid]::NewGuid().ToString('N'))
$null=New-Item -ItemType Directory -Path $stage -Force
$null=New-Item -ItemType Directory -Path $packages -Force
& $DotNet publish (Join-Path $root 'src\HolmesKit.Desktop\HolmesKit.Desktop.csproj') -c Release -r win-x64 --self-contained true -o $stage "-p:Version=$Version"
if ($LASTEXITCODE -ne 0) { throw 'Publish failed.' }
Copy-Item -LiteralPath (Join-Path $root 'README.md') -Destination $stage
Copy-Item -LiteralPath (Join-Path $root 'docs\WINDOWS_VM_VERIFICATION.md') -Destination $stage
$documents=@('docs/feature-parity.md','docs/WINDOWS_VM_VERIFICATION.md','docs/HANDBOOK.md','docs/RELEASE_READINESS.md','docs/screenshots/desktop-core.png','docs/screenshots/desktop-core-task05.png')
foreach($document in $documents){
    $destination=Join-Path $stage $document
    $null=New-Item -ItemType Directory -Path (Split-Path -Parent $destination) -Force
    Copy-Item -LiteralPath (Join-Path $root $document) -Destination $destination
}
[IO.File]::WriteAllText((Join-Path $stage 'VERSION.txt'),"$Version`r`nUnsigned validation candidate; no code-signing claim.`r`n",[Text.UTF8Encoding]::new($false))
$required=@('HolmesKit.exe','HolmesKit.bat','modules\gui_bridge.ps1','modules\recovery.ps1','modules\recovery_core.ps1','modules\startup_mgr.ps1','modules\apps_mgr.ps1','modules\sysinfo.ps1','modules\logo.ps1')
foreach($file in $required){if(-not (Test-Path -LiteralPath (Join-Path $stage $file) -PathType Leaf)){throw "Missing runtime file: $file"}}
$files=@(Get-ChildItem -LiteralPath $stage -Recurse -File | Where-Object Extension -ne '.pdb')
if(@($files | Where-Object { $_.FullName -match 'HolmesKit_Backups|\.log$|\.user$' }).Count){throw 'Local state detected in candidate.'}
$manifest=@($files | Sort-Object FullName | ForEach-Object { '{0}  {1}' -f (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash,$_.FullName.Substring($stage.Length+1) })
[IO.File]::WriteAllLines((Join-Path $stage 'SHA256SUMS.txt'),$manifest,[Text.UTF8Encoding]::new($false))
$zip=Join-Path $packages "HolmesKit-$Version-win-x64.zip"
# Enumerate explicitly: do not archive ignored backups/logs or unrelated local artifacts.
$pdb=Join-Path $stage 'HolmesKit.pdb'
if(Test-Path -LiteralPath $pdb){Remove-Item -LiteralPath $pdb}
Compress-Archive -Path (Join-Path $stage '*') -DestinationPath $zip
$hash=(Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash
[IO.File]::WriteAllText(($zip+'.sha256'),"$hash  $([IO.Path]::GetFileName($zip))`r`n",[Text.UTF8Encoding]::new($false))
& (Join-Path $PSScriptRoot 'Test-PortableCandidate.ps1') -CandidateZip $zip
Write-Output "Prepared unsigned candidate: $zip"
