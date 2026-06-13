# ============================================================
# MODULO 07: DESCARGA DE HERRAMIENTAS
# ============================================================

$Script:ToolsTable = @(
    @{Categoria="Diagnostico"; Nombre="HDDScan"; Descripcion="Diagnostico avanzado de discos duros"; URL="https://hddscan.com/download/HDDScan-4.1.zip"; Archivo="HDDScan-4.1.zip"},
    @{Categoria="Diagnostico"; Nombre="HWiNFO"; Descripcion="Informacion completa de hardware"; URL="https://www.sac.sk/download/utildiag/hwi_792.zip"; Archivo="HWiNFO_Portable.zip"},
    @{Categoria="Diagnostico"; Nombre="CrystalDiskInfo"; Descripcion="Salud S.M.A.R.T. de discos SSD/HDD"; URL="https://osdn.net/frs/redir.php?m=auto&f=%2Fcrystaldiskinfo%2F94272%2FCrystalDiskInfo9_4_1.zip"; Archivo="CrystalDiskInfo.zip"},
    @{Categoria="Diagnostico"; Nombre="MemTest86"; Descripcion="Prueba exhaustiva de memoria RAM"; URL="https://www.memtest86.com/downloads/memtest86-usb.zip"; Archivo="memtest86-usb.zip"},
    @{Categoria="Sysinternals"; Nombre="Autoruns"; Descripcion="Gestor avanzado de programas de inicio"; URL="https://download.sysinternals.com/files/Autoruns.zip"; Archivo="Autoruns.zip"},
    @{Categoria="Sysinternals"; Nombre="Process Explorer"; Descripcion="Administrador de tareas avanzado"; URL="https://download.sysinternals.com/files/ProcessExplorer.zip"; Archivo="ProcessExplorer.zip"},
    @{Categoria="Sysinternals"; Nombre="Process Monitor"; Descripcion="Monitor de actividad de procesos"; URL="https://download.sysinternals.com/files/ProcessMonitor.zip"; Archivo="ProcessMonitor.zip"},
    @{Categoria="Utilidades"; Nombre="Everything"; Descripcion="Busqueda instantanea de archivos"; URL="https://www.voidtools.com/Everything-1.4.1.1026.x86-Setup.exe"; Archivo="Everything-Setup.exe"},
    @{Categoria="Utilidades"; Nombre="Rufus"; Descripcion="Creador de USBs booteables"; URL="https://github.com/pbatard/rufus/releases/download/v4.9/rufus-4.9.exe"; Archivo="rufus.exe"},
    @{Categoria="Utilidades"; Nombre="7-Zip"; Descripcion="Compresor de archivos open-source"; URL="https://www.7-zip.org/a/7z2409-x64.exe"; Archivo="7zip_installer.exe"},
    @{Categoria="Utilidades"; Nombre="WinRAR"; Descripcion="Compresor de archivos clasico"; URL="https://www.rarlab.com/rar/winrar-x64-710.exe"; Archivo="winrar_installer.exe"},
    @{Categoria="Red"; Nombre="Brave Browser"; Descripcion="Navegador enfocado en privacidad"; URL="https://laptop-updates.brave.com/latest/winx64"; Archivo="brave_installer.exe"},
    @{Categoria="Red"; Nombre="Wireshark"; Descripcion="Analizador de protocolos de red"; URL="https://www.wireshark.org/download/win64/Wireshark-win64-4.4.3.exe"; Archivo="wireshark_installer.exe"}
)

function Descargar-Herramienta {
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Tool,
        [string]$CarpetaDestino = $null
    )
    if (-not $CarpetaDestino) {
        $CarpetaDestino = Obtener-CarpetaHerramientas
        if (-not $CarpetaDestino) { return }
    }
    Clear-Host
    Write-Host "Descargando: $($Tool.Nombre)" -ForegroundColor Cyan
    Write-Host ("=" * 45) -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Descripcion : $($Tool.Descripcion)" -ForegroundColor White
    Write-Host "  Categoria   : $($Tool.Categoria)" -ForegroundColor White
    Write-Host "  Archivo     : $($Tool.Archivo)" -ForegroundColor White
    Write-Host "  Destino     : $CarpetaDestino" -ForegroundColor White
    Write-Host ""
    if (-not (Test-ConexionInternet)) {
        Write-Host "[ERROR] No hay conexion a Internet." -ForegroundColor Red
        Pause-Kit
        return
    }
    $rutaCompleta = Join-Path $CarpetaDestino $Tool.Archivo
    if (Test-Path $rutaCompleta) {
        $existente = Get-Item $rutaCompleta
        $tamanoMB = [math]::Round($existente.Length / 1MB, 2)
        Write-Host "[INFO] El archivo ya existe ($tamanoMB MB)." -ForegroundColor Yellow
        if (-not (Confirmar-Accion "Deseas re-descargarlo?")) {
            if (Confirmar-Accion "Abrir carpeta de descargas?") { Start-Process explorer.exe $CarpetaDestino }
            Pause-Kit
            return
        }
        Remove-Item $rutaCompleta -Force
    }
    Write-Host "Iniciando descarga..." -ForegroundColor Yellow
    $maxReintentos = 3
    $descargado = $false
    for ($intento = 1; $intento -le $maxReintentos; $intento++) {
        try {
            Write-Host "Intento $intento de $maxReintentos..." -ForegroundColor Gray
            $ProgressPreference = 'Continue'
            Invoke-WebRequest -Uri $Tool.URL -OutFile $rutaCompleta -UseBasicParsing -TimeoutSec 120 -ErrorAction Stop
            $archivoInfo = Get-Item $rutaCompleta
            if ($archivoInfo.Length -lt 1024) { throw "Archivo demasiado pequeno" }
            $tamanoFinal = [math]::Round($archivoInfo.Length / 1MB, 2)
            Write-Host "[OK] Descarga completada ($tamanoFinal MB)." -ForegroundColor Green
            Write-Host "  Ubicacion: $rutaCompleta" -ForegroundColor Cyan
            $descargado = $true
            break
        } catch {
            Write-Host "[FALLO] Intento ${intento}: $($_.Exception.Message)" -ForegroundColor Red
            if (Test-Path $rutaCompleta) { Remove-Item $rutaCompleta -Force -ErrorAction SilentlyContinue }
            if ($intento -lt $maxReintentos) {
                Write-Host "Reintentando en 3 segundos..." -ForegroundColor Yellow
                Start-Sleep -Seconds 3
            }
        }
    }
    if (-not $descargado) {
        Write-Host "[ERROR] No se pudo descargar despues de $maxReintentos intentos." -ForegroundColor Red
    }
    Write-Host ""
    if (Confirmar-Accion "Abrir carpeta de descargas?") { Start-Process explorer.exe $CarpetaDestino }
    Pause-Kit
}

function Descargar-CategoriaCompleta {
    param([string]$Categoria)
    $herramientas = $Script:ToolsTable | Where-Object { $_.Categoria -eq $Categoria }
    if ($herramientas.Count -eq 0) { return }
    $carpeta = Obtener-CarpetaHerramientas
    if (-not $carpeta) { return }
    Clear-Host
    Write-Host "Descarga Masiva: $Categoria" -ForegroundColor Cyan
    Write-Host ("=" * 45) -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Se descargaran $($herramientas.Count) herramientas:" -ForegroundColor Yellow
    foreach ($tool in $herramientas) { Write-Host "  - $($tool.Nombre)" -ForegroundColor White }
    Write-Host ""
    if (-not (Confirmar-Accion "Proceder con la descarga masiva?")) { return }
    $i = 1
    foreach ($tool in $herramientas) {
        Write-Host "[$i/$($herramientas.Count)] $($tool.Nombre)..." -ForegroundColor Yellow
        try {
            $ruta = Join-Path $carpeta $tool.Archivo
            if (Test-Path $ruta) { Write-Host "  [SKIP] Ya existe." -ForegroundColor Gray }
            else {
                Invoke-WebRequest -Uri $tool.URL -OutFile $ruta -UseBasicParsing -TimeoutSec 120 -ErrorAction Stop
                Write-Host "  [OK] Descargado." -ForegroundColor Green
            }
        } catch { Write-Host "  [ERROR] $($_.Exception.Message)" -ForegroundColor Red }
        $i++
    }
    Write-Host ""
    Write-Host "[OK] Descarga masiva completada." -ForegroundColor Green
    if (Confirmar-Accion "Abrir carpeta de descargas?") { Start-Process explorer.exe $carpeta }
    Pause-Kit
}

function SubMenu-Descargas {
    while ($true) {
        Mostrar-Header
        Write-Host "   [ SUBMENU: DESCARGA DE HERRAMIENTAS ]" -ForegroundColor Cyan
        Write-Host "=========================================" -ForegroundColor Magenta
        Write-Host ""
        Write-Host "  [DIAGNOSTICO Y HARDWARE]" -ForegroundColor Yellow
        Write-Host "  1  - HDDScan   2  - HWiNFO"
        Write-Host "  3  - CrystalDiskInfo   4  - MemTest86"
        Write-Host ""
        Write-Host "  [SISTEMA Y PROCESOS (Sysinternals)]" -ForegroundColor Yellow
        Write-Host "  5  - Autoruns   6  - Process Explorer   7  - Process Monitor"
        Write-Host ""
        Write-Host "  [UTILIDADES]" -ForegroundColor Yellow
        Write-Host "  8  - Everything   9  - Rufus"
        Write-Host "  10 - 7-Zip   11 - WinRAR"
        Write-Host ""
        Write-Host "  [INTERNET Y RED]" -ForegroundColor Yellow
        Write-Host "  12 - Brave Browser   13 - Wireshark"
        Write-Host ""
        Write-Host "  [DESCARGAS MASIVAS]" -ForegroundColor Green
        Write-Host "  14 - TODO Diagnostico   15 - TODO Sysinternals"
        Write-Host "  16 - TODO Utilidades    17 - TODO Red"
        Write-Host "  18 - TODO (Kit completo)"
        Write-Host ""
        Write-Host "  0  - Volver al menu principal"
        Write-Host ""
        $opcion = Read-Host "Selecciona una opcion"
        switch ($opcion) {
            {$_ -match '^[1-9]$' -or $_ -match '^1[0-3]$'} { 
                $idx = [int]$opcion - 1
                if ($idx -ge 0 -and $idx -lt $Script:ToolsTable.Count) { Descargar-Herramienta -Tool $Script:ToolsTable[$idx] }
            }
            "14" { Descargar-CategoriaCompleta -Categoria "Diagnostico" }
            "15" { Descargar-CategoriaCompleta -Categoria "Sysinternals" }
            "16" { Descargar-CategoriaCompleta -Categoria "Utilidades" }
            "17" { Descargar-CategoriaCompleta -Categoria "Red" }
            "18" { 
                if (Confirmar-Accion "Descargar TODAS las herramientas?") {
                    foreach ($cat in @("Diagnostico","Sysinternals","Utilidades","Red")) { Descargar-CategoriaCompleta -Categoria $cat }
                }
            }
            "0" { return }
            default { Write-Host "Opcion invalida." -ForegroundColor Red; Start-Sleep -Seconds 1 }
        }
    }
}
