# ============================================================
# MODULO 12: REPORTES
# ============================================================

function Generar-Reporte {
    Clear-Host
    $archivo = "$env:USERPROFILE\Desktop\DarlingKit_Reporte.txt"
    Write-Host "Generando reporte TXT..." -ForegroundColor Yellow
    systeminfo | Out-File -FilePath $archivo -Encoding UTF8
    "`n--- IP CONFIG ---" | Out-File -FilePath $archivo -Append -Encoding UTF8
    ipconfig /all | Out-File -FilePath $archivo -Append -Encoding UTF8
    "`n--- PROCESOS ---" | Out-File -FilePath $archivo -Append -Encoding UTF8
    Get-Process | Select-Object Name, Id, WorkingSet | Out-File -FilePath $archivo -Append -Encoding UTF8
    Write-Host "[OK] Reporte guardado en:" -ForegroundColor Green
    Write-Host $archivo -ForegroundColor Cyan
    Pause-Kit
}

function Generar-ReporteHTML {
    Clear-Host
    $archivo = "$env:USERPROFILE\Desktop\DarlingSystem_Reporte.html"
    Write-Host "Generando reporte HTML, por favor espera..." -ForegroundColor Yellow
    $css = @"
<style>
body { font-family: 'Segoe UI', Arial, sans-serif; background: #f5f5f5; color: #333; margin: 20px; }
h1 { color: #8B0000; border-bottom: 3px solid #8B0000; padding-bottom: 10px; }
h2 { color: #4B0082; background: #e8e8e8; padding: 8px; border-left: 5px solid #4B0082; }
table { border-collapse: collapse; width: 100%; margin: 10px 0; background: white; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
th { background: #8B0000; color: white; padding: 10px; text-align: left; }
td { padding: 8px; border-bottom: 1px solid #ddd; }
tr:hover { background: #f9f9f9; }
.header { background: linear-gradient(135deg, #8B0000, #4B0082); color: white; padding: 20px; border-radius: 8px; text-align: center; }
.footer { text-align: center; color: #888; margin-top: 30px; font-size: 0.9em; }
</style>
"@
    $html = "<html><head><title>Darling System Reporte</title>$css</head><body>"
    $html += "<div class='header'><h1>Darling System - Reporte del Sistema</h1>"
    $html += "<p>Generado: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')</p></div>"
    $os = Get-CimInstance Win32_OperatingSystem
    $html += "<h2>Sistema Operativo</h2>"
    $html += "<table><tr><th>Propiedad</th><th>Valor</th></tr>"
    $html += "<tr><td>Sistema</td><td>$($os.Caption)</td></tr>"
    $html += "<tr><td>Version</td><td>$($os.Version)</td></tr>"
    $html += "<tr><td>Arquitectura</td><td>$($os.OSArchitecture)</td></tr>"
    $html += "<tr><td>Nombre PC</td><td>$($os.CSName)</td></tr></table>"
    $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
    $html += "<h2>Procesador</h2>"
    $html += "<table><tr><th>Propiedad</th><th>Valor</th></tr>"
    $html += "<tr><td>Modelo</td><td>$($cpu.Name)</td></tr>"
    $html += "<tr><td>Nucleos</td><td>$($cpu.NumberOfCores)</td></tr>"
    $html += "<tr><td>Hilos</td><td>$($cpu.NumberOfLogicalProcessors)</td></tr></table>"
    $totalRam = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    $freeRam = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
    $html += "<h2>Memoria RAM</h2>"
    $html += "<table><tr><th>Total</th><th>Libre</th><th>Usada</th></tr>"
    $html += "<tr><td>$totalRam GB</td><td>$freeRam GB</td><td>$([math]::Round($totalRam - $freeRam, 2)) GB</td></tr></table>"
    $gpu = Get-CimInstance Win32_VideoController
    $html += "<h2>Tarjeta Grafica</h2>"
    $html += $gpu | Select-Object Name, @{N='VRAM_MB'; E={[math]::Round($_.AdapterRAM/1MB,2)}}, DriverVersion | ConvertTo-Html -Fragment
    $html += "<h2>Discos</h2>"
    $html += Get-Volume | Where-Object DriveLetter | Select-Object DriveLetter, FileSystemLabel, FileSystem,
        @{N='Libre_GB'; E={[math]::Round($_.SizeRemaining/1GB,2)}}, @{N='Total_GB'; E={[math]::Round($_.Size/1GB,2)}} |
        ConvertTo-Html -Fragment
    $html += "<h2>Configuracion de Red</h2>"
    $adapters = Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object {$_.IPEnabled}
    $html += $adapters | Select-Object Description, @{N='IP'; E={$_.IPAddress[0]}}, @{N='Gateway'; E={$_.DefaultIPGateway}} | ConvertTo-Html -Fragment
    $html += "<h2>Top 10 Procesos (Memoria)</h2>"
    $html += Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 10 |
        Select-Object Name, Id, @{N='Memoria_MB'; E={[math]::Round($_.WorkingSet/1MB,2)}} | ConvertTo-Html -Fragment
    $html += "<h2>Servicios Criticos</h2>"
    $criticalServices = @("wuauserv", "BITS", "wscsvc", "WinDefend", "Dnscache", "Dhcp")
    $servicios = foreach ($svc in $criticalServices) { Get-Service $svc -ErrorAction SilentlyContinue | Select-Object Name, DisplayName, Status }
    $html += $servicios | ConvertTo-Html -Fragment
    $html += "<div class='footer'><p>Darling System v4.0 - Created by MIMASYS. Chu. & Co-authored by Qwen</p></div>"
    $html += "</body></html>"
    $html | Out-File -FilePath $archivo -Encoding UTF8
    Write-Host ""
    Write-Host "[OK] Reporte HTML guardado en:" -ForegroundColor Green
    Write-Host $archivo -ForegroundColor Cyan
    if (Confirmar-Accion "Abrir el reporte en el navegador?") { Start-Process $archivo }
    Pause-Kit
}
