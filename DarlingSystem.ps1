# ============================================================
# DARLING SYSTEM - Script Principal
# Version 4.1 - Modular
# ============================================================

# Forzar codificacion UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

# Forzar TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# ============================================================
# CARGAR MODULOS (Dot-Sourcing)
# ============================================================

$modulesPath = Join-Path $PSScriptRoot "modules"

$modulos = @(
    "00-Core.ps1",
    "01-Utilidades.ps1",
    "02-Herramientas.ps1",
    "03-Mantenimiento.ps1",
    "04-Discos.ps1",
    "05-Boot.ps1",
    "06-Optimizacion.ps1",
    "07-Descargas.ps1",
    "08-Perifericos.ps1",
    "09-Red.ps1",
    "10-Tecnico.ps1",
    "11-Winget.ps1",
    "12-Reportes.ps1"
)

foreach ($modulo in $modulos) {
    $rutaModulo = Join-Path $modulesPath $modulo
    if (Test-Path $rutaModulo) {
        try {
            . $rutaModulo
        } catch {
            Write-Host "[ERROR] No se pudo cargar el modulo $modulo" -ForegroundColor Red
            Write-Host $_.Exception.Message -ForegroundColor Red
            Pause
            exit
        }
    } else {
        Write-Host "[ADVERTENCIA] Modulo no encontrado: $modulo" -ForegroundColor Yellow
    }
}

# ============================================================
# INICIALIZACION
# ============================================================

Clear-Host

# Verificar actualizaciones
Verificar_Actualizacion

# Verificar permisos de Administrador
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ADVERTENCIA: Se recomienda ejecutar como Administrador." -ForegroundColor Yellow
    Write-Host "Algunas opciones requeriran permisos elevados." -ForegroundColor Yellow
    Start-Sleep -Seconds 3
}

# ============================================================
# MENU PRINCIPAL
# ============================================================

while ($true) {
    Mostrar-Header
    Write-Host ""
    Write-Host " 1  - Utilidades del sistema"
    Write-Host " 2  - Herramientas de gestion"
    Write-Host " 3  - Mantenimiento"
    Write-Host " 4  - Gestion de Discos"
    Write-Host " 5  - Opciones de Arranque (Boot/BIOS)"
    Write-Host " 6  - Optimizacion de Windows 11"
    Write-Host " 7  - Descarga de Herramientas"
    Write-Host " 8  - Perifericos y Hardware"
    Write-Host " 9  - Reparacion Avanzada de Red"
    Write-Host " 10 - Modo Tecnico"
    Write-Host " 11 - Instalacion con Winget"
    Write-Host " 12 - Reporte HTML avanzado"
    Write-Host " 13 - Reporte TXT al Escritorio"
    Write-Host " 0  - Salir"
    Write-Host ""
    $opcion = Read-Host "Selecciona una opcion"
    switch ($opcion) {
        "1" { SubMenu-Utilidades }
        "2" { SubMenu-Herramientas }
        "3" { SubMenu-Mantenimiento }
        "4" { SubMenu-Discos }
        "5" { SubMenu-Boot }
        "6" { SubMenu-Optimizacion }
        "7" { SubMenu-Descargas }
        "8" { SubMenu-Perifericos }
        "9" { SubMenu-Red }
        "10" { SubMenu-Tecnico }
        "11" { SubMenu-Winget }
        "12" { Generar-ReporteHTML }
        "13" { Generar-Reporte }
        "777" { Mostrar-ASCII-Art }        
        "0" {
            Clear-Host
            Write-Host "Saliendo de Darling System. Hasta luego!" -ForegroundColor Green
            Start-Sleep -Seconds 1
            break
        }
        default { Write-Host "Opcion invalida." -ForegroundColor Red; Start-Sleep -Seconds 2 }
    }
}
