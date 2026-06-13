# ============================================================
# DARLING SYSTEM - Instalador Inteligente
# Descarga, extrae y ejecuta el script completo
# ============================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Clear-Host
Write-Host "=========================================" -ForegroundColor Magenta
Write-Host "  DARLING SYSTEM - Instalador" -ForegroundColor Magenta
Write-Host "=========================================" -ForegroundColor Magenta
Write-Host ""

# URL del ZIP del ultimo release
$zipUrl = "https://github.com/MIMASYS/Darling-System/archive/refs/heads/main.zip"
$zipPath = Join-Path $env:TEMP "DarlingSystem.zip"
$extractPath = Join-Path $env:TEMP "DarlingSystem"

# Limpiar instalaciones anteriores
if (Test-Path $extractPath) {
    Remove-Item $extractPath -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "[1/4] Descargando ultima version..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing -ErrorAction Stop
    Write-Host "[OK] Descarga completada." -ForegroundColor Green
} catch {
    Write-Host "[ERROR] No se pudo descargar: $_" -ForegroundColor Red
    Write-Host "  Verifica tu conexion a internet." -ForegroundColor Yellow
    Read-Host "Presiona ENTER para salir"
    exit
}

Write-Host "[2/4] Extrayendo archivos..." -ForegroundColor Yellow
try {
    Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force -ErrorAction Stop
    # El ZIP extrae en una subcarpeta con el nombre del repo
    $realPath = Join-Path $extractPath "Darling-System-main"
    if (-not (Test-Path $realPath)) {
        # Buscar la carpeta real
        $realPath = (Get-ChildItem $extractPath -Directory | Select-Object -First 1).FullName
    }
    Write-Host "[OK] Archivos extraidos." -ForegroundColor Green
} catch {
    Write-Host "[ERROR] No se pudo extraer: $_" -ForegroundColor Red
    Read-Host "Presiona ENTER para salir"
    exit
}

Write-Host "[3/4] Verificando estructura..." -ForegroundColor Yellow
$scriptPath = Join-Path $realPath "DarlingSystem.ps1"
$modulesPath = Join-Path $realPath "modules"

if (-not (Test-Path $scriptPath)) {
    Write-Host "[ERROR] No se encontro DarlingSystem.ps1" -ForegroundColor Red
    Read-Host "Presiona ENTER para salir"
    exit
}

if (-not (Test-Path $modulesPath)) {
    Write-Host "[ERROR] No se encontro la carpeta modules/" -ForegroundColor Red
    Read-Host "Presiona ENTER para salir"
    exit
}

Write-Host "[OK] Estructura verificada." -ForegroundColor Green
Write-Host ""
Write-Host "[4/4] Iniciando Darling System..." -ForegroundColor Yellow
Write-Host ""

# Ejecutar el script principal
try {
    & $scriptPath
} catch {
    Write-Host "[ERROR] Error al ejecutar el script: $_" -ForegroundColor Red
    Read-Host "Presiona ENTER para salir"
}

# Limpieza opcional (descomenta si quieres borrar los temporales al salir)
# Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
# Remove-Item $extractPath -Recurse -Force -ErrorAction SilentlyContinue