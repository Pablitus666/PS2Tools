function Get-GameDatabasePath {
    param([Parameter(Mandatory)][string]$ProjectRoot)

    Join-Path $ProjectRoot 'Database\games.json'
}

function Get-GameDatabase {
    param([Parameter(Mandatory)][string]$ProjectRoot)

    $Path = Get-GameDatabasePath -ProjectRoot $ProjectRoot
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return $null
    }

    try {
        $Raw = Get-Content -LiteralPath $Path -Raw -Encoding utf8 -ErrorAction Stop
        if ([string]::IsNullOrWhiteSpace($Raw)) { return $null }
        return $Raw | ConvertFrom-Json -ErrorAction Stop
    }
    catch {
        return $null
    }
}

function Normalize-GameSerial {
    param([string]$Serial)

    if ([string]::IsNullOrWhiteSpace($Serial)) { return $null }
    $Serial.Trim().ToUpperInvariant()
}

function Get-GameDatabaseEntry {
    param(
        [string]$Serial,
        [Parameter(Mandatory)][string]$ProjectRoot
    )

    $Normalized = Normalize-GameSerial $Serial
    if (-not $Normalized) { return $null }

    $Database = Get-GameDatabase -ProjectRoot $ProjectRoot
    if (-not $Database) { return $null }

    try {
        # V4.2 uses the serial as the primary JSON key.
        $Property = $Database.PSObject.Properties |
            Where-Object { $_.Name -ieq $Normalized } |
            Select-Object -First 1

        if ($Property) {
            $Entry = $Property.Value
            $Entry | Add-Member -NotePropertyName 'Serial' -NotePropertyValue $Property.Name -Force
            return $Entry
        }

        # Compatibility with the V4.1 array format.
        if ($Database -is [System.Array]) {
            return @($Database | Where-Object Serial -ieq $Normalized) |
                Select-Object -First 1
        }
    }
    catch {
        return $null
    }

    return $null
}

function Test-GameDatabaseEntry {
    param(
        [string]$Serial,
        [Parameter(Mandatory)][string]$ProjectRoot
    )

    return $null -ne (Get-GameDatabaseEntry -Serial $Serial -ProjectRoot $ProjectRoot)
}
