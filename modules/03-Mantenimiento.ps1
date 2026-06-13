# ============================================================
# MODULO 03: MANTENIMIENTO
# ============================================================

function Mant-LimpiarTemp {
    Clear-Host
    Write-Host "Limpiando archivos temporales..." -ForegroundColor Yellow
    Remove-Item "$env:TEMP\*" -Force -Recurse -ErrorAction SilentlyContinue
    Write-Host "[OK] Archivos temporales eliminados." -ForegroundColor Green
    Pause-Kit
}

function Mant-LimpiarDNS {
    Clear-Host
    Clear-DnsClientCache
    Write-Host "[OK] Cache DNS limpiada correctamente." -ForegroundColor Green
    Pause-Kit
}

function Mant-SFC {
    Clear-Host
    Write-Host "ADVERTENCIA: SFC puede tardar varios minutos." -ForegroundColor Yellow
    sfc /scannow
    Pause-Kit
}

function Mant-DISM {
    Clear-Host
    Write-Host "ADVERTENCIA: DISM puede tardar varios minutos." -ForegroundColor Yellow
    DISM /Online /Cleanup-Image /RestoreHealth
    Pause-Kit
}

function Mant-ReparacionCompleta {
    Clear-Host
    Write-Host "Reparacion Completa de Windows" -ForegroundColor Red
    Write-Host "==============================" -ForegroundColor Red
    Write-Host ""
    Write-Host "ADVERTENCIA: Este proceso puede tardar 30-60 minutos." -ForegroundColor Yellow
    Write-Host "No cierres esta ventana durante el proceso." -ForegroundColor Yellow
    Write-Host ""
    if (-not (Confirmar-Accion "Iniciar reparacion completa de Windows?")) { return }
    Write-Host ""
    Write-Host "[1/4] DISM - CheckHealth..." -ForegroundColor Yellow
    DISM /Online /Cleanup-Image /CheckHealth
    Write-Host ""
    Write-Host "[2/4] DISM - ScanHealth..." -ForegroundColor Yellow
    DISM /Online /Cleanup-Image /ScanHealth
    Write-Host ""
    Write-Host "[3/4] DISM - RestoreHealth..." -ForegroundColor Yellow
    DISM /Online /Cleanup-Image /RestoreHealth
    Write-Host ""
    Write-Host "[4/4] SFC - Scannow..." -ForegroundColor Yellow
    sfc /scannow
    Write-Host ""
    Write-Host "[OK] Reparacion completa finalizada." -ForegroundColor Green
    Write-Host "  Se recomienda reiniciar el sistema." -ForegroundColor Yellow
    Pause-Kit
}

function Punto-CrearRestauracion {
    Clear-Host
    Write-Host "Crear Punto de Restauracion" -ForegroundColor Cyan
    Write-Host "===========================" -ForegroundColor Cyan
    Write-Host ""
    try {
        $vssStatus = vssadmin list shadowstorage 2>&1
        if ($vssStatus -match "Error") {
            Write-Host "[ADVERTENCIA] La Proteccion del Sistema parece estar DESACTIVADA." -ForegroundColor Red
            Write-Host ""
            Write-Host "Para activarla:" -ForegroundColor Yellow
            Write-Host "  1. Ve a: Sistema > Proteccion del sistema > Configurar" -ForegroundColor White
            Write-Host "  2. Selecciona 'Activar la proteccion del sistema'" -ForegroundColor White
            Write-Host ""
            Pause-Kit
            return
        }
    } catch { }
    Write-Host "Se creara un punto de restauracion del sistema." -ForegroundColor Yellow
    Write-Host ""
    if (Confirmar-Accion "Crear punto de restauracion ahora?") {
        try {
            Write-Host "Creando punto de restauracion..." -ForegroundColor Yellow
            Checkpoint-Computer -Description "DarlingSystem_Backup_$(Get-Date -Format 'yyyyMMdd_HHmm')" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
            Write-Host "[OK] Punto de restauracion creado exitosamente." -ForegroundColor Green
        } catch {
            Write-Host "[ERROR] No se pudo crear el punto: $_" -ForegroundColor Red
        }
    }
    Pause-Kit
}

function SubMenu-Mantenimiento {
    while ($true) {
        Mostrar-Header
        Write-Host "   [ SUBMENU: MANTENIMIENTO ]" -ForegroundColor Cyan
        Write-Host "=========================================" -ForegroundColor Magenta
        Write-Host " 1  - Limpiar archivos temporales"
        Write-Host " 2  - Limpiar cache DNS"
        Write-Host " 3  - Ejecutar SFC (Reparar sistema)"
        Write-Host " 4  - Ejecutar DISM (Restaurar imagen)"
        Write-Host " 5  - REPARACION COMPLETA DE WINDOWS"
        Write-Host " 6  - Crear Punto de Restauracion"
        Write-Host " 0  - Volver al menu principal"
        Write-Host ""
        $opcion = Read-Host "Selecciona una opcion"
        switch ($opcion) {
            "1" { Mant-LimpiarTemp }
            "2" { Mant-LimpiarDNS }
            "3" { Mant-SFC }
            "4" { Mant-DISM }
            "5" { Mant-ReparacionCompleta }
            "6" { Punto-CrearRestauracion }
            "0" { return }
            default { Write-Host "Opcion invalida." -ForegroundColor Red; Start-Sleep -Seconds 1 }
        }
    }
}
