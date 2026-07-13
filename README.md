[![http://hackingyseguridad.com/](https://github.com/hackingyseguridad/ia/raw/main/banner.png)](http://hackingyseguridad.com/)

---

### webaudit.sh — Análisis Automatizado de Vulnerabilidades Web

![GitHub Release](https://img.shields.io/badge/Release-Continuous-informational) ![License](https://img.shields.io/badge/License-GPL--3.0-green) ![Kali Linux](https://img.shields.io/badge/Platform-Kali%20Linux-red) ![Shell](https://img.shields.io/badge/Language-Shell%20%2F%20Bash-4EAA25)

Conjunto integral de scripts de **pentesting ofensivo** y **auditoría de seguridad web** diseñados para automatizar el descubrimiento, enumeración y detección de vulnerabilidades en aplicaciones web, APIs REST y servicios HTTP/HTTPS en entornos Linux Kali. Incluye exploits NSE nativos para Nmap, scripts de bypass de WAF, inyección SQL, XSS, LFI/RFI y búsqueda de secretos en código fuente.

**El autor no se responsabiliza de uso malintencionado.** bajo jurisdicción española (Código Penal Art. 197-198) y europea (Directiva 2013/40/UE).

---

### Tabla de Contenidos

1. [Requisitos del Sistema](#requisitos-del-sistema)
2. [Instalación Rápida](#instalación-rápida)
3. [Scripts Principales](#scripts-principales)
4. [Herramientas Requeridas](#herramientas-requeridas)
5. [Vulnerabilidades Detectadas](#vulnerabilidades-detectadas)
6. [Ejemplos de Uso](#ejemplos-de-uso)
7. [Estructura del Repositorio](#estructura-del-repositorio)
8. [Referencias OWASP](#referencias-owasp)
9. [Contribuciones](#contribuciones)

---

### Requisitos del Sistema

### Sistema Operativo

| Requisito | Versión | Notas |
|-----------|---------|-------|
| **Base** | Kali Linux 2024.x+ | Debian Bookworm basado |
| **Kernel** | 6.0+ | Soporte completo de namespaces |
| **Arquitectura** | x86_64, ARM64 | Procesador 64-bit mínimo |
| **RAM** | 4 GB | 8 GB recomendado para scans masivos |
| **Almacenamiento** | 5 GB libre | 20 GB recomendado con diccionarios |

### Permisos

```bash
# Requisitos para ejecución completa
sudo -l  # Algunos scripts necesitan acceso root
sudo apt update && sudo apt upgrade
```

---

### Instalación Rápida

### Opción 1: Clonación desde GitHub (Recomendado)

```bash
# Clona el repositorio en tu directorio de trabajo
git clone https://github.com/hackingyseguridad/webaudit.git
cd webaudit

# Dale permisos de ejecución a todos los scripts
chmod +x *.sh

# (Opcional) Copia scripts al PATH para acceso global
sudo cp *.sh /usr/local/bin/
```

### Opción 2: Instalación Directa (One-Liner)

```bash
# Descarga e instala en un paso
git clone https://github.com/hackingyseguridad/webaudit.git && \
cd webaudit && chmod +x *.sh && sudo bash instalar.sh
```

### Verificación de Instalación

```bash
# Verifica que todos los dependencias están instaladas
bash -c 'for tool in nmap nikto wapiti golismero wafw00f; do command -v "$tool" &>/dev/null && echo "✓ $tool" || echo "✗ $tool"; done'
```

---

### Scripts Principales

### 1. **webaudit.sh** — Orquestador Principal

Ejecuta un flujo completo de auditoría web: reconocimiento → enumeración → análisis → explotación

```bash
./webaudit.sh [opciones]
```

| Opción | Descripción | Ejemplo |
|--------|-------------|---------|
| `-u, --url` | URL objetivo (HTTP/HTTPS) | `./webaudit.sh -u https://example.com` |
| `-f, --file` | Fichero con lista de URLs | `./webaudit.sh -f urls.txt` |
| `-o, --output` | Directorio de salida | `./webaudit.sh -u target.com -o ./resultados/` |
| `-t, --threads` | Número de threads paralelos | `./webaudit.sh -u target.com -t 10` |
| `-v, --verbose` | Modo verboso (debug) | `./webaudit.sh -u target.com -v` |

---

### 2. **Reconocimiento & Enumeración**

| Script | Función | Herramientas Asociadas |
|--------|---------|------------------------|
| **fqdnaudit.sh** | Enumeración DNS masiva, subdominios | `dnsenum`, `fierce`, `dnsrecon`, `dnsmap` |
| **get.sh** | Obtiene headers HTTP/HTTPS respuesta | `curl`, `openssl s_client` |
| **metodos.sh** | Enumera métodos HTTP (GET, POST, PUT, DELETE) | `curl`, `netcat` |
| **explorarweb.sh** | Rastreo de estructura web (directorios, ficheros) | `wget`, `curl` |
| **desgargarweb.sh** | Descarga página completa (mirrors) | `wget`, `aria2` |

---

### 3. **Búsqueda de Secretos & Credenciales**

| Script | Función | Patrones Detectados |
|--------|---------|-------------------|
| **secretos.sh** | Búsqueda de API keys, tokens en código fuente | AWS keys, GitHub tokens, Slack webhooks |
| **buscasecretos.sh** | Variante mejorada con regex personalizado | SSH keys, .pem, database URLs |
| **buscasecretosauto.sh** | Búsqueda automática en directorios descargados | Todas las anteriores + credenciales hardcoded |

**Ejemplo de uso:**
```bash
# Busca secretos en directorio descargado
./buscasecretosauto.sh ./website-mirror/

# Busca solo API keys en archivos específicos
./secretos.sh -d ./código/ -pattern "api.key|AWS_SECRET"
```

---

### 4. **Bypass WAF & 403/404**

| Script | Función | Técnicas |
|--------|---------|----------|
| **wafbypass.sh** | Intenta bypass de WAF (Cloudflare, ModSecurity, etc) | Headers alternativos, encoding, IP spoofing |
| **wafbypass2.sh** | Variante con payloads adicionales | Doble encoding, case variation, unicode |
| **salta403.sh** | Técnicas para saltar respuestas 403 Forbidden | Path traversal headers, X-Original-URL |
| **curl403.sh** | Testea múltiples combinaciones 403 bypass | 30+ variantes de headers |
| **curl404.sh** | Identifica falsos 404 | Content-length, time-based detection |
| **curl4xx.sh** | Análisis generalizado códigos 4xx | Status code clustering |

**Ejemplo de bypass WAF:**
```bash
# Intenta 20+ métodos de bypass contra Cloudflare
./wafbypass.sh -u https://protected.example.com -l verbose

# Guarda resultados en fichero
./wafbypass.sh -u https://protected.example.com -o bypass-results.txt
```

---

### 5. **Inyección SQL & SQLMap**

| Script | Función | Métodos |
|--------|---------|---------|
| **sqli.sh** | Test manual SQLi en parámetros GET/POST | Boolean, Time-based, Error-based |
| **sqliauto.sh** | Wrapper automático de sqlmap | Enumeración BBDDs, exfiltración |

```bash
# Test manual de SQLi con payloads clásicos
./sqli.sh -u "https://example.com/search.php?id=" -t GET

# Automatizado con sqlmap
./sqliauto.sh -u "https://example.com/login" -d "user=admin&pass=test" -t POST
```

---

### 6. **Pruebas de Autenticación HTTP**

| Script | Función | Autenticación |
|--------|---------|---------------|
| **httpbasico.sh** | Testea autenticación HTTP Basic | Usuario/contraseña en Base64 |
| **httpauthbasic.sh** | Fuerza bruta HTTP Basic | Diccionario de credenciales |
| **httpauthcod.sh** | Fuerza bruta con headers custom | Codificación alternativa |
| **httpsauthcod.sh** | HTTPS Basic auth con validación certificado | SSL/TLS verification |

---

### 7. **Exploits NSE para Nmap**

| Script NSE | CVE | Vulnerabilidad | Severidad |
|------------|-----|-----------------|-----------|
| **CVE-2019-19781.nse** | CVE-2019-19781 | Citrix NetScaler RCE | 🔴 CRÍTICA |
| **CVE-2021-41773.nse** | CVE-2021-41773 | Apache HTTP Server Path Traversal | 🔴 CRÍTICA |
| **CVE-2022-22965.nse** | CVE-2022-22965 | Spring Framework RCE (Spring4Shell) | 🔴 CRÍTICA |
| **CVE-2022-31813.sh** | CVE-2022-31813 | Apache HTTP Server Mod_Proxy bypass | 🟠 ALTA |
| **CVE-2022-39952.nse** | CVE-2022-39952 | Cacti SQL Injection | 🟠 ALTA |
| **CVE-2023-20198.nse** | CVE-2023-20198 | Cisco IOS XE RCE | 🔴 CRÍTICA |
| **CVE-2023-27350.nse** | CVE-2023-27350 | Cacti RCE | 🔴 CRÍTICA |
| **CVE-2023-36845.nse** | CVE-2023-36845 | NETSCALER CVE | 🟠 ALTA |
| **CVE-2023-6553.nse** | CVE-2023-6553 | NVIDIA Driver EOP | 🟠 ALTA |
| **CVE-2024-3400.nse** | CVE-2024-3400 | PAN-OS RCE | 🔴 CRÍTICA |
| **cve-2022-40684.nse** | CVE-2022-40684 | Fortinet FortiOS RCE | 🔴 CRÍTICA |
| **traversal.nse** | Multiple | Path Traversal Detection | 🟠 ALTA |

**Uso en Nmap:**

```bash
# Copia scripts NSE al directorio de Nmap
sudo cp *.nse /usr/share/nmap/scripts/
sudo nmap --script-updatedb

# Ejecuta exploits CVE contra objetivos
nmap -sV --script CVE-2021-41773.nse target.com -p 80,443
nmap -sV --script CVE-2022-22965.nse target.com -p 8080,8081
```

---

### 8. **Detección de Proxy & Proxy Abiertos**

| Script | Función | Detección |
|--------|---------|-----------|
| **proxy.sh** | Detecta proxy forward abierto | Conexiones CONNECT salientes |
| **openproxy.sh** | Prueba vulnerabilidades proxy | Bypass de filtrado, exfiltración |

```bash
# Escanea rango de IPs buscando proxies abiertos
./openproxy.sh -t 192.168.1.0/24 -p 3128,8080,8888

# Valida si objetivo es proxy vulnerable
./proxy.sh -t 10.0.0.5:3128
```

---

### 9. **Análisis de Certificados TLS/SSL**

| Script | Función | Análisis |
|--------|---------|----------|
| **qtls.sh** | Auditoría completa TLS/SSL | Cifrados débiles, versionado |
| **qtls2.sh** | Análisis avanzado (BEAST, CRIME, etc) | Vulnerabilidades conocidas |

```bash
# Análisis completo de certificado y cifrados
./qtls.sh target.com:443

# Salida en fichero
./qtls.sh target.com:443 > tls-report.txt
```

---

### 10. **Herramientas Especializadas**

| Script | Función | Propósito |
|--------|---------|----------|
| **actualizar.sh** | Auto-actualiza repositorio y scripts | Mantiene versión actual |
| **instalar.sh** | Instalación automatizada de dependencias | Ahorra tiempo inicial |
| **pruebas.sh** | Suite de tests unitarios | Valida funcionalidad |
| **localhost.sh** | Genera servidor web local de prueba | Ambiente sandbox seguro |
| **txt2pdf.sh** | Convierte reportes TXT a PDF | Presentación profesional |

---

### Herramientas requeridas

### Instalación

El script `instalar.sh` instala automáticamente todas las dependencias:

```bash
sudo bash instalar.sh
```

### Instalación Manual

Si prefieres instalar manualmente, aquí están todas las herramientas:

```bash
# Actualiza índice de paquetes
sudo apt update && sudo apt upgrade -y

# Herramientas de escaneo web
sudo apt install -y nmap nikto wapiti golismero wafw00f davtest

# Herramientas de DNS & reconocimiento
sudo apt install -y dnsutils dnsenum dnsmap dnsrecon fierce dmitry whois

# Herramientas adicionales
sudo apt install -y curl wget sslyze theharvester uniscan xsser

# Herramientas de utilidad
sudo apt install -y git build-essential python3-pip

# Instala sqlmap (si no está incluído)
sudo apt install -y sqlmap
```

### Tabla de Herramientas

| Herramienta | Versión Mín. | Función | Instalación |
|-------------|--------------|---------|-------------|
| **nmap** | 7.91+ | Port scanning, service fingerprinting | `apt install nmap` |
| **nikto** | 2.1.5+ | Web server scanning | `apt install nikto` |
| **wapiti** | 3.0+ | Web application testing | `pip install wapiti3` |
| **golismero** | 2.0+ | Web security framework | `apt install golismero` |
| **wafw00f** | 2.4+ | WAF detection | `pip install wafw00f` |
| **dnsenum** | 1.2+ | DNS enumeration | `apt install dnsenum` |
| **fierce** | 1.4+ | Subdomain scanner | `pip install fierce` |
| **dnsrecon** | 0.10+ | DNS reconnaissance | `pip install dnsrecon` |
| **sslyze** | 5.1+ | TLS/SSL analysis | `pip install sslyze` |
| **theharvester** | 4.0+ | Email/subdomain gathering | `pip install theharvester` |

---

### Vulnerabilidades Detectadas

El repositorio cubre las **20+ principales vulnerabilidades OWASP Top 10 2024** y más:

### OWASP Top 10 (2024)

| # | Vulnerabilidad | CWE | Detección | Script |
|---|-----------------|-----|-----------|--------|
| **A01** | Broken Access Control | CWE-284 | Path traversal, IDOR, unauthorized access | `traversal.nse`, `salta403.sh` |
| **A02** | Cryptographic Failures | CWE-327 | Weak TLS, outdated ciphers, no HTTPS | `qtls.sh`, `qtls2.sh` |
| **A03** | Injection | CWE-94 | SQL, Command, LDAP, Template injection | `sqli.sh`, `sqliauto.sh` |
| **A04** | Insecure Design | CWE-434 | Insecure file upload, missing validation | `davtest`, `formularios` |
| **A05** | Security Misconfiguration | CWE-16 | Default credentials, verbose errors | `nikto`, `get.sh` |
| **A06** | Vulnerable & Outdated Components | CWE-1035 | Known CVEs, fingerprinting | `nmap`, `wapiti` |
| **A07** | Identification & Authentication Failures | CWE-287 | Weak passwords, session fixation | `httpauthbasic.sh` |
| **A08** | Software & Data Integrity Failures | CWE-353 | Unsigned components, tampered data | `checksums` |
| **A09** | Logging & Monitoring Failures | CWE-778 | Weak logging, no alerting | Manual review |
| **A10** | SSRF | CWE-918 | Server-side request forgery | `curl`, manual testing |

### Vulnerabilidades Adicionales Detectadas

| Categoría | Ejemplos | Severidad |
|-----------|----------|-----------|
| **XSS (Cross-Site Scripting)** | Reflected, Stored, DOM-based | Medio-Alto |
| **CSRF (Cross-Site Request Forgery)** | Token bypass, insecure SameSite | Medio |
| **File Inclusion** | LFI, RFI, Path traversal | Alto-Crítico |
| **Information Disclosure** | Banner grabbing, error messages, source code leaks | Bajo-Medio |
| **Authentication Bypass** | HTTP basic brute force, session bypass | Alto |
| **API Security** | Broken object level auth, excessive data exposure | Medio-Alto |
| **Web Services** | SOAP/XML vulnerabilities, service enumeration | Medio |

---

### Ejemplos de Uso

### Caso 1: Auditoría Web Completa

```bash
# Ejecuta scan completo contra dominio objetivo
cd ~/webaudit
./webaudit.sh -u https://example.com -o ./resultados-example -v

# Esto ejecutará:
# 1. Reconocimiento DNS (fqdnaudit.sh)
# 2. Enumeración web (explorarweb.sh)
# 3. Búsqueda de secretos (buscasecretosauto.sh)
# 4. Detección de WAF (wafw00f)
# 5. Análisis TLS (qtls.sh)
# 6. Tests de seguridad web (nikto, wapiti)

# Consulta resultados
ls -la ./resultados-example/
cat ./resultados-example/reporte.txt
```

### Caso 2: Enumeración DNS Masiva

```bash
# Enumera subdominios de un dominio
./fqdnaudit.sh -d example.com -o subdominios.txt

# Combina con scanning de puertos
nmap -iL subdominios.txt -p 80,443,8080,8443 -sV -oN nmap-results.txt
```

### Caso 3: Búsqueda de Secretos en Código

```bash
# Descarga espejo web completo
./desgargarweb.sh https://example.com -o website-backup

# Busca credenciales, API keys, tokens
./buscasecretosauto.sh ./website-backup/

# Filtra solo secretos críticos
./buscasecretosauto.sh ./website-backup/ | grep -E "AWS|DATABASE|API_KEY"
```

### Caso 4: Teste de SQLi Automatizado

```bash
# Ataque SQLi contra parámetro vulnerable
./sqliauto.sh -u "https://example.com/products.php" \
              -p "id" \
              -t GET \
              --dbs \
              --batch

# Extrae tablas de base de datos
./sqliauto.sh -u "https://example.com/products.php" \
              -p "id" \
              -t GET \
              -D database_name \
              --tables \
              --batch
```

### Caso 5: Bypass WAF & Acceso a Recursos

```bash
# Intenta bypass de WAF
./wafbypass.sh -u https://protected.example.com/admin \
               -l verbose \
               -t 30 \
               -o bypass-attempt.log

# Si tiene éxito:
# Procede con scanning más profundo
./nikto.pl -h https://protected.example.com -o nikto-report.html
```

### Caso 6: Análisis TLS/Certificados

```bash
# Audita configuración TLS/SSL
./qtls.sh example.com:443

# Salida típica:
# ✓ HSTS habilitado
# ✗ Soporta TLS 1.0 (débil)
# ✗ Cifrado anon-aes-256-cbc (anónimo)
# ⚠ Certificado válido hasta 2025-06-30
```

---

### Estructura del Repositorio

```
webaudit/
├── README.md                    # Este fichero (documentación principal)
├── LICENSE                      # GPL-3.0
├── instalar.sh                  # Script de instalación automatizada
├── actualizar.sh                # Auto-actualiza repositorio
│
├── SCRIPTS DE AUDITORÍA PRINCIPAL
├── webaudit.sh                  # Orquestador principal (flujo completo)
├── fqdnaudit.sh                 # Enumeración DNS masiva
│
├── RECONOCIMIENTO WEB
├── get.sh                       # Obtiene headers HTTP
├── metodos.sh                   # Enumera métodos HTTP
├── explorarweb.sh               # Rastreo de estructura web
├── desgargarweb.sh              # Descarga mirror de website
│
├── BÚSQUEDA DE SECRETOS
├── secretos.sh                  # Búsqueda de API keys/tokens
├── buscasecretos.sh             # Búsqueda mejorada de secretos
├── buscasecretosauto.sh         # Búsqueda automática en directorios
│
├── BYPASS WAF & STATUS CODES
├── wafbypass.sh                 # Bypass WAF (Cloudflare, ModSecurity)
├── wafbypass2.sh                # Bypass WAF (variante avanzada)
├── salta403.sh                  # Técnicas 403 Forbidden bypass
├── curl403.sh                   # Testea 403 bypass múltiples métodos
├── curl404.sh                   # Identifica falsos 404
├── curl4xx.sh                   # Análisis generalizado códigos 4xx
│
├── INYECCIÓN SQL
├── sqli.sh                      # Test manual SQLi
├── sqliauto.sh                  # Wrapper automático sqlmap
│
├── AUTENTICACIÓN HTTP
├── httpbasico.sh                # Testea HTTP Basic auth
├── httpauthbasic.sh             # Fuerza bruta HTTP Basic
├── httpauthcod.sh               # HTTP auth con headers custom
├── httpsauthcod.sh              # HTTPS auth con validación cert
│
├── ANÁLISIS TLS/SSL
├── qtls.sh                      # Auditoría TLS/SSL completa
├── qtls2.sh                     # Análisis avanzado (BEAST, CRIME)
│
├── PROXY & SERVICIOS
├── proxy.sh                     # Detecta proxy forward abierto
├── openproxy.sh                 # Testea vulnerabilidades proxy
│
├── EXPLOITS NSE PARA NMAP
├── CVE-2019-19781.nse           # Citrix NetScaler RCE
├── CVE-2021-41773.nse           # Apache Path Traversal
├── CVE-2022-22965.nse           # Spring4Shell RCE
├── CVE-2022-31813.sh            # Apache Mod_Proxy bypass
├── CVE-2022-39952.nse           # Cacti SQLi
├── CVE-2022-40684.nse           # FortiOS RCE
├── CVE-2023-20198.nse           # Cisco IOS XE RCE
├── CVE-2023-27350.nse           # Cacti RCE
├── CVE-2023-36845.nse           # NetScaler RCE
├── CVE-2023-6553.nse            # NVIDIA Driver EOP
├── CVE-2024-3400.nse            # PAN-OS RCE
├── cve-2022-40684.nse           # Fortinet FortiOS RCE
├── traversal.nse                # Path Traversal Detection
├── citrix.nse                   # Citrix detection
├── f5.nse                       # F5 BIG-IP detection
├── htpasswd.nse                 # htpasswd file detection
├── netscaler.nse                # NetScaler detection
├── phpadmin.nse                 # phpMyAdmin detection
│
├── HERRAMIENTAS ESPECIALES
├── localhost.sh                 # Genera servidor web local de prueba
├── pruebas.sh                   # Suite de tests unitarios
├── txt2pdf.sh                   # Convierte reportes TXT → PDF
├── apachebleed.sh               # Test Heartbleed sobre Apache
│
├── RECURSOS & REFERENCIAS
├── cifrados.png                 # Imagen resumen cifrados TLS
├── cifrados.xls                 # Tabla Excel cifrados TLS
├── qtls.png                     # Screenshot análisis TLS
├── webapi.png                   # Diagrama arquitectura API
├── webaudit.png                 # Logo del proyecto
├── x-cabeceras.txt              # Lista de headers HTTP/HTTPS comunes
├── scriptsnmapnse.md            # Documentación scripts NSE Nmap
└── .gitignore                   # Archivo .gitignore (datos sensibles)
```

---

###  Referencias OWASP

### OWASP Testing Guide

- [Full Path Disclosure (FPD)](https://owasp.org/www-community/attacks/Full_Path_Disclosure)
- [Arbitrary File Upload](https://owasp.org/www-community/attacks/Arbitrary_File_Upload)
- [Arbitrary File Download/Delete](https://owasp.org/www-community/attacks/Arbitrary_File_Download)
- [Local File Inclusion (LFI)](https://owasp.org/www-community/attacks/Path_Traversal)
- [Remote File Inclusion (RFI)](https://owasp.org/www-community/attacks/Remote_File_Inclusion)

### Inyecciones

- [SQL Injection (SQLi)](https://owasp.org/www-community/attacks/SQL_Injection)
- [XML Injection & XXE](https://owasp.org/www-community/attacks/XML_External_Entity_(XXE)_Processing)
- [XPATH Injection](https://owasp.org/www-community/attacks/XPATH_Injection)
- [Command Injection](https://owasp.org/www-community/attacks/Command_Injection)
- [Code Injection](https://owasp.org/www-community/attacks/Code_Injection)

### Scripting & Autorización

- [Cross Site Scripting (XSS)](https://owasp.org/www-community/attacks/xss/)
- [Cross Site Request Forgery (CSRF)](https://owasp.org/www-community/attacks/csrf)
- [Cookie Injection](https://owasp.org/www-community/attacks/Cookie_Injection)
- [Header Injection](https://owasp.org/www-community/attacks/HTTP_Parameter_pollution)

### Autenticación

- [Broken Authentication and Session Management](https://owasp.org/www-project-web-security-testing-guide/latest/4-Web_Application_Security_Testing/06-Session_Management_Testing/README.html)
- [HTTP Parameter Pollution](https://owasp.org/www-community/attacks/HTTP_Parameter_pollution)

### Seguridad API

- [API Security Top 10](https://owasp.org/www-project-api-security/)
- [Broken Object Level Authorization (BOLA)](https://owasp.org/www-community/API_Security/Broken_Object_Level_Authorization)

---

## 🔧 Configuración Avanzada

### Variables de Entorno

```bash
# Establece timeout por defecto (segundos)
export TIMEOUT=30

# Número de threads paralelos
export THREADS=10

# Directorio de salida por defecto
export OUTPUT_DIR="/tmp/webaudit-results"

# Nivel de verbosidad (0=silencioso, 3=máximo)
export VERBOSE=2

# Diccionarios personalizados
export DICT_USERS="/usr/share/wordlists/users.txt"
export DICT_PASS="/usr/share/wordlists/passwords.txt"
```

### Proxy y Certificados

```bash
# Configura proxy HTTP/HTTPS
export HTTP_PROXY="http://127.0.0.1:8080"
export HTTPS_PROXY="http://127.0.0.1:8080"

# Desactiva validación SSL (solo laboratorio)
export CURL_INSECURE="-k"

# Certificado personalizado
export CA_CERT="/path/to/ca-bundle.crt"
```

---

| Recurso | Enlace |
|---------|--------|
| Sitio oficial | [hackingyseguridad.com](http://hackingyseguridad.com/) |
| Documentación | [hackingyseguridad.github.io](https://hackingyseguridad.github.io/) |
| GitHub Profile | [@hackingyseguridad](https://github.com/hackingyseguridad) |
| Twitter/X | [@hackyseguridad](https://twitter.com/hackyseguridad) |

```

---

### Quick Reference

```bash
# Instalación rápida
git clone https://github.com/hackingyseguridad/webaudit.git && cd webaudit && bash instalar.sh

# Auditoría completa
./webaudit.sh -u https://target.com -o ./audit-results -v

# Enumeración DNS
./fqdnaudit.sh -d target.com

# Búsqueda de secretos
./buscasecretosauto.sh ./website-mirror/

# SQLi automatizado
./sqliauto.sh -u "https://target.com/search?q=" -p q -t GET --dbs --batch

# Bypass WAF
./wafbypass.sh -u https://protected.target.com -l verbose

# Análisis TLS
./qtls.sh target.com:443

# Exploits NSE
nmap --script CVE-2021-41773.nse target.com
```

---

**Última actualización:** Julio 2026  
**Versión:** 2.5 Continuous  

[@hackingyseguridad](https://github.com/hackingyseguridad)

---


