#requires -Version 7.0
[CmdletBinding()]
param(
    [Parameter(Position=0)][string]$Drive
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'SilentlyContinue'
$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$SourceRoot = Join-Path $ProjectRoot 'src'
. (Join-Path $SourceRoot 'Bootstrap.ps1')
if ([string]::IsNullOrWhiteSpace($Drive)) {
    $OpticalMedia = @(Get-OpticalDrive)
    if ($OpticalMedia.Count -eq 0) {
        Write-DiscError -Message 'No se detectó ninguna unidad óptica con medio insertado.' -Detail 'Inserta un disco y vuelve a ejecutar el programa.'
        exit 1
    }

    $Detected = @(Get-OpticalPs2Drive)
    if ($Detected.Count -eq 0) {
        if ($OpticalMedia.Count -eq 1) {
            $DriveLabel = $OpticalMedia[0].Drive
            Write-DiscError -Message 'Se detectó un disco óptico, pero no parece ser un disco de PlayStation 2.' -Detail "Unidad comprobada: $DriveLabel`
Verifica que el disco tenga SYSTEM.CNF con una entrada BOOT2."
        } else {
            Write-DiscError -Message 'Se detectaron discos ópticos, pero ninguno parece ser un disco de PlayStation 2.' -Detail 'Verifica los discos insertados y vuelve a ejecutar el programa.'
        }
        exit 1
    }

    if ($Detected.Count -gt 1) {
        Write-Host ''
        Write-Host 'Se encontraron varias unidades ópticas con disco PlayStation 2:'
        Write-Host ''
        for ($i=0; $i -lt $Detected.Count; $i++) {
            $Item = $Detected[$i]
            $Volume = if ([string]::IsNullOrWhiteSpace($Item.VolumeName)) { '(sin etiqueta)' } else { $Item.VolumeName }
            $Serial = Convert-BootToSerial -Boot $Item.Boot
            $Game = if ($Serial) { Get-GameDatabaseEntry -Serial $Serial -ProjectRoot $ProjectRoot } else { $null }
            $Title = if ($Game -and -not [string]::IsNullOrWhiteSpace($Game.Name)) { $Game.Name } else { '(título no encontrado en DB)' }
            Write-Host ("[{0}] {1}  {2}  |  {3}  |  {4}" -f ($i+1),$Item.Drive,$Title,$Serial,$Volume)
        }
        Write-Host ''
        $Index = 0
        do {
            $Choice = Read-Host ('Selecciona el número de la unidad [1-{0}]' -f $Detected.Count)
            $ValidChoice = [int]::TryParse($Choice,[ref]$Index) -and $Index -ge 1 -and $Index -le $Detected.Count
            if (-not $ValidChoice) {
                Write-Host 'Selección inválida. Introduce uno de los números mostrados.'
            }
        } while (-not $ValidChoice)
        $Drive = $Detected[$Index-1].Drive
    } else {
        $Drive = $Detected[0].Drive
    }
}
try {
    $Context = New-DiscContext -Drive $Drive -ProjectRoot $ProjectRoot
    if (-not $Context.IsValid) { Write-DiscError -Message 'La unidad o ruta no existe.' -Detail $Context.DrivePath; exit 1 }

    $Context = Invoke-DiscScan -Context $Context
    if (-not (Test-DiscMediaAvailable -DrivePath $Context.DrivePath)) { Throw-DiscRemoved }

    $Context = Resolve-PlayStationIdentity -Context $Context
    if (-not (Test-DiscMediaAvailable -DrivePath $Context.DrivePath)) { Throw-DiscRemoved }

    $Context = Resolve-DiscArtifacts -Context $Context
    if (-not (Test-DiscMediaAvailable -DrivePath $Context.DrivePath)) { Throw-DiscRemoved }

    $Context = Resolve-ElfAnalysis -Context $Context
    if (-not (Test-DiscMediaAvailable -DrivePath $Context.DrivePath)) { Throw-DiscRemoved }

    $Context = Resolve-DiscFeatures -Context $Context
    if (-not (Test-DiscMediaAvailable -DrivePath $Context.DrivePath)) { Throw-DiscRemoved }

    $Context = Resolve-DiscContentClassification -Context $Context
    if (-not (Test-DiscMediaAvailable -DrivePath $Context.DrivePath)) { Throw-DiscRemoved }

    $Context = Resolve-DiscFingerprint -Context $Context
    if (-not (Test-DiscMediaAvailable -DrivePath $Context.DrivePath)) { Throw-DiscRemoved }

    Show-DiscReport -Context $Context
    $HtmlOutput = Join-Path $ProjectRoot 'Output\PS2Tools-Report.html'
    New-PS2ToolsHtmlReport -Context $Context -OutputPath $HtmlOutput | Out-Null
    Write-Host ''
    Write-Host "Informe HTML : $HtmlOutput"
} catch {
    if ($_.Exception.Message -eq 'PS2Tools:DISC_REMOVED') {
        Write-DiscError -Message 'El disco fue retirado durante el análisis.' -Detail 'Inserta nuevamente el disco y vuelve a ejecutar el programa.'
        exit 2
    }
    Write-DiscError -Message 'No se pudo completar el análisis del disco.' -Detail $_.Exception.Message
    exit 1
}
