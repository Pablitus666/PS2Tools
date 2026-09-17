function Format-FileSize {
param([long]$Bytes)
if($Bytes -ge 1GB){'{0:N2} GB' -f ($Bytes/1GB)}
elseif($Bytes -ge 1MB){'{0:N2} MB' -f ($Bytes/1MB)}
elseif($Bytes -ge 1KB){'{0:N2} KB' -f ($Bytes/1KB)}
else{'{0:N0} B' -f $Bytes}
}
function Write-Section {param([string]$Title) Write-Host '';Write-Host ('-'*52);Write-Host $Title;Write-Host ('-'*52)}
function Write-DiscError {param([string]$Message,[string]$Detail) Write-Host "[ERROR] $Message";if($Detail){Write-Host "        $Detail"}}
function Get-RelativeDiscPath {
param([string]$FullName,[string]$Root)
if($FullName.StartsWith($Root,[StringComparison]::OrdinalIgnoreCase)){$FullName.Substring($Root.Length).TrimStart('\')}else{$FullName}
}

function Test-DiscMediaAvailable {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$DrivePath)

    try {
        return (Test-Path -LiteralPath $DrivePath -PathType Container -ErrorAction Stop)
    } catch {
        return $false
    }
}

function Throw-DiscRemoved {
    throw [System.IO.IOException]::new('PS2Tools:DISC_REMOVED')
}


function Get-DiscVolumeInfo {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$DrivePath)

    $Root = $DrivePath.Trim()
    if ($Root -notmatch '[\\/]$') { $Root += '\' }
    $DeviceID = $Root.TrimEnd('\','/')

    try {
        $Disk = Get-CimInstance -ClassName Win32_LogicalDisk -Filter ("DeviceID = '{0}'" -f $DeviceID) -ErrorAction Stop | Select-Object -First 1
        if ($Disk) {
            return [pscustomobject]@{
                VolumeName = $Disk.VolumeName
                FileSystem = $Disk.FileSystem
            }
        }
    } catch {
        # La información de volumen es complementaria; no debe impedir el análisis.
    }

    [pscustomobject]@{
        VolumeName = $null
        FileSystem = $null
    }
}

function Get-OpticalDrive {
    [CmdletBinding()]
    param([switch]$IncludeEmpty)
    $drives = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType = 5" -ErrorAction SilentlyContinue
    foreach ($d in @($drives)) {
        $root = $d.DeviceID + '\'
        $hasMedia = $true
        try { $hasMedia = Test-Path -LiteralPath $root -PathType Container -ErrorAction Stop } catch { $hasMedia = $false }
        if ($IncludeEmpty -or $hasMedia) {
            [pscustomobject]@{ Drive=$d.DeviceID; DrivePath=$root; VolumeName=$d.VolumeName; HasMedia=$hasMedia; DriveType='Optical' }
        }
    }
}

function Resolve-OpticalDrive {
    [CmdletBinding()]
    param([switch]$IncludeEmpty)
    $found = @(Get-OpticalDrive -IncludeEmpty:$IncludeEmpty)
    if ($found.Count -eq 0) { return $null }
    if ($found.Count -eq 1) { return $found[0] }
    return $found
}

function Test-OpticalPs2Disc {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][pscustomobject]$DriveInfo
    )

    if (-not $DriveInfo.HasMedia) { return $null }

    $root = $DriveInfo.DrivePath
    $systemCnfPath = Join-Path $root 'SYSTEM.CNF'
    if (-not (Test-Path -LiteralPath $systemCnfPath -PathType Leaf -ErrorAction SilentlyContinue)) {
        return $null
    }

    $boot = $null
    try {
        foreach ($line in @(Get-Content -LiteralPath $systemCnfPath -Encoding utf8 -ErrorAction Stop)) {
            if ($line -match '^\s*BOOT2\s*=\s*(.*?)\s*$') {
                $boot = $matches[1]
                break
            }
        }
    } catch {
        return $null
    }

    # BOOT2 is the PS2 system configuration entry. Require it to avoid
    # treating arbitrary optical discs (or PS1 discs using BOOT) as PS2.
    if ([string]::IsNullOrWhiteSpace($boot)) { return $null }

    [pscustomobject]@{
        Drive=$DriveInfo.Drive
        DrivePath=$root
        VolumeName=$DriveInfo.VolumeName
        HasMedia=$true
        DriveType='Optical'
        IsPlayStation2=$true
        SystemCnfPath=$systemCnfPath
        Boot=$boot
    }
}

function Get-OpticalPs2Drive {
    [CmdletBinding()]
    param()

    $optical = @(Get-OpticalDrive | Sort-Object Drive)
    foreach ($drive in $optical) {
        $match = Test-OpticalPs2Disc -DriveInfo $drive
        if ($match) { $match }
    }
}
