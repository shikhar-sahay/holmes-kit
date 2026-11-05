param([Parameter(Mandatory=$true)][string]$CandidateZip)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip=[IO.Compression.ZipFile]::OpenRead([IO.Path]::GetFullPath($CandidateZip))
try {
    $files=@{}
    foreach($entry in $zip.Entries){
        $name=$entry.FullName.Replace('\','/')
        if($name.StartsWith('/') -or $name.Contains(':') -or '..' -in ($name -split '/') -or $files.ContainsKey($name)){throw "Unsafe or duplicate archive path: $name"}
        if($name.EndsWith('/')){continue}
        if($name -match '(^|/)(HolmesKit_Backups|bin|obj|TestResults)(/|$)|\.(pdb|log|user|staging)$|(^|/)(baseline(?:\.previous)?\.json|service_states\.json|absent_keys\.txt)$'){throw "Local/build state in package: $name"}
        $files[$name]=$entry
    }
    foreach($name in @('HolmesKit.exe','HolmesKit.bat','modules/gui_bridge.ps1','modules/recovery.ps1','modules/recovery_core.ps1','modules/startup_mgr.ps1','modules/apps_mgr.ps1','modules/sysinfo.ps1','modules/logo.ps1','VERSION.txt','SHA256SUMS.txt')){
        if(-not $files.ContainsKey($name)){throw "Missing runtime/metadata: $name"}
    }
    $reader=[IO.StreamReader]::new($files['SHA256SUMS.txt'].Open())
    try{$lines=$reader.ReadToEnd() -split '\r?\n'}finally{$reader.Dispose()}
    $listed=@{}
    foreach($line in $lines){
        if(-not $line){continue}
        if($line -notmatch '^([A-Fa-f0-9]{64})  (.+)$'){throw 'Malformed checksum manifest.'}
        $expected=$Matches[1];$name=$Matches[2].Replace('\','/')
        if($name -eq 'SHA256SUMS.txt' -or $listed.ContainsKey($name) -or -not $files.ContainsKey($name)){throw "Invalid checksum entry: $name"}
        $stream=$files[$name].Open();$sha=[Security.Cryptography.SHA256]::Create()
        try{$hash=[BitConverter]::ToString($sha.ComputeHash($stream)).Replace('-','')}finally{$stream.Dispose();$sha.Dispose()}
        if($hash -ine $expected){throw "Checksum mismatch: $name"};$listed[$name]=$true
    }
    if($listed.Count -ne $files.Count-1){throw 'Unlisted payload file in archive.'}
    if(Test-Path -LiteralPath ($CandidateZip+'.sha256')){
        $record=[IO.File]::ReadAllText([IO.Path]::GetFullPath($CandidateZip+'.sha256'))
        $stream=[IO.File]::OpenRead([IO.Path]::GetFullPath($CandidateZip));$sha=[Security.Cryptography.SHA256]::Create()
        try{$actual=[BitConverter]::ToString($sha.ComputeHash($stream)).Replace('-','')}finally{$stream.Dispose();$sha.Dispose()}
        if(-not $record.StartsWith($actual,[StringComparison]::OrdinalIgnoreCase)){throw 'Archive checksum mismatch.'}
    }
    [pscustomobject]@{Status='PASS';Files=$files.Count;VerifiedChecksums=$listed.Count;Signature='NOT CHECKED';NativeValidation='NOT EXECUTED'}
}finally{$zip.Dispose()}
