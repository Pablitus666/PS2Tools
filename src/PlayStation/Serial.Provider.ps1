function Convert-BootToSerial {
param([string]$Boot)
if([string]::IsNullOrWhiteSpace($Boot)){return $null}
$Name=Split-Path -Leaf (($Boot-replace '/','\')-replace ';[0-9]+$','')
if($Name -match '^([A-Z]{4})[_-](\d{3})[._-](\d{2})$'){"$($matches[1])-$($matches[2])$($matches[3])"}else{($Name-replace '_','-').ToUpperInvariant()}
}
function Get-GamePlatform {param([string]$Serial);if($Serial -match '^(SCES|SLES|SLUS|SLPM|SCKA|SCPS|SCAJ|SLKA)-'){'PlayStation 2'}else{'Desconocida'}}
function Get-GameRegion {
param([string]$Serial)
switch -Regex ($Serial){
'^(SCES|SLES)-'{'PAL / Europa'} '^SLUS-'{ 'NTSC-U / USA'} '^SLPM-'{ 'NTSC-J / Japón'} '^SCKA-'{ 'NTSC-K / Corea'} '^SCPS-'{ 'NTSC-J / Asia'} '^SCAJ-'{ 'NTSC-J / Asia'} '^SLKA-'{ 'NTSC-K / Corea'} default{'Desconocida'}}
}
function Resolve-PlayStationIdentity {
param([Parameter(Mandatory)][pscustomobject]$Context)
$System=if($Context.SystemCnf){$Context.SystemCnf}else{Read-SystemCnf $Context}
$Serial=Convert-BootToSerial $(if($System){$System.Boot}else{$null})
$Homebrew=Get-HomebrewIdentity $(if($System){$System.Boot}else{$null})
$DB=$null
if(-not $Homebrew){$DB=Get-GameDatabaseEntry -Serial $Serial -ProjectRoot $Context.ProjectRoot}
$Context.SystemCnf=$System

if($Homebrew){
    $Context.Identity=[pscustomobject]@{
        Boot=$(if($System){$System.Boot})
        Serial=$Serial
        DatabaseStatus='Homebrew/Utility'
        Name=$Homebrew.Name
        Type=$Homebrew.Type
        Platform='PlayStation 2'
        Region='No aplica'
        Publisher='No aplica'
        Developer='No aplica'
        Year='No aplica'
        Genre='Homebrew / Utility'
        Version=$(if($System -and $System.Version){$System.Version}else{'No disponible'})
        VMode=$(if($System){$System.VMode})
    }
    return $Context
}

$Context.Identity=[pscustomobject]@{
Boot=$(if($System){$System.Boot});Serial=$Serial
DatabaseStatus=$(if($DB){'Encontrado'}elseif($Serial){'No encontrado'}else{'No disponible'})
Name=$(if($DB){$DB.Name}else{'Desconocido'})
Type=$(if($DB){'Juego'}else{'Desconocido'})
Platform=Get-GamePlatform $Serial;Region=$(if($DB){$DB.Region}elseif($Serial){Get-GameRegion $Serial}else{'Desconocida'})
Publisher=$(if($DB){$DB.Publisher}else{'Desconocido'});Developer=$(if($DB){$DB.Developer}else{'Desconocido'})
Year=$(if($DB){$DB.Year}else{'Desconocido'});Genre=$(if($DB){$DB.Genre}else{'Desconocido'})
Version=$(if($DB -and $DB.Version){$DB.Version}elseif($System){$System.Version});VMode=$(if($System){$System.VMode})}
$Context
}
