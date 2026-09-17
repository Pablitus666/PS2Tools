function Get-HomebrewIdentity {
param([string]$Boot)

if([string]::IsNullOrWhiteSpace($Boot)){ return $null }

$Name = Split-Path -Leaf (($Boot -replace '/','\') -replace ';[0-9]+$','')
$Key = $Name.ToUpperInvariant()

$Known = @{
    'LAUNCHELF.ELF'     = 'uLaunchELF'
    'BOOT.ELF'          = 'PS2 Homebrew Boot'
    'HDLOADER.ELF'      = 'HDLoader'
    'USBADVANCE_GW.ELF' = 'USBAdvance'
    'CODEBREAKER_9_2.ELF' = 'CodeBreaker 9.2'
    'SWAPMAGIC.ELF'     = 'Swap Magic'
}

if($Known.ContainsKey($Key)){
    return [pscustomobject]@{
        IsHomebrew=$true
        Name=$Known[$Key]
        Type='Homebrew/Utility'
        Executable=$Name
    }
}

if($Key -match '\.ELF$'){
    return [pscustomobject]@{
        IsHomebrew=$true
        Name="Homebrew/Utility ($Name)"
        Type='Homebrew/Utility'
        Executable=$Name
    }
}

return $null
}
