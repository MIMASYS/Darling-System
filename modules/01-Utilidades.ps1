# ============================================================
# MODULO 01: UTILIDADES DEL SISTEMA
# Version 4.1 - Expandido y optimizado
# ============================================================

# ============================================================
# FUNCIONES AUXILIARES REUTILIZABLES
# ============================================================

function Get-SistemaInfo {
    return Get-CimInstance Win32_OperatingSystem
}

function Get-CPUInfo {
    return Get-CimInstance Win32_Processor | Select-Object -First 1
}

function Get-RAMInfo {
    return Get-CimInstance Win32_PhysicalMemory
}

function Get-GPUInfo {
    return Get-CimInstance Win32_VideoController
}

function Get-DiscoInfo {
    return Get-CimInstance Win32_DiskDrive
}

function Get-PlacaBaseInfo {
    return Get-CimInstance Win32_BaseBoard
}

function Get-BIOSInfo {
    return Get-CimInstance Win32_BIOS
}

# ============================================================
# FUNCIONES EXISTENTES (OPTIMIZADAS)
# ============================================================

function Util-InfoSistema {
    Clear-Host
    Write-Host "Informacion Completa del Sistema" -ForegroundColor Cyan
    Write-Host "=================================" -ForegroundColor Cyan
    Write-Host ""
    
    $os = Get-SistemaInfo
    Write-Host "[SISTEMA OPERATIVO]" -ForegroundColor Yellow
    Write-Host "  Sistema      : $($os.Caption)"
    Write-Host "  Version      : $($os.Version)"
    Write-Host "  Arquitectura : $($os.OSArchitecture)"
    Write-Host "  Build        : $($os.BuildNumber)"
    Write-Host ""
    
    $cpu = Get-CPUInfo
    Write-Host "[PROCESADOR]" -ForegroundColor Yellow
    Write-Host "  Modelo        : $($cpu.Name)"
    Write-Host "  Nucleos       : $($cpu.NumberOfCores)"
    Write-Host "  Hilos         : $($cpu.NumberOfLogicalProcessors)"
    Write-Host ""
    
    $ram = Get-RAMInfo
    $totalRam = ($ram | Measure-Object -Property Capacity -Sum).Sum / 1GB
    Write-Host "[MEMORIA RAM]" -ForegroundColor Yellow
    Write-Host "  Total         : $([math]::Round($totalRam, 2)) GB"
    Write-Host "  Slots usados  : $($ram.Count)"
    Write-Host ""
    
    $gpu = Get-GPUInfo
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
    
    $os = Get-SistemaInfo
    $total = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    $free  = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
    $used  = [math]::Round($total - $free, 2)
    $percent = [math]::Round(($used / $total) * 100, 2)
    
    Write-Host "[USO ACTUAL]" -ForegroundColor Yellow
    Write-Host "  Total       : $total GB"
    Write-Host "  Usada       : $used GB ($percent%)"
    Write-Host "  Libre       : $free GB"
    Write-Host ""
    
    $typeMap = @{ 20 = "DDR"; 21 = "DDR2"; 24 = "DDR3"; 26 = "DDR4"; 34 = "DDR5" }
    $ram = Get-RAMInfo
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
    
    $cpu = Get-CPUInfo
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
        if ($result) { Write-Host " [OK]" -ForegroundColor Green } else { Write-Host " [FALLO]" -ForegroundColor Red }
    }
    Write-Host ""
    Pause-Kit
}

function Util-ProcesosPesados {
    Clear-Host
    Write-Host "Procesos del Sistema" -ForegroundColor Cyan
    Write-Host "====================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "[TOP 15 POR MEMORIA]" -ForegroundColor Yellow
    Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 15 | 
        Format-Table @{Label="Nombre"; Expression={$_.ProcessName}}, @{Label="PID"; Expression={$_.Id}}, @{Label="Memoria (MB)"; Expression={[math]::Round($_.WorkingSet / 1MB, 2)}} -AutoSize
    
    Write-Host ""
    Write-Host "[RESUMEN]" -ForegroundColor Yellow
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
        try {
            $vms = Get-VM -ErrorAction Stop
            Write-Host "[MAQUINAS VIRTUALES]" -ForegroundColor Yellow
            if ($vms) { $vms | Format-Table Name, State, CPUUsage, MemoryAssigned -AutoSize }
            else { Write-Host "  No hay maquinas virtuales creadas" -ForegroundColor Gray }
        } catch { Write-Host "No se pudo obtener informacion de las VMs" -ForegroundColor Red }
    } else { Write-Host "Hyper-V no esta instalado" -ForegroundColor Yellow }
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
    } else { Write-Host "No se detecto bateria (PC de escritorio)" -ForegroundColor Yellow }
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
# FUNCIONES NUEVAS
# ============================================================

function Util-PlacaBaseBIOS {
    Clear-Host
    Write-Host "Informacion de Placa Base y BIOS" -ForegroundColor Cyan
    Write-Host "=================================" -ForegroundColor Cyan
    Write-Host ""
    
    $placa = Get-PlacaBaseInfo
    Write-Host "[PLACA BASE]" -ForegroundColor Yellow
    Write-Host "  Fabricante    : $($placa.Manufacturer)"
    Write-Host "  Modelo        : $($placa.Product)"
    Write-Host "  Version       : $($placa.Version)"
    Write-Host "  Serial        : $($placa.SerialNumber)"
    Write-Host ""
    
    $bios = Get-BIOSInfo
    Write-Host "[BIOS/UEFI]" -ForegroundColor Yellow
    Write-Host "  Fabricante    : $($bios.Manufacturer)"
    Write-Host "  Version       : $($bios.SMBIOSBIOSVersion)"
    Write-Host "  Fecha         : $($bios.ReleaseDate)"
    Write-Host "  Serial        : $($bios.SerialNumber)"
    Write-Host ""
    
    # Detectar modo UEFI vs Legacy
    try {
        $bcdedit = bcdedit /enum '{current}' 2>&1
        $isUEFI = $bcdedit -match "path.*\.efi"
        $modoBoot = if ($isUEFI) { "UEFI" } else { "Legacy BIOS" }
        Write-Host "  Modo de arranque: $modoBoot" -ForegroundColor $(if ($isUEFI) { 'Green' } else { 'Yellow' })
    } catch {
        Write-Host "  Modo de arranque: No se pudo determinar" -ForegroundColor Red
    }
    Write-Host ""
    Pause-Kit
}

function Util-IdentidadSistema {
    Clear-Host
    Write-Host "Identidad del Sistema" -ForegroundColor Cyan
    Write-Host "=====================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "[INFORMACION BASICA]" -ForegroundColor Yellow
    Write-Host "  Nombre del equipo  : $($env:COMPUTERNAME)"
    Write-Host "  Usuario activo     : $($env:USERNAME)"
    Write-Host "  Dominio            : $($env:USERDOMAIN)"
    Write-Host ""
    
    # Obtener SID del usuario actual
    try {
        $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
        Write-Host "[SEGURIDAD]" -ForegroundColor Yellow
        Write-Host "  SID del usuario    : $($currentUser.User.Value)"
        Write-Host "  Es administrador   : $(if ($currentUser.Groups -match 'S-1-5-32-544') { 'Si' } else { 'No' })"
        Write-Host ""
    } catch {
        Write-Host "[SEGURIDAD]" -ForegroundColor Yellow
        Write-Host "  No se pudo obtener informacion de seguridad" -ForegroundColor Red
        Write-Host ""
    }
    
    # Tipo de sistema
    $cs = Get-CimInstance Win32_ComputerSystem
    Write-Host "[TIPO DE SISTEMA]" -ForegroundColor Yellow
    Write-Host "  Fabricante         : $($cs.Manufacturer)"
    Write-Host "  Modelo             : $($cs.Model)"
    Write-Host "  Tipo de dominio    : $($cs.DomainRole)"
    Write-Host ""
    Pause-Kit
}

function Util-DetectarVirtualizacion {
    Clear-Host
    Write-Host "Deteccion de Virtualizacion" -ForegroundColor Cyan
    Write-Host "===========================" -ForegroundColor Cyan
    Write-Host ""
    
    $cs = Get-CimInstance Win32_ComputerSystem
    $bios = Get-BIOSInfo
    
    Write-Host "[INFORMACION DEL SISTEMA]" -ForegroundColor Yellow
    Write-Host "  Fabricante    : $($cs.Manufacturer)"
    Write-Host "  Modelo        : $($cs.Model)"
    Write-Host ""
    
    # Detectar tipo de virtualización
    $esVirtual = $false
    $tipoVirtual = "Sistema físico (no virtualizado)"
    
    if ($cs.Manufacturer -match "VMware") {
        $esVirtual = $true
        $tipoVirtual = "VMware"
    }
    elseif ($cs.Manufacturer -match "VirtualBox") {
        $esVirtual = $true
        $tipoVirtual = "Oracle VirtualBox"
    }
    elseif ($cs.Manufacturer -match "QEMU") {
        $esVirtual = $true
        $tipoVirtual = "QEMU/KVM"
    }
    elseif ($cs.Model -match "Virtual Machine") {
        $esVirtual = $true
        $tipoVirtual = "Hyper-V o Microsoft Virtual"
    }
    elseif ($bios.Manufacturer -match "innotek") {
        $esVirtual = $true
        $tipoVirtual = "VirtualBox"
    }
    
    Write-Host "[RESULTADO]" -ForegroundColor Yellow
    if ($esVirtual) {
        Write-Host "  Estado        : VIRTUALIZADO" -ForegroundColor Yellow
        Write-Host "  Tipo          : $tipoVirtual" -ForegroundColor Yellow
    } else {
        Write-Host "  Estado        : SISTEMA FISICO" -ForegroundColor Green
    }
    Write-Host ""
    Pause-Kit
}

function Util-SecureBoot {
    Clear-Host
    Write-Host "Estado de Secure Boot" -ForegroundColor Cyan
    Write-Host "=====================" -ForegroundColor Cyan
    Write-Host ""
    
    try {
        $secureBoot = Confirm-SecureBootUEFI
        Write-Host "[SECURE BOOT]" -ForegroundColor Yellow
        if ($secureBoot) {
            Write-Host "  Estado        : ACTIVADO" -ForegroundColor Green
            Write-Host "  Proteccion    : Tu sistema esta protegido contra bootkits" -ForegroundColor Green
        } else {
            Write-Host "  Estado        : DESACTIVADO" -ForegroundColor Red
            Write-Host "  Advertencia   : Tu sistema puede ser vulnerable" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "[SECURE BOOT]" -ForegroundColor Yellow
        Write-Host "  Estado        : NO DISPONIBLE" -ForegroundColor Yellow
        Write-Host "  Nota          : Secure Boot solo esta disponible en sistemas UEFI" -ForegroundColor Gray
    }
    Write-Host ""
    Pause-Kit
}

function Util-TipoDisco {
    Clear-Host
    Write-Host "Informacion de Discos" -ForegroundColor Cyan
    Write-Host "=====================" -ForegroundColor Cyan
    Write-Host ""
    
    $discos = Get-DiscoInfo
    Write-Host "[DISCOS FISICOS]" -ForegroundColor Yellow
    
    foreach ($disco in $discos) {
        $sizeGB = [math]::Round($disco.Size / 1GB, 2)
        $tipoMedio = switch ($disco.MediaType) {
            "Fixed hard disk media" { "HDD/SSD" }
            "Removable Media" { "Extraible" }
            default { $disco.MediaType }
        }
        
        # Intentar detectar SSD vs HDD
        $tipoReal = "Desconocido"
        try {
            $physicalDisk = Get-PhysicalDisk | Where-Object { $_.SerialNumber -eq $disco.SerialNumber }
            if ($physicalDisk) {
                $tipoReal = $physicalDisk.MediaType
            }
        } catch { }
        
        Write-Host ""
        Write-Host "  Disco: $($disco.Model)" -ForegroundColor Green
        Write-Host "    Tamano      : $sizeGB GB"
        Write-Host "    Tipo medio  : $tipoMedio"
        Write-Host "    Tipo real   : $tipoReal" -ForegroundColor $(if ($tipoReal -eq "SSD") { 'Green' } elseif ($tipoReal -eq "HDD") { 'Yellow' } else { 'Gray' })
        Write-Host "    Interfaz    : $($disco.InterfaceType)"
        Write-Host "    Serial      : $($disco.SerialNumber)"
    }
    Write-Host ""
    Pause-Kit
}

function Util-Uptime {
    Clear-Host
    Write-Host "Uptime del Sistema" -ForegroundColor Cyan
    Write-Host "==================" -ForegroundColor Cyan
    Write-Host ""
    
    $os = Get-SistemaInfo
    $lastBoot = $os.LastBootUpTime
    $uptime = (Get-Date) - $lastBoot
    
    Write-Host "[TIEMPO DE ACTIVIDAD]" -ForegroundColor Yellow
    Write-Host "  Ultimo arranque : $($lastBoot.ToString('dd/MM/yyyy HH:mm:ss'))"
    Write-Host "  Uptime total    : $($uptime.Days) dias, $($uptime.Hours) horas, $($uptime.Minutes) minutos"
    Write-Host ""
    
    # Contar reinicios recientes (últimos 30 días)
    try {
        $eventos = Get-WinEvent -FilterHashtable @{LogName='System'; ID=6005,6006,6009; StartTime=(Get-Date).AddDays(-30)} -ErrorAction SilentlyContinue
        $reinicios = ($eventos | Where-Object { $_.Id -eq 6005 -or $_.Id -eq 6009 }).Count
        Write-Host "[ESTADISTICAS]" -ForegroundColor Yellow
        Write-Host "  Reinicios (30 dias) : $reinicios"
    } catch {
        Write-Host "[ESTADISTICAS]" -ForegroundColor Yellow
        Write-Host "  No se pudo obtener historial de reinicios" -ForegroundColor Gray
    }
    Write-Host ""
    Pause-Kit
}

function Util-TipoEquipo {
    Clear-Host
    Write-Host "Tipo de Equipo" -ForegroundColor Cyan
    Write-Host "================" -ForegroundColor Cyan
    Write-Host ""
    
    $cs = Get-CimInstance Win32_ComputerSystem
    $battery = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue
    
    Write-Host "[CLASIFICACION]" -ForegroundColor Yellow
    
    if ($battery) {
        Write-Host "  Tipo            : LAPTOP / PORTATIL" -ForegroundColor Green
        Write-Host "  Bateria         : Detectada"
        Write-Host "  Carga actual    : $($battery.EstimatedChargeRemaining)%"
    } else {
        Write-Host "  Tipo            : PC DE ESCRITORIO" -ForegroundColor Cyan
        Write-Host "  Bateria         : No detectada"
    }
    
    Write-Host ""
    Write-Host "[INFORMACION ADICIONAL]" -ForegroundColor Yellow
    Write-Host "  Fabricante      : $($cs.Manufacturer)"
    Write-Host "  Modelo          : $($cs.Model)"
    Write-Host "  Nombre          : $($cs.Name)"
    Write-Host ""
    Pause-Kit
}

function Util-UsuarioActivo {
    Clear-Host
    Write-Host "Informacion del Usuario Activo" -ForegroundColor Cyan
    Write-Host "===============================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "[USUARIO ACTUAL]" -ForegroundColor Yellow
    Write-Host "  Nombre de usuario  : $($env:USERNAME)"
    Write-Host "  Nombre completo    : $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)"
    Write-Host "  Perfil             : $($env:USERPROFILE)"
    Write-Host ""
    
    Write-Host "[SESION]" -ForegroundColor Yellow
    Write-Host "  Dominio            : $($env:USERDOMAIN)"
    Write-Host "  Equipo             : $($env:COMPUTERNAME)"
    Write-Host "  Inicio de sesion   : $((Get-CimInstance Win32_OperatingSystem).LastBootUpTime.ToString('dd/MM/yyyy HH:mm:ss'))"
    Write-Host ""
    
    # Verificar si es administrador
    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $isAdmin = $currentUser.Groups -match 'S-1-5-32-544'
    
    Write-Host "[PERMISOS]" -ForegroundColor Yellow
    Write-Host "  Es administrador   : $(if ($isAdmin) { 'Si' } else { 'No' })" -ForegroundColor $(if ($isAdmin) { 'Green' } else { 'Yellow' })
    Write-Host ""
    Pause-Kit
}

function Util-EstadoSeguridad {
    Clear-Host
    Write-Host "Estado de Seguridad del Sistema" -ForegroundColor Cyan
    Write-Host "===============================" -ForegroundColor Cyan
    Write-Host ""
    
    # Windows Defender
    Write-Host "[WINDOWS DEFENDER]" -ForegroundColor Yellow
    try {
        $defender = Get-MpComputerStatus -ErrorAction Stop
        Write-Host "  Estado              : $(if ($defender.AntivirusEnabled) { 'ACTIVADO' } else { 'DESACTIVADO' })" -ForegroundColor $(if ($defender.AntivirusEnabled) { 'Green' } else { 'Red' })
        Write-Host "  Antispyware         : $(if ($defender.AntispywareEnabled) { 'ACTIVADO' } else { 'DESACTIVADO' })" -ForegroundColor $(if ($defender.AntispywareEnabled) { 'Green' } else { 'Red' })
        Write-Host "  Ultima actualizacion: $($defender.AntivirusSignatureLastUpdated.ToString('dd/MM/yyyy HH:mm'))"
    } catch {
        Write-Host "  No se pudo obtener informacion de Windows Defender" -ForegroundColor Red
    }
    Write-Host ""
    
    # Firewall
    Write-Host "[FIREWALL DE WINDOWS]" -ForegroundColor Yellow
    try {
        $firewall = Get-NetFirewallProfile -ErrorAction Stop
        foreach ($profile in $firewall) {
            $estado = if ($profile.Enabled) { "ACTIVADO" } else { "DESACTIVADO" }
            Write-Host "  Perfil $($profile.Name.PadRight(10)): $estado" -ForegroundColor $(if ($profile.Enabled) { 'Green' } else { 'Red' })
        }
    } catch {
        Write-Host "  No se pudo obtener informacion del Firewall" -ForegroundColor Red
    }
    Write-Host ""
    
    # UAC
    Write-Host "[CONTROL DE CUENTAS DE USUARIO (UAC)]" -ForegroundColor Yellow
    try {
        $uac = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -ErrorAction Stop
        $uacStatus = if ($uac.EnableLUA -eq 1) { "ACTIVADO" } else { "DESACTIVADO" }
        Write-Host "  Estado              : $uacStatus" -ForegroundColor $(if ($uac.EnableLUA -eq 1) { 'Green' } else { 'Red' })
    } catch {
        Write-Host "  No se pudo obtener informacion de UAC" -ForegroundColor Red
    }
    Write-Host ""
    Pause-Kit
}

function Util-ConteoBSOD {
    Clear-Host
    Write-Host "Conteo de BSOD y Errores Criticos" -ForegroundColor Cyan
    Write-Host "==================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "[BUSQUEDA DE BSOD (Ultimos 90 dias)]" -ForegroundColor Yellow
    
    try {
        $fechaInicio = (Get-Date).AddDays(-90)
        
        # Buscar eventos de bugcheck (BSOD)
        $bsods = Get-WinEvent -FilterHashtable @{
            LogName = 'System'
            ID = 1001
            ProviderName = 'Microsoft-Windows-WER-SystemErrorReporting'
            StartTime = $fechaInicio
        } -ErrorAction SilentlyContinue
        
        if ($bsods) {
            Write-Host "  BSODs encontrados   : $($bsods.Count)" -ForegroundColor Red
            Write-Host ""
            Write-Host "  Ultimos 5 BSODs:" -ForegroundColor Yellow
            $bsods | Select-Object -First 5 | ForEach-Object {
                Write-Host "    $($_.TimeCreated.ToString('dd/MM/yyyy HH:mm')) - $($_.Message.Substring(0, [Math]::Min(80, $_.Message.Length)))..." -ForegroundColor Gray
            }
        } else {
            Write-Host "  BSODs encontrados   : 0" -ForegroundColor Green
            Write-Host "  Estado              : Sistema estable" -ForegroundColor Green
        }
    } catch {
        Write-Host "  No se pudo obtener informacion de BSODs" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "[ERRORES CRITICOS DEL SISTEMA]" -ForegroundColor Yellow
    try {
        $errores = Get-EventLog -LogName System -EntryType Error -After $fechaInicio -ErrorAction SilentlyContinue
        Write-Host "  Errores (90 dias)   : $($errores.Count)" -ForegroundColor $(if ($errores.Count -gt 50) { 'Red' } elseif ($errores.Count -gt 20) { 'Yellow' } else { 'Green' })
    } catch {
        Write-Host "  No se pudo obtener conteo de errores" -ForegroundColor Red
    }
    Write-Host ""
    Pause-Kit
}

function Util-DashboardRapido {
    Clear-Host
    Write-Host "╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                    DASHBOARD DEL SISTEMA                      ║" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    # CPU
    $cpu = Get-CPUInfo
    $cpuLoad = $cpu.LoadPercentage
    $cpuColor = if ($cpuLoad -gt 80) { 'Red' } elseif ($cpuLoad -gt 50) { 'Yellow' } else { 'Green' }
    Write-Host "  CPU Usage     : " -NoNewline
    Write-Host "$cpuLoad%" -ForegroundColor $cpuColor
    
    # RAM
    $os = Get-SistemaInfo
    $totalRAM = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    $freeRAM = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
    $usedRAM = [math]::Round($totalRAM - $freeRAM, 2)
    $ramPercent = [math]::Round(($usedRAM / $totalRAM) * 100, 0)
    $ramColor = if ($ramPercent -gt 80) { 'Red' } elseif ($ramPercent -gt 50) { 'Yellow' } else { 'Green' }
    Write-Host "  RAM Usage     : " -NoNewline
    Write-Host "$usedRAM GB / $totalRAM GB ($ramPercent%)" -ForegroundColor $ramColor
    
    # Disco C:
    $discoC = Get-Volume -DriveLetter C -ErrorAction SilentlyContinue
    if ($discoC) {
        $discoTotal = [math]::Round($discoC.Size / 1GB, 2)
        $discoLibre = [math]::Round($discoC.SizeRemaining / 1GB, 2)
        $discoUsado = [math]::Round($discoTotal - $discoLibre, 2)
        $discoPercent = [math]::Round(($discoUsado / $discoTotal) * 100, 0)
        $discoColor = if ($discoPercent -gt 90) { 'Red' } elseif ($discoPercent -gt 70) { 'Yellow' } else { 'Green' }
        Write-Host "  Disco C:      : " -NoNewline
        Write-Host "$discoUsado GB / $discoTotal GB ($discoPercent%)" -ForegroundColor $discoColor
    }
    
    # Uptime
    $uptime = (Get-Date) - $os.LastBootUpTime
    Write-Host "  Uptime        : " -NoNewline
    Write-Host "$($uptime.Days)d $($uptime.Hours)h $($uptime.Minutes)m" -ForegroundColor Cyan
    
    # Procesos
    $totalProcesos = (Get-Process).Count
    Write-Host "  Procesos      : " -NoNewline
    Write-Host "$totalProcesos activos" -ForegroundColor White
    
    # Red (test rápido)
    Write-Host "  Internet      : " -NoNewline
    $internetOK = Test-Connection -ComputerName "8.8.8.8" -Count 1 -Quiet -ErrorAction SilentlyContinue
    if ($internetOK) {
        Write-Host "CONECTADO" -ForegroundColor Green
    } else {
        Write-Host "DESCONECTADO" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║  Actualizado: $(Get-Date -Format 'HH:mm:ss')                                              ║" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    Pause-Kit
}

# ============================================================
# SUBMENU ACTUALIZADO
# ============================================================

function SubMenu-Utilidades {
    while ($true) {
        Mostrar-Header
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
        Write-Host " 11 - Placa base y BIOS/UEFI"
        Write-Host " 12 - Identidad del sistema"
        Write-Host " 13 - Deteccion de virtualizacion"
        Write-Host " 14 - Estado de Secure Boot"
        Write-Host " 15 - Tipo de disco (HDD/SSD/NVMe)"
        Write-Host " 16 - Uptime del sistema"
        Write-Host " 17 - Tipo de equipo (Laptop/Desktop)"
        Write-Host " 18 - Informacion del usuario activo"
        Write-Host " 19 - Estado de seguridad (Defender/Firewall/UAC)"
        Write-Host " 20 - Conteo de BSOD y errores criticos"
        Write-Host " 21 - DASHBOARD RAPIDO (vista completa)"
        Write-Host " 0  - Volver al menu principal"
        Write-Host ""
        $opcion = Read-Host "Selecciona una opcion"
        switch ($opcion) {
            "1" { Util-InfoSistema }
            "2" { Util-EstadoRAM }
            "3" { Util-EstadoCPU }
            "4" { Util-DireccionesIP }
            "5" { Util-ProbarInternet }
            "6" { Util-ProcesosPesados }
            "7" { Util-HyperV }
            "8" { Util-Bateria }
            "9" { Util-ServiciosCriticos }
            "10" { Util-EventosRecientes }
            "11" { Util-PlacaBaseBIOS }
            "12" { Util-IdentidadSistema }
            "13" { Util-DetectarVirtualizacion }
            "14" { Util-SecureBoot }
            "15" { Util-TipoDisco }
            "16" { Util-Uptime }
            "17" { Util-TipoEquipo }
            "18" { Util-UsuarioActivo }
            "19" { Util-EstadoSeguridad }
            "20" { Util-ConteoBSOD }
            "21" { Util-DashboardRapido }
            "0" { return }
            default { Write-Host "Opcion invalida." -ForegroundColor Red; Start-Sleep -Seconds 1 }
        }
    }
}