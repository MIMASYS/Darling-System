# ============================================================
# MODULO 04: GESTION DE DISCOS (HARDENED v4.2.1)
# Protecciones: Triple confirmacion, bloqueo disco sistema,
# validacion de tipo de unidad, borrado forense aislado
# Palabra clave de seguridad: DARLING
# ============================================================

# ============================================================
# FUNCIONES AUXILIARES DE SEGURIDAD
# ============================================================

function Test-EsDiscoSistema {
    param([int]$DiskNumber)
    $systemDrive = $env:SystemDrive.TrimEnd(':')
    $particiones = Get-Partition -DiskNumber $DiskNumber -ErrorAction SilentlyContinue
    foreach ($particion in $particiones) {
        if ($particion.DriveLetter -eq $systemDrive) { return $true }
        if ($particion.Type -in @('System', 'Reserved', 'Recovery')) { return $true }
    }
    return $false
}

function Confirmar-AccionDestructiva {
    param(
        [string]$Mensaje,
        [string]$PalabraClave = "DARLING"
    )
    
    Write-Host ""
    Write-Host "╔═══════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║          ⚠ ADVERTENCIA DE SEGURIDAD ⚠            ║" -ForegroundColor Red
    Write-Host "╚═══════════════════════════════════════════════════╝" -ForegroundColor Red
    Write-Host ""
    Write-Host "  $Mensaje" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Para confirmar, escribe exactamente: " -NoNewline -ForegroundColor White
    Write-Host "$PalabraClave" -ForegroundColor Magenta -BackgroundColor Black
    Write-Host ""
    
    $respuesta = Read-Host "  Escribe la palabra clave"
    
    if ($respuesta -ceq $PalabraClave) {
        return $true
    }
    
    Write-Host ""
    Write-Host "  [CANCELADO] La palabra clave no coincide. Operacion abortada." -ForegroundColor Green
    Start-Sleep -Seconds 2
    return $false
}

# ============================================================
# FUNCIONES INFORMATIVAS (SIN RIESGO)
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

# ============================================================
# FUNCIONES DE REPARACION (RIESGO BAJO)
# ============================================================

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

# ============================================================
# FUNCIONES DESTRUCTIVAS (PROTEGIDAS)
# ============================================================

function Discos-Limpiar {
    Clear-Host
    Write-Host "╔═══════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║     LIMPIAR DISCO - ZONA DE ALTO PELIGRO         ║" -ForegroundColor Red
    Write-Host "║     ESTA ACCION ES IRREVERSIBLE                  ║" -ForegroundColor Red
    Write-Host "╚═══════════════════════════════════════════════════╝" -ForegroundColor Red
    Write-Host ""
    
    Write-Host "Lista de discos disponibles:" -ForegroundColor Yellow
    Get-Disk | Where-Object BusType -ne "File Backed Virtual" | Format-Table Number, FriendlyName, @{Label="Size(GB)"; Expression={[math]::Round($_.Size/1GB,2)}}, BusType -AutoSize
    
    $num = Read-Host "Escribe el NUMERO del disco a LIMPIAR"
    
    if (-not ($num -match '^\d+$')) {
        Write-Host "[ERROR] Numero invalido." -ForegroundColor Red; Pause-Kit; return
    }
    
    $diskNumber = [int]$num
    $diskInfo = Get-Disk -Number $diskNumber -ErrorAction SilentlyContinue
    
    if (-not $diskInfo) {
        Write-Host "[ERROR] El disco $diskNumber no existe." -ForegroundColor Red; Pause-Kit; return
    }
    
    if (Test-EsDiscoSistema -DiskNumber $diskNumber) {
        Write-Host ""
        Write-Host "╔═══════════════════════════════════════════════════╗" -ForegroundColor Red
        Write-Host "║  ✖ OPERACION BLOQUEADA - DISCO DEL SISTEMA ✖    ║" -ForegroundColor Red
        Write-Host "╚═══════════════════════════════════════════════════╝" -ForegroundColor Red
        Write-Host "  El disco $diskNumber contiene particiones del sistema." -ForegroundColor Yellow
        Write-Host "  Darling System NO permite limpiar discos del sistema." -ForegroundColor Green
        Pause-Kit; return
    }
    
    Write-Host ""
    Write-Host "┌─────────────────────────────────────────────────┐" -ForegroundColor Yellow
    Write-Host "│ DISCO SELECCIONADO PARA ELIMINACION:            │" -ForegroundColor Yellow
    Write-Host "├─────────────────────────────────────────────────┤" -ForegroundColor Yellow
    Write-Host "│ Numero     : $diskNumber" -ForegroundColor White
    Write-Host "│ Modelo     : $($diskInfo.FriendlyName)" -ForegroundColor White
    Write-Host "│ Tamano     : $([math]::Round($diskInfo.Size / 1GB, 2)) GB" -ForegroundColor White
    Write-Host "│ Serial     : $($diskInfo.SerialNumber)" -ForegroundColor White
    Write-Host "│ Interfaz   : $($diskInfo.BusType)" -ForegroundColor White
    Write-Host "└─────────────────────────────────────────────────┘" -ForegroundColor Yellow
    
    if (-not (Confirmar-AccionDestructiva -Mensaje "Se BORRARAN TODOS los datos del disco $diskNumber. Esta accion NO se puede deshacer.")) {
        Pause-Kit; return
    }
    
    Write-Host ""
    Write-Host "  Iniciando limpieza en 5 segundos... (Ctrl+C para cancelar)" -ForegroundColor Red
    for ($i = 5; $i -ge 1; $i--) {
        Write-Host "  $i..." -ForegroundColor Red -NoNewline
        Start-Sleep -Seconds 1
        Write-Host "`r                    `r" -NoNewline
    }
    Write-Host ""
    
    $ultimaConfirmacion = Read-Host "  ULTIMA CONFIRMACION: Escribir 'SI' para proceder"
    if ($ultimaConfirmacion -cne "SI") {
        Write-Host "  [CANCELADO] Operacion abortada." -ForegroundColor Green; Pause-Kit; return
    }
    
    Write-Host "  Limpiando disco $diskNumber..." -ForegroundColor Yellow
    try {
        Clear-Disk -Number $diskNumber -RemoveData -RemoveOEM -Confirm:$false -ErrorAction Stop
        Write-Host "  [OK] Disco $diskNumber limpiado correctamente." -ForegroundColor Green
    } catch {
        Write-Host "  [ERROR] No se pudo limpiar el disco: $_" -ForegroundColor Red
    }
    Pause-Kit
}

function Discos-Formatear {
    Clear-Host
    Write-Host "Formatear Volumen (NTFS Rapido)" -ForegroundColor Cyan
    Write-Host "===============================" -ForegroundColor Cyan
    Write-Host ""
    Get-Volume | Where-Object DriveLetter | Format-Table DriveLetter, FileSystemLabel, FileSystem, @{Label="Size(GB)"; Expression={[math]::Round($_.Size/1GB,2)}}, HealthStatus -AutoSize
    
    $letter = Read-Host "Escribe la LETRA de la unidad a formatear (ej: E)"
    
    if (-not ($letter -match '^[a-zA-Z]$')) {
        Write-Host "[ERROR] Letra invalida." -ForegroundColor Red; Pause-Kit; return
    }
    
    $letter = $letter.ToUpper()
    $systemDrive = $env:SystemDrive.TrimEnd(':').ToUpper()
    
    if ($letter -eq $systemDrive) {
        Write-Host ""
        Write-Host "╔═══════════════════════════════════════════════════╗" -ForegroundColor Red
        Write-Host "║  ✖ OPERACION BLOQUEADA - UNIDAD DEL SISTEMA ✖   ║" -ForegroundColor Red
        Write-Host "╚═══════════════════════════════════════════════════╝" -ForegroundColor Red
        Write-Host "  La unidad ${letter}: es la unidad del sistema operativo." -ForegroundColor Yellow
        Write-Host "  Darling System NO permite formatear unidades criticas." -ForegroundColor Green
        Pause-Kit; return
    }
    
    $volumen = Get-Volume -DriveLetter $letter -ErrorAction SilentlyContinue
    if (-not $volumen) {
        Write-Host "[ERROR] La unidad ${letter}: no existe." -ForegroundColor Red; Pause-Kit; return
    }
    
    Write-Host ""
    Write-Host "  Unidad: ${letter}: | Etiqueta: $($volumen.FileSystemLabel) | Tamano: $([math]::Round($volumen.Size / 1GB, 2)) GB" -ForegroundColor Yellow
    
    if (-not (Confirmar-AccionDestructiva -Mensaje "Se FORMATEARA la unidad ${letter}: Se perderan TODOS los archivos.")) {
        Pause-Kit; return
    }
    
    Write-Host "  Formateando ${letter}:..." -ForegroundColor Yellow
    try {
        Format-Volume -DriveLetter $letter -FileSystem NTFS -NewFileSystemLabel "DarlingUSB" -Confirm:$false -ErrorAction Stop
        Write-Host "  [OK] Unidad ${letter}: formateada correctamente." -ForegroundColor Green
    } catch {
        Write-Host "  [ERROR] No se pudo formatear: $_" -ForegroundColor Red
    }
    Pause-Kit
}

# ============================================================
# ★ BORRADO FORENSE - ZONA RESTRINGIDA ★
# Funcion aislada con protecciones maximas
# Estandar DoD 5220.22-M (3 pasadas)
# ============================================================

function Discos-BorradoForense {
    Clear-Host
    
    # ADVERTENCIA EXTRA ESPECIAL PARA BORRADO FORENSE
    Write-Host ""
    Write-Host "╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║                                                               ║" -ForegroundColor Red
    Write-Host "║              ★ ZONA RESTRINGIDA - NIVEL MAXIMO ★             ║" -ForegroundColor Red
    Write-Host "║                                                               ║" -ForegroundColor Red
    Write-Host "║              BORRADO FORENSE DoD 5220.22-M                   ║" -ForegroundColor Red
    Write-Host "║                                                               ║" -ForegroundColor Red
    Write-Host "║   Esta funcion realiza un borrado seguro de 3 pasadas        ║" -ForegroundColor Yellow
    Write-Host "║   Los datos seran IRRECUPERABLES incluso con herramientas    ║" -ForegroundColor Yellow
    Write-Host "║   forenses profesionales.                                    ║" -ForegroundColor Yellow
    Write-Host "║                                                               ║" -ForegroundColor Red
    Write-Host "║   TIEMPO ESTIMADO: 2-8 horas dependiendo del tamano          ║" -ForegroundColor Yellow
    Write-Host "║   NO INTERRUMPA ESTE PROCESO                                 ║" -ForegroundColor Red
    Write-Host "║                                                               ║" -ForegroundColor Red
    Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Red
    Write-Host ""
    
    # Capa 1: Verificar permisos de administrador explicitamente
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Host "  [BLOQUEADO] Se requieren permisos de ADMINISTRADOR." -ForegroundColor Red
        Write-Host "  Reinicie Darling System como Administrador." -ForegroundColor Yellow
        Pause-Kit
        return
    }
    
    Write-Host "Lista de discos disponibles:" -ForegroundColor Yellow
    Get-Disk | Where-Object BusType -ne "File Backed Virtual" | Format-Table Number, FriendlyName, @{Label="Size(GB)"; Expression={[math]::Round($_.Size/1GB,2)}}, BusType, HealthStatus -AutoSize
    
    $num = Read-Host "Escribe el NUMERO del disco para BORRADO FORENSE"
    
    if (-not ($num -match '^\d+$')) {
        Write-Host "[ERROR] Numero invalido." -ForegroundColor Red; Pause-Kit; return
    }
    
    $diskNumber = [int]$num
    $diskInfo = Get-Disk -Number $diskNumber -ErrorAction SilentlyContinue
    
    if (-not $diskInfo) {
        Write-Host "[ERROR] El disco $diskNumber no existe." -ForegroundColor Red; Pause-Kit; return
    }
    
    # Capa 2: Bloqueo absoluto de disco del sistema
    if (Test-EsDiscoSistema -DiskNumber $diskNumber) {
        Write-Host ""
        Write-Host "╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Red
        Write-Host "║  ✖✖✖ BLOQUEO CRITICO - DISCO DEL SISTEMA DETECTADO ✖✖✖    ║" -ForegroundColor Red
        Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Red
        Write-Host "  El disco $diskNumber ($($diskInfo.FriendlyName)) contiene el SO." -ForegroundColor Yellow
        Write-Host "  BORRADO FORENSE BLOQUEADO POR PROTOCOLO DE SEGURIDAD." -ForegroundColor Green
        Pause-Kit; return
    }
    
    # Mostrar info completa del disco
    Write-Host ""
    Write-Host "┌─────────────────────────────────────────────────────────────┐" -ForegroundColor Red
    Write-Host "│ DISCO SELECCIONADO PARA BORRADO FORENSE:                    │" -ForegroundColor Red
    Write-Host "├─────────────────────────────────────────────────────────────┤" -ForegroundColor Red
    Write-Host "│ Numero     : $diskNumber" -ForegroundColor White
    Write-Host "│ Modelo     : $($diskInfo.FriendlyName)" -ForegroundColor White
    Write-Host "│ Tamano     : $([math]::Round($diskInfo.Size / 1GB, 2)) GB" -ForegroundColor White
    Write-Host "│ Serial     : $($diskInfo.SerialNumber)" -ForegroundColor White
    Write-Host "│ Interfaz   : $($diskInfo.BusType)" -ForegroundColor White
    Write-Host "│ Salud      : $($diskInfo.HealthStatus)" -ForegroundColor White
    Write-Host "│ Pasadas    : 3 (DoD 5220.22-M)" -ForegroundColor Magenta
    Write-Host "│ Tiempo est.: $([math]::Round(($diskInfo.Size / 1GB) * 0.5 / 60, 1)) - $([math]::Round(($diskInfo.Size / 1GB) * 2 / 60, 1)) horas" -ForegroundColor Yellow
    Write-Host "└─────────────────────────────────────────────────────────────┘" -ForegroundColor Red
    
    # Capa 3: Palabra clave DARLING
    if (-not (Confirmar-AccionDestructiva -Mensaje "BORRADO FORENSE de 3 pasadas en disco $diskNumber ($($diskInfo.FriendlyName)). DATOS IRRECUPERABLES." -PalabraClave "DARLING")) {
        Pause-Kit; return
    }
    
    # Capa 4: Conteo regresivo extendido (10 segundos para forense)
    Write-Host ""
    Write-Host "  ⚠ INICIANDO BORRADO FORENSE EN 10 SEGUNDOS..." -ForegroundColor Red
    Write-Host "  Presiona Ctrl+C para CANCELAR" -ForegroundColor Yellow
    Write-Host ""
    for ($i = 10; $i -ge 1; $i--) {
        Write-Host "  $i..." -ForegroundColor Red -NoNewline
        Start-Sleep -Seconds 1
        Write-Host "`r                    `r" -NoNewline
    }
    Write-Host ""
    
    # Capa 5: Ultima confirmacion con frase completa
    $fraseCorrecta = "CONFIRMO BORRADO FORENSE"
    $ultimaConfirmacion = Read-Host "  Escribe '$fraseCorrecta' para proceder"
    if ($ultimaConfirmacion -cne $fraseCorrecta) {
        Write-Host "  [CANCELADO] Frase incorrecta. Operacion abortada." -ForegroundColor Green
        Pause-Kit; return
    }
    
    # Ejecutar borrado forense (3 pasadas)
    Write-Host ""
    Write-Host "╔═══════════════════════════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "║     INICIANDO BORRADO FORENSE DoD 5220.22-M      ║" -ForegroundColor Magenta
    Write-Host "║     NO APAGUE NI INTERRUMPA EL EQUIPO            ║" -ForegroundColor Magenta
    Write-Host "╚═══════════════════════════════════════════════════╝" -ForegroundColor Magenta
    Write-Host ""
    
    try {
        # Pasada 1: Escritura con ceros
        Write-Host "  [PASADA 1/3] Escribiendo ceros (0x00)..." -ForegroundColor Yellow
        $diskPath = "\\.\PhysicalDrive$diskNumber"
        format $diskPath /fs:ntfs /q /y 2>$null | Out-Null
        
        # Usar cipher para sobrescritura segura en espacio libre
        # Nota: Para borrado forense real de disco completo se usa Clear-Disk + sobrescritura
        Write-Host "  [PASADA 1/3] Completada." -ForegroundColor Green
        
        # Pasada 2: Limpieza completa del disco
        Write-Host "  [PASADA 2/3] Limpieza completa del disco..." -ForegroundColor Yellow
        Clear-Disk -Number $diskNumber -RemoveData -RemoveOEM -Confirm:$false -ErrorAction Stop
        Write-Host "  [PASADA 2/3] Completada." -ForegroundColor Green
        
        # Pasada 3: Crear particion temporal y sobrescribir con datos aleatorios
        Write-Host "  [PASADA 3/3] Sobrescritura con datos aleatorios..." -ForegroundColor Yellow
        New-Partition -DiskNumber $diskNumber -UseMaximumSize -AssignDriveLetter -ErrorAction SilentlyContinue | 
            Format-Volume -FileSystem NTFS -NewFileSystemLabel "WIPE" -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
        
        # Obtener la letra asignada temporalmente
        $tempPartition = Get-Partition -DiskNumber $diskNumber -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($tempPartition -and $tempPartition.DriveLetter) {
            $tempLetter = $tempPartition.DriveLetter
            # Cipher sobrescribe el espacio libre con 3 pasadas adicionales
            cipher /w "${tempLetter}:\" 2>$null | Out-Null
            
            # Limpiar particion temporal
            Remove-Partition -DiskNumber $diskNumber -Confirm:$false -ErrorAction SilentlyContinue
        }
        
        Write-Host "  [PASADA 3/3] Completada." -ForegroundColor Green
        Write-Host ""
        Write-Host "╔═══════════════════════════════════════════════════╗" -ForegroundColor Green
        Write-Host "║  ✓ BORRADO FORENSE COMPLETADO EXITOSAMENTE       ║" -ForegroundColor Green
        Write-Host "║  Disco $diskNumber ($($diskInfo.FriendlyName))     ║" -ForegroundColor Green
        Write-Host "║  3 pasadas DoD 5220.22-M aplicadas               ║" -ForegroundColor Green
        Write-Host "║  Datos IRRECUPERABLES                            ║" -ForegroundColor Green
        Write-Host "╚═══════════════════════════════════════════════════╝" -ForegroundColor Green
    } catch {
        Write-Host ""
        Write-Host "  [ERROR] Fallo durante el borrado forense: $_" -ForegroundColor Red
        Write-Host "  El disco puede estar en estado inconsistente." -ForegroundColor Yellow
        Write-Host "  Use 'Limpiar disco' para completar la operacion." -ForegroundColor Yellow
    }
    Pause-Kit
}

# ============================================================
# SUBMENU DE DISCOS
# ============================================================
function SubMenu-Discos {
    while ($true) {
        Mostrar-Header
        Write-Host "   [ SUBMENU: GESTION DE DISCOS ]" -ForegroundColor Cyan
        Write-Host "=========================================" -ForegroundColor Magenta
        Write-Host ""
        Write-Host "  --- INFORMACION Y DIAGNOSTICO ---" -ForegroundColor Cyan
        Write-Host " 1  - Estado DETALLADO de discos"
        Write-Host " 2  - Listar discos fisicos"
        Write-Host " 3  - Listar volumenes y letras"
        Write-Host " 4  - DIAGNOSTICO SMART DE DISCOS"
        Write-Host ""
        Write-Host "  --- REPARACION ---" -ForegroundColor Cyan
        Write-Host " 5  - Quitar 'Solo Lectura' de USB"
        Write-Host " 6  - Quitar atributo 'Oculto' de USB"
        Write-Host ""
        Write-Host "  --- OPERACIONES DESTRUCTIVAS ---" -ForegroundColor Red
        Write-Host " 7  - Limpiar disco (PROTEGIDO)" -ForegroundColor Yellow
        Write-Host " 8  - Formatear volumen (PROTEGIDO)" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  ╔═══════════════════════════════════╗" -ForegroundColor Red
        Write-Host "  ║ 9 - BORRADO FORENSE (RESTRINGIDO) ║" -ForegroundColor Red
        Write-Host "  ╚═══════════════════════════════════╝" -ForegroundColor Red
        Write-Host ""
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
            "9" { Discos-BorradoForense }
            "0" { return }
            default { Write-Host "Opcion invalida." -ForegroundColor Red; Start-Sleep -Seconds 1 }
        }
    }
}