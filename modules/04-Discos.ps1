# ============================================================
# MODULO 04: GESTION DE DISCOS
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
        @{Label="Unidad"; Expression={$_.DriveLetter}}, @{Label="Etiqueta"; Expression={$_.FileSystemLabel}},
        @{Label="Sistema"; Expression={$_.FileSystem}}, @{Label="Libre (GB)"; Expression={[math]::Round($_.SizeRemaining / 1GB, 2)}},
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

function Smart-Diagnostico {
    Clear-Host
    Write-Host "Diagnostico SMART de Discos" -ForegroundColor Cyan
    Write-Host "===========================" -ForegroundColor Cyan
    Write-Host ""
    try {
        $discos = Get-PhysicalDisk -ErrorAction Stop
        foreach ($disco in $discos) {
            Write-Host "======================================" -ForegroundColor Cyan
            Write-Host "DISCO: $($disco.FriendlyName)" -ForegroundColor Green
            Write-Host "======================================" -ForegroundColor Cyan
            Write-Host "  Estado de Salud    : $($disco.HealthStatus)" -ForegroundColor $(if ($disco.HealthStatus -eq 'Healthy') { 'Green' } else { 'Red' })
            Write-Host "  Estado Operativo   : $($disco.OperationalStatus)"
            Write-Host "  Tipo de Medio      : $($disco.MediaType)"
            Write-Host "  Tamano             : $([math]::Round($disco.Size / 1GB, 2)) GB"
            Write-Host "  Interfaz           : $($disco.BusType)"
            Write-Host "  Numero de serie    : $($disco.SerialNumber)"
            try {
                $reliability = $disco | Get-StorageReliabilityCounter -ErrorAction Stop
                Write-Host ""
                Write-Host "  [DATOS SMART]" -ForegroundColor Yellow
                Write-Host "    Temperatura        : $($reliability.Temperature) C"
                Write-Host "    Ciclos inicio/paro : $($reliability.StartStopCycleCount)"
                Write-Host "    Errores L/E        : $($reliability.ReadErrorsTotal) / $($reliability.WriteErrorsTotal)"
            } catch {
                Write-Host "    [INFO] Datos SMART no disponibles." -ForegroundColor Gray
            }
            Write-Host ""
        }
    } catch {
        Write-Host "[ERROR] No se pudo obtener informacion SMART: $_" -ForegroundColor Red
    }
    Pause-Kit
}

function Discos-QuitarSoloLectura {
    Clear-Host
    Write-Host "Quitar atributo 'Solo Lectura'" -ForegroundColor Cyan
    Write-Host "===============================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Lista de discos:" -ForegroundColor Yellow
    Get-Disk | Where-Object BusType -ne "File Backed Virtual" | Format-Table Number, FriendlyName, Size -AutoSize
    $num = Read-Host "Escribe el NUMERO del disco a reparar"
    if ($num -match '^\d+$') {
        Set-Disk -Number $num -IsReadOnly $false -ErrorAction SilentlyContinue
        Write-Host "[OK] Atributo de Solo Lectura eliminado." -ForegroundColor Green
    } else { Write-Host "[ERROR] Numero invalido." -ForegroundColor Red }
    Pause-Kit
}

function Discos-QuitarOculto {
    Clear-Host
    Write-Host "Quitar atributo 'Oculto'" -ForegroundColor Cyan
    Write-Host "========================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Lista de discos:" -ForegroundColor Yellow
    Get-Disk | Where-Object BusType -ne "File Backed Virtual" | Format-Table Number, FriendlyName, Size -AutoSize
    $num = Read-Host "Escribe el NUMERO del disco a reparar"
    if ($num -match '^\d+$') {
        Get-Partition -DiskNumber $num | Set-Partition -IsHidden $false -ErrorAction SilentlyContinue
        Write-Host "[OK] Atributo Oculto eliminado." -ForegroundColor Green
    } else { Write-Host "[ERROR] Numero invalido." -ForegroundColor Red }
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
        if (Confirmar-Accion "Estas SEGURO de borrar TODO el disco $num?") {
            Clear-Disk -Number $num -RemoveData -RemoveOEM -Confirm:$false -ErrorAction SilentlyContinue
            Write-Host "[OK] Disco limpiado." -ForegroundColor Green
        }
    } else { Write-Host "[ERROR] Numero invalido." -ForegroundColor Red }
    Pause-Kit
}

function Discos-Formatear {
    Clear-Host
    Write-Host "Formatear Volumen (NTFS Rapido)" -ForegroundColor Cyan
    Write-Host "===============================" -ForegroundColor Cyan
    Write-Host ""
    Get-Volume | Where-Object DriveLetter | Format-Table DriveLetter, FileSystemLabel, FileSystem, Size -AutoSize
    $letter = Read-Host "Escribe la LETRA de la unidad a formatear (ej: E)"
    if ($letter -match '^[a-zA-Z]$') {
        if (Confirmar-Accion "Formatear la unidad $letter`:?") {
            Format-Volume -DriveLetter $letter -FileSystem NTFS -NewFileSystemLabel "DarlingUSB" -Confirm:$false -ErrorAction SilentlyContinue
            Write-Host "[OK] Unidad $letter` formateada." -ForegroundColor Green
        }
    } else { Write-Host "[ERROR] Letra invalida." -ForegroundColor Red }
    Pause-Kit
}

function SubMenu-Discos {
    while ($true) {
        Mostrar-Header
        Write-Host "   [ SUBMENU: GESTION DE DISCOS ]" -ForegroundColor Cyan
        Write-Host "=========================================" -ForegroundColor Magenta
        Write-Host " 1  - Estado DETALLADO de discos"
        Write-Host " 2  - Listar discos fisicos"
        Write-Host " 3  - Listar volumenes y letras"
        Write-Host " 4  - DIAGNOSTICO SMART DE DISCOS"
        Write-Host " 5  - Quitar 'Solo Lectura' de USB"
        Write-Host " 6  - Quitar atributo 'Oculto' de USB"
        Write-Host " 7  - Limpiar disco (PELIGRO!)"
        Write-Host " 8  - Formatear volumen (NTFS)"
        Write-Host " 0  - Volver al menu principal"
        Write-Host ""
        $opcion = Read-Host "Selecciona una opcion"
        switch ($opcion) {
            "1" { Discos-EstadoDetallado }
            "2" { Discos-ListarDiscos }
            "3" { Discos-ListarVolumenes }
            "4" { Smart-Diagnostico }
            "5" { Discos-QuitarSoloLectura }
            "6" { Discos-QuitarOculto }
            "7" { Discos-Limpiar }
            "8" { Discos-Formatear }
            "0" { return }
            default { Write-Host "Opcion invalida." -ForegroundColor Red; Start-Sleep -Seconds 1 }
        }
    }
}
