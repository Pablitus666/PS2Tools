function Invoke-DiscScan {
param([Parameter(Mandatory)][pscustomobject]$Context)

if (-not (Test-DiscMediaAvailable -DrivePath $Context.DrivePath)) { Throw-DiscRemoved }

$RootPath = $Context.DrivePath
try {
    $Files=@(Get-ChildItem -LiteralPath $RootPath -File -Recurse -Force -ErrorAction Stop)
    $Directories=@(Get-ChildItem -LiteralPath $RootPath -Directory -Recurse -Force -ErrorAction Stop)
} catch {
    if (-not (Test-DiscMediaAvailable -DrivePath $Context.DrivePath)) { Throw-DiscRemoved }
    throw
}

if (-not (Test-DiscMediaAvailable -DrivePath $Context.DrivePath)) { Throw-DiscRemoved }

# Obtener los elementos directamente en la raíz sin depender de propiedades del padre.
try {
    $RootItems=@(Get-ChildItem -LiteralPath $RootPath -Force -ErrorAction Stop)
} catch {
    if (-not (Test-DiscMediaAvailable -DrivePath $Context.DrivePath)) { Throw-DiscRemoved }
    throw
}
$RootFiles=@($RootItems | Where-Object { -not $_.PSIsContainer })
$RootDirectories=@($RootItems | Where-Object { $_.PSIsContainer })
$TotalBytes=[long]0
foreach($File in $Files){$TotalBytes+=[long]$File.Length}
$Context.Files=$Files
$Context.Directories=$Directories
$Context.Statistics=[pscustomobject]@{
    RootFiles=$RootFiles.Count
    RootDirectories=$RootDirectories.Count
    TotalFiles=$Files.Count
    TotalDirectories=$Directories.Count
    TotalBytes=$TotalBytes
    TotalSize=(Format-FileSize $TotalBytes)
}
$Context
}
