# 🎮 PS2Tools

### 🚀 PS2Tools Version 1 — PlayStation 2 Disc Identifier

PS2Tools es una herramienta de escritorio para **Windows** diseñada para identificar y analizar técnicamente discos físicos originales y no originales de **PlayStation 2**.

El proyecto combina un launcher desarrollado en **C# / .NET 8 WinForms** con una implementación de análisis en **PowerShell 7**, utilizando una base de datos local y recursos de idioma independientes.

PS2Tools está diseñado desde el principio para funcionar **completamente offline**, sin APIs externas, scraping, servicios web ni bases de datos online.

---
## 🧱 Tecnologías

![Platform](https://img.shields.io/badge/platform-Windows-0078D6?style=flat\&logo=windows\&logoColor=white)

![Language](https://img.shields.io/badge/language-C%23-512BD4?style=flat\&logo=csharp\&logoColor=white)

![Framework](https://img.shields.io/badge/.NET-8-512BD4?style=flat\&logo=dotnet\&logoColor=white)

![PowerShell](https://img.shields.io/badge/PowerShell-7-5391FE?style=flat\&logo=powershell\&logoColor=white)

![UI](https://img.shields.io/badge/UI-WinForms-0078D4?style=flat)

![Database](https://img.shields.io/badge/database-JSON-000000?style=flat)

![Architecture](https://img.shields.io/badge/architecture-offline-success?style=flat)

![Executable](https://img.shields.io/badge/output-.exe-5C2D91?style=flat)

![Architecture](https://img.shields.io/badge/architecture-x64-blue?style=flat)

![Status](https://img.shields.io/badge/status-stable-brightgreen?style=flat)

![Security](https://img.shields.io/badge/code%20signing-signed-success?style=flat)

![Localization](https://img.shields.io/badge/i18n-11%20languages-blue?style=flat)

![License](https://img.shields.io/badge/license-MIT-green?style=flat)

---

## ✨ Características principales

* 🎮 Identificación de discos físicos de PlayStation 2
* 💿 Detección automática de la unidad óptica disponible
* 🔎 Identificación mediante `SYSTEM.CNF` y código BOOT
* 🆔 Conversión y reconocimiento de seriales PS2
* 📚 Consulta de base de datos local `games.json`
* 🧩 Análisis de estructura del disco
* 📁 Conteo de archivos y directorios
* 💾 Cálculo del tamaño total del contenido
* 🔐 Análisis técnico de ejecutables ELF
* 🧠 Identificación de IOPRP e IRX
* 🎬 Detección de contenido multimedia y otros archivos
* 🧬 Generación de fingerprint técnico estructural
* 🔑 Cálculo de hashes SHA-256
* 📄 Generación automática de informe HTML
* 🌐 Internacionalización mediante archivos JSON
* 🪟 Interfaz y launcher nativos para Windows
* 📦 PowerShell 7 portable incluido
* 🚫 Funcionamiento completamente offline
* 🛡️ El disco físico nunca es modificado
* 🔏 Ejecutable de distribución firmado digitalmente

---

![Social Preview](images/Preview.png)

---

## 🌐 Internacionalización

PS2Tools utiliza archivos JSON independientes para la localización de la interfaz y de los informes.

Los idiomas se almacenan en:

```text
Languages/
```

La arquitectura permite seleccionar primero la cultura exacta, después el idioma base y finalmente utilizar inglés como fallback.

Actualmente se incluyen recursos para:

* 🇪🇸 Español
* 🇺🇸 English
* 🇩🇪 Deutsch
* 🇫🇷 Français
* 🇮🇹 Italiano
* 🇧🇷 Português (Brasil)
* 🇯🇵 日本語
* 🇰🇷 한국어
* 🇨🇳 简体中文
* 🇷🇺 Русский
* 🇳🇱 Nederlands

La incorporación de un nuevo idioma está diseñada para realizarse mediante un nuevo archivo JSON, sin necesidad de modificar la lógica principal de la aplicación.

---

## 🔬 Análisis técnico

PS2Tools no se limita a mostrar el nombre de un juego.

Durante el análisis puede obtener información técnica como:

### Identificación

* Nombre del juego
* Serial
* Plataforma
* Región
* Publisher
* Developer
* Año
* Género
* Versión
* Video Mode

### Estructura del disco

* Sistema de archivos
* Etiqueta del volumen
* Cantidad de archivos
* Cantidad de directorios
* Tamaño total
* Archivos raíz
* Directorios raíz

### Ejecutable BOOT

* Nombre del ejecutable
* Tamaño
* Tipo ELF
* Arquitectura
* Endianness
* ABI
* Tipo de ejecutable
* Máquina
* Versión ELF
* Entry Point
* SHA-256

### Módulos y contenido

* IOPRP
* IRX
* Videos SFD
* Audio
* Imágenes
* Binarios
* Datos
* Otros contenidos detectados

---

## 🧬 Fingerprint técnico

PS2Tools genera un **fingerprint técnico estructural** del disco.

El fingerprint se construye a partir de información estructural y técnica del medio, incluyendo elementos como:

* Rutas
* Tamaños
* Identidad del contenido
* `SYSTEM.CNF`
* Ejecutable BOOT
* SHA-256 del BOOT
* SHA-256 de `SYSTEM.CNF`
* Estructura general del disco

El fingerprint utiliza **SHA-256**.

Este mecanismo permite representar técnicamente la estructura analizada sin tener que realizar un hash completo de todos los gigabytes del disco.

---

## 📄 Informe HTML

Después de una identificación correcta, PS2Tools genera automáticamente un informe HTML técnico.

El informe es autónomo y contiene sus propios recursos necesarios para visualizarse.

Incluye:

* Identificación del juego
* Información del disco
* Estructura del medio
* Análisis ELF
* IOPRP e IRX
* Contenido detectado
* Fingerprint técnico
* Hashes SHA-256
* Características detectadas
* Contenido de `SYSTEM.CNF`

El informe puede abrirse directamente en el navegador.

---

## 🛡️ Funcionamiento offline

PS2Tools está diseñado para funcionar sin conexión a Internet.

No utiliza:

* APIs online
* Web scraping
* Servicios externos
* Registro online
* Bases de datos remotas
* Servicios de identificación externos

La información del juego procede de la base de datos local:

```text
Database/games.json
```

Esto permite utilizar PS2Tools incluso en equipos sin conexión a Internet.

---

## 💿 Seguridad del disco físico

PS2Tools está diseñado como una herramienta de **lectura y análisis**.

La aplicación:

* ✔️ Lee información del disco
* ✔️ Analiza su estructura
* ✔️ Examina archivos técnicos
* ✔️ Genera información local
* ❌ No modifica el disco
* ❌ No escribe archivos en el disco
* ❌ No altera `SYSTEM.CNF`
* ❌ No altera ejecutables
* ❌ No realiza operaciones de escritura sobre el medio físico

El análisis se realiza de forma no destructiva.

---

## 🏗️ Arquitectura del proyecto

```text
PS2Tools/
│
├── Assets/
│   ├── icon.ico
│   ├── logo.png
│   └── Pablo_Tellez_A.png
│
├── Database/
│   └── games.json
│
├── Html/
│   ├── PS2Tools.Html.ps1
│   └── PS2Tools.css
│
├── Languages/
│   ├── es-ES.json
│   ├── en-US.json
│   ├── de-DE.json
│   ├── fr-FR.json
│   ├── it-IT.json
│   ├── pt-BR.json
│   ├── ja-JP.json
│   ├── ko-KR.json
│   ├── zh-CN.json
│   ├── ru-RU.json
│   └── nl-NL.json
│
├── src/
│   ├── Bootstrap.ps1
│   ├── Core/
│   │   ├── Disc.Context.ps1
│   │   ├── Disc.Report.ps1
│   │   ├── Disc.Scanner.ps1
│   │   └── Disc.Utilities.ps1
│   │
│   ├── Database/
│   │   └── Game.Database.ps1
│   │
│   └── PlayStation/
│       ├── Artifacts.Provider.ps1
│       ├── Elf.Provider.ps1
│       ├── Features.Provider.ps1
│       ├── Homebrew.Provider.ps1
│       ├── Serial.Provider.ps1
│       └── SystemCnf.Provider.ps1
│
├── build.cmd
├── Get-PlayStationGame.ps1
├── PowerShell.Payload.zip
├── PS2Tools.Payload.zip
├── Program.cs
├── PS2ToolsLauncher.csproj
├── README.md
├── RELEASE_DESCRIPTION.md
├── requirements.txt
└── .gitignore
```

---

## 📷 Capturas de pantalla

<p align="center">
  <img src="images/screenshot.png?v=2" alt="Vista previa de la aplicación" width="600"/>
</p>

---

## 🚀 Descarga y uso normal

La versión estable se distribuye mediante **GitHub Releases**.

### Pasos

1. Descargar el archivo ZIP de la versión correspondiente.
2. Extraer el contenido.
3. Ejecutar:

```text
PS2Tools.exe
```

4. Insertar un disco PlayStation 2.
5. PS2Tools detectará automáticamente la unidad óptica disponible.
6. El análisis se realizará localmente.
7. El informe HTML se abrirá automáticamente cuando la identificación finalice correctamente.

### Requisitos del usuario final

✔️ Windows 10 / Windows 11 x64

✔️ Unidad óptica compatible con lectura de discos PS2

✔️ No requiere PowerShell instalado

✔️ No requiere .NET instalado

✔️ No requiere Python

✔️ No requiere conexión a Internet

✔️ No requiere dependencias externas

PowerShell 7 se incluye de forma portable dentro de la distribución.

---

## 🛠️ Compilación desde el código fuente

Para desarrollar o recompilar PS2Tools se requiere:

* Windows x64
* .NET 8 SDK
* PowerShell 7
* Windows SDK
* SignTool únicamente para la firma de releases

Desde la carpeta raíz del proyecto:

```powershell
.\build.cmd
```

El proceso genera el ejecutable self-contained para Windows x64.

El resultado se encuentra en:

```text
bin\Release\net8.0-windows\win-x64\publish\PS2Tools.exe
```

---

## 📦 Distribución

El launcher se publica como:

* Windows x64
* Self-contained
* Single-file executable
* WinExe
* Sin consola PowerShell visible para el usuario
* PowerShell 7 portable incluido

La aplicación extrae sus componentes necesarios de forma local y utiliza el runtime portable incluido en la distribución.

---

## 🔏 Firma digital

Las versiones de distribución pueden estar firmadas digitalmente mediante Authenticode.

La firma utiliza:

```text
SHA-256
```

Los releases firmados también utilizan timestamp RFC3161.

El certificado que contiene la clave privada (`.pfx`) es un recurso privado del desarrollador y **no forma parte de la distribución pública ni debe publicarse en el repositorio**.

---

## 📁 Base de datos

La base de datos principal se encuentra en:

```text
Database/games.json
```

Es una base de datos local en formato JSON.

Su utilización permite que la identificación de juegos pueda realizarse sin depender de servicios online.

---

## 📋 Requirements

Los requisitos y herramientas utilizadas por el proyecto están documentados en:

```text
requirements.txt
```

El archivo documenta los requisitos de ejecución, desarrollo, compilación y distribución del proyecto.

---

## 📊 Estado del proyecto

* ✔️ Version 1
* ✔️ Estable
* ✔️ Funcionamiento offline
* ✔️ Compatible con Windows 10 / 11 x64
* ✔️ Identificación física de discos PS2
* ✔️ Análisis técnico
* ✔️ Fingerprint estructural SHA-256
* ✔️ Informe HTML
* ✔️ Internacionalización
* ✔️ PowerShell 7 portable
* ✔️ Launcher C# / .NET 8
* ✔️ Ejecutable self-contained
* ✔️ Firma digital para distribución

---

## 🔮 Posibles mejoras futuras

Algunas posibles líneas de evolución:

* Ampliación de la base de datos local
* Más idiomas
* Mejoras adicionales del análisis técnico
* Información técnica adicional de ejecutables y módulos
* Mejoras de presentación del informe
* Evolución de la interfaz gráfica
* Migración progresiva de componentes PowerShell hacia C# / .NET

Estas mejoras no forman parte necesariamente de Version 1.

---

## 🤝 Contribuciones

Las contribuciones, sugerencias, correcciones y mejoras son bienvenidas.

Si encuentras un problema o tienes una propuesta:

* Abre un **Issue**
* Envía un **Pull Request**
* Describe claramente el cambio propuesto

Las contribuciones deben mantener los principios fundamentales del proyecto:

* Funcionamiento offline
* Seguridad
* No modificación de discos físicos
* Compatibilidad con Windows
* Código mantenible
* Ausencia de dependencias externas innecesarias

---

## 📄 Licencia


Este proyecto se distribuye bajo la licencia:

**MIT License**

Consulta el archivo de licencia del repositorio para conocer los términos completos de distribución y uso.

---

## 👨‍💻 Autor

**Walter Pablo Téllez Ayala**  
Software Developer  
📍 Bolivia 🇧🇴 <img src="https://flagcdn.com/w20/bo.png" width="20"/><br>
📧 pharmakoz@gmail.com

© 2026 — PS2Tools

---

## ⚖️ Nota legal

PS2Tools está destinado al análisis legítimo de discos físicos de PlayStation 2 que sean propiedad del usuario o cuyo análisis esté autorizado.

El software está diseñado para realizar operaciones de lectura y análisis técnico y no modifica físicamente los discos analizados.

El autor no se responsabiliza por usos indebidos del software.

---

## 🎮 PS2Tools

**PlayStation Disc Identifier**

Herramienta de identificación y análisis técnico offline para discos de PlayStation 2.

**Version 1 — 2026**
