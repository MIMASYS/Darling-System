# ============================================================
# MODULO 10: MODO TECNICO
# ============================================================

function Tecnico-MsInfo { Start-Process msinfo32 }
function Tecnico-DxDiag { Start-Process dxdiag }
function Tecnico-EventViewer { Start-Process eventvwr.msc }
function Tecnico-PerfMon { Start-Process perfmon.msc }
function Tecnico-DevMgr { Start-Process devmgmt.msc }
function Tecnico-DiskMgr { Start-Process diskmgmt.msc }
function Tecnico-RegEdit { Start-Process regedit }
function Tecnico-SecPol { Start-Process secpol.msc }
function Tecnico-GPEdit { Start-Process gpedit.msc }
function Tecnico-TaskSched { Start-Process taskschd.msc }

function SubMenu-Tecnico {
    while ($true) {
        Mostrar-Header
        Write-Host "   [ SUBMENU: MODO TECNICO ]" -ForegroundColor Cyan
        Write-Host "=========================================" -ForegroundColor Magenta
        Write-Host " 1  - Informacion del sistema (msinfo32)"
        Write-Host " 2  - Diagnostico DirectX (dxdiag)"
        Write-Host " 3  - Visor de eventos (eventvwr)"
        Write-Host " 4  - Monitor de rendimiento (perfmon)"
        Write-Host " 5  - Administrador de dispositivos (devmgmt)"
        Write-Host " 6  - Administracion de discos (diskmgmt)"
        Write-Host " 7  - Editor de registro (regedit)"
        Write-Host " 8  - Politica de seguridad local (secpol)"
        Write-Host " 9  - Editor de directivas de grupo (gpedit)"
        Write-Host " 10 - Programador de tareas (taskschd)"
        Write-Host " 0  - Volver al menu principal"
        Write-Host ""
        $opcion = Read-Host "Selecciona una opcion"
        switch ($opcion) {
            "1" { Tecnico-MsInfo; Pause-Kit }
            "2" { Tecnico-DxDiag; Pause-Kit }
            "3" { Tecnico-EventViewer; Pause-Kit }
            "4" { Tecnico-PerfMon; Pause-Kit }
            "5" { Tecnico-DevMgr; Pause-Kit }
            "6" { Tecnico-DiskMgr; Pause-Kit }
            "7" { Tecnico-RegEdit; Pause-Kit }
            "8" { Tecnico-SecPol; Pause-Kit }
            "9" { Tecnico-GPEdit; Pause-Kit }
            "10" { Tecnico-TaskSched; Pause-Kit }
            "0" { return }
            default { Write-Host "Opcion invalida." -ForegroundColor Red; Start-Sleep -Seconds 1 }
        }
    }
}
