
function ConvertTo-HtmlSafe {
    param([AllowNull()][object]$Value)
    if ($null -eq $Value) { return '' }
    return [System.Net.WebUtility]::HtmlEncode([string]$Value)
}

function Get-HtmlDiscRelativePath {
    param([Parameter(Mandatory)][string]$FullName,[Parameter(Mandatory)][string]$DrivePath)
    $Root = $DrivePath
    if ($Root -notmatch '[\\/]$') { $Root += '\' }
    $Full = $FullName
    if ($Full.StartsWith($Root,[System.StringComparison]::OrdinalIgnoreCase)) {
        return $Full.Substring($Root.Length).Replace('\','/')
    }
    return $Full.Replace('\','/')
}

function Get-PS2ToolsHtmlCss {
    $CssPath = Join-Path $PSScriptRoot 'PS2Tools.css'
    if (-not (Test-Path -LiteralPath $CssPath -PathType Leaf)) {
        throw "PS2Tools: no se encontró el archivo CSS: $CssPath"
    }
    return [System.IO.File]::ReadAllText($CssPath, [System.Text.Encoding]::UTF8)
}



function New-PS2ToolsHtmlReport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][pscustomobject]$Context,
        [Parameter(Mandatory)][string]$OutputPath
    )

    $Language = Get-PS2ToolsLanguage -ProjectRoot $Context.ProjectRoot

    $GameName = if ($Context.Identity.Name) { $Context.Identity.Name } else { $Language.messages.defaultGame }
    $Serial = [string]$Context.Identity.Serial
    $DbStatus = switch ([string]$Context.Identity.DatabaseStatus) {
        'Encontrado' { $Language.messages.databaseFound }
        'No encontrado' { $Language.messages.databaseNotFound }
        'No disponible' { $Language.messages.databaseUnavailable }
        default { [string]$Context.Identity.DatabaseStatus }
    }
    $Drive = [string]$Context.DrivePath
    $Fs = if ($Context.FileSystem) { $Context.FileSystem } else { $Language.disc.unavailable }
    $Volume = if ($Context.VolumeName) { $Context.VolumeName } else { $Language.disc.noLabel }

    $contentRows = ''
    foreach ($Group in @($Context.ContentClassification)) {
        $contentRows += "<tr><td>$(ConvertTo-HtmlSafe $(if ($Language.content.groups.PSObject.Properties.Name -contains [string]$Group.Type) { $Language.content.groups.([string]$Group.Type) } else { $Group.Type }))</td><td>$([int]$Group.Count)</td><td>$(ConvertTo-HtmlSafe $Group.TotalSize)</td><td>$(ConvertTo-HtmlSafe ($Group.Extensions -join ', '))</td></tr>"
    }

    $elfRows = ''
    foreach ($Item in @($Context.ELF)) {
        $role = if ($Item.IsPrimaryExecutable) { $Language.elf.primary } elseif ($Item.IsBootExecutable) { $Language.elf.bootExecutable } else { $Language.elf.secondary }
        $elfRows += "<tr><td>$(ConvertTo-HtmlSafe $Item.FileName)</td><td>$(ConvertTo-HtmlSafe $role)</td><td>$(ConvertTo-HtmlSafe $Item.Class)</td><td>$(ConvertTo-HtmlSafe $Item.Machine)</td><td class='tech'>$(ConvertTo-HtmlSafe $Item.SHA256)</td></tr>"
    }

    $bootRows = ''
    foreach ($File in @($Context.BootFiles)) {
        $rel = Get-HtmlDiscRelativePath $File.FullName $Context.DrivePath
        $bootRows += "<tr><td class='tech'>$(ConvertTo-HtmlSafe $rel)</td><td>$(ConvertTo-HtmlSafe (Format-FileSize $File.Length))</td></tr>"
    }
    if (-not $bootRows) { $bootRows = "<tr><td colspan='2'>$(ConvertTo-HtmlSafe $Language.boot.notFound)</td></tr>" }

    $ioRows = ''
    foreach ($File in @($Context.IOPRP)) {
        $ioRows += "<tr><td class='tech'>$(ConvertTo-HtmlSafe (Get-HtmlDiscRelativePath $File.FullName $Context.DrivePath))</td><td>$(ConvertTo-HtmlSafe (Format-FileSize $File.Length))</td></tr>"
    }
    if (-not $ioRows) { $ioRows = "<tr><td colspan='2'>$(ConvertTo-HtmlSafe $Language.modules.notDetected)</td></tr>" }

    $irRows = ''
    foreach ($File in @($Context.IRX)) {
        $irRows += "<tr><td class='tech'>$(ConvertTo-HtmlSafe (Get-HtmlDiscRelativePath $File.FullName $Context.DrivePath))</td><td>$(ConvertTo-HtmlSafe (Format-FileSize $File.Length))</td></tr>"
    }
    if (-not $irRows) { $irRows = "<tr><td colspan='2'>$(ConvertTo-HtmlSafe $Language.modules.notDetected)</td></tr>" }

    $finger = $Context.Fingerprint
    $features = @($Context.Features)
    $featureHtml = if ($features.Count) {
        '<ul>' + (($features | ForEach-Object { "<li>$(ConvertTo-HtmlSafe $_)</li>" }) -join '') + '</ul>'
    } else { "<p class='note'>$(ConvertTo-HtmlSafe $Language.features.none)</p>" }

    if ($finger) {
        $fingerHtml = @"
<div class="summary-grid">
<div class="summary-item"><b>$($Language.fingerprint.algorithm)</b> $(ConvertTo-HtmlSafe $finger.Algorithm)</div>
<div class="summary-item"><b>$($Language.fingerprint.version)</b> $(ConvertTo-HtmlSafe $finger.Version)</div>
<div class="summary-item"><b>$($Language.fingerprint.type)</b> $(ConvertTo-HtmlSafe $(if ([string]$finger.Type -eq 'Huella técnica estructural') { $Language.fingerprint.typeStructural } else { $finger.Type }))</div>
<div class="summary-item"><b>$($Language.fingerprint.files)</b> $([int]$finger.TotalFiles)</div>
<div class="summary-item"><b>$($Language.fingerprint.directories)</b> $([int]$finger.TotalDirectories)</div>
<div class="summary-item"><b>$($Language.fingerprint.size)</b> $(ConvertTo-HtmlSafe (Format-FileSize $finger.TotalBytes))</div>
</div>
<p><b>$($Language.fingerprint.fingerprint)</b></p><p class="tech">$(ConvertTo-HtmlSafe $finger.Value)</p>
<p><b>$($Language.fingerprint.bootSha)</b></p><p class="tech">$(ConvertTo-HtmlSafe $finger.BootSHA256)</p>
<p><b>$($Language.fingerprint.systemCnfSha)</b></p><p class="tech">$(ConvertTo-HtmlSafe $finger.SystemCnfSHA256)</p>
"@
    } else {
        $fingerHtml = "<p class='note'>$(ConvertTo-HtmlSafe $Language.fingerprint.unavailable)</p>"
    }

    $HtmlModuleDir = $PSScriptRoot
$LogoPath = Join-Path $HtmlModuleDir "..\Assets\logo.png"
$AuthorImagePath = Join-Path $HtmlModuleDir "..\Assets\Pablo_Tellez_A.png"
$IconPath = Join-Path $HtmlModuleDir "..\Assets\icon.ico"
$LogoBase64 = if (Test-Path -LiteralPath $LogoPath) { [Convert]::ToBase64String([IO.File]::ReadAllBytes($LogoPath)) } else { "" }
$AuthorImageBase64 = if (Test-Path -LiteralPath $AuthorImagePath) { [Convert]::ToBase64String([IO.File]::ReadAllBytes($AuthorImagePath)) } else { "" }
$IconBase64 = if (Test-Path -LiteralPath $IconPath) { [Convert]::ToBase64String([IO.File]::ReadAllBytes($IconPath)) } else { "" }

$systemLines = if ($Context.SystemCnf -and $Context.SystemCnf.RawLines) {
        (($Context.SystemCnf.RawLines | ForEach-Object { ConvertTo-HtmlSafe $_ }) -join "`n")
    } else { $Language.systemCnf.unavailable }

    $html = @"
<!DOCTYPE html>
<html lang="$(ConvertTo-HtmlSafe $Language.meta.htmlLang)">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>PS2Tools</title>
$(if ($IconBase64) { '<link rel="icon" type="image/x-icon" sizes="16x16 24x24 32x32 48x48 64x64 128x128 256x256" href="data:image/x-icon;base64,' + $IconBase64 + '"><link rel="shortcut icon" type="image/x-icon" href="data:image/x-icon;base64,' + $IconBase64 + '">' } else { '' })
<style>
$(Get-PS2ToolsHtmlCss)
</style>
</head>
<body>
<button type="button" class="about-toggle" id="aboutToggle" aria-label="$(ConvertTo-HtmlSafe $Language.about.aria)" title="$(ConvertTo-HtmlSafe $Language.about.aria)">i</button>
<div class="container">
<header class="header">
<h1>$(ConvertTo-HtmlSafe $Language.report.title)</h1>
<p>$(ConvertTo-HtmlSafe $Language.report.subtitle)</p>
</header>
<div class="grid">
<section class="card">
<h2>$(ConvertTo-HtmlSafe $Language.identification.section)</h2>
<div class="highlight">$(ConvertTo-HtmlSafe $GameName)</div>
<p class="note"><span class="badge">$(ConvertTo-HtmlSafe $Serial)</span> &nbsp; $(ConvertTo-HtmlSafe $DbStatus)</p>
<div class="summary-grid">
<div class="summary-item"><b>$(ConvertTo-HtmlSafe $Language.identification.platform)</b> $(ConvertTo-HtmlSafe $Context.Identity.Platform)</div>
<div class="summary-item"><b>$(ConvertTo-HtmlSafe $Language.identification.region)</b> $(ConvertTo-HtmlSafe $Context.Identity.Region)</div>
<div class="summary-item"><b>$(ConvertTo-HtmlSafe $Language.identification.publisher)</b> $(ConvertTo-HtmlSafe $Context.Identity.Publisher)</div>
<div class="summary-item"><b>$(ConvertTo-HtmlSafe $Language.identification.developer)</b> $(ConvertTo-HtmlSafe $Context.Identity.Developer)</div>
<div class="summary-item"><b>$(ConvertTo-HtmlSafe $Language.identification.year)</b> $(ConvertTo-HtmlSafe $Context.Identity.Year)</div>
<div class="summary-item"><b>$(ConvertTo-HtmlSafe $Language.identification.genre)</b> $(ConvertTo-HtmlSafe $Context.Identity.Genre)</div>
<div class="summary-item"><b>$(ConvertTo-HtmlSafe $Language.identification.version)</b> $(ConvertTo-HtmlSafe $Context.Identity.Version)</div>
<div class="summary-item"><b>$(ConvertTo-HtmlSafe $Language.identification.videoMode)</b> $(ConvertTo-HtmlSafe $Context.Identity.VMode)</div>
</div>
</section>

<section class="card">
<h2>$(ConvertTo-HtmlSafe $Language.disc.section)</h2>
<div class="metric-grid">
<div class="metric"><div class="metric-label">$(ConvertTo-HtmlSafe $Language.disc.drive)</div><div class="metric-value">$(ConvertTo-HtmlSafe $Drive)</div></div>
<div class="metric"><div class="metric-label">$(ConvertTo-HtmlSafe $Language.disc.files)</div><div class="metric-value">$([int]$Context.Statistics.TotalFiles)</div></div>
<div class="metric"><div class="metric-label">$(ConvertTo-HtmlSafe $Language.disc.directories)</div><div class="metric-value">$([int]$Context.Statistics.TotalDirectories)</div></div>
<div class="metric"><div class="metric-label">$(ConvertTo-HtmlSafe $Language.disc.size)</div><div class="metric-value">$(ConvertTo-HtmlSafe $Context.Statistics.TotalSize)</div></div>
</div>
<div class="summary-grid" style="margin-top:16px">
<div class="summary-item"><b>$(ConvertTo-HtmlSafe $Language.disc.volumeLabel)</b> $(ConvertTo-HtmlSafe $Volume)</div>
<div class="summary-item"><b>$(ConvertTo-HtmlSafe $Language.disc.fileSystem)</b> $(ConvertTo-HtmlSafe $Fs)</div>
<div class="summary-item"><b>$(ConvertTo-HtmlSafe $Language.disc.rootFiles)</b> $([int]$Context.Statistics.RootFiles)</div>
<div class="summary-item"><b>$(ConvertTo-HtmlSafe $Language.disc.rootDirectories)</b> $([int]$Context.Statistics.RootDirectories)</div>
</div>
</section>

<section class="card">
<h2>$(ConvertTo-HtmlSafe $Language.boot.section)</h2>
<table><thead><tr><th>$(ConvertTo-HtmlSafe $Language.boot.path)</th><th>$(ConvertTo-HtmlSafe $Language.boot.size)</th></tr></thead><tbody>$bootRows</tbody></table>
</section>

<section class="card">
<h2>$(ConvertTo-HtmlSafe $Language.modules.section)</h2>
<h3>$(ConvertTo-HtmlSafe $Language.modules.ioprp)</h3>
<table><thead><tr><th>$(ConvertTo-HtmlSafe $Language.modules.path)</th><th>$(ConvertTo-HtmlSafe $Language.modules.size)</th></tr></thead><tbody>$ioRows</tbody></table>
<h3>$(ConvertTo-HtmlSafe $Language.modules.irx)</h3>
<table><thead><tr><th>$(ConvertTo-HtmlSafe $Language.modules.path)</th><th>$(ConvertTo-HtmlSafe $Language.modules.size)</th></tr></thead><tbody>$irRows</tbody></table>
</section>

<section class="card">
<h2>$(ConvertTo-HtmlSafe $Language.elf.section)</h2>
<table><thead><tr><th>$(ConvertTo-HtmlSafe $Language.elf.file)</th><th>$(ConvertTo-HtmlSafe $Language.elf.role)</th><th>$(ConvertTo-HtmlSafe $Language.elf.class)</th><th>$(ConvertTo-HtmlSafe $Language.elf.machine)</th><th>$(ConvertTo-HtmlSafe $Language.elf.sha256)</th></tr></thead><tbody>$elfRows</tbody></table>
</section>

<section class="card">
<h2>$(ConvertTo-HtmlSafe $Language.content.section)</h2>
<table><thead><tr><th>$(ConvertTo-HtmlSafe $Language.content.group)</th><th>$(ConvertTo-HtmlSafe $Language.content.files)</th><th>$(ConvertTo-HtmlSafe $Language.content.size)</th><th>$(ConvertTo-HtmlSafe $Language.content.extensions)</th></tr></thead><tbody>$contentRows</tbody></table>
</section>

<section class="card">
<h2>$(ConvertTo-HtmlSafe $Language.fingerprint.section)</h2>
$fingerHtml
</section>

<section class="card">
<h2>$(ConvertTo-HtmlSafe $Language.features.section)</h2>
$featureHtml
</section>

<section class="card">
<h2>$(ConvertTo-HtmlSafe $Language.systemCnf.section)</h2>
<pre class="tech">$(ConvertTo-HtmlSafe $systemLines)</pre>
</section>
</div>
<footer>$(ConvertTo-HtmlSafe $Language.report.footer)</footer>
</div>

<div id="about" class="about-overlay" onclick="if(event.target===this)this.classList.remove('open')" aria-hidden="true">
<div class="about-card" role="dialog" aria-modal="true" aria-labelledby="aboutTitle">
<button class="about-close" onclick="document.getElementById('about').classList.remove('open')" aria-label="$(ConvertTo-HtmlSafe $Language.about.close)">×</button>
<img class="about-logo" src="data:image/png;base64,$LogoBase64" alt="PS2Tools">
<h2 id="aboutTitle">PS2Tools</h2>
<p class="about-subtitle">$(ConvertTo-HtmlSafe $Language.about.subtitle)</p>
<div class="about-meta">
<div class="about-meta-row"><strong>$(ConvertTo-HtmlSafe $Language.about.version)</strong><span>Version 1</span></div>
<div class="about-meta-row"><strong>$(ConvertTo-HtmlSafe $Language.about.platform)</strong><span>Windows</span></div>
<div class="about-meta-row"><strong>$(ConvertTo-HtmlSafe $Language.about.technology)</strong><span>PowerShell</span></div>
<div class="about-meta-row"><strong>$(ConvertTo-HtmlSafe $Language.about.mode)</strong><span>$(ConvertTo-HtmlSafe $Language.about.offline)</span></div>
</div>
<div class="about-separator"></div>
<div class="about-credit-label">$(ConvertTo-HtmlSafe $Language.about.developedBy)</div>
<img class="about-author-image" src="data:image/png;base64,$AuthorImageBase64" alt="Walter Pablo Téllez Ayala">
<div>$(ConvertTo-HtmlSafe $Language.about.location)</div>

</div>
</div>
<script>
(function () {
    const about = document.getElementById('about');
    const toggle = document.getElementById('aboutToggle');
    const close = document.querySelector('.about-close');
    if (toggle) toggle.addEventListener('click', function () { about.classList.add('open'); about.setAttribute('aria-hidden','false'); });
    if (close) close.addEventListener('click', function () { about.classList.remove('open'); about.setAttribute('aria-hidden','true'); });
    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') { about.classList.remove('open'); about.setAttribute('aria-hidden','true'); }
    });
})();
</script>
</body>
</html>
"@

    $Parent = Split-Path -Parent $OutputPath
    if (-not (Test-Path -LiteralPath $Parent)) {
        New-Item -ItemType Directory -Path $Parent -Force | Out-Null
    }
    [System.IO.File]::WriteAllText($OutputPath,$html,(New-Object System.Text.UTF8Encoding($false)))
    return $OutputPath
}
