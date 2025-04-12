#!/bin/sh

# ==================================================
# (R) hackingyseguridad.com 2025
# busca secretos en el codigo de las páginas web y sus recursos
# Compatible con Bash 1.x+ y shells antiguas
# Uso; 
# sh buscasecretos.sh http://hackingyseguridad.com
# ==================================================

# Configuración básica
TMPDIR="/tmp/secretscan_$$"
mkdir "$TMPDIR" || exit 1
LOG="$TMPDIR/scan.log"

# Funciones básicas (compatibles con shells antiguas)
error() {
  echo "ERROR: $1"
  exit 1
}

download() {
  url="$1"
  outfile="$2"
  echo "Descargando: $url" >> "$LOG"
  wget -q -O "$outfile" "$url" 2>> "$LOG"
  return $?
}

# Verificar comandos esenciales
for cmd in wget grep sed tr; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    error "Falta comando: $cmd"
  fi
done

# Verificar argumentos
if [ $# -lt 1 ]; then
  echo "Uso: $0 [URL]"
  echo "Ejemplo: $0 http://ejemplo.com"
  exit 1
fi

URL="$1"
BASE_URL=$(echo "$URL" | sed 's|^\(https\?://[^/]*\).*|\1|')

# Descargar página principal
MAIN_FILE="$TMPDIR/main.html"
download "$URL" "$MAIN_FILE" || error "No se pudo descargar URL principal"

# Extraer recursos (JS, CSS)
echo "Extrayendo recursos..." >> "$LOG"
grep -E -i 'src=["'\'']|href=["'\'']' "$MAIN_FILE" | 
  sed 's/.*src=["'\'']//;s/.*href=["'\'']//;s/["'\''].*//' |
  grep -E -i '\.(js|css)(\?.*)?$' |
  sort -u > "$TMPDIR/resources.txt"

# Descargar recursos encontrados
echo "Descargando recursos..." >> "$LOG"
while read -r resource; do
  # Convertir a URL absoluta si es relativa
  case "$resource" in
    http*) res_url="$resource" ;;
    /*) res_url="${BASE_URL}${resource}" ;;
    *) res_url="${BASE_URL}/${resource}" ;;
  esac

  safe_name=$(echo "$resource" | tr '/?&' '_')
  outfile="$TMPDIR/res_$safe_name"
  
  download "$res_url" "$outfile" && echo "OK: $res_url" >> "$LOG" || echo "FALLO: $res_url" >> "$LOG"
done < "$TMPDIR/resources.txt"

# Patrones de búsqueda (compatibles con grep antiguo)
PATTERNS='
api.?key
secret.?key
password
[A-Za-z0-9_\-]{24,}
AKIA[0-9A-Z]{16}
eyJ[a-zA-Z0-9_\-]+\.[a-zA-Z0-9_\-]+\.[a-zA-Z0-9_\-]+
mysql://[a-zA-Z0-9_]+:[^@]+@
postgres://[a-zA-Z0-9_]+:[^@]+@
'

# Escanear archivos
echo ""
echo "=== RESULTADOS DEL ESCANEO ==="
echo ""

find "$TMPDIR" -type f | while read -r file; do
  filename=$(echo "$file" | sed "s|$TMPDIR/||")
  echo "Analizando: $filename"
  
  echo "$PATTERNS" | while read -r pattern; do
    [ -z "$pattern" ] && continue
    
    matches=$(grep -E -o "$pattern" "$file" 2>/dev/null | sed 's/^/  /')
    if [ -n "$matches" ]; then
      echo "[!] Posible secreto (patrón: $pattern):"
      echo "$matches"
      echo "--------------------------------"
    fi
  done
done

# Limpieza
rm -rf "$TMPDIR"
echo ""
echo "Escaneo completado. Ver $LOG para detalles."
