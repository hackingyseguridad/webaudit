#!/bin/bash

# busca online en el codigo secretos: credenciales, tokens, claves
# uso.: secretos.sh URL 
# cat index.html | grep -aoP "(?<=(\"|\'|\`))\/[a-zA-Z0-9_?&=\/\-\#\.]*(?=(\"|\'|\`))" | sort -u
# hackingyseguridad.com 2026
# @antonio_taboada
# curl -s $1 $2 | grep -aoP "(?<=(\"|\'|\`))\/[a-zA-Z0-9_?&=\/\-\#\.]*(?=(\"|\'|\`))" | sort -u
# curl -s $1 $2 | grep -Ei "user|token|password|auth|api|sql|digest|email|oauth2"


# Verificar que se proporcionó una URL
if [ -z "$1" ]; then
    echo "Uso: $0 <URL>"
    echo "Ejemplo: $0 https://ejemplo.com"
    exit 1
fi

URL="$1"
DOMINIO=$(echo "$URL" | sed -e 's|^[^/]*://||' -e 's|/.*$||')

echo "=============================================="
echo "AUDITORÍA WEB COMPLETA"
echo "=============================================="
echo "Dominio: $DOMINIO"
echo "URL: $URL"
echo "Fecha: $(date)"
echo "=============================================="

# Crear directorio para la descarga
DIRECTORIO="web_${DOMINIO}_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$DIRECTORIO"
cd "$DIRECTORIO"

echo " [+] Descargando sitio web completo..."
echo "=============================================="

# Descargar el sitio web completo
wget --recursive \
     --no-clobber \
     --page-requisites \
     --html-extension \
     --convert-links \
     --restrict-file-names=windows \
     --domains "$DOMINIO" \
     --no-parent \
     --no-check-certificate \
     --timeout=30 \
     --tries=3 \
     --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" \
     "$URL" 2>&1 | tee wget.log

echo "=============================================="
echo " [+] Descarga completada"
echo " [+] Directorio: $(pwd)"
echo "=============================================="
echo ""
echo "=============================================="
echo "BUSCANDO SECRETOS Y DATOS SENSIBLES"
echo "=============================================="

# Patrones para buscar secretos y datos sensibles
PATRONES=(
    # API Keys
    "api[_-]?key"
    "apikey"
    
    # Tokens de acceso
    "access[_-]?token"
    "secret[_-]?token"
    "bearer[[:space:]]+[A-Za-z0-9._-]{10,}"
    
    # Claves de servicios
    "aws[_-]?access[_-]?key[_-]?id"
    "aws[_-]?secret[_-]?access[_-]?key"
    "aws[_-]?session[_-]?token"
    
    # Claves de API específicas
    "google[_-]?api[_-]?key"
    "firebase[_-]?api[_-]?key"
    "github[_-]?token"
    "gitlab[_-]?token"
    
    # Credenciales de base de datos
    "db[_-]?(password|pass|pwd)"
    "database[_-]?(password|pass|pwd)"
    "mysql[_-]?(password|pass|pwd)"
    "postgres[_-]?(password|pass|pwd)"
    "mongodb[_-]?(password|pass|pwd)"
    
    # Configuraciones de conexión
    "(jdbc|odbc):.*:.*"
    "://.*:.*@"
    
    # Archivos de configuración sensibles
    ".env"
    "config\.(php|js|json|yml|yaml)"
    "settings\.(php|js|json|yml|yaml)"
    
    # JWT tokens
    "eyJ[A-Za-z0-9_-]*\.[A-Za-z0-9._-]*"
    
    # SSH keys
    "-----BEGIN (RSA|DSA|EC|OPENSSH) PRIVATE KEY-----"
    
    # Passwords en código
    "password[[:space:]]*=[[:space:]]*['\"][^'\"]{4,}['\"]"
    "passwd[[:space:]]*=[[:space:]]*['\"][^'\"]{4,}['\"]"
    
    # Emails
    "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}"
    
    # Números de tarjetas de crédito (formato básico)
    "[0-9]{4}[ -]?[0-9]{4}[ -]?[0-9]{4}[ -]?[0-9]{4}"
    
    # Secretos en URLs
    "secret=.*"
    "token=.*"
    "key=.*"
    "auth=.*"
    
    # Variables de entorno con valores
    "[A-Z_][A-Z0-9_]*[[:space:]]*=[[:space:]]*['\"][^'\"]{4,}['\"]"
)

# Colores para la salida
ROJO='\033[0;31m'
VERDE='\033[0;32m'
AMARILLO='\033[1;33m'
AZUL='\033[0;34m'
NC='\033[0m' # No Color

# Contadores
TOTAL_ARCHIVOS=$(find . -type f \( -name "*.html" -o -name "*.js" -o -name "*.php" -o -name "*.json" -o -name "*.xml" -o -name "*.yml" -o -name "*.yaml" -o -name "*.txt" -o -name "*.md" -o -name "*.py" -o -name "*.rb" -o -name "*.java" -o -name "*.cpp" -o -name "*.c" \) 2>/dev/null | wc -l)
ENCONTRADOS=0

echo " [+] Analizando $TOTAL_ARCHIVOS archivos..."
echo "=============================================="

# Buscar en todos los archivos
for patron in "${PATRONES[@]}"; do
    echo -e "\n${AZUL}[*] Buscando: $patron${NC}"
    echo "--------------------------------------------------"
    
    # Buscar el patrón en todos los archivos
    grep_result=$(grep -r -i -n -I -H -E "$patron" . 2>/dev/null | head -20)
    
    if [ ! -z "$grep_result" ]; then
        echo -e "${ROJO}¡POSIBLES SECRETOS ENCONTRADOS!${NC}"
        echo "$grep_result" | while read -r linea; do
            ENCONTRADOS=$((ENCONTRADOS + 1))
            echo -e "${AMARILLO}$linea${NC}"
        done
    else
        echo -e "${VERDE}No se encontraron coincidencias${NC}"
    fi
done

# Buscar también en archivos específicos de configuración
echo -e "\n${AZUL}[*] Buscando en archivos de configuración comunes${NC}"
echo "--------------------------------------------------"

ARCHIVOS_CONFIG=(".env" "config.php" "config.js" "config.json" "settings.py" "config.yml" "config.yaml" ".git/config" ".htaccess" "wp-config.php")

for archivo_config in "${ARCHIVOS_CONFIG[@]}"; do
    find . -type f -name "$archivo_config" 2>/dev/null | while read -r archivo; do
        echo -e "${AMARILLO}Archivo de configuración encontrado: $archivo${NC}"
        # Mostrar primeras líneas
        head -20 "$archivo" 2>/dev/null | sed 's/^/  /'
        echo "---"
    done
done

# Resumen final
echo "=============================================="
echo -e "${AZUL}[+] RESUMEN DE LA AUDITORÍA${NC}"
echo "=============================================="
echo "Dominio analizado: $DOMINIO"
echo "Directorio: $(pwd)"
echo "Total de archivos analizados: $TOTAL_ARCHIVOS"
echo -e "${ROJO}Posibles secretos encontrados: $ENCONTRADOS${NC}"
echo "Fecha de auditoría: $(date)"
echo "=============================================="
echo ""
echo "Notas:"
echo "1. Revisa manualmente los hallazgos para confirmar si son realmente sensibles"
echo "2. Algunas coincidencias pueden ser falsos positivos"
echo "3. Si encuentras secretos reales, repórtalos de manera responsable"
echo "=============================================="

# Crear archivo de resumen
echo "Resumen de auditoría para $URL" > resumen_auditoria.txt
echo "Fecha: $(date)" >> resumen_auditoria.txt
echo "Total archivos: $TOTAL_ARCHIVOS" >> resumen_auditoria.txt
echo "Hallazgos: $ENCONTRADOS" >> resumen_auditoria.txt
echo "" >> resumen_auditoria.txt
echo "Para ver detalles, revisa la salida anterior." >> resumen_auditoria.txt

echo -e "\n${VERDE}[+] Resumen guardado en: $(pwd)/resumen_auditoria.txt${NC}"




