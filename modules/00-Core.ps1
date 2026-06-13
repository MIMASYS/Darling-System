# ============================================================
# MODULO 00: FUNCIONES CORE Y AUXILIARES
# ============================================================

$Script:VersionActual = "4.0"
$Script:VersionURL = "https://raw.githubusercontent.com/MIMASYS/Darling-System/main/version.txt"
$Script:ReleasesURL = "https://github.com/MIMASYS/Darling-System/releases"

function Pause-Kit { 
    Write-Host ""
    Read-Host "Presiona ENTER para volver al menu" 
}

function Confirmar-Accion {
    param([string]$Mensaje = "Deseas continuar?")
    Write-Host ""
    Write-Host "$Mensaje (s/n): " -ForegroundColor Yellow -NoNewline
    $respuesta = Read-Host
    if ($respuesta -in @('s', 'S', 'si', 'Si', 'SI')) { return $true }
    return $false
}

function Mostrar-Header {
    Clear-Host
    Write-Host "=========================================" -ForegroundColor Magenta
    Write-Host "            DARLING SYSTEM" -ForegroundColor Magenta
    Write-Host "        Version CherryRed Flavor 4.0" -ForegroundColor Magenta
    Write-Host "=========================================" -ForegroundColor Magenta
    Write-Host "           Dirty and dummy system" -ForegroundColor Magenta
    Write-Host "          Created by: MIMASYS. Chu." -ForegroundColor Magenta
    Write-Host "       Co-authored by: Qwen (AI Dev)" -ForegroundColor Magenta
    Write-Host "=========================================" -ForegroundColor Magenta
}

function Verificar_Actualizacion {
    try {
        $respuestaWeb = Invoke-WebRequest -Uri $Script:VersionURL -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        $versionRemota = $respuestaWeb.Content.Trim()
        $versionRemota = $versionRemota -replace '[^\d\.]', ''
        if ([string]::IsNullOrWhiteSpace($versionRemota)) { return }
        $verLocal = [version]$Script:VersionActual
        $verRemota = [version]$versionRemota
        if ($verRemota -gt $verLocal) {
            Write-Host ""
            Write-Host "=====================================================" -ForegroundColor Yellow
            Write-Host "  NUEVA VERSION DISPONIBLE: v$versionRemota" -ForegroundColor Yellow
            Write-Host "  Tu version actual: v$Script:VersionActual" -ForegroundColor White
            Write-Host "  Descarga la nueva version en:" -ForegroundColor White
            Write-Host "  $Script:ReleasesURL" -ForegroundColor Cyan
            Write-Host "=====================================================" -ForegroundColor Yellow
            Write-Host ""
            $abrir = Read-Host "Deseas abrir la pagina de descargas? (s/n)"
            if ($abrir -in @('s', 'S', 'si', 'Si', 'SI')) { Start-Process $Script:ReleasesURL }
        }
    } catch { }
}

function Test-ConexionInternet {
    try { return (Test-Connection -ComputerName "8.8.8.8" -Count 1 -Quiet -ErrorAction SilentlyContinue) }
    catch { return $false }
}

function Seleccionar-Unidad {
    Clear-Host
    Write-Host "Seleccionar Unidad de Descarga" -ForegroundColor Cyan
    Write-Host "==============================" -ForegroundColor Cyan
    Write-Host ""
    $volumes = Get-Volume | Where-Object { $_.DriveLetter -and $_.DriveType -eq 'Fixed' -and $_.HealthStatus -eq 'Healthy' }
    if ($volumes.Count -eq 0) {
        Write-Host "[ERROR] No se encontraron unidades disponibles." -ForegroundColor Red
        Pause-Kit
        return $null
    }
    Write-Host "Unidades disponibles:" -ForegroundColor Yellow
    $i = 1
    foreach ($vol in $volumes) {
        $freeGB = [math]::Round($vol.SizeRemaining / 1GB, 2)
        $totalGB = [math]::Round($vol.Size / 1GB, 2)
        $percent = [math]::Round(($vol.SizeRemaining / $vol.Size) * 100, 0)
        $color = if ($percent -lt 20) { 'Red' } elseif ($percent -lt 50) { 'Yellow' } else { 'Green' }
        Write-Host "  $i - $($vol.DriveLetter): [$percent% libre] $freeGB GB / $totalGB GB" -ForegroundColor $color
        $i++
    }
    Write-Host ""
    $seleccion = Read-Host "Selecciona el numero de la unidad"
    if ($seleccion -match '^\d+$' -and [int]$seleccion -ge 1 -and [int]$seleccion -le $volumes.Count) {
        $unidadSeleccionada = $volumes[[int]$seleccion - 1].DriveLetter
        Write-Host ""
        Write-Host "[OK] Unidad seleccionada: $($unidadSeleccionada):\" -ForegroundColor Green
        return "$($unidadSeleccionada):\"
    } else {
        Write-Host "[ERROR] Seleccion invalida." -ForegroundColor Red
        Pause-Kit
        return $null
    }
}

function Obtener-CarpetaHerramientas {
    param([string]$UnidadBase = $null)
    if (-not $UnidadBase) {
        $UnidadBase = Seleccionar-Unidad
        if (-not $UnidadBase) { return $null }
    }
    $carpeta = Join-Path $UnidadBase "DarlingTools"
    if (-not (Test-Path $carpeta)) { New-Item -ItemType Directory -Path $carpeta -Force | Out-Null }
    return $carpeta
}
