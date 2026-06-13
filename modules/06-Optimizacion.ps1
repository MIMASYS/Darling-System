# ============================================================
# MODULO 06: OPTIMIZACION DE WINDOWS 11
# ============================================================

function Opt-DesactivarCopilot {
    Clear-Host
    Write-Host "Desactivar Copilot (AI integrada)" -ForegroundColor Cyan
    Write-Host "=================================" -ForegroundColor Cyan
    Write-Host ""
    if (Confirmar-Accion "Desactivar Copilot?") {
        try {
            $path = "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot"
            if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
            Set-ItemProperty -Path $path -Name "TurnOffWindowsCopilot" -Value 1 -Type DWord -Force
            $path2 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot"
            if (-not (Test-Path $path2)) { New-Item -Path $path2 -Force | Out-Null }
            Set-ItemProperty -Path $path2 -Name "TurnOffWindowsCopilot" -Value 1 -Type DWord -Force
            Write-Host "[OK] Copilot desactivado." -ForegroundColor Green
        } catch { Write-Host "[ERROR] $_" -ForegroundColor Red }
        Pause-Kit
    }
}

function Opt-DesactivarWidgets {
    Clear-Host
    Write-Host "Desactivar Widgets" -ForegroundColor Cyan
    Write-Host "==================" -ForegroundColor Cyan
    Write-Host ""
    if (Confirmar-Accion "Desactivar Widgets?") {
        try {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value 0 -Type DWord -Force
            Write-Host "[OK] Widgets desactivados." -ForegroundColor Green
        } catch { Write-Host "[ERROR] $_" -ForegroundColor Red }
        Pause-Kit
    }
}

function Opt-DesactivarPhoneLink {
    Clear-Host
    Write-Host "Desactivar Phone Link" -ForegroundColor Cyan
    Write-Host "=====================" -ForegroundColor Cyan
    Write-Host ""
    if (Confirmar-Accion "Desinstalar Phone Link?") {
        try {
            Get-AppxPackage *Microsoft.YourPhone* | Remove-AppxPackage -ErrorAction SilentlyContinue
            Write-Host "[OK] Phone Link desinstalado." -ForegroundColor Green
        } catch { Write-Host "[ERROR] $_" -ForegroundColor Red }
        Pause-Kit
    }
}

function Opt-DesactivarXboxGameBar {
    Clear-Host
    Write-Host "Desactivar Xbox Game Bar" -ForegroundColor Cyan
    Write-Host "========================" -ForegroundColor Cyan
    Write-Host ""
    if (Confirmar-Accion "Desactivar Xbox Game Bar?") {
        try {
            $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR"
            if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
            Set-ItemProperty -Path $path -Name "AppCaptureEnabled" -Value 0 -Type DWord -Force
            Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0 -Type DWord -Force
            Write-Host "[OK] Xbox Game Bar desactivado." -ForegroundColor Green
        } catch { Write-Host "[ERROR] $_" -ForegroundColor Red }
        Pause-Kit
    }
}

function Opt-DesactivarTips {
    Clear-Host
    Write-Host "Desactivar Tips y Sugerencias" -ForegroundColor Cyan
    Write-Host "=============================" -ForegroundColor Cyan
    Write-Host ""
    if (Confirmar-Accion "Desactivar Tips y Sugerencias?") {
        try {
            $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
            Set-ItemProperty -Path $path -Name "SubscribedContent-338389Enabled" -Value 0 -Type DWord -Force
            Set-ItemProperty -Path $path -Name "SoftLandingEnabled" -Value 0 -Type DWord -Force
            Write-Host "[OK] Tips desactivados." -ForegroundColor Green
        } catch { Write-Host "[ERROR] $_" -ForegroundColor Red }
        Pause-Kit
    }
}

function Opt-DesactivarPublicidad {
    Clear-Host
    Write-Host "Desactivar Publicidad del Sistema" -ForegroundColor Cyan
    Write-Host "=================================" -ForegroundColor Cyan
    Write-Host ""
    if (Confirmar-Accion "Desactivar Publicidad del Sistema?") {
        try {
            $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
            Set-ItemProperty -Path $path -Name "ContentDeliveryAllowed" -Value 0 -Type DWord -Force
            Set-ItemProperty -Path $path -Name "SilentInstalledAppsEnabled" -Value 0 -Type DWord -Force
            $path3 = "HKCU:\Software\Policies\Microsoft\Windows\CloudContent"
            if (-not (Test-Path $path3)) { New-Item -Path $path3 -Force | Out-Null }
            Set-ItemProperty -Path $path3 -Name "DisableWindowsConsumerFeatures" -Value 1 -Type DWord -Force
            Write-Host "[OK] Publicidad desactivada." -ForegroundColor Green
        } catch { Write-Host "[ERROR] $_" -ForegroundColor Red }
        Pause-Kit
    }
}

function Opt-DesactivarAppsPreinstaladas {
    Clear-Host
    Write-Host "Desinstalar Apps Preinstaladas" -ForegroundColor Cyan
    Write-Host "==============================" -ForegroundColor Cyan
    Write-Host ""
    if (Confirmar-Accion "Desinstalar apps preinstaladas no criticas?") {
        $appsToRemove = @("*CandyCrush*","*Disney*","*Spotify*","*TikTok*","*Instagram*","*Netflix*","*WhatsApp*","*AdobeExpress*","*Twitter*","*Facebook*","*Solitaire*","*Minecraft*")
        $count = 0
        foreach ($app in $appsToRemove) {
            Get-AppxPackage -Name $app -ErrorAction SilentlyContinue | ForEach-Object {
                try { Remove-AppxPackage -Package $_.PackageFullName -ErrorAction SilentlyContinue; $count++ } catch { }
            }
        }
        Write-Host "[OK] $count aplicaciones desinstaladas." -ForegroundColor Green
        Pause-Kit
    }
}

function Opt-DesactivarPersonalizacionCloud {
    Clear-Host
    Write-Host "Desactivar Personalizacion en la Nube" -ForegroundColor Cyan
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host ""
    if (Confirmar-Accion "Desactivar Personalizacion en la Nube?") {
        try {
            $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudContent"
            if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
            Set-ItemProperty -Path $path -Name "DisableWindowsConsumerFeatures" -Value 1 -Type DWord -Force
            Write-Host "[OK] Personalizacion en la nube desactivada." -ForegroundColor Green
        } catch { Write-Host "[ERROR] $_" -ForegroundColor Red }
        Pause-Kit
    }
}

function Opt-TodasLasOptimizaciones {
    Clear-Host
    Write-Host "Aplicar TODAS las Optimizaciones" -ForegroundColor Red
    Write-Host "================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "ADVERTENCIA: Esta accion no se puede deshacer facilmente." -ForegroundColor Red
    Write-Host ""
    if (-not (Confirmar-Accion "Aplicar TODAS las optimizaciones?")) { return }
    Write-Host "Aplicando optimizaciones..." -ForegroundColor Yellow
    $tareas = @(
        @{Desc="Copilot"; Code={ $p="HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot"; if(-not(Test-Path $p)){New-Item -Path $p -Force|Out-Null}; Set-ItemProperty -Path $p -Name "TurnOffWindowsCopilot" -Value 1 -Type DWord -Force }},
        @{Desc="Widgets"; Code={ Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value 0 -Type DWord -Force }},
        @{Desc="Phone Link"; Code={ Get-AppxPackage *Microsoft.YourPhone* | Remove-AppxPackage -ErrorAction SilentlyContinue }},
        @{Desc="Xbox Game Bar"; Code={ $p="HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR"; if(-not(Test-Path $p)){New-Item -Path $p -Force|Out-Null}; Set-ItemProperty -Path $p -Name "AppCaptureEnabled" -Value 0 -Type DWord -Force }},
        @{Desc="Tips"; Code={ $p="HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; Set-ItemProperty -Path $p -Name "SubscribedContent-338389Enabled" -Value 0 -Type DWord -Force; Set-ItemProperty -Path $p -Name "SoftLandingEnabled" -Value 0 -Type DWord -Force }},
        @{Desc="Publicidad"; Code={ Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "ContentDeliveryAllowed" -Value 0 -Type DWord -Force }},
        @{Desc="Apps Preinstaladas"; Code={ @("*CandyCrush*","*Disney*","*Spotify*","*TikTok*","*Instagram*","*Netflix*") | ForEach-Object { Get-AppxPackage -Name $_ -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue } }},
        @{Desc="Personalizacion Cloud"; Code={ $p="HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudContent"; if(-not(Test-Path $p)){New-Item -Path $p -Force|Out-Null}; Set-ItemProperty -Path $p -Name "DisableWindowsConsumerFeatures" -Value 1 -Type DWord -Force }}
    )
    $i = 1
    foreach ($t in $tareas) {
        Write-Host "[$i/$($tareas.Count)] $($t.Desc)..." -NoNewline
        try { & $t.Code; Write-Host " [OK]" -ForegroundColor Green } catch { Write-Host " [ERROR]" -ForegroundColor Red }
        $i++
    }
    Write-Host ""
    Write-Host "[OK] Todas las optimizaciones aplicadas." -ForegroundColor Green
    Pause-Kit
}

function SubMenu-Optimizacion {
    while ($true) {
        Mostrar-Header
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
            default { Write-Host "Opcion invalida." -ForegroundColor Red; Start-Sleep -Seconds 1 }
        }
    }
}
