function New-DiscContext {
param([Parameter(Mandatory)][string]$Drive,[Parameter(Mandatory)][string]$ProjectRoot)
$DrivePath=$Drive.Trim();if($DrivePath -notmatch '[\\/]$'){$DrivePath+='\'}
$VolumeInfo=Get-DiscVolumeInfo -DrivePath $DrivePath
[pscustomobject]@{
DrivePath=$DrivePath;ProjectRoot=$ProjectRoot;IsValid=(Test-Path -LiteralPath $DrivePath -PathType Container);VolumeName=$VolumeInfo.VolumeName;FileSystem=$VolumeInfo.FileSystem
Files=@();Directories=@();SystemCnf=$null;Identity=$null;BootFiles=@();IOPRP=@();IRX=@();ELF=@();Features=@();ContentClassification=@();Fingerprint=$null;Statistics=$null}
}
