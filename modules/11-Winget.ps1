# ============================================================
# MODULO 11: INSTALACION CON WINGET
# ============================================================

function Winget-Verificar {
    try {
        $null = Get-Command winget -ErrorAction Stop
        return $true
    } catch { return $false }
}

function Winget-Instalar {
    param([string]$Paquete, [string]$Nombre)
    Clear-Host
    Write-Host "Instalando $Nombre con Winget" -ForegroundColor Cyan
    Write-Host "=================================" -ForegroundColor Cyan
    Write-Host ""
    if (-not (Winget-Verificar)) {
        Write-Host "[ERROR] Winget no esta instalado en este sistema." -ForegroundColor Red
        Write-Host "  Descargalo desde: https://aka.ms/getwinget" -ForegroundColor Yellow
        Pause-Kit
        return
    }
    Write-Host "Buscando $Paquete..." -ForegroundColor Yellow
    try {
        winget install --id $Paquete --accept-source-agreements --accept-package-agreements --silent
        Write-Host ""
        Write-Host "[OK] $Nombre instalado correctamente." -ForegroundColor Green
    } catch {
        Write-Host "[ERROR] No se pudo instalar: $_" -ForegroundColor Red
    }
    Pause-Kit
}

function SubMenu-Winget {
    while ($true) {
        Mostrar-Header
        Write-Host "   [ SUBMENU: INSTALACION CON WINGET ]" -ForegroundColor Cyan
        Write-Host "=========================================" -ForegroundColor Magenta
        if (-not (Winget-Verificar)) {
            Write-Host ""
            Write-Host "[ADVERTENCIA] Winget no esta disponible." -ForegroundColor Red
            Write-Host "  Descargalo desde: https://aka.ms/getwinget" -ForegroundColor Yellow
            Write-Host ""
        }
        Write-Host " 1  - Instalar 7-Zip"
        Write-Host " 2  - Instalar Everything"
        Write-Host " 3  - Instalar CrystalDiskInfo"
        Write-Host " 4  - Instalar HWiNFO"
        Write-Host " 5  - Instalar Wireshark"
        Write-Host " 6  - Instalar Brave Browser"
        Write-Host " 7  - Instalar Rufus"
        Write-Host " 0  - Volver al menu principal"
        Write-Host ""
        $opcion = Read-Host "Selecciona una opcion"
        switch ($opcion) {
            "1" { Winget-Instalar -Paquete "7zip.7zip" -Nombre "7-Zip" }
            "2" { Winget-Instalar -Paquete "voidtools.Everything" -Nombre "Everything" }
            "3" { Winget-Instalar -Paquete "crystalidea.crystaldiskinfo" -Nombre "CrystalDiskInfo" }
            "4" { Winget-Instalar -Paquete "realsoft.HWiNFO" -Nombre "HWiNFO" }
            "5" { Winget-Instalar -Paquete "WiresharkFoundation.Wireshark" -Nombre "Wireshark" }
            "6" { Winget-Instalar -Paquete "Brave.Brave" -Nombre "Brave Browser" }
            "7" { Winget-Instalar -Paquete "Rufus.Rufus" -Nombre "Rufus" }
            "0" { return }
            default { Write-Host "Opcion invalida." -ForegroundColor Red; Start-Sleep -Seconds 1 }
        }
    }
}
