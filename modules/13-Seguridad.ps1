# ============================================================
# MODULO 13: SEGURIDAD DEL SISTEMA
# ============================================================

function Seg-SecureBoot {
    Clear-Host
    Write-Host "Estado de Secure Boot" -ForegroundColor Cyan
    Write-Host "=====================" -ForegroundColor Cyan
    Write-Host ""
    try {
        $secureBoot = Confirm-SecureBootUEFI
        Write-Host "[SECURE BOOT]" -ForegroundColor Yellow
        if ($secureBoot) {
            Write-Host "  Estado        : ACTIVADO" -ForegroundColor Green
            Write-Host "  Proteccion    : Sistema protegido contra bootkits/rootkits" -ForegroundColor Green
        } else {
            Write-Host "  Estado        : DESACTIVADO" -ForegroundColor Red
            Write-Host "  Advertencia   : El sistema es vulnerable a modificaciones de arranque" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "[SECURE BOOT]" -ForegroundColor Yellow
        Write-Host "  Estado        : NO DISPONIBLE / LEGACY BIOS" -ForegroundColor Yellow
    }
    Write-Host ""
    Pause-Kit
}

function Seg-EstadoDefenderFirewallUAC {
    Clear-Host
    Write-Host "Estado de Seguridad del Sistema" -ForegroundColor Cyan
    Write-Host "===============================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "[WINDOWS DEFENDER]" -ForegroundColor Yellow
    try {
        $defender = Get-MpComputerStatus -ErrorAction Stop
        Write-Host "  Antivirus             : $(if ($defender.AntivirusEnabled) { 'ACTIVADO' } else { 'DESACTIVADO' })" -ForegroundColor $(if ($defender.AntivirusEnabled) { 'Green' } else { 'Red' })
        Write-Host "  Antispyware           : $(if ($defender.AntispywareEnabled) { 'ACTIVADO' } else { 'DESACTIVADO' })" -ForegroundColor $(if ($defender.AntispywareEnabled) { 'Green' } else { 'Red' })
        Write-Host "  Ultima actualizacion  : $($defender.AntivirusSignatureLastUpdated.ToString('dd/MM/yyyy HH:mm'))"
    } catch {
        Write-Host "  No se pudo obtener informacion (Posible desinstalacion o error)" -ForegroundColor Red
    }
    Write-Host ""
    
    Write-Host "[FIREWALL DE WINDOWS]" -ForegroundColor Yellow
    try {
        $firewall = Get-NetFirewallProfile -ErrorAction Stop
        foreach ($profile in $firewall) {
            $estado = if ($profile.Enabled) { "ACTIVADO" } else { "DESACTIVADO" }
            Write-Host "  Perfil $($profile.Name.PadRight(10)): $estado" -ForegroundColor $(if ($profile.Enabled) { 'Green' } else { 'Red' })
        }
    } catch { Write-Host "  No se pudo obtener informacion del Firewall" -ForegroundColor Red }
    Write-Host ""
    
    Write-Host "[CONTROL DE CUENTAS (UAC)]" -ForegroundColor Yellow
    try {
        $uac = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -ErrorAction Stop
        $uacStatus = if ($uac.EnableLUA -eq 1) { "ACTIVADO" } else { "DESACTIVADO" }
        Write-Host "  Estado                : $uacStatus" -ForegroundColor $(if ($uac.EnableLUA -eq 1) { 'Green' } else { 'Red' })
    } catch { Write-Host "  No se pudo obtener informacion de UAC" -ForegroundColor Red }
    Write-Host ""
    Pause-Kit
}

function Seg-ConteoBSOD {
    Clear-Host
    Write-Host "Estabilidad del Sistema (BSOD y Errores)" -ForegroundColor Cyan
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "[BUSQUEDA DE BSOD (Ultimos 90 dias)]" -ForegroundColor Yellow
    try {
        $fechaInicio = (Get-Date).AddDays(-90)
        $bsods = Get-WinEvent -FilterHashtable @{
            LogName = 'System'
            ID = 1001
            ProviderName = 'Microsoft-Windows-WER-SystemErrorReporting'
            StartTime = $fechaInicio
        } -ErrorAction SilentlyContinue
        
        if ($bsods) {
            Write-Host "  BSODs encontrados   : $($bsods.Count)" -ForegroundColor Red
            Write-Host "  Ultimos 3 registros:" -ForegroundColor Yellow
            $bsods | Select-Object -First 3 | ForEach-Object {
                Write-Host "    - $($_.TimeCreated.ToString('dd/MM/yyyy')) : $($_.Message.Substring(0, [Math]::Min(70, $_.Message.Length)))..." -ForegroundColor Gray
            }
        } else {
            Write-Host "  BSODs encontrados   : 0" -ForegroundColor Green
            Write-Host "  Estado              : Sistema estable" -ForegroundColor Green
        }
    } catch { Write-Host "  No se pudo obtener informacion de BSODs" -ForegroundColor Yellow }
    Write-Host ""
    Pause-Kit
}

# --- FUNCIONES NUEVAS Y POTENTES ---

function Seg-PuertosAbiertos {
    Clear-Host
    Write-Host "Puertos de Red Escuchando (Listening)" -ForegroundColor Cyan
    Write-Host "======================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "[PUERTOS ABIERTOS - Top 15]" -ForegroundColor Yellow
    try {
        $puertos = Get-NetTCPConnection -State Listen -ErrorAction Stop | Select-Object -First 15 LocalPort, @{Name="Proceso"; Expression={(Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).ProcessName}}, OwningProcess
        if ($puertos) {
            $puertos | Format-Table @{Label="Puerto"; Expression={$_.LocalPort}}, @{Label="Proceso"; Expression={$_.Proceso}}, @{Label="PID"; Expression={$_.OwningProcess}} -AutoSize
        } else {
            Write-Host "  No se encontraron puertos abiertos inusuales." -ForegroundColor Green
        }
    } catch {
        Write-Host "  Se requieren permisos de Administrador para ver los puertos." -ForegroundColor Red
    }
    Write-Host ""
    Pause-Kit
}

function Seg-CuentasPrivilegiadas {
    Clear-Host
    Write-Host "Cuentas con Privilegios de Administrador" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "[ADMINISTRADORES LOCALES]" -ForegroundColor Yellow
    try {
        $admins = Get-LocalGroupMember -Group "Administradores" -ErrorAction Stop
        foreach ($admin in $admins) {
            $esPeligroso = $admin.Name -notmatch "Administrador" -and $admin.Name -notmatch "Administrator"
            $color = if ($esPeligroso) { 'Red' } else { 'Green' }
            Write-Host "  - $($admin.Name)" -ForegroundColor $color
            if ($esPeligroso) { Write-Host "    [!] ADVERTENCIA: Cuenta no estandar con privilegios elevados" -ForegroundColor Yellow }
        }
    } catch {
        Write-Host "  No se pudo obtener la lista (posible equipo en dominio o sin permisos)." -ForegroundColor Yellow
    }
    Write-Host ""
    Pause-Kit
}

function Seg-HistorialIniciosSesion {
    Clear-Host
    Write-Host "Historial de Inicios de Sesion (Ultimas 24h)" -ForegroundColor Cyan
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "[INTENTOS FALLIDOS (Event ID 4625)]" -ForegroundColor Yellow
    try {
        $fechaInicio = (Get-Date).AddHours(-24)
        $fallidos = Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4625; StartTime=$fechaInicio} -MaxEvents 5 -ErrorAction SilentlyContinue
        
        if ($fallidos) {
            Write-Host "  Se detectaron $($fallidos.Count) intentos fallidos recientes." -ForegroundColor Red
            foreach ($evento in $fallidos) {
                $mensaje = $evento.Message -split "`n" | Select-String "Nombre de la cuenta:" | Select-Object -First 1
                Write-Host "  - $($evento.TimeCreated.ToString('dd/MM HH:mm')) : $mensaje" -ForegroundColor Gray
            }
        } else {
            Write-Host "  No se detectaron intentos fallidos en las ultimas 24 horas." -ForegroundColor Green
        }
    } catch {
        Write-Host "  Se requieren permisos de Administrador para leer el registro de Seguridad." -ForegroundColor Red
    }
    Write-Host ""
    Pause-Kit
}

function Seg-PoliticasContrasenas {
    Clear-Host
    Write-Host "Politicas de Contraseñas Locales" -ForegroundColor Cyan
    Write-Host "================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "[CONFIGURACION ACTUAL]" -ForegroundColor Yellow
    try {
        $politicas = net accounts
        $longitud = ($politicas | Select-String "Longitud mínima de la contraseña") -replace ".*: ", ""
        $historial = ($politicas | Select-String "Forzar el historial de contraseñas") -replace ".*: ", ""
        $bloqueo = ($politicas | Select-String "Umbral de bloqueo de la cuenta") -replace ".*: ", ""
        
        Write-Host "  Longitud minima      : $longitud caracteres" -ForegroundColor $(if ([int]$longitud -ge 8) { 'Green' } else { 'Yellow' })
        Write-Host "  Historial recordado  : $historial contraseñas"
        Write-Host "  Bloqueo por intentos : $bloqueo intentos" -ForegroundColor $(if ($bloqueo -ne "Nunca") { 'Green' } else { 'Red' })
    } catch {
        Write-Host "  No se pudo obtener la informacion." -ForegroundColor Red
    }
    Write-Host ""
    Pause-Kit
}

function Seg-EstadoActualizaciones {
    Clear-Host
    Write-Host "Estado de Actualizaciones de Seguridad" -ForegroundColor Cyan
    Write-Host "======================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "[SERVICIO WINDOWS UPDATE]" -ForegroundColor Yellow
    $wuService = Get-Service wuauserv -ErrorAction SilentlyContinue
    if ($wuService) {
        Write-Host "  Estado del servicio  : $($wuService.Status)" -ForegroundColor $(if ($wuService.Status -eq 'Running') { 'Green' } else { 'Red' })
    }
    
    Write-Host ""
    Write-Host "[ULTIMOS PARCHES INSTALADOS]" -ForegroundColor Yellow
    try {
        $parches = Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 5
        foreach ($parche in $parches) {
            Write-Host "  - $($parche.HotFixID) : Instalado el $($parche.InstalledOn.ToString('dd/MM/yyyy'))" -ForegroundColor Gray
        }
    } catch {
        Write-Host "  No se pudo obtener el historial de parches." -ForegroundColor Red
    }
    Write-Host ""
    Pause-Kit
}

# ============================================================
# SUBMENU DE SEGURIDAD
# ============================================================

function SubMenu-Seguridad {
    while ($true) {
        Mostrar-Header
        Write-Host "   [ SUBMENU: SEGURIDAD DEL SISTEMA ]" -ForegroundColor Cyan
        Write-Host "=========================================" -ForegroundColor Magenta
        Write-Host " 1  - Estado de Secure Boot"
        Write-Host " 2  - Estado Defender / Firewall / UAC"
        Write-Host " 3  - Conteo de BSOD y Errores Criticos"
        Write-Host " 4  - Puertos de Red Abiertos (Listening)"
        Write-Host " 5  - Cuentas con Privilegios de Admin"
        Write-Host " 6  - Historial de Inicios de Sesion Fallidos"
        Write-Host " 7  - Politicas de Contrasenas Locales"
        Write-Host " 8  - Estado de Actualizaciones de Seguridad"
        Write-Host " 0  - Volver al menu principal"
        Write-Host ""
        $opcion = Read-Host "Selecciona una opcion"
        switch ($opcion) {
            "1" { Seg-SecureBoot }
            "2" { Seg-EstadoDefenderFirewallUAC }
            "3" { Seg-ConteoBSOD }
            "4" { Seg-PuertosAbiertos }
            "5" { Seg-CuentasPrivilegiadas }
            "6" { Seg-HistorialIniciosSesion }
            "7" { Seg-PoliticasContrasenas }
            "8" { Seg-EstadoActualizaciones }
            "0" { return }
            default { Write-Host "Opcion invalida." -ForegroundColor Red; Start-Sleep -Seconds 1 }
        }
    }
}