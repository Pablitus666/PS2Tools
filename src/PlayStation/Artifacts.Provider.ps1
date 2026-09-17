function Find-BootFile {
param([Parameter(Mandatory)][pscustomobject]$Context,[string]$BootName)
if([string]::IsNullOrWhiteSpace($BootName)){return @()}
$Target=$BootName.Trim().Trim('"').Trim("'")-replace '/','\'
$Target=$Target-replace ';[0-9]+$','';$Target=Split-Path -Leaf $Target
$Matches=@($Context.Files|Where-Object {$CleanName=$_.Name-replace ';[0-9]+$','';$_.Name -ieq $Target -or $CleanName -ieq $Target})
if($Matches.Count -eq 0){$Candidate=Join-Path $Context.DrivePath $Target;if(Test-Path -LiteralPath $Candidate -PathType Leaf){$Matches=@(Get-Item -LiteralPath $Candidate)}}
@($Matches)
}
function Resolve-DiscArtifacts {
param([Parameter(Mandatory)][pscustomobject]$Context)
$Context.BootFiles=@(Find-BootFile $Context $Context.SystemCnf.Boot)
$Context.IOPRP=@($Context.Files|Where-Object Name -match '^IOPRP.*\.IMG$')
$Context.IRX=@($Context.Files|Where-Object Extension -ieq '.IRX')
$Context
}
