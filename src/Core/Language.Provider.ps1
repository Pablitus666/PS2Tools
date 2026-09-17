function Get-PS2ToolsLanguage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$ProjectRoot
    )

    $LanguageRoot = Join-Path $ProjectRoot 'Languages'
    $UiCulture = $null

    try {
        $UiCulture = (Get-UICulture).Name
    } catch {
        try { $UiCulture = [System.Globalization.CultureInfo]::InstalledUICulture.Name } catch { $UiCulture = 'en-US' }
    }

    if ([string]::IsNullOrWhiteSpace($UiCulture)) { $UiCulture = 'en-US' }

    $Candidates = @($UiCulture)
    $BaseLanguage = ($UiCulture -split '-')[0]
    if ($BaseLanguage -and $BaseLanguage -ne $UiCulture) { $Candidates += $BaseLanguage }
    $Candidates += 'en-US'

    $LanguagePath = $null
    $SelectedCulture = $null
    foreach ($Candidate in $Candidates) {
        $Path = Join-Path $LanguageRoot ($Candidate + '.json')
        if (Test-Path -LiteralPath $Path -PathType Leaf) {
            $LanguagePath = $Path
            $SelectedCulture = $Candidate
            break
        }
    }

    if (-not $LanguagePath) {
        throw "PS2Tools: no se encontró ningún archivo de idioma en $LanguageRoot"
    }

    try {
        $Language = Get-Content -LiteralPath $LanguagePath -Raw -Encoding UTF8 | ConvertFrom-Json
    } catch {
        throw "PS2Tools: no se pudo cargar el idioma '$SelectedCulture': $($_.Exception.Message)"
    }

    if ($null -eq $Language.meta) { throw "PS2Tools: el idioma '$SelectedCulture' no contiene la sección 'meta'." }

    $Language | Add-Member -NotePropertyName RequestedCulture -NotePropertyValue $UiCulture -Force
    $Language | Add-Member -NotePropertyName SelectedCulture -NotePropertyValue $SelectedCulture -Force
    $Language | Add-Member -NotePropertyName LanguagePath -NotePropertyValue $LanguagePath -Force
    return $Language
}
