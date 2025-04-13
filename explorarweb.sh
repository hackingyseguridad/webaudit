#!/bin/sh

# =============================================
# WEB_RESOURCES_SCAN v1.0
# Lista recursos web (Bash 1.x+ compatible)
# =============================================

# Configuración
TMPFILE="/tmp/webscan_$$.html"

# Verificar dependencias
for cmd in wget grep sed; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "ERROR: Falta el comando '$cmd'"
    exit 1
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
echo "Descargando página principal..."
wget -q -O "$TMPFILE" "$URL" || {
  echo "ERROR: No se pudo descargar la URL"
  exit 1
}

# Extraer y mostrar recursos
echo ""
echo "=== RECURSOS ENCONTRADOS EN: $URL ==="
echo ""

# 1. Recursos JavaScript
echo "Archivos JavaScript (.js):"
grep -i 'src="[^"]*\.js"' "$TMPFILE" | 
  sed 's/.*src="//;s/".*//' |
  awk -v base="$BASE_URL" '{print (index($0,"http") ? "" : base) $0}' |
  sort -u | sed 's/^/  /'
echo ""

# 2. Hojas de estilo
echo "Archivos CSS (.css):"
grep -i 'href="[^"]*\.css"' "$TMPFILE" | 
  sed 's/.*href="//;s/".*//' |
  awk -v base="$BASE_URL" '{print (index($0,"http") ? "" : base) $0}' |
  sort -u | sed 's/^/  /'
echo ""

# 3. Imágenes
echo "Archivos de imagen:"
grep -i 'src="[^"]*\.\(png\|jpg\|jpeg\|gif\|svg\)"' "$TMPFILE" | 
  sed 's/.*src="//;s/".*//' |
  awk -v base="$BASE_URL" '{print (index($0,"http") ? "" : base) $0}' |
  sort -u | sed 's/^/  /'
echo ""

# 4. Recursos externos
echo "Otros recursos externos:"
grep -i 'src="[^"]*"' "$TMPFILE" | grep -v -i '\.\(js\|css\|png\|jpg\|jpeg\|gif\|svg\)"' |
  sed 's/.*src="//;s/".*//' |
  awk -v base="$BASE_URL" '{print (index($0,"http") ? "" : base) $0}' |
  sort -u | sed 's/^/  /'
echo ""

# Limpieza
rm -f "$TMPFILE"
echo "Escaneo completado."
