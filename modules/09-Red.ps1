# ============================================================
# MODULO 09: REPARACION AVANZADA DE RED
# ============================================================

function Red-LiberarIP {
    Clear-Host
    Write-Host "Liberando direccion IP..." -ForegroundColor Yellow
    ipconfig /release
    Write-Host "[OK] Direccion IP liberada." -ForegroundColor Green
    Pause-Kit
}

function Red-RenovarIP {
    Clear-Host
    Write-Host "Renovando direccion IP..." -ForegroundColor Yellow
    ipconfig /renew
    Write-Host "[OK] Direccion IP renovada." -ForegroundColor Green
    Pause-Kit
}

function Red-ReiniciarWinsock {
    Clear-Host
    Write-Host "Reiniciando Winsock..." -ForegroundColor Yellow
    netsh winsock reset
    Write-Host "[OK] Winsock reiniciado. Se requiere reinicio del sistema." -ForegroundColor Green
    Pause-Kit
}

function Red-ReiniciarTCPIP {
    Clear-Host
    Write-Host "Reiniciando pila TCP/IP..." -ForegroundColor Yellow
    netsh int ip reset
    Write-Host "[OK] Pila TCP/IP reiniciada. Se requiere reinicio del sistema." -ForegroundColor Green
    Pause-Kit
}

function Red-MostrarConfig {
    Clear-Host
    Write-Host "Configuracion IP Actual" -ForegroundColor Cyan
    Write-Host "=======================" -ForegroundColor Cyan
    Write-Host ""
    ipconfig /all
    Pause-Kit
}

function Red-PruebasAutomaticas {
    Clear-Host
    Write-Host "Pruebas Automaticas de Conectividad" -ForegroundColor Cyan
    Write-Host "====================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "[1/4] Probando gateway..." -NoNewline
    $gateway = (Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object {$_.IPEnabled} | Select-Object -First 1).DefaultIPGateway
    if ($gateway) {
        $test = Test-Connection -ComputerName $gateway[0] -Count 1 -Quiet -ErrorAction SilentlyContinue
        if ($test) { Write-Host " [OK] ($($gateway[0]))" -ForegroundColor Green }
        else { Write-Host " [FALLO]" -ForegroundColor Red }
    } else { Write-Host " [N/A]" -ForegroundColor Yellow }
    Write-Host "[2/4] Probando DNS (8.8.8.8)..." -NoNewline
    $test = Test-Connection -ComputerName "8.8.8.8" -Count 1 -Quiet -ErrorAction SilentlyContinue
    if ($test) { Write-Host " [OK]" -ForegroundColor Green } else { Write-Host " [FALLO]" -ForegroundColor Red }
    Write-Host "[3/4] Probando resolucion DNS (google.com)..." -NoNewline
    $test = Test-Connection -ComputerName "google.com" -Count 1 -Quiet -ErrorAction SilentlyContinue
    if ($test) { Write-Host " [OK]" -ForegroundColor Green } else { Write-Host " [FALLO]" -ForegroundColor Red }
    Write-Host "[4/4] Probando HTTP (microsoft.com)..." -NoNewline
    try {
        $web = Invoke-WebRequest -Uri "http://microsoft.com" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        Write-Host " [OK] (HTTP $($web.StatusCode))" -ForegroundColor Green
    } catch { Write-Host " [FALLO]" -ForegroundColor Red }
    Write-Host ""
    Pause-Kit
}

function Red-ReparacionCompleta {
    Clear-Host
    Write-Host "Reparacion Completa de Red" -ForegroundColor Red
    Write-Host "==========================" -ForegroundColor Red
    Write-Host ""
    Write-Host "ADVERTENCIA: Se requiere reinicio despues de esta operacion." -ForegroundColor Yellow
    Write-Host ""
    if (-not (Confirmar-Accion "Ejecutar reparacion completa de red?")) { return }
    Write-Host "[1/5] Liberando IP..." -ForegroundColor Yellow
    ipconfig /release | Out-Null
    Write-Host "[2/5] Renovando IP..." -ForegroundColor Yellow
    ipconfig /renew | Out-Null
    Write-Host "[3/5] Limpiando cache DNS..." -ForegroundColor Yellow
    Clear-DnsClientCache
    Write-Host "[4/5] Reiniciando Winsock..." -ForegroundColor Yellow
    netsh winsock reset | Out-Null
    Write-Host "[5/5] Reiniciando pila TCP/IP..." -ForegroundColor Yellow
    netsh int ip reset | Out-Null
    Write-Host ""
    Write-Host "[OK] Reparacion completada." -ForegroundColor Green
    Write-Host "  Se recomienda reiniciar el sistema." -ForegroundColor Yellow
    Pause-Kit
}

function SubMenu-Red {
    while ($true) {
        Mostrar-Header
        Write-Host "   [ SUBMENU: REPARACION AVANZADA DE RED ]" -ForegroundColor Cyan
        Write-Host "=========================================" -ForegroundColor Magenta
        Write-Host " 1  - Vaciar cache DNS"
        Write-Host " 2  - Liberar direccion IP"
        Write-Host " 3  - Renovar direccion IP"
        Write-Host " 4  - Reiniciar Winsock"
        Write-Host " 5  - Reiniciar pila TCP/IP"
        Write-Host " 6  - Mostrar configuracion IP"
        Write-Host " 7  - Pruebas automaticas de conectividad"
        Write-Host " 8  - REPARACION COMPLETA DE RED"
        Write-Host " 0  - Volver al menu principal"
        Write-Host ""
        $opcion = Read-Host "Selecciona una opcion"
        switch ($opcion) {
            "1" { Clear-DnsClientCache; Write-Host "[OK] Cache DNS limpiada." -ForegroundColor Green; Pause-Kit }
            "2" { Red-LiberarIP }
            "3" { Red-RenovarIP }
            "4" { Red-ReiniciarWinsock }
            "5" { Red-ReiniciarTCPIP }
            "6" { Red-MostrarConfig }
            "7" { Red-PruebasAutomaticas }
            "8" { Red-ReparacionCompleta }
            "0" { return }
            default { Write-Host "Opcion invalida." -ForegroundColor Red; Start-Sleep -Seconds 1 }
        }
    }
}
