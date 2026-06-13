# ============================================================
# MODULO 02: HERRAMIENTAS DE GESTION
# ============================================================

function Herr-TaskMgr { Start-Process taskmgr }
function Herr-ResMon  { Start-Process resmon }
function Herr-Services { Start-Process services.msc }
function Herr-CompMgmt { Start-Process compmgmt.msc }

function Herr-ReiniciarExplorer {
    Clear-Host
    Write-Host "Reiniciando Explorer.exe..." -ForegroundColor Yellow
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    Start-Process explorer.exe
    Write-Host "[OK] Explorer reiniciado correctamente." -ForegroundColor Green
    Pause-Kit
}

function SubMenu-Herramientas {
    while ($true) {
        Mostrar-Header
        Write-Host "   [ SUBMENU: HERRAMIENTAS DE GESTION ]" -ForegroundColor Cyan
        Write-Host "=========================================" -ForegroundColor Magenta
        Write-Host " 1  - Abrir Administrador de tareas"
        Write-Host " 2  - Abrir Monitor de recursos"
        Write-Host " 3  - Abrir Servicios"
        Write-Host " 4  - Abrir Administracion de equipos"
        Write-Host " 5  - Reiniciar Explorer"
        Write-Host " 0  - Volver al menu principal"
        Write-Host ""
        $opcion = Read-Host "Selecciona una opcion"
        switch ($opcion) {
            "1" { Herr-TaskMgr; Pause-Kit }
            "2" { Herr-ResMon; Pause-Kit }
            "3" { Herr-Services; Pause-Kit }
            "4" { Herr-CompMgmt; Pause-Kit }
            "5" { Herr-ReiniciarExplorer }
            "0" { return }
            default { Write-Host "Opcion invalida." -ForegroundColor Red; Start-Sleep -Seconds 1 }
        }
    }
}
