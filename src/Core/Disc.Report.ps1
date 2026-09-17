function Show-DiscReport {
    param([Parameter(Mandatory)][pscustomobject]$Context)

    Write-Host ''
    Write-Host '===================================================='
    Write-Host '          PLAYSTATION DISC IDENTIFIER VERSION 1 OFFLINE'
    Write-Host '===================================================='

    Write-Section 'IDENTIFICACIÓN'
    Write-Host "Unidad            : $($Context.DrivePath)"
    Write-Host "Etiqueta volumen  : $(if([string]::IsNullOrWhiteSpace($Context.VolumeName)){'(sin etiqueta)'}else{$Context.VolumeName})"
    Write-Host "Sistema de archivos: $(if([string]::IsNullOrWhiteSpace($Context.FileSystem)){'No disponible'}else{$Context.FileSystem})"
    Write-Host "SYSTEM.CNF        : $(if($Context.SystemCnf){'OK'}else{'No encontrado'})"
    Write-Host "BOOT              : $($Context.Identity.Boot)"
    Write-Host "ID del juego      : $($Context.Identity.Serial)"
    Write-Host "Tipo              : $($Context.Identity.Type)"
    Write-Host "Base de datos     : $($Context.Identity.DatabaseStatus)"
    Write-Host "Nombre            : $($Context.Identity.Name)"
    Write-Host "Plataforma        : $($Context.Identity.Platform)"
    Write-Host "Región            : $($Context.Identity.Region)"
    Write-Host "Publisher         : $($Context.Identity.Publisher)"
    Write-Host "Developer         : $($Context.Identity.Developer)"
    Write-Host "Año               : $($Context.Identity.Year)"
    Write-Host "Género            : $($Context.Identity.Genre)"
    Write-Host "Versión           : $($Context.Identity.Version)"
    Write-Host "Video Mode        : $($Context.Identity.VMode)"

    Write-Section 'ESTRUCTURA DEL DISCO'
    Write-Host "Etiqueta volumen  : $(if([string]::IsNullOrWhiteSpace($Context.VolumeName)){'(sin etiqueta)'}else{$Context.VolumeName})"
    Write-Host "Sistema de archivos: $(if([string]::IsNullOrWhiteSpace($Context.FileSystem)){'No disponible'}else{$Context.FileSystem})"
    Write-Host "Archivos raíz     : $($Context.Statistics.RootFiles)"
    Write-Host "Directorios raíz  : $($Context.Statistics.RootDirectories)"

    Write-Section 'ESTADÍSTICAS DEL DISCO'
    Write-Host "Archivos totales  : $($Context.Statistics.TotalFiles)"
    Write-Host "Directorios totales: $($Context.Statistics.TotalDirectories)"
    Write-Host "Tamaño total      : $($Context.Statistics.TotalSize)"

    Write-Section 'EJECUTABLE DE ARRANQUE'
    $Boot = @($Context.BootFiles)
    if ($Boot.Count) {
        foreach ($File in $Boot) {
            Write-Host ''
            Write-Host "  $(Get-RelativeDiscPath $File.FullName $Context.DrivePath)"
            Write-Host "      Tamaño: $(Format-FileSize $File.Length)"
        }
    } else {
        Write-Host '  No encontrado físicamente'
    }

    Write-Section 'IOPRP'
    $IO = @($Context.IOPRP)
    Write-Host "Estado            : $(if($IO.Count){'Detectado'}else{'No detectado'})"
    Write-Host "Cantidad          : $($IO.Count)"
    foreach ($File in $IO) {
        Write-Host "  $(Get-RelativeDiscPath $File.FullName $Context.DrivePath)"
    }

    Write-Section 'MÓDULOS IRX'
    $IR = @($Context.IRX)
    Write-Host "Estado            : $(if($IR.Count){'Detectado'}else{'No detectado'})"
    Write-Host "Cantidad          : $($IR.Count)"
    foreach ($File in $IR) {
        Write-Host "  $(Get-RelativeDiscPath $File.FullName $Context.DrivePath)"
    }

    Write-Section 'ANÁLISIS ELF'
    $ELF = @($Context.ELF)
    if (-not $ELF.Count) {
        Write-Host '  No se encontraron archivos ELF'
    } else {
        foreach ($Item in $ELF) {
            Write-Host ''
            Write-Host "  Archivo         : $($Item.FileName)"
            Write-Host "  Ruta            : $(Get-RelativeDiscPath $Item.FullName $Context.DrivePath)"
            Write-Host "  Rol             : $(if($Item.IsPrimaryExecutable){'Ejecutable principal'}elseif($Item.IsBootExecutable){'Ejecutable BOOT'}else{'ELF secundario'})"
            Write-Host "  Tamaño          : $($Item.SizeFormatted)"
            Write-Host "  SHA-256         : $($Item.SHA256)"
            Write-Host "  Clase           : $($Item.Class)"
            Write-Host "  Endianness      : $($Item.Endianness)"
            Write-Host "  OS ABI          : $($Item.OSABI)"
            Write-Host "  Tipo ELF        : $($Item.Type)"
            Write-Host "  Máquina         : $($Item.Machine)"
            Write-Host "  Versión ELF     : $($Item.Version)"
            Write-Host "  Entry Point     : 0x$($Item.EntryPoint)"
        }
    }

    Write-Section 'CONTENIDO DEL DISCO'
    $Content=@($Context.ContentClassification)
    if (-not $Content.Count) {
        Write-Host '  Sin clasificación disponible.'
    } else {
        foreach ($Group in $Content) {
            Write-Host "  $($Group.Type) : $($Group.Count)"
            $Paths=@($Group.Paths)
            if ($Group.Type -ne 'DATOS') {
                foreach ($Path in $Paths) { Write-Host "      $Path" }
            } elseif ($Paths.Count -gt 0) {
                Write-Host "      (contenido de datos no listado individualmente)"
            }
        }
    }

    Write-Section 'HUELLA TÉCNICA'
    if ($Context.Fingerprint) {
        Write-Host "Algoritmo          : $($Context.Fingerprint.Algorithm)"
        Write-Host "Versión            : $($Context.Fingerprint.Version)"
        Write-Host "Tipo               : $($Context.Fingerprint.Type)"
        Write-Host "Fingerprint        : $($Context.Fingerprint.Value)"
        Write-Host "BOOT SHA-256       : $($Context.Fingerprint.BootSHA256)"
        Write-Host "SYSTEM.CNF SHA-256 : $($Context.Fingerprint.SystemCnfSHA256)"
        Write-Host "Archivos           : $($Context.Fingerprint.TotalFiles)"
        Write-Host "Directorios        : $($Context.Fingerprint.TotalDirectories)"
        Write-Host "Tamaño             : $(Format-FileSize $Context.Fingerprint.TotalBytes)"
    } else {
        Write-Host '  Huella técnica no disponible.'
    }

    Write-Section 'CARACTERÍSTICAS DETECTADAS'
    if (@($Context.Features).Count) {
        foreach ($Feature in $Context.Features) {
            Write-Host "  [OK] $Feature"
        }
    } else {
        Write-Host '  Ninguna característica adicional detectada.'
    }

    Write-Section 'SYSTEM.CNF'
    if ($Context.SystemCnf) {
        $Context.SystemCnf.RawLines | ForEach-Object { Write-Host $_ }
    } else {
        Write-Host 'SYSTEM.CNF no disponible.'
    }

    Write-Section 'RESUMEN'
    Write-Host "Juego             : $($Context.Identity.Name)"
    Write-Host "Tipo              : $($Context.Identity.Type)"
    Write-Host "Serial            : $($Context.Identity.Serial)"
    Write-Host "Base de datos     : $($Context.Identity.DatabaseStatus)"
    Write-Host "Plataforma        : $($Context.Identity.Platform)"
    Write-Host "Región            : $($Context.Identity.Region)"
    Write-Host "Publisher         : $($Context.Identity.Publisher)"
    Write-Host "Developer         : $($Context.Identity.Developer)"
    Write-Host "Año               : $($Context.Identity.Year)"
    Write-Host "Género            : $($Context.Identity.Genre)"
    Write-Host "Versión           : $($Context.Identity.Version)"
    Write-Host "BOOT físico       : $(if($Boot.Count){'Sí'}else{'No'})"
    Write-Host "IOPRP             : $(if($IO.Count){'Sí'}else{'No'})"
    Write-Host "IRX               : $(if($IR.Count){'Sí'}else{'No'})"
    Write-Host "ELF               : $(if($ELF.Count){'Sí'}else{'No'})"
    Write-Host "Tamaño            : $($Context.Statistics.TotalSize)"
}
