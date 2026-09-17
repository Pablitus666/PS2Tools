function Resolve-DiscContentClassification {
param([Parameter(Mandatory)][pscustomobject]$Context)

$Groups = [ordered]@{
    'SYSTEM.CNF' = @()
    'BOOT / ELF PRINCIPAL' = @()
    'ELF SECUNDARIOS' = @()
    'IOPRP' = @()
    'IRX' = @()
    'VIDEO' = @()
    'AUDIO' = @()
    'IMÁGENES / BINARIOS' = @()
    'DATOS' = @()
}

if ($Context.SystemCnf) {
    $SystemFile=$Context.SystemCnf.File
    if ($SystemFile) { $Groups['SYSTEM.CNF'] += $SystemFile }
}

$BootPaths=@($Context.BootFiles | ForEach-Object FullName)
$IoprPaths=@($Context.IOPRP | ForEach-Object FullName)
$IrxPaths=@($Context.IRX | ForEach-Object FullName)
$PrimaryElfPaths=@($Context.ELF | Where-Object IsPrimaryExecutable | ForEach-Object FullName)
$SecondaryElfPaths=@($Context.ELF | Where-Object { -not $_.IsPrimaryExecutable } | ForEach-Object FullName)

foreach ($File in @($Context.Files)) {
    $Full=$File.FullName
    if ($File.Name -ieq 'SYSTEM.CNF') { continue }
    if ($PrimaryElfPaths -contains $Full -or $BootPaths -contains $Full) { $Groups['BOOT / ELF PRINCIPAL'] += $File; continue }
    if ($SecondaryElfPaths -contains $Full) { $Groups['ELF SECUNDARIOS'] += $File; continue }
    if ($IoprPaths -contains $Full) { $Groups['IOPRP'] += $File; continue }
    if ($IrxPaths -contains $Full) { $Groups['IRX'] += $File; continue }

    switch -Regex ($File.Extension.ToUpperInvariant()) {
        '^\.SFD$|^\.PSS$|^\.STR$|^\.M2V$' { $Groups['VIDEO'] += $File; continue }
        '^\.ADX$|^\.VAG$|^\.XA$|^\.AT3$|^\.WAV$' { $Groups['AUDIO'] += $File; continue }
        '^\.IMG$|^\.BIN$|^\.ISO$|^\.CUE$' { $Groups['IMÁGENES / BINARIOS'] += $File; continue }
        default { $Groups['DATOS'] += $File; continue }
    }
}

$Result=@()
foreach ($Name in $Groups.Keys) {
    $Items=@($Groups[$Name])
    if ($Items.Count -gt 0) {
        $Extensions=@($Items | ForEach-Object { if ([string]::IsNullOrWhiteSpace($_.Extension)) {'(sin extensión)'} else {$_.Extension.ToUpperInvariant()} } | Sort-Object -Unique)
        $Bytes=[long]0
        foreach($Item in $Items){ $Bytes += [long]$Item.Length }
        $Result += [pscustomobject]@{
            Type=$Name
            Count=$Items.Count
            TotalBytes=$Bytes
            TotalSize=(Format-FileSize $Bytes)
            Extensions=$Extensions
            Paths=@($Items | ForEach-Object { Get-RelativeDiscPath $_.FullName $Context.DrivePath })
        }
    }
}
$Context.ContentClassification=@($Result)
return $Context
}

function Resolve-DiscFingerprint {
param([Parameter(Mandatory)][pscustomobject]$Context)

$Manifest=@()
foreach($File in @($Context.Files | Sort-Object FullName)){
    $Relative=Get-RelativeDiscPath $File.FullName $Context.DrivePath
    $Manifest += ('{0}|{1}' -f $Relative.ToUpperInvariant(),[long]$File.Length)
}

$SystemRaw=''
if($Context.SystemCnf -and $Context.SystemCnf.RawLines){
    $SystemRaw=(@($Context.SystemCnf.RawLines) -join "`n").Trim()
}
$SystemHash=''
if($SystemRaw){
    $SystemBytes=[Text.Encoding]::UTF8.GetBytes($SystemRaw)
    $SystemHash=([Security.Cryptography.SHA256]::Create().ComputeHash($SystemBytes) | ForEach-Object { $_.ToString('X2') }) -join ''
}

$BootSha=''
$Primary=@($Context.ELF | Where-Object IsPrimaryExecutable | Select-Object -First 1)
if($Primary.Count -and $Primary[0].SHA256){ $BootSha=$Primary[0].SHA256 }

$Canonical=@(
    'PS2TOOLS-FINGERPRINT-V1'
    ('SERIAL={0}' -f [string]$Context.Identity.Serial)
    ('BOOT={0}' -f [string]$Context.SystemCnf.Boot)
    ('VERSION={0}' -f [string]$Context.SystemCnf.Version)
    ('VMODE={0}' -f [string]$Context.SystemCnf.VMode)
    ('SYSTEMCNF_SHA256={0}' -f $SystemHash)
    ('BOOT_SHA256={0}' -f $BootSha)
    ('TOTAL_FILES={0}' -f [int]$Context.Statistics.TotalFiles)
    ('TOTAL_DIRECTORIES={0}' -f [int]$Context.Statistics.TotalDirectories)
    ('TOTAL_BYTES={0}' -f [long]$Context.Statistics.TotalBytes)
    $Manifest
)
$CanonicalText=$Canonical -join "`n"
$HashBytes=[Text.Encoding]::UTF8.GetBytes($CanonicalText)
$Hash=([Security.Cryptography.SHA256]::Create().ComputeHash($HashBytes) | ForEach-Object { $_.ToString('X2') }) -join ''

$GroupCounts=[ordered]@{}
foreach($Group in @($Context.ContentClassification)){
    $GroupCounts[$Group.Type]=[int]$Group.Count
}

$Context.Fingerprint=[pscustomobject]@{
    Algorithm='SHA-256'
    Version='V1'
    Type='Huella técnica estructural'
    Value=$Hash
    BootSHA256=$BootSha
    SystemCnfSHA256=$SystemHash
    TotalFiles=[int]$Context.Statistics.TotalFiles
    TotalDirectories=[int]$Context.Statistics.TotalDirectories
    TotalBytes=[long]$Context.Statistics.TotalBytes
    GroupCounts=[pscustomobject]$GroupCounts
}
return $Context
}

function Resolve-DiscFeatures {
param([Parameter(Mandatory)][pscustomobject]$Context)
$F=@()
$Names=@($Context.Files|ForEach-Object Name)
if($Names -contains 'PSXDATA' -or @($Context.Directories|Where-Object Name -ieq 'PSXDATA').Count){$F += 'PSXDATA'}
if($Names -contains 'PSXIRX' -or @($Context.Directories|Where-Object Name -ieq 'PSXIRX').Count){$F += 'PSXIRX'}
if($Names -contains 'FFEMU.BIN'){$F += 'FFEMU.BIN'}
if(@($Context.Files|Where-Object Extension -ieq '.SFD').Count){$F += 'SFD video'}
if(@($Context.Files|Where-Object Extension -ieq '.ADX').Count){$F += 'ADX audio'}
$Context.Features=@($F)
return $Context
}
