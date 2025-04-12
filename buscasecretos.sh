#!/bin/sh

# ==================================================
# (R) hackingyseguridad.com 2025
# busca secretos en el codigo de las páginas web y sus recursos
# Compatible con Bash 1.x+ y shells antiguas
# Uso; 
# sh buscasecretos.sh http://hackingyseguridad.com
# ==================================================

# Configuración
TMPDIR="/tmp/webscan_$$"
mkdir "$TMPDIR" || {
  echo "ERROR: No se pudo crear directorio temporal"
  exit 1
}
LOG="$TMPDIR/scan.log"

# Funciones básicas compatibles
error() {
  echo "ERROR: $1"
  rm -rf "$TMPDIR"
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
for cmd in wget grep sed tr file; do
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

# Extraer recursos (JS, CSS, JSON)
echo "Extrayendo recursos..." >> "$LOG"
grep -E -i 'src=["'\'']|href=["'\'']' "$MAIN_FILE" | 
  sed 's/.*src=["'\'']//;s/.*href=["'\'']//;s/["'\''].*//' |
  grep -E -i '\.(js|css|json)(\?.*)?$' |
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
  
  if download "$res_url" "$outfile"; then
    echo "OK: $res_url" >> "$LOG"
  else
    echo "FALLO: $res_url" >> "$LOG"
  fi
done < "$TMPDIR/resources.txt"

# Patrones de búsqueda
PATTERNS='
api.?key
secret.?key
[A-Za-z0-9_\-]{24,}
AKIA[0-9A-Z]{16}
eyJ[a-zA-Z0-9_\-]+\.[a-zA-Z0-9_\-]+\.[a-zA-Z0-9_\-]+
password
token
access[_-]?key
credentials
'

# Escanear archivos
echo ""
echo "=== RESULTADOS DEL ESCANEO ==="
echo "URL analizada: $URL"
echo ""

find "$TMPDIR" -type f | while read -r file; do
  filename=$(echo "$file" | sed "s|$TMPDIR/||")
  [ "$filename" = "scan.log" ] && continue
  
  # Determinar origen del archivo
  case "$filename" in
    main.html) origen="Página principal ($URL)" ;;
    res_*) origen="Recurso: $(echo "$filename" | sed 's/res_//;s/_/\//g')" ;;
    *) origen="Archivo interno: $filename" ;;
  esac

  echo "--------------------------------------------------"
  echo "Analizando: $origen"
  echo "--------------------------------------------------"

  # Determinar si es binario
  if file "$file" | grep -q "text"; then
    # Archivo de texto
    echo "$PATTERNS" | while read -r pattern; do
      [ -z "$pattern" ] && continue
      
      matches=$(grep -E -n -o "$pattern" "$file" 2>/dev/null | sed 's/^/  Línea /')
      if [ -n "$matches" ]; then
        echo "[!] Secreto encontrado (patrón: $pattern)"
        echo "$matches"
        echo ""
      fi
    done
  else
    # Archivo binario
    echo "$PATTERNS" | while read -r pattern; do
      [ -z "$pattern" ] && continue
      
      matches=$(strings "$file" | grep -E -n -o "$pattern" 2>/dev/null | sed 's/^/  Offset /')
      if [ -n "$matches" ]; then
        echo "[!] Secreto encontrado (patrón: $pattern)"
        echo "$matches"
        echo ""
      fi
    done
  fi
done

# Limpieza
rm -rf "$TMPDIR"
echo ""
echo "Escaneo completado. Ver $LOG para detalles de descarga."

