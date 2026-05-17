
# HolmesKit System Info Panel - Real-time dashboard

function Get-BarString($value, $max, $width) {
    $filled = [Math]::Round(($value / $max) * $width)
    $filled = [Math]::Max(0, [Math]::Min($filled, $width))
    $empty  = $width - $filled
    $color  = if ($value -gt 85) { "Red" } elseif ($value -gt 60) { "Yellow" } else { "Green" }
    Write-Host "[" -NoNewline -ForegroundColor DarkGray
    Write-Host ("$([char]0x2588)" * $filled) -NoNewline -ForegroundColor $color
    Write-Host (" " * $empty) -NoNewline -ForegroundColor DarkGray
    Write-Host "] " -NoNewline -ForegroundColor DarkGray
}

function Get-TopProcesses($type, $count) {
    if ($type -eq "CPU") {
        return Get-Process | Where-Object { $_.CPU -gt 0 } |
            Sort-Object CPU -Descending |
            Select-Object -First $count Name,
                @{N="Value"; E={ [Math]::Round($_.CPU, 1).ToString() + "s CPU" }}
    } else {
        return Get-Process |
            Sort-Object WorkingSet64 -Descending |
            Select-Object -First $count Name,
                @{N="Value"; E={ [Math]::Round($_.WorkingSet64 / 1MB, 0).ToString() + " MB" }}
    }
}

function Get-DiskInfo {
    $disks = @()
    foreach ($d in (Get-PSDrive -PSProvider FileSystem -ErrorAction SilentlyContinue)) {
        if ($d.Used -ne $null -and ($d.Used + $d.Free) -gt 0) {
            $total = $d.Used + $d.Free
            $pct   = [Math]::Round(($d.Used / $total) * 100)
            $disks += [PSCustomObject]@{
                Name  = $d.Name + ":"
                Used  = [Math]::Round($d.Used / 1GB, 1)
                Total = [Math]::Round($total / 1GB, 1)
                Pct   = $pct
            }
        }
    }
    return $disks
}

function Get-NetStats {
    try {
        $stats = Get-NetAdapterStatistics -ErrorAction Stop |
            Where-Object { $_.ReceivedBytes -gt 0 -or $_.SentBytes -gt 0 } |
            Select-Object -First 1
        if ($stats) {
            return [PSCustomObject]@{
                Recv = [Math]::Round($stats.ReceivedBytes / 1MB, 1)
                Sent = [Math]::Round($stats.SentBytes / 1MB, 1)
            }
        }
    } catch {}
    return $null
}

function Get-PowerPlanName {
    try {
        $line = powercfg /getactivescheme 2>$null
        if ($line -match "Power Scheme GUID.*\((.+)\)") { return $Matches[1].Trim() }
    } catch {}
    return "Unknown"
}

function Get-UptimeStr {
    $up = (Get-Date) - (gcim Win32_OperatingSystem).LastBootUpTime
    return "$($up.Days)d $($up.Hours)h $($up.Minutes)m"
}

function Get-StartupCount {
    $count = 0
    try {
        $hkcu = Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -EA Stop
        $count += ($hkcu.PSObject.Properties | Where-Object { $_.Name -notmatch "^PS" }).Count
    } catch {}
    try {
        $hklm = Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" -EA Stop
        $count += ($hklm.PSObject.Properties | Where-Object { $_.Name -notmatch "^PS" }).Count
    } catch {}
    return $count
}

function Show-Dashboard {
    $os  = gcim Win32_OperatingSystem
    $cpu = gcim Win32_Processor

    try {
        $cpuLoad = [Math]::Round((Get-Counter '\Processor(_Total)\% Processor Time' -SampleInterval 1 -MaxSamples 1).CounterSamples.CookedValue)
    } catch { $cpuLoad = 0 }

    $ramTotal = [Math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
    $ramFree  = [Math]::Round($os.FreePhysicalMemory / 1MB, 1)
    $ramUsed  = [Math]::Round($ramTotal - $ramFree, 1)
    $ramPct   = [Math]::Round(($ramUsed / $ramTotal) * 100)

    $disks     = Get-DiskInfo
    $net       = Get-NetStats
    $powerPlan = Get-PowerPlanName
    $uptime    = Get-UptimeStr
    $startups  = Get-StartupCount
    $topCPU    = Get-TopProcesses "CPU" 5
    $topRAM    = Get-TopProcesses "RAM" 5

    Clear-Host
    Write-Host ""
    Write-Host "                 ====================== SYSTEM INFO ======================" -ForegroundColor DarkGray
    Write-Host ("                 " + (Get-Date -Format "dddd, MMMM dd yyyy  |  HH:mm:ss")) -ForegroundColor DarkGray
    Write-Host "                 ========================================================" -ForegroundColor DarkGray
    Write-Host ""

    $machineName = $env:COMPUTERNAME
    $osName      = $os.Caption -replace "Microsoft Windows ", "Win "
    $cpuName     = ($cpu.Name -replace "\s+", " ").Trim()
    if ($cpuName.Length -gt 48) { $cpuName = $cpuName.Substring(0,48) + "..." }

    Write-Host "                 " -NoNewline
    Write-Host $machineName -NoNewline -ForegroundColor Cyan
    Write-Host "  |  " -NoNewline -ForegroundColor DarkGray
    Write-Host $osName -NoNewline -ForegroundColor White
    Write-Host "  |  Uptime: " -NoNewline -ForegroundColor DarkGray
    Write-Host $uptime -ForegroundColor White
    Write-Host "                 $cpuName" -ForegroundColor DarkGray
    Write-Host ""

    Write-Host "                 CPU  " -NoNewline -ForegroundColor White
    Get-BarString $cpuLoad 100 30
    Write-Host "$cpuLoad%" -ForegroundColor White
    Write-Host ""

    Write-Host "                 RAM  " -NoNewline -ForegroundColor White
    Get-BarString $ramPct 100 30
    Write-Host "$ramUsed / $ramTotal GB  ($ramPct%)" -ForegroundColor White
    Write-Host ""

    foreach ($d in $disks) {
        $label = ("  $($d.Name)  ").PadLeft(8)
        Write-Host "                $label" -NoNewline -ForegroundColor White
        Get-BarString $d.Pct 100 30
        Write-Host "$($d.Used) / $($d.Total) GB  ($($d.Pct)%)" -ForegroundColor White
    }
    Write-Host ""

    Write-Host "                 Power Plan : " -NoNewline -ForegroundColor DarkGray
    $ppColor = if ($powerPlan -match "High") { "Green" } elseif ($powerPlan -match "Balanced") { "Yellow" } else { "DarkGray" }
    Write-Host $powerPlan -ForegroundColor $ppColor

    if ($net) {
        Write-Host "                 Network    : " -NoNewline -ForegroundColor DarkGray
        Write-Host "Recv $($net.Recv) MB  |  Sent $($net.Sent) MB  (session totals)" -ForegroundColor White
    }

    Write-Host "                 Startups   : " -NoNewline -ForegroundColor DarkGray
    $scColor = if ($startups -gt 10) { "Red" } elseif ($startups -gt 5) { "Yellow" } else { "Green" }
    Write-Host "$startups registered startup entries" -ForegroundColor $scColor

    Write-Host ""
    Write-Host "                 --------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "                 TOP BY CPU                          TOP BY RAM" -ForegroundColor DarkGray
    Write-Host "                 --------------------------------------------------------" -ForegroundColor DarkGray

    for ($i = 0; $i -lt 5; $i++) {
        $cProc   = if ($i -lt $topCPU.Count) { $topCPU[$i] } else { $null }
        $rProc   = if ($i -lt $topRAM.Count) { $topRAM[$i] } else { $null }
        $cName   = if ($cProc) { $cProc.Name.Substring(0,[Math]::Min($cProc.Name.Length,18)).PadRight(18) } else { "".PadRight(18) }
        $cVal    = if ($cProc) { $cProc.Value.PadLeft(10) } else { "".PadLeft(10) }
        $rName   = if ($rProc) { $rProc.Name.Substring(0,[Math]::Min($rProc.Name.Length,18)).PadRight(18) } else { "".PadRight(18) }
        $rVal    = if ($rProc) { $rProc.Value.PadLeft(10) } else { "".PadLeft(10) }

        Write-Host "                 " -NoNewline
        Write-Host $cName -NoNewline -ForegroundColor White
        Write-Host $cVal  -NoNewline -ForegroundColor Yellow
        Write-Host "    "  -NoNewline
        Write-Host $rName -NoNewline -ForegroundColor White
        Write-Host $rVal  -ForegroundColor Cyan
    }

    Write-Host ""
    Write-Host "                 ========================================================" -ForegroundColor DarkGray
    Write-Host "                 R = Refresh    Q = Back To Menu" -ForegroundColor DarkGray
    Write-Host ""
}

$running = $true
while ($running) {
    Show-Dashboard
    $waited = 0
    $key    = $null
    while ($waited -lt 5000) {
        if ([Console]::KeyAvailable) { $key = [Console]::ReadKey($true); break }
        Start-Sleep -Milliseconds 100
        $waited += 100
    }
    if ($key) {
        if ($key.KeyChar.ToString().ToUpper() -eq "Q") { $running = $false }
    }
}
Write-Host ""
