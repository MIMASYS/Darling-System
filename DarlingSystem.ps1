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
    "13-Seguridad.ps1"
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
# MENU PRINCIPAL (ESTILO PROFESIONAL CON CATEGORIAS)
# ============================================================

while ($true) {
    Mostrar-Header
    Write-Host ""
    
    # CATEGORIA 1: DIAGNOSTICO
    Write-Host "  ┌─ DIAGNOSTICO Y ANALISIS " -ForegroundColor Cyan
    Write-Host "  │  1  - Utilidades del sistema" -ForegroundColor White
    Write-Host "  │  2  - Perifericos y Hardware" -ForegroundColor White
    Write-Host "  │  3  - Modo Tecnico" -ForegroundColor White
    Write-Host "  └────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host ""
    
    # CATEGORIA 2: MANTENIMIENTO
    Write-Host "  ┌─ MANTENIMIENTO Y REPARACION " -ForegroundColor Yellow
    Write-Host "  │  4  - Herramientas de gestion" -ForegroundColor White
    Write-Host "  │  5  - Mantenimiento del sistema" -ForegroundColor White
    Write-Host "  │  6  - Gestion de Discos" -ForegroundColor White
    Write-Host "  │  7  - Reparacion Avanzada de Red" -ForegroundColor White
    Write-Host "  └────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host ""
    
    # CATEGORIA 3: CONFIGURACION
    Write-Host "  ┌─ CONFIGURACION Y OPTIMIZACION " -ForegroundColor Green
    Write-Host "  │  8  - Opciones de Arranque (Boot/BIOS)" -ForegroundColor White
    Write-Host "  │  9  - Optimizacion de Windows 11" -ForegroundColor White
    Write-Host "  │  10 - SEGURIDAD DEL SISTEMA" -ForegroundColor Red -BackgroundColor Black
    Write-Host "  └────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host ""
    
    # CATEGORIA 4: HERRAMIENTAS Y REPORTES
    Write-Host "  ┌─ HERRAMIENTAS Y REPORTES " -ForegroundColor Magenta
    Write-Host "  │  11 - Descarga de Herramientas" -ForegroundColor White
    Write-Host "  │  12 - Instalacion con Winget" -ForegroundColor White
    Write-Host "  │  13 - Reporte HTML avanzado" -ForegroundColor White
    Write-Host "  │  14 - Reporte TXT al Escritorio" -ForegroundColor White
    Write-Host "  └────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host ""
    
    # SALIR
    Write-Host "  0  - Salir de Darling System" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
    
    $opcion = Read-Host "  Selecciona una opcion"
    
    switch ($opcion) {
        "1" { SubMenu-Utilidades }
        "2" { SubMenu-Perifericos }
        "3" { SubMenu-Tecnico }
        "4" { SubMenu-Herramientas }
        "5" { SubMenu-Mantenimiento }
        "6" { SubMenu-Discos }
        "7" { SubMenu-Red }
        "8" { SubMenu-Boot }
        "9" { SubMenu-Optimizacion }
        "10" { SubMenu-Seguridad }
        "11" { SubMenu-Descargas }
        "12" { SubMenu-Winget }
        "13" { Generar-ReporteHTML }
        "14" { Generar-Reporte }
        "777" { Mostrar-ASCII-Art }
        "0" {
            Clear-Host
            Write-Host ""
            Write-Host "  ❤ Gracias por usar Darling System ❤" -ForegroundColor Magenta
            Write-Host "  Created by MIMASYS. Chu. & Qwen" -ForegroundColor Gray
            Write-Host ""
            Start-Sleep -Seconds 2
            break
        }
        default { 
            Write-Host "  Opcion invalida. Por favor selecciona un numero del 0 al 14." -ForegroundColor Red
            Start-Sleep -Seconds 2 
        }
    }
}