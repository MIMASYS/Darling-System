
# ❤ Darling System

**Version CherryRed Flavor 3.1**  
*Dirty and dummy system*  
Created by: MIMASYS. Chu.

---
Copia y pega el comando en PowerShell como administrador para descargar e iniciar el script al instante.

irm https://raw.githubusercontent.com/MIMASYS/Darling-System/main/DarlingSystemv.ps1 | iex

Darling System es un kit de herramientas todo-en-uno para Windows 11/10, desarrollado en PowerShell. Permite gestionar, diagnosticar, optimizar y mantener el sistema operativo desde una interfaz de menú intuitiva.

---

Características

Utilidades del Sistema
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

Herramientas de Gestión
- Administrador de tareas
- Monitor de recursos
- Servicios de Windows
- Administración de equipos
- Reinicio de Explorer

Mantenimiento
- Limpieza de archivos temporales
- Limpieza de caché DNS
- Ejecución de SFC (System File Checker)
- Ejecución de DISM (Deployment Image Servicing)

Gestión de Discos
- Estado detallado de discos y volúmenes
- Quitar atributo "Solo Lectura" de USB
- Quitar atributo "Oculto" de USB
- Limpieza completa de discos
- Formateo rápido NTFS

Opciones de Arranque
- Reinicio directo a BIOS/UEFI
- Menú de arranque avanzado
- Modo seguro (normal, con red, con CMD)

Optimización de Windows 11
- Desactivar Copilot (AI integrada)
- Desactivar Widgets
- Desinstalar Phone Link
- Desactivar Xbox Game Bar
- Desactivar Tips y sugerencias
- Desactivar publicidad del sistema
- Desinstalar apps preinstaladas (bloatware)
- Desactivar personalización en la nube
- Aplicar todas las optimizaciones de una vez

Descarga de Herramientas
- Descarga individual o masiva de herramientas especializadas
- Selección de unidad de destino
- Reintentos automáticos ante fallos
- Herramientas incluidas:
  - HDDScan, HWiNFO, CrystalDiskInfo, MemTest86
  - Autoruns, Process Explorer, Process Monitor (Sysinternals)
  - Everything, Rufus, 7-Zip, WinRAR
  - Brave Browser, Wireshark

---

Requisitos

- **Sistema operativo**: Windows 10 / Windows 11
- **PowerShell**: 5.1 o superior
- **Permisos**: Se recomienda ejecutar como Administrador
- **Conexión a Internet**: Requerida para la sección de descargas

---

Instalación

1. Descarga el archivo `DarlingSystemv.ps1`
2. Abre PowerShell como Administrador
3. Si es la primera vez, permite la ejecución de scripts:
   ```powershell
   Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
   ```
4. Ejecuta el script:
   ```powershell
   .\DarlingSystemv.ps1
   ```

---

Advertencias

- **Ejecutar como Administrador**: Muchas funciones (SFC, DISM, gestión de discos, optimización) requieren permisos elevados.
- **Acciones destructivas**: Funciones como "Limpiar disco" o "Formatear volumen" son **irreversibles**. El script incluye confirmaciones dobles, pero úsalas con responsabilidad.
- **Modo Seguro**: Si activas el Modo Seguro, recuerda salir manualmente ejecutando:
  ```powershell
  bcdedit /deletevalue {current} safeboot
  ```
- **Descargas**: Las URLs apuntan a los sitios oficiales de cada herramienta, pero siempre verifica la integridad de los archivos descargados.

---

Licencia

Este proyecto está bajo la licencia MIT.

---

Contribuciones

Las contribuciones son bienvenidas. Si encuentras un bug o tienes una sugerencia, abre un issue o envía un pull request.

---

Contacto

- **Autor**: MIMASYS. Chu.
- **Repositorio**: [GitHub](https://github.com/MIMASYS/Darling-System)

---

*Made with ❤ by MIMASYS*
```
