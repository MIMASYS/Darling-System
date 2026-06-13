# ============================================================
# MODULO 08: PERIFERICOS Y HARDWARE
# ============================================================

function Peri-DispositivosUSB {
    Clear-Host
    Write-Host "Dispositivos USB Conectados" -ForegroundColor Cyan
    Write-Host "===========================" -ForegroundColor Cyan
    Write-Host ""
    $usb = Get-CimInstance Win32_USBHub -ErrorAction SilentlyContinue
    if ($usb) { $usb | Format-Table DeviceID, Name, Status -AutoSize }
    else { Write-Host "No se detectaron dispositivos USB." -ForegroundColor Yellow }
    Write-Host ""
    Pause-Kit
}

function Peri-Impresoras {
    Clear-Host
    Write-Host "Impresoras Instaladas" -ForegroundColor Cyan
    Write-Host "=====================" -ForegroundColor Cyan
    Write-Host ""
    $printers = Get-CimInstance Win32_Printer -ErrorAction SilentlyContinue
    if ($printers) { $printers | Format-Table Name, @{Label="Puerto"; Expression={$_.PortName}}, @{Label="Default"; Expression={$_.Default}}, DriverName -AutoSize }
    else { Write-Host "No se detectaron impresoras." -ForegroundColor Yellow }
    Write-Host ""
    Pause-Kit
}

function Peri-Bluetooth {
    Clear-Host
    Write-Host "Dispositivos Bluetooth" -ForegroundColor Cyan
    Write-Host "======================" -ForegroundColor Cyan
    Write-Host ""
    $bt = Get-CimInstance Win32_PNPEntity | Where-Object { $_.Name -match 'Bluetooth' -and $_.Status -eq 'OK' } -ErrorAction SilentlyContinue
    if ($bt) { $bt | Format-Table Name, Status, @{Label="Clase"; Expression={$_.PNPClass}} -AutoSize }
    else { Write-Host "No se detectaron dispositivos Bluetooth." -ForegroundColor Yellow }
    Write-Host ""
    Pause-Kit
}

function Peri-Camaras {
    Clear-Host
    Write-Host "Camaras Web Detectadas" -ForegroundColor Cyan
    Write-Host "======================" -ForegroundColor Cyan
    Write-Host ""
    $cameras = Get-CimInstance Win32_PNPEntity | Where-Object { $_.PNPClass -eq 'Camera' -or $_.PNPClass -eq 'Image' } -ErrorAction SilentlyContinue
    if ($cameras) { $cameras | Format-Table Name, Status, Manufacturer -AutoSize }
    else { Write-Host "No se detectaron camaras web." -ForegroundColor Yellow }
    Write-Host ""
    Pause-Kit
}

function Peri-DispositivosError {
    Clear-Host
    Write-Host "Dispositivos con Errores" -ForegroundColor Cyan
    Write-Host "========================" -ForegroundColor Cyan
    Write-Host ""
    $errores = Get-CimInstance Win32_PNPEntity | Where-Object { $_.ConfigManagerErrorCode -ne 0 } -ErrorAction SilentlyContinue
    if ($errores) {
        Write-Host "[DISPOSITIVOS CON PROBLEMAS]" -ForegroundColor Red
        $errores | Format-Table Name, @{Label="Codigo Error"; Expression={$_.ConfigManagerErrorCode}}, Status -AutoSize
    } else { Write-Host "[OK] No hay dispositivos con errores." -ForegroundColor Green }
    Write-Host ""
    Pause-Kit
}

function Peri-Monitores {
    Clear-Host
    Write-Host "Monitores Conectados" -ForegroundColor Cyan
    Write-Host "====================" -ForegroundColor Cyan
    Write-Host ""
    try {
        $monitores = Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorID -ErrorAction Stop
        foreach ($m in $monitores) {
            $nombre = ($m.UserFriendlyName | Where-Object { $_ -ne 0 } | ForEach-Object { [char]$_ }) -join ''
            $serial = ($m.SerialNumberID | Where-Object { $_ -ne 0 } | ForEach-Object { [char]$_ }) -join ''
            $fabricante = ($m.ManufacturerName | Where-Object { $_ -ne 0 } | ForEach-Object { [char]$_ }) -join ''
            Write-Host "  Monitor:" -ForegroundColor Green
            Write-Host "    Nombre      : $nombre"
            Write-Host "    Fabricante  : $fabricante"
            Write-Host "    Serial      : $serial"
            Write-Host "    Ano         : $($m.YearOfManufacture)"
            Write-Host ""
        }
    } catch {
        Write-Host "Mostrando informacion basica:" -ForegroundColor Yellow
        Get-CimInstance Win32_DesktopMonitor | Format-Table Name, ScreenHeight, ScreenWidth -AutoSize
    }
    Write-Host ""
    Pause-Kit
}

function Peri-Audio {
    Clear-Host
    Write-Host "Dispositivos de Audio" -ForegroundColor Cyan
    Write-Host "=====================" -ForegroundColor Cyan
    Write-Host ""
    $audio = Get-CimInstance Win32_SoundDevice -ErrorAction SilentlyContinue
    if ($audio) { $audio | Format-Table Name, Manufacturer, Status -AutoSize }
    else { Write-Host "No se detectaron dispositivos de audio." -ForegroundColor Yellow }
    Write-Host ""
    Pause-Kit
}

function Peri-TecladoRaton {
    Clear-Host
    Write-Host "Teclados y Ratones" -ForegroundColor Cyan
    Write-Host "==================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "[TECLADOS]" -ForegroundColor Yellow
    Get-CimInstance Win32_Keyboard | Format-Table Name, Description, Status -AutoSize
    Write-Host ""
    Write-Host "[RATONES / PUNTEROS]" -ForegroundColor Yellow
    Get-CimInstance Win32_PointingDevice | Format-Table Name, Description, @{Label="Tipo"; Expression={$_.PointingType}} -AutoSize
    Write-Host ""
    Pause-Kit
}

function SubMenu-Perifericos {
    while ($true) {
        Mostrar-Header
        Write-Host "   [ SUBMENU: PERIFERICOS Y HARDWARE ]" -ForegroundColor Cyan
        Write-Host "=========================================" -ForegroundColor Magenta
        Write-Host " 1  - Dispositivos USB conectados"
        Write-Host " 2  - Impresoras instaladas"
        Write-Host " 3  - Dispositivos Bluetooth"
        Write-Host " 4  - Camaras web detectadas"
        Write-Host " 5  - Dispositivos con errores"
        Write-Host " 6  - Monitores conectados"
        Write-Host " 7  - Dispositivos de audio"
        Write-Host " 8  - Teclados y ratones"
        Write-Host " 0  - Volver al menu principal"
        Write-Host ""
        $opcion = Read-Host "Selecciona una opcion"
        switch ($opcion) {
            "1" { Peri-DispositivosUSB }
            "2" { Peri-Impresoras }
            "3" { Peri-Bluetooth }
            "4" { Peri-Camaras }
            "5" { Peri-DispositivosError }
            "6" { Peri-Monitores }
            "7" { Peri-Audio }
            "8" { Peri-TecladoRaton }
            "0" { return }
            default { Write-Host "Opcion invalida." -ForegroundColor Red; Start-Sleep -Seconds 1 }
        }
    }
}
