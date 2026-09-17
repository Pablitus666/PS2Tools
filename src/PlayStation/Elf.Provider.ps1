function Get-U16 {param([byte[]]$B,[int]$O,[bool]$BE);if($BE){[uint16](($B[$O]-shl 8)-bor $B[$O+1])}else{[uint16]($B[$O]-bor ($B[$O+1]-shl 8))}}
function Get-U32 {param([byte[]]$B,[int]$O,[bool]$BE);if($BE){[uint32](($B[$O]-shl 24)-bor($B[$O+1]-shl 16)-bor($B[$O+2]-shl 8)-bor $B[$O+3])}else{[uint32]($B[$O]-bor($B[$O+1]-shl 8)-bor($B[$O+2]-shl 16)-bor($B[$O+3]-shl 24))}}
function Read-ElfFile {
param([Parameter(Mandatory)][System.IO.FileInfo]$File)
try{
$B=[IO.File]::ReadAllBytes($File.FullName);if($B.Length -lt 52){return $null}
if($B[0]-ne 0x7F-or $B[1]-ne 0x45-or $B[2]-ne 0x4C-or $B[3]-ne 0x46){return $null}
$C=$B[4];$D=$B[5];$BE=($D-eq 2)
$Class=switch($C){1{'ELF32'}2{'ELF64'}default{"Unknown ($C)"}}
$Endian=switch($D){1{'Little-endian'}2{'Big-endian'}default{"Unknown ($D)"}}
$OS=@{0='System V';1='HP-UX';2='NetBSD';3='Linux';6='Solaris';7='AIX';8='IRIX';9='FreeBSD';12='OpenBSD'}
$Type=@{0='NONE';1='REL';2='EXEC';3='DYN';4='CORE'}
$Mach=@{3='x86';8='MIPS';10='MIPS RS3000 LE';62='x86-64'}
$TypeId=Get-U16 $B 16 $BE;$MachineId=Get-U16 $B 18 $BE;$Ver=Get-U32 $B 20 $BE
$Entry=Get-U32 $B 24 $BE
$Hash=(Get-FileHash -LiteralPath $File.FullName -Algorithm SHA256).Hash
[pscustomobject]@{IsElf=$true;IsBootExecutable=$false;IsPrimaryExecutable=$false;Source='ELF';FileName=$File.Name;FullName=$File.FullName;SizeBytes=[long]$File.Length;SizeFormatted=(Format-FileSize $File.Length);SHA256=$Hash;Class=$Class;Endianness=$Endian;OSABI=$(if($OS.ContainsKey([int]$B[7])){$OS[[int]$B[7]]}else{"Unknown ($($B[7]))"});Type=$(if($Type.ContainsKey([int]$TypeId)){$Type[[int]$TypeId]}else{"Unknown ($TypeId)"});Machine=$(if($Mach.ContainsKey([int]$MachineId)){$Mach[[int]$MachineId]}else{"Unknown ($MachineId)"});MachineId=$MachineId;Version=$Ver;EntryPoint=('{0:X}'-f $Entry)}
}catch{return $null}}
function Resolve-ElfAnalysis {
param([Parameter(Mandatory)][pscustomobject]$Context)
$Results=@()
foreach($File in @($Context.Files|Where-Object Extension -ieq '.ELF')){$Item=Read-ElfFile $File;if($Item){$Results+=$Item}}
foreach($File in @($Context.BootFiles)){
    $AlreadyIncluded=$false
    foreach($Existing in @($Results)){
        if($Existing.FullName -eq $File.FullName){$AlreadyIncluded=$true;break}
    }
    if(-not $AlreadyIncluded){$Item=Read-ElfFile $File;if($Item){$Results+=$Item}}
}
# Marcar el ejecutable de arranque como principal cuando el BOOT físico es un ELF válido.
$BootPaths=@($Context.BootFiles | ForEach-Object { $_.FullName })
$PrimaryAssigned=$false
foreach($Item in @($Results)){
    if($BootPaths -contains $Item.FullName){
        $Item.IsBootExecutable=$true
        if(-not $PrimaryAssigned -and $Item.Type -eq 'EXEC' -and $Item.Machine -like 'MIPS*'){
            $Item.IsPrimaryExecutable=$true
            $Item.Source='BOOT'
            $PrimaryAssigned=$true
        }
    }
}
# Si el BOOT fue detectado pero su ELF no figura como EXEC/MIPS, no inventamos un principal.
$Context.ELF=@($Results);$Context
}
