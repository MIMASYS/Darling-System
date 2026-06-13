# ============================================================
# MODULO 01: UTILIDADES DEL SISTEMA
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
    $typeMap = @{ 20 = "DDR"; 21 = "DDR2"; 24 = "DDR3"; 26 = "DDR4"; 34 = "DDR5" }
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
            "0" { return }
            default { Write-Host "Opcion invalida." -ForegroundColor Red; Start-Sleep -Seconds 1 }
        }
    }
}
