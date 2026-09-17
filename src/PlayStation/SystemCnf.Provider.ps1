function Read-SystemCnf {
param([Parameter(Mandatory)][pscustomobject]$Context)
$File=@($Context.Files|Where-Object Name -ieq 'SYSTEM.CNF')|Select-Object -First 1
if(-not $File){return $null}
$Lines=@(Get-Content -LiteralPath $File.FullName -Encoding utf8 -ErrorAction SilentlyContinue);$Values=@{}
foreach($Line in $Lines){if($Line -match '^\s*([^=\s]+)\s*=\s*(.*?)\s*$'){$Values[$matches[1].ToUpperInvariant()]=$matches[2]}}
[pscustomobject]@{File=$File;RawLines=$Lines;Values=$Values;Boot=$Values['BOOT2'];Version=$Values['VER'];VMode=$Values['VMODE']}
}
