# 📦 PS2Tools – Notas de la Versión

## 🟢 Versión 1.0.0 – Edición Estable

**Fecha:** 31 de marzo de 2026

---

## 🚀 Resumen del Lanzamiento

Esta versión consolida **PS2Tools** como una herramienta de escritorio para la identificación y análisis técnico de discos físicos de **PlayStation 2**, con funcionamiento completamente offline.

El lanzamiento integra un launcher nativo desarrollado en **C# / .NET 8 WinForms**, el motor de análisis basado en **PowerShell 7**, una base de datos local de juegos y un sistema de generación de informes HTML autónomos.

---

## ✨ Cambios destacados

### 🎮 Identificación de discos PlayStation 2

* **Identificación automática del medio:** PS2Tools detecta automáticamente la unidad óptica disponible sin depender de una letra de unidad fija.

* **Detección mediante SYSTEM.CNF:** Se analiza `SYSTEM.CNF` para localizar el ejecutable BOOT del disco.

* **Reconocimiento de seriales:** Conversión y reconocimiento de códigos PS2 como `SCES`, `SLES`, `SLUS`, `SLPM`, `SCPS`, `SCAJ`, `SCKA` y `SLKA`.

* **Consulta de base de datos local:** Identificación del juego mediante `Database/games.json`, sin conexión a Internet.

### 🔬 Análisis técnico

* **Análisis de estructura del disco:** Detección del sistema de archivos, etiqueta de volumen, archivos, directorios y tamaño total.

* **Análisis del ejecutable BOOT:** Identificación de formato ELF, arquitectura, endianness, ABI, tipo de ejecutable, máquina, versión, entry point y SHA-256.

* **Identificación de módulos:** Detección de componentes técnicos como IOPRP e IRX.

* **Análisis multimedia:** Identificación de vídeos SFD, audio, imágenes, binarios y otros contenidos.

* **Clasificación estructural:** Organización del contenido del disco en grupos técnicos para facilitar el análisis.

### 🧬 Fingerprint técnico

* **Nuevo fingerprint estructural:** PS2Tools genera una huella técnica basada en la estructura y características del disco.

* **SHA-256:** El fingerprint utiliza SHA-256 sobre un manifiesto técnico y estructural, evitando realizar un hash completo de todos los gigabytes del medio.

* **Información utilizada:** Rutas, tamaños, identidad del contenido, `SYSTEM.CNF`, ejecutable BOOT, hashes SHA-256 y estructura general del disco.

### 📄 Informe HTML

* **Generación automática:** Después de una identificación correcta se genera un informe técnico HTML.

* **Informe autónomo:** El documento incorpora sus propios recursos necesarios para visualizarse.

* **Información técnica:** El informe incluye identificación del juego, estructura del disco, análisis ELF, módulos, contenido detectado, fingerprint y hashes SHA-256.

* **Apertura automática:** El informe se abre directamente en el navegador al finalizar correctamente el análisis.

### 🌐 Internacionalización

* **Sistema de idiomas:** Se incorporan recursos JSON independientes para la localización.

* **Idiomas incluidos:** Español, English, Deutsch, Français, Italiano, Português (Brasil), 日本語, 한국어, 简体中文, Русский y Nederlands.

* **Sistema de fallback:** La aplicación puede utilizar la cultura exacta, el idioma base y finalmente inglés como fallback.

### 🪟 Launcher y distribución

* **Launcher nativo:** Se incorpora un launcher desarrollado en C# / .NET 8 WinForms.

* **PowerShell 7 portable:** El runtime necesario se incluye dentro de la distribución.

* **Aplicación self-contained:** El usuario final no necesita instalar .NET ni PowerShell.

* **Single-file executable:** El launcher se distribuye como un único ejecutable Windows x64.

* **Modo WinExe:** La aplicación se ejecuta sin mostrar una consola de PowerShell al usuario.

### 🛡️ Seguridad y funcionamiento offline

* **Funcionamiento completamente offline:** No se utilizan APIs online, scraping, servicios externos ni bases de datos remotas.

* **Análisis no destructivo:** PS2Tools solamente realiza operaciones de lectura y análisis.

* **Protección del medio físico:** El software no modifica, escribe ni altera los discos PlayStation 2 analizados.

* **Ejecución independiente:** La distribución incorpora los componentes necesarios para funcionar sin depender de instalaciones externas.

### 🔏 Firma digital

* **Firma Authenticode:** El ejecutable de distribución puede estar firmado digitalmente.

* **SHA-256:** La firma utiliza SHA-256.

* **Timestamp RFC3161:** Las versiones firmadas incorporan timestamp RFC3161 para preservar la validez temporal de la firma.

---

## ⚙️ Detalles de Distribución

* **Plataforma:** Windows 10 / Windows 11 x64.
* **Framework:** .NET 8.
* **Launcher:** C# / WinForms.
* **Motor de análisis:** PowerShell 7.
* **Empaquetado:** Self-contained / Single-file.
* **Runtime PowerShell:** Portable incluido.
* **Base de datos:** JSON local.
* **Funcionamiento:** 100% offline.
* **Arquitectura:** x64.
* **Firma:** Authenticode SHA-256 con timestamp RFC3161 en releases firmados.

---

## 📊 Estado de la Versión

* **Versión:** 1.0.0
* **Estado:** Estable
* **Identificación física:** Implementada
* **Análisis técnico:** Implementado
* **Fingerprint estructural:** Implementado
* **Informe HTML:** Implementado
* **Internacionalización:** Implementada
* **Launcher C# / .NET 8:** Implementado
* **PowerShell 7 portable:** Incluido
* **Distribución self-contained:** Implementada

---

## 👨‍💻 Autor

**Walter Pablo Téllez Ayala**  
Software Developer  
📍 Bolivia 🇧🇴 <img src="https://flagcdn.com/w20/bo.png" width="20"/><br>
📧 pharmakoz@gmail.com

© 2026 — PS2Tools
