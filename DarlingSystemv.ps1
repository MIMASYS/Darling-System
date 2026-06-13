# Forzar codificación UTF-8 en la consola
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

# Forzar TLS 1.2 para descargas modernas (critico para sitios actuales)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Clear-Host

# Verificar si se ejecuta como Administrador
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ADVERTENCIA: Se recomienda ejecutar este script como Administrador." -ForegroundColor Yellow
    Write-Host "Algunas opciones (SFC, DISM, Discos, BIOS/Boot, Optimizacion) requeriran permisos elevados." -ForegroundColor Yellow
    Start-Sleep -Seconds 3
}

# ============================================================
# FUNCIONES AUXILIARES
# ============================================================

function Pause-Kit { 
    Write-Host ""
    Read-Host "Presiona ENTER para volver al menu" 
}

function Confirmar-Accion {
    param([string]$Mensaje = "Deseas continuar?")
    Write-Host ""
    Write-Host "$Mensaje (s/n): " -ForegroundColor Yellow -NoNewline
    $respuesta = Read-Host
    if ($respuesta -in @('s', 'S', 'si', 'Si', 'SI')) {
        return $true
    }
    return $false
}

function Mostrar-Header {
    Clear-Host
    Write-Host "=========================================" -ForegroundColor Magenta
    Write-Host "            ❤ DARLING SYSTEM ❤" -ForegroundColor Magenta
    Write-Host "        Version CherryRed Flavor 3.1" -ForegroundColor Magenta
    Write-Host "=========================================" -ForegroundColor Magenta
    Write-Host "           Dirty and dummy system" -ForegroundColor Magenta
    Write-Host "          Created by: MIMASYS. Chu." -ForegroundColor Magenta
    Write-Host "=========================================" -ForegroundColor Magenta
}

function Test-ConexionInternet {
    try {
        $resultado = Test-Connection -ComputerName "8.8.8.8" -Count 1 -Quiet -ErrorAction SilentlyContinue
        return $resultado
    } catch {
        return $false
    }
}

function Seleccionar-Unidad {
    Clear-Host
    Write-Host "Seleccionar Unidad de Descarga" -ForegroundColor Cyan
    Write-Host "==============================" -ForegroundColor Cyan
    Write-Host ""
    
    $volumes = Get-Volume | Where-Object { $_.DriveLetter -and $_.DriveType -eq 'Fixed' -and $_.HealthStatus -eq 'Healthy' }
    
    if ($volumes.Count -eq 0) {
        Write-Host "[ERROR] No se encontraron unidades disponibles." -ForegroundColor Red
        Pause-Kit
        return $null
    }
    
    Write-Host "Unidades disponibles:" -ForegroundColor Yellow
    $i = 1
    foreach ($vol in $volumes) {
        $freeGB = [math]::Round($vol.SizeRemaining / 1GB, 2)
        $totalGB = [math]::Round($vol.Size / 1GB, 2)
        $percent = [math]::Round(($vol.SizeRemaining / $vol.Size) * 100, 0)
        $color = if ($percent -lt 20) { 'Red' } elseif ($percent -lt 50) { 'Yellow' } else { 'Green' }
        Write-Host "  $i - $($vol.DriveLetter): [$percent% libre] $freeGB GB / $totalGB GB" -ForegroundColor $color
        $i++
    }
    Write-Host ""
    
    $seleccion = Read-Host "Selecciona el numero de la unidad"
    
    if ($seleccion -match '^\d+$' -and [int]$seleccion -ge 1 -and [int]$seleccion -le $volumes.Count) {
        $unidadSeleccionada = $volumes[[int]$seleccion - 1].DriveLetter
        Write-Host ""
        Write-Host "[OK] Unidad seleccionada: $($unidadSeleccionada):\" -ForegroundColor Green
        return "$($unidadSeleccionada):\"
    } else {
        Write-Host "[ERROR] Seleccion invalida." -ForegroundColor Red
        Pause-Kit
        return $null
    }
}

# ============================================================
# TABLA DE HERRAMIENTAS (Centralizada y escalable)
# ============================================================

$Script:ToolsTable = @(
    @{
        Categoria = "Diagnostico"
        Nombre = "HDDScan"
        Descripcion = "Diagnostico avanzado de discos duros"
        URL = "https://hddscan.com/download/HDDScan-4.1.zip"
        Archivo = "HDDScan-4.1.zip"
    },
    @{
        Categoria = "Diagnostico"
        Nombre = "HWiNFO"
        Descripcion = "Informacion completa de hardware"
        URL = "https://www.sac.sk/download/utildiag/hwi_792.zip"
        Archivo = "HWiNFO_Portable.zip"
    },
    @{
        Categoria = "Diagnostico"
        Nombre = "CrystalDiskInfo"
        Descripcion = "Salud S.M.A.R.T. de discos SSD/HDD"
        URL = "https://osdn.net/frs/redir.php?m=auto&f=%2Fcrystaldiskinfo%2F94272%2FCrystalDiskInfo9_4_1.zip"
        Archivo = "CrystalDiskInfo.zip"
    },
    @{
        Categoria = "Diagnostico"
        Nombre = "MemTest86"
        Descripcion = "Prueba exhaustiva de memoria RAM (ISO)"
        URL = "https://www.memtest86.com/downloads/memtest86-usb.zip"
        Archivo = "memtest86-usb.zip"
    },
    @{
        Categoria = "Sysinternals"
        Nombre = "Autoruns"
        Descripcion = "Gestor avanzado de programas de inicio"
        URL = "https://download.sysinternals.com/files/Autoruns.zip"
        Archivo = "Autoruns.zip"
    },
    @{
        Categoria = "Sysinternals"
        Nombre = "Process Explorer"
        Descripcion = "Administrador de tareas avanzado"
        URL = "https://download.sysinternals.com/files/ProcessExplorer.zip"
        Archivo = "ProcessExplorer.zip"
    },
    @{
        Categoria = "Sysinternals"
        Nombre = "Process Monitor"
        Descripcion = "Monitor de actividad de procesos y registro"
        URL = "https://download.sysinternals.com/files/ProcessMonitor.zip"
        Archivo = "ProcessMonitor.zip"
    },
    @{
        Categoria = "Utilidades"
        Nombre = "Everything"
        Descripcion = "Busqueda instantanea de archivos"
        URL = "https://www.voidtools.com/Everything-1.4.1.1026.x86-Setup.exe"
        Archivo = "Everything-Setup.exe"
    },
    @{
        Categoria = "Utilidades"
        Nombre = "Rufus"
        Descripcion = "Creador de USBs booteables"
        URL = "https://github.com/pbatard/rufus/releases/download/v4.9/rufus-4.9.exe"
        Archivo = "rufus.exe"
    },
    @{
        Categoria = "Utilidades"
        Nombre = "7-Zip"
        Descripcion = "Compresor de archivos open-source"
        URL = "https://www.7-zip.org/a/7z2409-x64.exe"
        Archivo = "7zip_installer.exe"
    },
    @{
        Categoria = "Utilidades"
        Nombre = "WinRAR"
        Descripcion = "Compresor de archivos clasico"
        URL = "https://www.rarlab.com/rar/winrar-x64-710.exe"
        Archivo = "winrar_installer.exe"
    },
    @{
        Categoria = "Red"
        Nombre = "Brave Browser"
        Descripcion = "Navegador enfocado en privacidad"
        URL = "https://laptop-updates.brave.com/latest/winx64"
        Archivo = "brave_installer.exe"
    },
    @{
        Categoria = "Red"
        Nombre = "Wireshark"
        Descripcion = "Analizador de protocolos de red"
        URL = "https://www.wireshark.org/download/win64/Wireshark-win64-4.4.3.exe"
        Archivo = "wireshark_installer.exe"
    }
)

# ============================================================
# FUNCION DE DESCARGA OPTIMIZADA
# ============================================================

function Descargar-Herramienta {
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Tool,
        [string]$CarpetaDestino = $null
    )
    
    # Si no se especifica carpeta, preguntar al usuario
    if (-not $CarpetaDestino) {
        $unidad = Seleccionar-Unidad
        if (-not $unidad) { return }
        $CarpetaDestino = Join-Path $unidad "DarlingTools"
    }
    
    if (-not (Test-Path $CarpetaDestino)) { 
        New-Item -ItemType Directory -Path $CarpetaDestino -Force | Out-Null 
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
    
    # Verificar conexion antes de descargar
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
        if (-not (Confirmar-Accion "¿Deseas re-descargarlo?")) {
            if (Confirmar-Accion "¿Abrir carpeta de descargas?") {
                Start-Process explorer.exe $CarpetaDestino
            }
            Pause-Kit
            return
        }
        Remove-Item $rutaCompleta -Force
    }
    
    Write-Host "Iniciando descarga..." -ForegroundColor Yellow
    Write-Host ""
    
    $maxReintentos = 3
    $descargado = $false
    
    for ($intento = 1; $intento -le $maxReintentos; $intento++) {
        try {
            Write-Host "Intento $intento de $maxReintentos..." -ForegroundColor Gray
            
            # Metodo 1: Invoke-WebRequest con progreso
            $ProgressPreference = 'Continue'
            Invoke-WebRequest -Uri $Tool.URL -OutFile $rutaCompleta -UseBasicParsing -TimeoutSec 120 -ErrorAction Stop
            
            # Validar que el archivo no esté vacío
            $archivoInfo = Get-Item $rutaCompleta
            if ($archivoInfo.Length -lt 1024) {
                throw "El archivo descargado es demasiado pequeño (posible error)"
            }
            
            $tamanoFinal = [math]::Round($archivoInfo.Length / 1MB, 2)
            Write-Host ""
            Write-Host "[OK] Descarga completada exitosamente ($tamanoFinal MB)." -ForegroundColor Green
            Write-Host "  Ubicacion: $rutaCompleta" -ForegroundColor Cyan
            
            $descargado = $true
            break
        } catch {
            Write-Host "[FALLO] Intento $intento falló: $($_.Exception.Message)" -ForegroundColor Red
            if (Test-Path $rutaCompleta) { Remove-Item $rutaCompleta -Force -ErrorAction SilentlyContinue }
            if ($intento -lt $maxReintentos) {
                Write-Host "Reintentando en 3 segundos..." -ForegroundColor Yellow
                Start-Sleep -Seconds 3
            }
        }
    }
    
    if (-not $descargado) {
        Write-Host ""
        Write-Host "[ERROR] No se pudo descargar despues de $maxReintentos intentos." -ForegroundColor Red
        Write-Host "  Posibles causas: URL obsoleta, servidor caido, bloqueo de red." -ForegroundColor Yellow
        Write-Host "  URL original: $($Tool.URL)" -ForegroundColor Gray
    }
    
    Write-Host ""
    if (Confirmar-Accion "¿Abrir carpeta de descargas?") {
        Start-Process explorer.exe $CarpetaDestino
    }
    
    Pause-Kit
}

function Descargar-CategoriaCompleta {
    param([string]$Categoria)
    
    $herramientas = $Script:ToolsTable | Where-Object { $_.Categoria -eq $Categoria }
    
    if ($herramientas.Count -eq 0) { return }
    
    $unidad = Seleccionar-Unidad
    if (-not $unidad) { return }
    $carpeta = Join-Path $unidad "DarlingTools"
    if (-not (Test-Path $carpeta)) { New-Item -ItemType Directory -Path $carpeta -Force | Out-Null }
    
    Clear-Host
    Write-Host "Descarga Masiva: $Categoria" -ForegroundColor Cyan
    Write-Host ("=" * 45) -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Se descargarán $($herramientas.Count) herramientas:" -ForegroundColor Yellow
    foreach ($tool in $herramientas) {
        Write-Host "  - $($tool.Nombre)" -ForegroundColor White
    }
    Write-Host ""
    
    if (-not (Confirmar-Accion "¿Proceder con la descarga masiva?")) { return }
    
    $i = 1
    foreach ($tool in $herramientas) {
        Write-Host ""
        Write-Host "[$i/$($herramientas.Count)] $($tool.Nombre)..." -ForegroundColor Yellow
        
        try {
            $ruta = Join-Path $carpeta $tool.Archivo
            if (Test-Path $ruta) {
                Write-Host "  [SKIP] Ya existe." -ForegroundColor Gray
            } else {
                Invoke-WebRequest -Uri $tool.URL -OutFile $ruta -UseBasicParsing -TimeoutSec 120 -ErrorAction Stop
                Write-Host "  [OK] Descargado." -ForegroundColor Green
            }
        } catch {
            Write-Host "  [ERROR] $($_.Exception.Message)" -ForegroundColor Red
        }
        $i++
    }
    
    Write-Host ""
    Write-Host "[OK] Descarga masiva completada." -ForegroundColor Green
    
    if (Confirmar-Accion "¿Abrir carpeta de descargas?") {
        Start-Process explorer.exe $carpeta
    }
    
    Pause-Kit
}

# ============================================================
# FUNCIONES DE UTILIDADES DEL SISTEMA
# ============================================================

function Util-InfoSistema {
    Clear-Host
    Write-Host "Informacion Completa del Sistema" -ForegroundColor Cyan
    Write-Host "=================================" -ForegroundColor Cyan
    Write-Host ""
    
    $os = Get-CimInstance Win32_OperatingSystem
    Write-Host "[SISTEMA OPERATIVO]" -ForegroundColor Yellow
    Write-Host "  Sistema      : $($os.Caption)"
    Write-Host "  Version      : $($os.Version)"
    Write-Host "  Arquitectura : $($os.OSArchitecture)"
    Write-Host ""
    
    $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
    Write-Host "[PROCESADOR]" -ForegroundColor Yellow
    Write-Host "  Modelo        : $($cpu.Name)"
    Write-Host "  Nucleos       : $($cpu.NumberOfCores)"
    Write-Host "  Hilos         : $($cpu.NumberOfLogicalProcessors)"
    Write-Host ""
    
    $ram = Get-CimInstance Win32_PhysicalMemory
    $totalRam = ($ram | Measure-Object -Property Capacity -Sum).Sum / 1GB
    Write-Host "[MEMORIA RAM]" -ForegroundColor Yellow
    Write-Host "  Total         : $([math]::Round($totalRam, 2)) GB"
    Write-Host "  Slots usados  : $($ram.Count)"
    Write-Host ""
    
    $gpu = Get-CimInstance Win32_VideoController
    Write-Host "[TARJETA GRAFICA]" -ForegroundColor Yellow
    foreach ($g in $gpu) {
        Write-Host "  GPU           : $($g.Name)"
        Write-Host "  VRAM          : $([math]::Round($g.AdapterRAM / 1MB, 2)) MB"
    }
    Write-Host ""
    Pause-Kit
}

function Util-EstadoRAM {
    Clear-Host
    Write-Host "Estado Detallado de la RAM" -ForegroundColor Cyan
    Write-Host "==========================" -ForegroundColor Cyan
    Write-Host ""
    
    $os = Get-CimInstance Win32_OperatingSystem
    $total = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    $free  = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
    $used  = [math]::Round($total - $free, 2)
    $percent = [math]::Round(($used / $total) * 100, 2)
    
    Write-Host "[USO ACTUAL]" -ForegroundColor Yellow
    Write-Host "  Total       : $total GB"
    Write-Host "  Usada       : $used GB ($percent%)"
    Write-Host "  Libre       : $free GB"
    Write-Host ""
    
    $typeMap = @{
        20 = "DDR"; 21 = "DDR2"; 24 = "DDR3"; 26 = "DDR4"; 34 = "DDR5"
    }

    $ram = Get-CimInstance Win32_PhysicalMemory
    Write-Host "[MODULOS INSTALADOS]" -ForegroundColor Yellow
    $i = 1
    foreach ($module in $ram) {
        $ramType = if ($typeMap.ContainsKey($module.SMBIOSMemoryType)) { $typeMap[$module.SMBIOSMemoryType] } else { "Desconocido" }
        Write-Host "  Modulo $i : $([math]::Round($module.Capacity / 1GB, 2)) GB | $ramType | $($module.Speed) MHz | $($module.Manufacturer)" -ForegroundColor Green
        $i++
    }
    Write-Host ""
    Pause-Kit
}

function Util-EstadoCPU {
    Clear-Host
    Write-Host "Estado Detallado del CPU" -ForegroundColor Cyan
    Write-Host "========================" -ForegroundColor Cyan
    Write-Host ""
    
    $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
    
    Write-Host "[INFORMACION GENERAL]" -ForegroundColor Yellow
    Write-Host "  Modelo              : $($cpu.Name)"
    Write-Host "  Nucleos fisicos     : $($cpu.NumberOfCores)"
    Write-Host "  Nucleos logicos     : $($cpu.NumberOfLogicalProcessors)"
    Write-Host "  Frecuencia max      : $($cpu.MaxClockSpeed) MHz"
    Write-Host "  Carga actual        : $($cpu.LoadPercentage) %" -ForegroundColor $(if ($cpu.LoadPercentage -gt 80) { 'Red' } else { 'Green' })
    Write-Host ""
    Pause-Kit
}

function Util-DireccionesIP {
    Clear-Host
    Write-Host "Informacion de Red Detallada" -ForegroundColor Cyan
    Write-Host "============================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "[CONFIGURACION IP]" -ForegroundColor Yellow
    $adapters = Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object {$_.IPEnabled}
    foreach ($adapter in $adapters) {
        Write-Host "  Adaptador: $($adapter.Description)" -ForegroundColor Green
        Write-Host "    IP            : $($adapter.IPAddress[0])"
        Write-Host "    Mascara       : $($adapter.IPSubnet[0])"
        Write-Host "    Gateway       : $($adapter.DefaultIPGateway)"
        Write-Host "    DNS Servers   : $($adapter.DNSServerSearchOrder -join ', ')"
        Write-Host ""
    }
    Pause-Kit
}

function Util-ProbarInternet {
    Clear-Host
    Write-Host "Prueba de Conexion a Internet" -ForegroundColor Cyan
    Write-Host "=============================" -ForegroundColor Cyan
    Write-Host ""
    
    $tests = @(
        @{Name="Google DNS (8.8.8.8)"; Address="8.8.8.8"},
        @{Name="Cloudflare DNS (1.1.1.1)"; Address="1.1.1.1"},
        @{Name="Google.com"; Address="google.com"}
    )
    
    foreach ($test in $tests) {
        Write-Host "  Probando $($test.Name)..." -NoNewline
        $result = Test-Connection -ComputerName $test.Address -Count 2 -Quiet -ErrorAction SilentlyContinue
        if ($result) {
            Write-Host " [OK]" -ForegroundColor Green
        } else {
            Write-Host " [FALLO]" -ForegroundColor Red
        }
    }
    Write-Host ""
    Pause-Kit
}

function Util-ProcesosPesados {
    Clear-Host
    Write-Host "Procesos del Sistema - Analisis Completo" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "[TOP 15 POR MEMORIA]" -ForegroundColor Yellow
    Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 15 | 
        Format-Table @{Label="Nombre"; Expression={$_.ProcessName}},
                    @{Label="PID"; Expression={$_.Id}},
                    @{Label="Memoria (MB)"; Expression={[math]::Round($_.WorkingSet / 1MB, 2)}} -AutoSize
    
    Write-Host ""
    Write-Host "[RESUMEN DEL SISTEMA]" -ForegroundColor Yellow
    Write-Host "  Total procesos  : $((Get-Process).Count)"
    Write-Host ""
    Pause-Kit
}

function Util-HyperV {
    Clear-Host
    Write-Host "Estado de Hyper-V" -ForegroundColor Cyan
    Write-Host "=================" -ForegroundColor Cyan
    Write-Host ""
    
    $service = Get-Service vmms -ErrorAction SilentlyContinue
    if ($service) {
        Write-Host "[SERVICIO HYPER-V]" -ForegroundColor Yellow
        Write-Host "  Estado      : $($service.Status)"
        Write-Host ""
        try {
            $vms = Get-VM -ErrorAction Stop
            Write-Host "[MAQUINAS VIRTUALES]" -ForegroundColor Yellow
            if ($vms) {
                $vms | Format-Table Name, State, CPUUsage, MemoryAssigned -AutoSize
            } else {
                Write-Host "  No hay maquinas virtuales creadas" -ForegroundColor Gray
            }
        } catch {
            Write-Host "No se pudo obtener informacion de las VMs" -ForegroundColor Red
        }
    } else {
        Write-Host "Hyper-V no esta instalado o no esta disponible" -ForegroundColor Yellow
    }
    Write-Host ""
    Pause-Kit
}

function Util-Bateria {
    Clear-Host
    Write-Host "Estado de la Bateria" -ForegroundColor Cyan
    Write-Host "====================" -ForegroundColor Cyan
    Write-Host ""
    
    $battery = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue
    if ($battery) {
        foreach ($bat in $battery) {
            Write-Host "[INFORMACION]" -ForegroundColor Yellow
            Write-Host "  Fabricante    : $($bat.Manufacturer)"
            Write-Host "  Carga actual  : $($bat.EstimatedChargeRemaining)%"
            Write-Host "  Tiempo resto  : $($bat.EstimatedRunTime) minutos"
        }
    } else {
        Write-Host "No se detecto bateria (PC de escritorio o error de lectura)" -ForegroundColor Yellow
    }
    Write-Host ""
    Pause-Kit
}

function Util-ServiciosCriticos {
    Clear-Host
    Write-Host "Servicios Criticos del Sistema" -ForegroundColor Cyan
    Write-Host "==============================" -ForegroundColor Cyan
    Write-Host ""
    
    $criticalServices = @("wuauserv", "BITS", "wscsvc", "WinDefend", "Dnscache", "Dhcp", "EventLog")
    
    Write-Host "[ESTADO DE SERVICIOS]" -ForegroundColor Yellow
    foreach ($svc in $criticalServices) {
        $service = Get-Service $svc -ErrorAction SilentlyContinue
        if ($service) {
            $status = if ($service.Status -eq "Running") { "[OK]" } else { "[STOP]" }
            $color = if ($service.Status -eq "Running") { "Green" } else { "Red" }
            Write-Host "  $($service.DisplayName)" -NoNewline
            Write-Host " $status" -ForegroundColor $color
        }
    }
    Write-Host ""
    Pause-Kit
}

function Util-EventosRecientes {
    Clear-Host
    Write-Host "Eventos Recientes del Sistema" -ForegroundColor Cyan
    Write-Host "=============================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "[ERRORES CRITICOS (Ultimos 5)]" -ForegroundColor Yellow
    Get-EventLog -LogName System -EntryType Error -Newest 5 -ErrorAction SilentlyContinue | 
        Format-Table TimeGenerated, Source, @{Label="Mensaje"; Expression={$_.Message.Substring(0, [Math]::Min(60, $_.Message.Length))}} -AutoSize
    
    Write-Host ""
    Pause-Kit
}

# ============================================================
# FUNCIONES DE HERRAMIENTAS
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

# ============================================================
# FUNCIONES DE MANTENIMIENTO
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
    Write-Host "ADVERTENCIA: SFC puede tardar varios minutos. No cierres esta ventana." -ForegroundColor Yellow
    sfc /scannow
    Pause-Kit
}

function Mant-DISM {
    Clear-Host
    Write-Host "ADVERTENCIA: DISM puede tardar varios minutos. No cierres esta ventana." -ForegroundColor Yellow
    DISM /Online /Cleanup-Image /RestoreHealth
    Pause-Kit
}

# ============================================================
# FUNCIONES DE GESTION DE DISCOS
# ============================================================

function Discos-EstadoDetallado {
    Clear-Host
    Write-Host "Estado Detallado de Discos" -ForegroundColor Cyan
    Write-Host "==========================" -ForegroundColor Cyan
    Write-Host ""
    
    $disks = Get-CimInstance Win32_DiskDrive
    Write-Host "[DISCOS FISICOS]" -ForegroundColor Yellow
    foreach ($disk in $disks) {
        $sizeGB = [math]::Round($disk.Size / 1GB, 2)
        Write-Host "  Disco: $($disk.Model) - $sizeGB GB ($($disk.MediaType))" -ForegroundColor Green
    }
    Write-Host ""
    
    Write-Host "[VOLUMENES Y PARTICIONES]" -ForegroundColor Yellow
    Get-Volume | Where-Object DriveLetter | Format-Table `
        @{Label="Unidad"; Expression={$_.DriveLetter}},
        @{Label="Etiqueta"; Expression={$_.FileSystemLabel}},
        @{Label="Sistema"; Expression={$_.FileSystem}},
        @{Label="Libre (GB)"; Expression={[math]::Round($_.SizeRemaining / 1GB, 2)}},
        @{Label="Total (GB)"; Expression={[math]::Round($_.Size / 1GB, 2)}},
        @{Label="Uso (%)"; Expression={[math]::Round(($_.Size - $_.SizeRemaining) / $_.Size * 100, 2)}} -AutoSize
    
    Write-Host ""
    Pause-Kit
}

function Discos-ListarDiscos {
    Clear-Host
    Write-Host "Discos Fisicos Conectados" -ForegroundColor Cyan
    Write-Host "=========================" -ForegroundColor Cyan
    Write-Host ""
    Get-Disk | Format-Table Number, FriendlyName, @{Label="Size(GB)"; Expression={[math]::Round($_.Size/1GB,2)}}, MediaType, BusType, OperationalStatus -AutoSize
    Pause-Kit
}

function Discos-ListarVolumenes {
    Clear-Host
    Write-Host "Volumenes y Particiones" -ForegroundColor Cyan
    Write-Host "=======================" -ForegroundColor Cyan
    Write-Host ""
    Get-Volume | Format-Table DriveLetter, FileSystemLabel, FileSystem, @{Label="Free(GB)"; Expression={[math]::Round($_.SizeRemaining/1GB,2)}}, @{Label="Size(GB)"; Expression={[math]::Round($_.Size/1GB,2)}}, HealthStatus -AutoSize
    Pause-Kit
}

function Discos-QuitarSoloLectura {
    Clear-Host
    Write-Host "Quitar atributo 'Solo Lectura' de USB/Disco" -ForegroundColor Cyan
    Write-Host "===========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Lista de discos:" -ForegroundColor Yellow
    Get-Disk | Where-Object BusType -ne "File Backed Virtual" | Format-Table Number, FriendlyName, Size -AutoSize
    
    $num = Read-Host "Escribe el NUMERO del disco a reparar"
    if ($num -match '^\d+$') {
        Write-Host "Quitando modo Solo Lectura del disco $num..." -ForegroundColor Yellow
        Set-Disk -Number $num -IsReadOnly $false -ErrorAction SilentlyContinue
        Write-Host "[OK] Atributo de Solo Lectura eliminado." -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Numero invalido." -ForegroundColor Red
    }
    Pause-Kit
}

function Discos-QuitarOculto {
    Clear-Host
    Write-Host "Quitar atributo 'Oculto' de USB/Disco" -ForegroundColor Cyan
    Write-Host "======================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Lista de discos:" -ForegroundColor Yellow
    Get-Disk | Where-Object BusType -ne "File Backed Virtual" | Format-Table Number, FriendlyName, Size -AutoSize
    
    $num = Read-Host "Escribe el NUMERO del disco a reparar"
    if ($num -match '^\d+$') {
        Write-Host "Quitando modo Oculto de las particiones del disco $num..." -ForegroundColor Yellow
        Get-Partition -DiskNumber $num | Set-Partition -IsHidden $false -ErrorAction SilentlyContinue
        Write-Host "[OK] Atributo Oculto eliminado." -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Numero invalido." -ForegroundColor Red
    }
    Pause-Kit
}

function Discos-Limpiar {
    Clear-Host
    Write-Host "LIMPIAR DISCO (Borra TODOS los datos)" -ForegroundColor Red
    Write-Host "=====================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Lista de discos:" -ForegroundColor Yellow
    Get-Disk | Where-Object BusType -ne "File Backed Virtual" | Format-Table Number, FriendlyName, Size -AutoSize
    
    $num = Read-Host "Escribe el NUMERO del disco a LIMPIAR"
    if ($num -match '^\d+$') {
        if (Confirmar-Accion "¿Estas SEGURO de borrar TODO el disco $num? Esta accion es irreversible") {
            Write-Host "Limpiando disco $num..." -ForegroundColor Yellow
            Clear-Disk -Number $num -RemoveData -RemoveOEM -Confirm:$false -ErrorAction SilentlyContinue
            Write-Host "[OK] Disco limpiado y convertido en espacio no asignado." -ForegroundColor Green
        }
    } else {
        Write-Host "[ERROR] Numero invalido." -ForegroundColor Red
    }
    Pause-Kit
}

function Discos-Formatear {
    Clear-Host
    Write-Host "Formatear Volumen (NTFS Rapido)" -ForegroundColor Cyan
    Write-Host "===============================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Volumenes disponibles:" -ForegroundColor Yellow
    Get-Volume | Where-Object DriveLetter | Format-Table DriveLetter, FileSystemLabel, FileSystem, Size -AutoSize
    
    $letter = Read-Host "Escribe la LETRA de la unidad a formatear (ej: E)"
    if ($letter -match '^[a-zA-Z]$') {
        if (Confirmar-Accion "¿Formatear la unidad $letter`:? Se perderan todos los archivos") {
            Write-Host "Formateando $letter`:... " -ForegroundColor Yellow
            Format-Volume -DriveLetter $letter -FileSystem NTFS -NewFileSystemLabel "DarlingUSB" -Confirm:$false -ErrorAction SilentlyContinue
            Write-Host "[OK] Unidad $letter` formateada correctamente." -ForegroundColor Green
        }
    } else {
        Write-Host "[ERROR] Letra invalida." -ForegroundColor Red
    }
    Pause-Kit
}

# ============================================================
# FUNCIONES DE ARRANQUE (BOOT/BIOS)
# ============================================================

function Boot-ReiniciarBIOS {
    Clear-Host
    Write-Host "Reiniciar en BIOS/UEFI" -ForegroundColor Cyan
    Write-Host "======================" -ForegroundColor Cyan
    Write-Host ""
    
    $isUEFI = (bcdedit /enum {current} | Select-String -Pattern "path.*\.efi") -ne $null
    
    if (-not $isUEFI) {
        Write-Host "[ERROR] Tu sistema parece usar BIOS Legacy (no UEFI)." -ForegroundColor Red
        Write-Host "  El reinicio directo a BIOS solo funciona en sistemas UEFI." -ForegroundColor Red
        Write-Host ""
        if (Confirmar-Accion "¿Reiniciar de todas formas? (presiona F2 o SUPR rapidamente)") {
            Write-Host "Reiniciando en 5 segundos..." -ForegroundColor Yellow
            Start-Sleep -Seconds 5
            shutdown.exe /r /f /t 0
        }
        return
    }
    
    Write-Host "Este comando reiniciara la PC y entrara DIRECTO a la BIOS/UEFI." -ForegroundColor Yellow
    Write-Host "Guarda tu trabajo antes de continuar." -ForegroundColor Yellow
    Write-Host ""
    
    if (Confirmar-Accion "¿Reiniciar ahora y entrar a la BIOS?") {
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
    
    Write-Host "[OPCIONES DISPONIBLES EN EL MENU AZUL]" -ForegroundColor Yellow
    Write-Host "  - Continuar (Windows 10/11)"
    Write-Host "  - Usar un dispositivo (USB/DVD)"
    Write-Host "  - Solucionar problemas"
    Write-Host "    * Restablecer PC"
    Write-Host "    * Opciones avanzadas"
    Write-Host "      - Restaurar sistema"
    Write-Host "      - Configuracion de firmware UEFI (BIOS)"
    Write-Host "      - Configuracion de inicio (Modo Seguro)"
    Write-Host "      - Simbolo del sistema"
    Write-Host ""
    
    Write-Host "Guarda tu trabajo antes de continuar." -ForegroundColor Yellow
    Write-Host ""
    
    if (Confirmar-Accion "¿Reiniciar ahora en el Menu de Arranque Avanzado?") {
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
    
    $safeBootValue = switch ($tipo) {
        "1" { "minimal" }
        "2" { "network" }
        "3" { "dsrepair" }
        default { $null }
    }
    
    if ($safeBootValue) {
        Write-Host ""
        Write-Host "NOTA: Para salir del Modo Seguro despues, ejecuta:" -ForegroundColor Yellow
        Write-Host "  bcdedit /deletevalue {current} safeboot" -ForegroundColor Cyan
        Write-Host ""
        
        if (Confirmar-Accion "¿Configurar Modo Seguro y reiniciar?") {
            Write-Host "Configurando Modo Seguro..." -ForegroundColor Yellow
            bcdedit /set {current} safeboot $safeBootValue | Out-Null
            Write-Host "Reiniciando en 3 segundos..." -ForegroundColor Yellow
            Start-Sleep -Seconds 3
            shutdown.exe /r /f /t 0
        }
    } else {
        Write-Host "[ERROR] Opcion invalida." -ForegroundColor Red
        Pause-Kit
    }
}

# ============================================================
# FUNCIONES DE OPTIMIZACION DE WINDOWS 11
# ============================================================

function Opt-DesactivarCopilot {
    Clear-Host
    Write-Host "Desactivar Copilot (AI integrada)" -ForegroundColor Cyan
    Write-Host "=================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Esta opcion desactivara Copilot de Windows 11 mediante el registro." -ForegroundColor Yellow
    Write-Host ""
    
    if (Confirmar-Accion "¿Desactivar Copilot?") {
        try {
            $path = "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot"
            if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
            Set-ItemProperty -Path $path -Name "TurnOffWindowsCopilot" -Value 1 -Type DWord -Force
            
            $path2 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot"
            if (-not (Test-Path $path2)) { New-Item -Path $path2 -Force | Out-Null }
            Set-ItemProperty -Path $path2 -Name "TurnOffWindowsCopilot" -Value 1 -Type DWord -Force
            
            Write-Host "[OK] Copilot desactivado correctamente." -ForegroundColor Green
            Write-Host "  Nota: Puede requerir reinicio para aplicar completamente." -ForegroundColor Yellow
        } catch {
            Write-Host "[ERROR] No se pudo desactivar Copilot: $_" -ForegroundColor Red
        }
        Pause-Kit
    }
}

function Opt-DesactivarWidgets {
    Clear-Host
    Write-Host "Desactivar Widgets" -ForegroundColor Cyan
    Write-Host "==================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Esta opcion ocultara el boton de Widgets de la barra de tareas." -ForegroundColor Yellow
    Write-Host ""
    
    if (Confirmar-Accion "¿Desactivar Widgets?") {
        try {
            $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
            Set-ItemProperty -Path $path -Name "TaskbarDa" -Value 0 -Type DWord -Force
            
            Write-Host "[OK] Widgets desactivados correctamente." -ForegroundColor Green
            Write-Host "  Nota: Puede requerir reinicio de Explorer para aplicar." -ForegroundColor Yellow
        } catch {
            Write-Host "[ERROR] No se pudo desactivar Widgets: $_" -ForegroundColor Red
        }
        Pause-Kit
    }
}

function Opt-DesactivarPhoneLink {
    Clear-Host
    Write-Host "Desactivar Phone Link" -ForegroundColor Cyan
    Write-Host "=====================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Esta opcion desinstalara la aplicacion Phone Link (Tu Telefono)." -ForegroundColor Yellow
    Write-Host ""
    
    if (Confirmar-Accion "¿Desinstalar Phone Link?") {
        try {
            Get-AppxPackage *Microsoft.YourPhone* | Remove-AppxPackage -ErrorAction SilentlyContinue
            Write-Host "[OK] Phone Link desinstalado correctamente." -ForegroundColor Green
        } catch {
            Write-Host "[ERROR] No se pudo desinstalar Phone Link: $_" -ForegroundColor Red
        }
        Pause-Kit
    }
}

function Opt-DesactivarXboxGameBar {
    Clear-Host
    Write-Host "Desactivar Xbox Game Bar" -ForegroundColor Cyan
    Write-Host "========================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Esta opcion desactivara Xbox Game Bar y Game DVR." -ForegroundColor Yellow
    Write-Host ""
    
    if (Confirmar-Accion "¿Desactivar Xbox Game Bar?") {
        try {
            $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR"
            if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
            Set-ItemProperty -Path $path -Name "AppCaptureEnabled" -Value 0 -Type DWord -Force
            
            $path2 = "HKCU:\System\GameConfigStore"
            Set-ItemProperty -Path $path2 -Name "GameDVR_Enabled" -Value 0 -Type DWord -Force
            
            Write-Host "[OK] Xbox Game Bar desactivado correctamente." -ForegroundColor Green
        } catch {
            Write-Host "[ERROR] No se pudo desactivar Xbox Game Bar: $_" -ForegroundColor Red
        }
        Pause-Kit
    }
}

function Opt-DesactivarTips {
    Clear-Host
    Write-Host "Desactivar Tips y Sugerencias" -ForegroundColor Cyan
    Write-Host "=============================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Esta opcion desactivara las sugerencias y tips de Windows." -ForegroundColor Yellow
    Write-Host ""
    
    if (Confirmar-Accion "¿Desactivar Tips y Sugerencias?") {
        try {
            $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
            Set-ItemProperty -Path $path -Name "SubscribedContent-338389Enabled" -Value 0 -Type DWord -Force
            Set-ItemProperty -Path $path -Name "SoftLandingEnabled" -Value 0 -Type DWord -Force
            Set-ItemProperty -Path $path -Name "SubscribedContent-310093Enabled" -Value 0 -Type DWord -Force
            
            Write-Host "[OK] Tips y Sugerencias desactivados correctamente." -ForegroundColor Green
        } catch {
            Write-Host "[ERROR] No se pudo desactivar Tips: $_" -ForegroundColor Red
        }
        Pause-Kit
    }
}

function Opt-DesactivarPublicidad {
    Clear-Host
    Write-Host "Desactivar Publicidad del Sistema" -ForegroundColor Cyan
    Write-Host "=================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Esta opcion desactivara la publicidad y sugerencias de Windows." -ForegroundColor Yellow
    Write-Host ""
    
    if (Confirmar-Accion "¿Desactivar Publicidad del Sistema?") {
        try {
            $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
            Set-ItemProperty -Path $path -Name "ContentDeliveryAllowed" -Value 0 -Type DWord -Force
            Set-ItemProperty -Path $path -Name "OemPreInstalledAppsEnabled" -Value 0 -Type DWord -Force
            Set-ItemProperty -Path $path -Name "PreInstalledAppsEnabled" -Value 0 -Type DWord -Force
            Set-ItemProperty -Path $path -Name "PreInstalledAppsEverEnabled" -Value 0 -Type DWord -Force
            Set-ItemProperty -Path $path -Name "SilentInstalledAppsEnabled" -Value 0 -Type DWord -Force
            
            $path2 = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
            Set-ItemProperty -Path $path2 -Name "ShowSyncProviderNotifications" -Value 0 -Type DWord -Force
            
            $path3 = "HKCU:\Software\Policies\Microsoft\Windows\CloudContent"
            if (-not (Test-Path $path3)) { New-Item -Path $path3 -Force | Out-Null }
            Set-ItemProperty -Path $path3 -Name "DisableWindowsConsumerFeatures" -Value 1 -Type DWord -Force
            
            Write-Host "[OK] Publicidad del sistema desactivada correctamente." -ForegroundColor Green
        } catch {
            Write-Host "[ERROR] No se pudo desactivar publicidad: $_" -ForegroundColor Red
        }
        Pause-Kit
    }
}

function Opt-DesactivarAppsPreinstaladas {
    Clear-Host
    Write-Host "Desinstalar Apps Preinstaladas No Criticas" -ForegroundColor Cyan
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Esta opcion desinstalara aplicaciones bloatware comunes:" -ForegroundColor Yellow
    Write-Host "  - Candy Crush"
    Write-Host "  - Disney+"
    Write-Host "  - Spotify"
    Write-Host "  - TikTok"
    Write-Host "  - Instagram"
    Write-Host "  - Netflix"
    Write-Host "  - WhatsApp"
    Write-Host "  - Adobe Express"
    Write-Host ""
    
    if (Confirmar-Accion "¿Desinstalar apps preinstaladas no criticas?") {
        $appsToRemove = @(
            "*CandyCrush*","*Disney*","*Spotify*","*TikTok*",
            "*Instagram*","*Netflix*","*WhatsApp*","*AdobeExpress*",
            "*Twitter*","*Facebook*","*Solitaire*","*Minecraft*"
        )
        
        $count = 0
        foreach ($app in $appsToRemove) {
            $packages = Get-AppxPackage -Name $app -ErrorAction SilentlyContinue
            if ($packages) {
                foreach ($pkg in $packages) {
                    try {
                        Remove-AppxPackage -Package $pkg.PackageFullName -ErrorAction SilentlyContinue
                        $count++
                    } catch { }
                }
            }
        }
        
        Write-Host "[OK] $count aplicaciones desinstaladas correctamente." -ForegroundColor Green
        Pause-Kit
    }
}

function Opt-DesactivarPersonalizacionCloud {
    Clear-Host
    Write-Host "Desactivar Personalizacion en la Nube" -ForegroundColor Cyan
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Esta opcion desactivara la sincronizacion de configuracion y temas de Microsoft." -ForegroundColor Yellow
    Write-Host ""
    
    if (Confirmar-Accion "¿Desactivar Personalizacion en la Nube?") {
        try {
            $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudContent"
            if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
            Set-ItemProperty -Path $path -Name "DisableWindowsConsumerFeatures" -Value 1 -Type DWord -Force
            Set-ItemProperty -Path $path -Name "DisableSoftLanding" -Value 1 -Type DWord -Force
            
            $path2 = "HKCU:\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Personalization"
            if (Test-Path $path2) {
                Set-ItemProperty -Path $path2 -Name "Enabled" -Value 0 -Type DWord -Force
            }
            
            Write-Host "[OK] Personalizacion en la nube desactivada correctamente." -ForegroundColor Green
        } catch {
            Write-Host "[ERROR] No se pudo desactivar personalizacion: $_" -ForegroundColor Red
        }
        Pause-Kit
    }
}

function Opt-TodasLasOptimizaciones {
    Clear-Host
    Write-Host "Aplicar TODAS las Optimizaciones" -ForegroundColor Red
    Write-Host "================================" -ForegroundColor Red
    Write-Host ""
    
    Write-Host "Esta opcion aplicara TODAS las optimizaciones de una vez:" -ForegroundColor Yellow
    Write-Host "  - Desactivar Copilot, Widgets, Phone Link, Xbox Game Bar"
    Write-Host "  - Desactivar Tips, Publicidad, Apps Preinstaladas, Personalizacion Cloud"
    Write-Host ""
    Write-Host "ADVERTENCIA: Esta accion no se puede deshacer facilmente." -ForegroundColor Red
    Write-Host ""
    
    if (-not (Confirmar-Accion "¿Aplicar TODAS las optimizaciones? (s/n)")) { return }
    
    Write-Host "Aplicando optimizaciones..." -ForegroundColor Yellow
    Write-Host ""
    
    $tareas = @(
        @{Desc="Copilot"; Code={ 
            $p="HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot"
            if(-not(Test-Path $p)){New-Item -Path $p -Force|Out-Null}
            Set-ItemProperty -Path $p -Name "TurnOffWindowsCopilot" -Value 1 -Type DWord -Force
        }},
        @{Desc="Widgets"; Code={ Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value 0 -Type DWord -Force }},
        @{Desc="Phone Link"; Code={ Get-AppxPackage *Microsoft.YourPhone* | Remove-AppxPackage -ErrorAction SilentlyContinue }},
        @{Desc="Xbox Game Bar"; Code={ 
            $p="HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR"
            if(-not(Test-Path $p)){New-Item -Path $p -Force|Out-Null}
            Set-ItemProperty -Path $p -Name "AppCaptureEnabled" -Value 0 -Type DWord -Force
        }},
        @{Desc="Tips"; Code={ 
            $p="HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
            Set-ItemProperty -Path $p -Name "SubscribedContent-338389Enabled" -Value 0 -Type DWord -Force
            Set-ItemProperty -Path $p -Name "SoftLandingEnabled" -Value 0 -Type DWord -Force
        }},
        @{Desc="Publicidad"; Code={ Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "ContentDeliveryAllowed" -Value 0 -Type DWord -Force }},
        @{Desc="Apps Preinstaladas"; Code={ 
            @("*CandyCrush*","*Disney*","*Spotify*","*TikTok*","*Instagram*","*Netflix*") | ForEach-Object {
                Get-AppxPackage -Name $_ -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue
            }
        }},
        @{Desc="Personalizacion Cloud"; Code={ 
            $p="HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudContent"
            if(-not(Test-Path $p)){New-Item -Path $p -Force|Out-Null}
            Set-ItemProperty -Path $p -Name "DisableWindowsConsumerFeatures" -Value 1 -Type DWord -Force
        }}
    )
    
    $i = 1
    foreach ($t in $tareas) {
        Write-Host "[$i/$($tareas.Count)] $($t.Desc)..." -NoNewline
        try {
            & $t.Code
            Write-Host " [OK]" -ForegroundColor Green
        } catch { 
            Write-Host " [ERROR]" -ForegroundColor Red 
        }
        $i++
    }
    
    Write-Host ""
    Write-Host "[OK] Todas las optimizaciones aplicadas." -ForegroundColor Green
    Write-Host "  Nota: Se recomienda reiniciar para aplicar todos los cambios." -ForegroundColor Yellow
    Pause-Kit
}

# ============================================================
# FUNCION DE REPORTE
# ============================================================

function Generar-Reporte {
    Clear-Host
    $archivo = "$env:USERPROFILE\Desktop\DarlingKit_Reporte.txt"
    Write-Host "Generando reporte, por favor espera..." -ForegroundColor Yellow
    
    systeminfo | Out-File -FilePath $archivo -Encoding UTF8
    "`n--- IP CONFIG ---" | Out-File -FilePath $archivo -Append -Encoding UTF8
    ipconfig /all | Out-File -FilePath $archivo -Append -Encoding UTF8
    "`n--- PROCESOS ---" | Out-File -FilePath $archivo -Append -Encoding UTF8
    Get-Process | Select-Object Name, Id, WorkingSet | Out-File -FilePath $archivo -Append -Encoding UTF8

    Write-Host ""
    Write-Host "[OK] Reporte guardado exitosamente en:" -ForegroundColor Green
    Write-Host $archivo -ForegroundColor Cyan
    Pause-Kit
}

# ============================================================
# SUBMENUS
# ============================================================

function SubMenu-Utilidades {
    while ($true) {
        Mostrar-Header
        Write-Host ""
        Write-Host "   [ SUBMENU: UTILIDADES DEL SISTEMA ]" -ForegroundColor Cyan
        Write-Host "=========================================" -ForegroundColor Magenta
        Write-Host " 1  - Informacion COMPLETA del sistema"
        Write-Host " 2  - Estado DETALLADO de RAM"
        Write-Host " 3  - Estado DETALLADO de CPU"
        Write-Host " 4  - Informacion de RED detallada"
        Write-Host " 5  - Probar Internet (Multi-test)"
        Write-Host " 6  - Analisis de procesos (CPU/RAM)"
        Write-Host " 7  - Estado de Hyper-V"
        Write-Host " 8  - Estado de bateria (Laptops)"
        Write-Host " 9  - Servicios criticos del sistema"
        Write-Host " 10 - Eventos recientes (Errores)"
        Write-Host " 0  - Volver al menu principal"
        Write-Host ""

        $opcion = Read-Host "Selecciona una opcion"

        switch ($opcion) {
            "1" { if (Confirmar-Accion "Ejecutar Informacion completa del sistema?") { Util-InfoSistema } }
            "2" { if (Confirmar-Accion "Consultar estado detallado de RAM?") { Util-EstadoRAM } }
            "3" { if (Confirmar-Accion "Consultar estado detallado de CPU?") { Util-EstadoCPU } }
            "4" { if (Confirmar-Accion "Ver informacion de red detallada?") { Util-DireccionesIP } }
            "5" { if (Confirmar-Accion "Probar conexion a Internet?") { Util-ProbarInternet } }
            "6" { if (Confirmar-Accion "Ver analisis completo de procesos?") { Util-ProcesosPesados } }
            "7" { if (Confirmar-Accion "Ver estado de Hyper-V?") { Util-HyperV } }
            "8" { if (Confirmar-Accion "Ver estado de bateria?") { Util-Bateria } }
            "9" { if (Confirmar-Accion "Ver servicios criticos?") { Util-ServiciosCriticos } }
            "10" { if (Confirmar-Accion "Ver eventos recientes?") { Util-EventosRecientes } }
            "0" { return }
            default {
                Write-Host "Opcion invalida." -ForegroundColor Red
                Start-Sleep -Seconds 1
            }
        }
    }
}

function SubMenu-Herramientas {
    while ($true) {
        Mostrar-Header
        Write-Host ""
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
            "1" { if (Confirmar-Accion "Abrir Administrador de tareas?") { Herr-TaskMgr; Pause-Kit } }
            "2" { if (Confirmar-Accion "Abrir Monitor de recursos?") { Herr-ResMon; Pause-Kit } }
            "3" { if (Confirmar-Accion "Abrir Servicios?") { Herr-Services; Pause-Kit } }
            "4" { if (Confirmar-Accion "Abrir Administracion de equipos?") { Herr-CompMgmt; Pause-Kit } }
            "5" { if (Confirmar-Accion "Reiniciar Explorer? (La barra de tareas parpadeara)") { Herr-ReiniciarExplorer } }
            "0" { return }
            default {
                Write-Host "Opcion invalida." -ForegroundColor Red
                Start-Sleep -Seconds 1
            }
        }
    }
}

function SubMenu-Mantenimiento {
    while ($true) {
        Mostrar-Header
        Write-Host ""
        Write-Host "   [ SUBMENU: MANTENIMIENTO ]" -ForegroundColor Cyan
        Write-Host "=========================================" -ForegroundColor Magenta
        Write-Host " 1  - Limpiar archivos temporales"
        Write-Host " 2  - Limpiar cache DNS"
        Write-Host " 3  - Ejecutar SFC (Reparar sistema)"
        Write-Host " 4  - Ejecutar DISM (Restaurar imagen)"
        Write-Host " 0  - Volver al menu principal"
        Write-Host ""

        $opcion = Read-Host "Selecciona una opcion"

        switch ($opcion) {
            "1" { if (Confirmar-Accion "Eliminar archivos temporales?") { Mant-LimpiarTemp } }
            "2" { if (Confirmar-Accion "Limpiar cache DNS?") { Mant-LimpiarDNS } }
            "3" { if (Confirmar-Accion "Ejecutar SFC? (Puede tardar varios minutos)") { Mant-SFC } }
            "4" { if (Confirmar-Accion "Ejecutar DISM? (Puede tardar varios minutos)") { Mant-DISM } }
            "0" { return }
            default {
                Write-Host "Opcion invalida." -ForegroundColor Red
                Start-Sleep -Seconds 1
            }
        }
    }
}

function SubMenu-Discos {
    while ($true) {
        Mostrar-Header
        Write-Host ""
        Write-Host "   [ SUBMENU: GESTION DE DISCOS ]" -ForegroundColor Cyan
        Write-Host "=========================================" -ForegroundColor Magenta
        Write-Host " 1  - Estado DETALLADO de discos"
        Write-Host " 2  - Listar discos fisicos"
        Write-Host " 3  - Listar volumenes y letras"
        Write-Host " 4  - Quitar 'Solo Lectura' de USB"
        Write-Host " 5  - Quitar atributo 'Oculto' de USB"
        Write-Host " 6  - Limpiar disco (¡PELIGRO! Borra todo)"
        Write-Host " 7  - Formatear volumen (NTFS Rapido)"
        Write-Host " 0  - Volver al menu principal"
        Write-Host ""

        $opcion = Read-Host "Selecciona una opcion"

        switch ($opcion) {
            "1" { Discos-EstadoDetallado }
            "2" { Discos-ListarDiscos }
            "3" { Discos-ListarVolumenes }
            "4" { if (Confirmar-Accion "Reparar USB con error de Solo Lectura?") { Discos-QuitarSoloLectura } }
            "5" { if (Confirmar-Accion "Reparar USB con particion Oculta?") { Discos-QuitarOculto } }
            "6" { Discos-Limpiar }
            "7" { Discos-Formatear }
            "0" { return }
            default {
                Write-Host "Opcion invalida." -ForegroundColor Red
                Start-Sleep -Seconds 1
            }
        }
    }
}

function SubMenu-Boot {
    while ($true) {
        Mostrar-Header
        Write-Host ""
        Write-Host "   [ SUBMENU: OPCIONES DE ARRANQUE ]" -ForegroundColor Cyan
        Write-Host "=========================================" -ForegroundColor Magenta
        Write-Host " 1  - Reiniciar en BIOS/UEFI (Directo)"
        Write-Host " 2  - Reiniciar en Menu Avanzado (Modo Seguro, etc.)"
        Write-Host " 3  - Reiniciar en Modo Seguro"
        Write-Host " 0  - Volver al menu principal"
        Write-Host ""

        $opcion = Read-Host "Selecciona una opcion"

        switch ($opcion) {
            "1" { if (Confirmar-Accion "¿Reiniciar y entrar a la BIOS/UEFI?") { Boot-ReiniciarBIOS } }
            "2" { if (Confirmar-Accion "¿Reiniciar en el Menu de Arranque Avanzado?") { Boot-AdvancedStartup } }
            "3" { if (Confirmar-Accion "¿Reiniciar en Modo Seguro?") { Boot-ModoSeguro } }
            "0" { return }
            default {
                Write-Host "Opcion invalida." -ForegroundColor Red
                Start-Sleep -Seconds 1
            }
        }
    }
}

function SubMenu-Optimizacion {
    while ($true) {
        Mostrar-Header
        Write-Host ""
        Write-Host "   [ SUBMENU: OPTIMIZACION DE WINDOWS 11 ]" -ForegroundColor Cyan
        Write-Host "=========================================" -ForegroundColor Magenta
        Write-Host " 1  - Desactivar Copilot (AI integrada)"
        Write-Host " 2  - Desactivar Widgets"
        Write-Host " 3  - Desactivar Phone Link"
        Write-Host " 4  - Desactivar Xbox Game Bar"
        Write-Host " 5  - Desactivar Tips y Sugerencias"
        Write-Host " 6  - Desactivar Publicidad del Sistema"
        Write-Host " 7  - Desinstalar Apps Preinstaladas"
        Write-Host " 8  - Desactivar Personalizacion en la Nube"
        Write-Host " 9  - Aplicar TODAS las optimizaciones"
        Write-Host " 0  - Volver al menu principal"
        Write-Host ""

        $opcion = Read-Host "Selecciona una opcion"

        switch ($opcion) {
            "1" { Opt-DesactivarCopilot }
            "2" { Opt-DesactivarWidgets }
            "3" { Opt-DesactivarPhoneLink }
            "4" { Opt-DesactivarXboxGameBar }
            "5" { Opt-DesactivarTips }
            "6" { Opt-DesactivarPublicidad }
            "7" { Opt-DesactivarAppsPreinstaladas }
            "8" { Opt-DesactivarPersonalizacionCloud }
            "9" { Opt-TodasLasOptimizaciones }
            "0" { return }
            default {
                Write-Host "Opcion invalida." -ForegroundColor Red
                Start-Sleep -Seconds 1
            }
        }
    }
}

function SubMenu-Descargas {
    while ($true) {
        Mostrar-Header
        Write-Host ""
        Write-Host "   [ SUBMENU: DESCARGA DE HERRAMIENTAS ]" -ForegroundColor Cyan
        Write-Host "=========================================" -ForegroundColor Magenta
        Write-Host ""
        Write-Host "  [DIAGNOSTICO Y HARDWARE]" -ForegroundColor Yellow
        Write-Host "  1  - HDDScan (Diagnostico de discos)"
        Write-Host "  2  - HWiNFO (Info de hardware)"
        Write-Host "  3  - CrystalDiskInfo (Salud de discos)"
        Write-Host "  4  - MemTest86 (Prueba de RAM)"
        Write-Host ""
        Write-Host "  [SISTEMA Y PROCESOS (Sysinternals)]" -ForegroundColor Yellow
        Write-Host "  5  - Autoruns"
        Write-Host "  6  - Process Explorer"
        Write-Host "  7  - Process Monitor"
        Write-Host ""
        Write-Host "  [UTILIDADES]" -ForegroundColor Yellow
        Write-Host "  8  - Everything (Busqueda rapida)"
        Write-Host "  9  - Rufus (USB booteable)"
        Write-Host "  10 - 7-Zip (Compresion)"
        Write-Host "  11 - WinRAR (Compresion)"
        Write-Host ""
        Write-Host "  [INTERNET Y RED]" -ForegroundColor Yellow
        Write-Host "  12 - Brave Browser"
        Write-Host "  13 - Wireshark (Analisis de red)"
        Write-Host ""
        Write-Host "  [DESCARGAS MASIVAS POR CATEGORIA]" -ForegroundColor Green
        Write-Host "  14 - Descargar TODO Diagnostico"
        Write-Host "  15 - Descargar TODO Sysinternals"
        Write-Host "  16 - Descargar TODO Utilidades"
        Write-Host "  17 - Descargar TODO Red"
        Write-Host "  18 - Descargar TODO (Kit completo)"
        Write-Host ""
        Write-Host "  0  - Volver al menu principal"
        Write-Host ""

        $opcion = Read-Host "Selecciona una opcion"

        switch ($opcion) {
            # Descargas individuales (índices de la tabla 0-12)
            {$_ -match '^[1-9]$' -or $_ -match '^1[0-3]$'} { 
                $idx = [int]$opcion - 1
                if ($idx -ge 0 -and $idx -lt $Script:ToolsTable.Count) {
                    Descargar-Herramienta -Tool $Script:ToolsTable[$idx]
                } else {
                    Write-Host "Opcion invalida." -ForegroundColor Red
                    Start-Sleep -Seconds 1
                }
            }
            "14" { Descargar-CategoriaCompleta -Categoria "Diagnostico" }
            "15" { Descargar-CategoriaCompleta -Categoria "Sysinternals" }
            "16" { Descargar-CategoriaCompleta -Categoria "Utilidades" }
            "17" { Descargar-CategoriaCompleta -Categoria "Red" }
            "18" { 
                if (Confirmar-Accion "¿Descargar TODAS las herramientas (13 apps)?") {
                    $categorias = @("Diagnostico","Sysinternals","Utilidades","Red")
                    foreach ($cat in $categorias) {
                        Descargar-CategoriaCompleta -Categoria $cat
                    }
                }
            }
            "0" { return }
            default {
                Write-Host "Opcion invalida." -ForegroundColor Red
                Start-Sleep -Seconds 1
            }
        }
    }
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
    Write-Host " 8  - Exportar reporte al Escritorio"
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
        "8" { if (Confirmar-Accion "Generar reporte en el Escritorio?") { Generar-Reporte } }
        "0" {
            Clear-Host
            Write-Host "Saliendo de Darling System. Hasta luego!" -ForegroundColor Green
            Start-Sleep -Seconds 1
            break
        }
        default {
            Write-Host "Opcion invalida. Por favor, selecciona un numero del 0 al 8." -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    }
}