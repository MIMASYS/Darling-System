# ============================================================
# MODULO 05: OPCIONES DE ARRANQUE
# ============================================================

function Boot-ReiniciarBIOS {
    Clear-Host
    Write-Host "Reiniciar en BIOS/UEFI" -ForegroundColor Cyan
    Write-Host "======================" -ForegroundColor Cyan
    Write-Host ""
    $isUEFI = (bcdedit /enum {current} | Select-String -Pattern "path.*\.efi") -ne $null
    if (-not $isUEFI) {
        Write-Host "[ERROR] Tu sistema usa BIOS Legacy (no UEFI)." -ForegroundColor Red
        if (Confirmar-Accion "Reiniciar de todas formas?") {
            shutdown.exe /r /f /t 0
        }
        return
    }
    Write-Host "Este comando reiniciara la PC y entrara DIRECTO a la BIOS/UEFI." -ForegroundColor Yellow
    if (Confirmar-Accion "Reiniciar ahora y entrar a la BIOS?") {
        Write-Host "Reiniciando en 3 segundos..." -ForegroundColor Yellow
        Start-Sleep -Seconds 3
        shutdown.exe /r /fw /f /t 0
    }
}

function Boot-AdvancedStartup {
    Clear-Host
    Write-Host "Reiniciar en Menu de Arranque Avanzado" -ForegroundColor Cyan
    Write-Host "======================================" -ForegroundColor Cyan
    Write-Host ""
    if (Confirmar-Accion "Reiniciar ahora en el Menu de Arranque Avanzado?") {
        Write-Host "Reiniciando en 3 segundos..." -ForegroundColor Yellow
        Start-Sleep -Seconds 3
        shutdown.exe /r /o /f /t 0
    }
}

function Boot-ModoSeguro {
    Clear-Host
    Write-Host "Reiniciar en Modo Seguro" -ForegroundColor Cyan
    Write-Host "========================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "[TIPOS DE MODO SEGURO]" -ForegroundColor Yellow
    Write-Host "  1 - Modo Seguro normal"
    Write-Host "  2 - Modo Seguro con funciones de red"
    Write-Host "  3 - Modo Seguro con simbolo del sistema"
    Write-Host ""
    $tipo = Read-Host "Selecciona el tipo (1-3)"
    $safeBootValue = switch ($tipo) { "1" { "minimal" } "2" { "network" } "3" { "dsrepair" } default { $null } }
    if ($safeBootValue) {
        Write-Host ""
        Write-Host "NOTA: Para salir del Modo Seguro: bcdedit /deletevalue {current} safeboot" -ForegroundColor Yellow
        if (Confirmar-Accion "Configurar Modo Seguro y reiniciar?") {
            bcdedit /set {current} safeboot $safeBootValue | Out-Null
            Start-Sleep -Seconds 3
            shutdown.exe /r /f /t 0
        }
    } else { Write-Host "[ERROR] Opcion invalida." -ForegroundColor Red; Pause-Kit }
}

function SubMenu-Boot {
    while ($true) {
        Mostrar-Header
        Write-Host "   [ SUBMENU: OPCIONES DE ARRANQUE ]" -ForegroundColor Cyan
        Write-Host "=========================================" -ForegroundColor Magenta
        Write-Host " 1  - Reiniciar en BIOS/UEFI (Directo)"
        Write-Host " 2  - Reiniciar en Menu Avanzado"
        Write-Host " 3  - Reiniciar en Modo Seguro"
        Write-Host " 0  - Volver al menu principal"
        Write-Host ""
        $opcion = Read-Host "Selecciona una opcion"
        switch ($opcion) {
            "1" { Boot-ReiniciarBIOS }
            "2" { Boot-AdvancedStartup }
            "3" { Boot-ModoSeguro }
            "0" { return }
            default { Write-Host "Opcion invalida." -ForegroundColor Red; Start-Sleep -Seconds 1 }
        }
    }
}
