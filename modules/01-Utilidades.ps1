
# ============================================================
# FUNCIONES AUXILIARES REUTILIZABLES
# ============================================================

function Get-SistemaInfo { return Get-CimInstance Win32_OperatingSystem }
function Get-CPUInfo { return Get-CimInstance Win32_Processor | Select-Object -First 1 }
function Get-RAMInfo { return Get-CimInstance Win32_PhysicalMemory }
function Get-GPUInfo { return Get-CimInstance Win32_VideoController }
function Get-DiscoInfo { return Get-CimInstance Win32_DiskDrive }
function Get-PlacaBaseInfo { return Get-CimInstance Win32_BaseBoard }
function Get-BIOSInfo { return Get-CimInstance Win32_BIOS }

# ============================================================
# FUNCIONES DE UTILIDADES
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
    
    try {
        $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
        Write-Host "[SEGURIDAD BASICA]" -ForegroundColor Yellow
        Write-Host "  SID del usuario    : $($currentUser.User.Value)"
        Write-Host "  Es administrador   : $(if ($currentUser.Groups -match 'S-1-5-32-544') { 'Si' } else { 'No' })"
        Write-Host ""
    } catch { }
    
    $cs = Get-CimInstance Win32_ComputerSystem
    Write-Host "[TIPO DE SISTEMA]" -ForegroundColor Yellow
    Write-Host "  Fabricante         : $($cs.Manufacturer)"
    Write-Host "  Modelo             : $($cs.Model)"
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
    
    $esVirtual = $false
    $tipoVirtual = "Sistema físico (no virtualizado)"
    
    if ($cs.Manufacturer -match "VMware") { $esVirtual = $true; $tipoVirtual = "VMware" }
    elseif ($cs.Manufacturer -match "VirtualBox") { $esVirtual = $true; $tipoVirtual = "Oracle VirtualBox" }
    elseif ($cs.Manufacturer -match "QEMU") { $esVirtual = $true; $tipoVirtual = "QEMU/KVM" }
    elseif ($cs.Model -match "Virtual Machine") { $esVirtual = $true; $tipoVirtual = "Hyper-V o Microsoft Virtual" }
    elseif ($bios.Manufacturer -match "innotek") { $esVirtual = $true; $tipoVirtual = "VirtualBox" }
    
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
        
        $tipoReal = "Desconocido"
        try {
            $physicalDisk = Get-PhysicalDisk | Where-Object { $_.SerialNumber -eq $disco.SerialNumber }
            if ($physicalDisk) { $tipoReal = $physicalDisk.MediaType }
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
    
    try {
        $eventos = Get-WinEvent -FilterHashtable @{LogName='System'; ID=6005,6006,6009; StartTime=(Get-Date).AddDays(-30)} -ErrorAction SilentlyContinue
        $reinicios = ($eventos | Where-Object { $_.Id -eq 6005 -or $_.Id -eq 6009 }).Count
        Write-Host "[ESTADISTICAS]" -ForegroundColor Yellow
        Write-Host "  Reinicios (30 dias) : $reinicios"
    } catch { }
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
    Write-Host "  Inicio de sesion   : $((Get-SistemaInfo).LastBootUpTime.ToString('dd/MM/yyyy HH:mm:ss'))"
    Write-Host ""
    
    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $isAdmin = $currentUser.Groups -match 'S-1-5-32-544'
    
    Write-Host "[PERMISOS]" -ForegroundColor Yellow
    Write-Host "  Es administrador   : $(if ($isAdmin) { 'Si' } else { 'No' })" -ForegroundColor $(if ($isAdmin) { 'Green' } else { 'Yellow' })
    Write-Host ""
    Pause-Kit
}

function Util-DashboardRapido {
    Clear-Host
    Write-Host "╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                    DASHBOARD DEL SISTEMA                      ║" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    $cpu = Get-CPUInfo
    $cpuLoad = $cpu.LoadPercentage
    $cpuColor = if ($cpuLoad -gt 80) { 'Red' } elseif ($cpuLoad -gt 50) { 'Yellow' } else { 'Green' }
    Write-Host "  CPU Usage     : " -NoNewline
    Write-Host "$cpuLoad%" -ForegroundColor $cpuColor
    
    $os = Get-SistemaInfo
    $totalRAM = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    $freeRAM = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
    $usedRAM = [math]::Round($totalRAM - $freeRAM, 2)
    $ramPercent = [math]::Round(($usedRAM / $totalRAM) * 100, 0)
    $ramColor = if ($ramPercent -gt 80) { 'Red' } elseif ($ramPercent -gt 50) { 'Yellow' } else { 'Green' }
    Write-Host "  RAM Usage     : " -NoNewline
    Write-Host "$usedRAM GB / $totalRAM GB ($ramPercent%)" -ForegroundColor $ramColor
    
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
    
    $uptime = (Get-Date) - $os.LastBootUpTime
    Write-Host "  Uptime        : " -NoNewline
    Write-Host "$($uptime.Days)d $($uptime.Hours)h $($uptime.Minutes)m" -ForegroundColor Cyan
    
    $totalProcesos = (Get-Process).Count
    Write-Host "  Procesos      : " -NoNewline
    Write-Host "$totalProcesos activos" -ForegroundColor White
    
    Write-Host "  Internet      : " -NoNewline
    $internetOK = Test-Connection -ComputerName "8.8.8.8" -Count 1 -Quiet -ErrorAction SilentlyContinue
    if ($internetOK) { Write-Host "CONECTADO" -ForegroundColor Green } else { Write-Host "DESCONECTADO" -ForegroundColor Red }
    
    Write-Host ""
    Write-Host "╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║  Actualizado: $(Get-Date -Format 'HH:mm:ss')                                              ║" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    Pause-Kit
}

# ============================================================
# SUBMENU DE UTILIDADES (RENUMERADO Y LIMPIO: 18 OPCIONES)
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
        Write-Host " 14 - Tipo de disco (HDD/SSD/NVMe)"
        Write-Host " 15 - Uptime del sistema"
        Write-Host " 16 - Tipo de equipo (Laptop/Desktop)"
        Write-Host " 17 - Informacion del usuario activo"
        Write-Host " 18 - DASHBOARD RAPIDO (vista completa)"
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
            "14" { Util-TipoDisco }
            "15" { Util-Uptime }
            "16" { Util-TipoEquipo }
            "17" { Util-UsuarioActivo }
            "18" { Util-DashboardRapido }
            "0" { return }
            default { Write-Host "Opcion invalida." -ForegroundColor Red; Start-Sleep -Seconds 1 }
        }
    }
}