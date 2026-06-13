
# ❤ Darling System

**Version CherryRed Flavor 4.0 - Arquitectura Modular**  
*Dirty and dummy system*  
Created by: MIMASYS. Chu.  
Co-authored by: Qwen (AI Dev)

---

## Instalación Rápida

Copia y pega este comando en PowerShell como administrador para descargar e iniciar el script al instante:


irm https://raw.githubusercontent.com/MIMASYS/Darling-System/main/Install.ps1 | iex

---

## Descripción

Darling System es un kit de herramientas todo-en-uno para Windows 11/10, desarrollado en PowerShell con **arquitectura modular**. Permite gestionar, diagnosticar, optimizar y mantener el sistema operativo desde una interfaz de menú intuitiva.

Arquitectura Modular (v4.0)

A partir de la versión 4.0, el proyecto utiliza una estructura modular profesional con 13 módulos independientes:

- **00-Core.ps1** - Funciones auxiliares y configuración
- **01-Utilidades.ps1** - Información del sistema, RAM, CPU, red
- **02-Herramientas.ps1** - Taskmgr, resmon, servicios
- **03-Mantenimiento.ps1** - Limpieza, SFC, DISM, punto de restauración
- **04-Discos.ps1** - Estado, SMART, formateo
- **05-Boot.ps1** - BIOS, modo seguro
- **06-Optimizacion.ps1** - Tweaks de Windows 11
- **07-Descargas.ps1** - Descargador de herramientas
- **08-Perifericos.ps1** - USB, impresoras, Bluetooth, cámaras
- **09-Red.ps1** - Reparación avanzada de red
- **10-Tecnico.ps1** - msinfo32, regedit, gpedit
- **11-Winget.ps1** - Instalación con winget
- **12-Reportes.ps1** - Reportes HTML y TXT

---

## Características

### Utilidades del Sistema
- Información completa del sistema (SO, CPU, RAM, GPU)
- Estado detallado de RAM (con detección de tipo DDR3/DDR4/DDR5)
- Estado detallado de CPU
- Información de red y direcciones IP
- Pruebas de conexión a Internet (multi-test)
- Análisis de procesos pesados
- Estado de Hyper-V
- Estado de batería (laptops)
- Servicios críticos del sistema
- Eventos recientes del sistema

### Herramientas de Gestión
- Administrador de tareas
- Monitor de recursos
- Servicios de Windows
- Administración de equipos
- Reinicio de Explorer

### Mantenimiento
- Limpieza de archivos temporales
- Limpieza de caché DNS
- Ejecución de SFC (System File Checker)
- Ejecución de DISM (Deployment Image Servicing)
- **NUEVO**: Reparación completa de Windows (DISM + SFC)
- **NUEVO**: Crear punto de restauración del sistema

### Gestión de Discos
- Estado detallado de discos y volúmenes
- **NUEVO**: Diagnóstico SMART de discos (temperatura, horas de uso, errores)
- Quitar atributo "Solo Lectura" de USB
- Quitar atributo "Oculto" de USB
- Limpieza completa de discos
- Formateo rápido NTFS

### Opciones de Arranque
- Reinicio directo a BIOS/UEFI
- Menú de arranque avanzado
- Modo seguro (normal, con red, con CMD)

### Optimización de Windows 11
- Desactivar Copilot (AI integrada)
- Desactivar Widgets
- Desinstalar Phone Link
- Desactivar Xbox Game Bar
- Desactivar Tips y sugerencias
- Desactivar publicidad del sistema
- Desinstalar apps preinstaladas (bloatware)
- Desactivar personalización en la nube
- Aplicar todas las optimizaciones de una vez

### Descarga de Herramientas
- Descarga individual o masiva de herramientas especializadas
- Selección de unidad de destino
- Reintentos automáticos ante fallos
- Herramientas incluidas:
  - HDDScan, HWiNFO, CrystalDiskInfo, MemTest86
  - Autoruns, Process Explorer, Process Monitor (Sysinternals)
  - Everything, Rufus, 7-Zip, WinRAR
  - Brave Browser, Wireshark

### NUEVO: Periféricos y Hardware
- Dispositivos USB conectados
- Impresoras instaladas
- Dispositivos Bluetooth
- Cámaras web detectadas
- Dispositivos con errores en el administrador de dispositivos
- Información detallada de monitores conectados
- Dispositivos de audio instalados
- Teclados y ratones detectados

### NUEVO: Reparación Avanzada de Red
- Vaciar caché DNS
- Liberar y renovar dirección IP
- Reiniciar Winsock
- Reiniciar pila TCP/IP
- Mostrar configuración IP actual
- Pruebas automáticas de conectividad
- Reparación completa de red (todo en uno)

### NUEVO: Modo Técnico
- msinfo32 (Información del sistema)
- dxdiag (Diagnóstico DirectX)
- eventvwr.msc (Visor de eventos)
- perfmon.msc (Monitor de rendimiento)
- devmgmt.msc (Administrador de dispositivos)
- diskmgmt.msc (Administración de discos)
- regedit (Editor de registro)
- secpol.msc (Política de seguridad local)
- gpedit.msc (Editor de directivas de grupo)
- taskschd.msc (Programador de tareas)

### NUEVO: Instalación con Winget
- 7-Zip
- Everything
- CrystalDiskInfo
- HWiNFO
- Wireshark
- Brave Browser
- Rufus

###  NUEVO: Reportes
- Reporte TXT al Escritorio
- **NUEVO**: Reporte HTML avanzado con estilos CSS profesionales

---

## Requisitos

- **Sistema operativo**: Windows 10 / Windows 11
- **PowerShell**: 5.1 o superior
- **Permisos**: Se recomienda ejecutar como Administrador
- **Conexión a Internet**: Requerida para la sección de descargas y verificación de actualizaciones

---

## Instalación

### Opción 1: Instalación Rápida (Recomendada)

irm https://raw.githubusercontent.com/MIMASYS/Darling-System/main/Install.ps1 | iex


### Opción 2: Descarga Manual

1. Ve a la sección [Releases](https://github.com/MIMASYS/Darling-System/releases)
2. Descarga `DarlingSystem_v4.0.zip`
3. Extrae el contenido en una carpeta (por ejemplo: `C:\Tools\DarlingSystem`)
4. Abre PowerShell como Administrador
5. Navega a la carpeta:
   ```powershell
   cd C:\Tools\DarlingSystem

6. Si es la primera vez, permite la ejecución de scripts:

   Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
   
7. Ejecuta el script:
  
   .\DarlingSystem.ps1


---

## ⚠️ Advertencias

- **Ejecutar como Administrador**: Muchas funciones (SFC, DISM, gestión de discos, optimización) requieren permisos elevados.
- **Acciones destructivas**: Funciones como "Limpiar disco" o "Formatear volumen" son **irreversibles**. El script incluye confirmaciones dobles, pero úsalas con responsabilidad.
- **Modo Seguro**: Si activas el Modo Seguro, recuerda salir manualmente ejecutando:
  ```powershell
  bcdedit /deletevalue {current} safeboot
  ```
- **Descargas**: Las URLs apuntan a los sitios oficiales de cada herramienta, pero siempre verifica la integridad de los archivos descargados.
- **Autoverificación**: El script verifica automáticamente si hay nuevas versiones en GitHub al iniciar.

---

## Actualizaciones

El script verifica automáticamente si hay nuevas versiones al iniciar. Si hay una actualización disponible, verás un mensaje amarillo con un enlace para descargarla.

Para actualizar manualmente:
1. Descarga la nueva versión desde [Releases](https://github.com/MIMASYS/Darling-System/releases)
2. Reemplaza los archivos antiguos
3. Ejecuta el script nuevamente

---


## Contribuciones

Las contribuciones son bienvenidas. Si encuentras un bug o tienes una sugerencia, abre un issue o envía un pull request.

### Estructura del Proyecto

```
Darling-System/
├── DarlingSystem.ps1          ← Script principal (menú)
├── version.txt                ← Archivo de versión para autoverificación
├── README.md                  ← Este archivo
├── LICENSE                    ← Licencia MIT
└── modules/
    ├── 00-Core.ps1
    ├── 01-Utilidades.ps1
    ├── 02-Herramientas.ps1
    ├── 03-Mantenimiento.ps1
    ├── 04-Discos.ps1
    ├── 05-Boot.ps1
    ├── 06-Optimizacion.ps1
    ├── 07-Descargas.ps1
    ├── 08-Perifericos.ps1
    ├── 09-Red.ps1
    ├── 10-Tecnico.ps1
    ├── 11-Winget.ps1
    └── 12-Reportes.ps1
```

---

##  Contacto

- **Autor**: MIMASYS. Chu.
- **Co-autor**: Qwen (AI Dev)
- **Repositorio**: [GitHub](https://github.com/MIMASYS/Darling-System)

---

##  Historial de Versiones

- **v4.0** - Arquitectura modular con 13 módulos, periféricos, SMART, reparación de red, modo técnico, winget
- **v3.1** - Autoverificación de actualizaciones desde GitHub
- **v3.0** - Descargador de herramientas con selección de unidad
- **v2.3** - Optimización de Windows 11 (Copilot, Widgets, bloatware)
- **v2.2** - Opciones de arranque (BIOS, Modo Seguro)
- **v2.1** - Gestión de discos avanzada
- **v2.0** - Submenús organizados
- **v1.0** - Versión inicial

---

*Made with ❤ by MIMASYS & Qwen*
```
