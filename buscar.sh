#!/bin/bash
# Script compatible con Bash 1.0.x
# sh.busca.sh <palabra>  en URLs con timeout de 30 segundos
# Muestra URL completa y  linea donde se encontro▒

# Configuración
TIMEOUT=39  # Segundos máximos de espera por URL
URL_FILE="url.txt"  # Archivo con las URLs
TEMP_PREFIX="/tmp/websearch_$$"  # Prefijo para archivos temporales

# Verificar existencia del archivo de URLs
if [ ! -f "$URL_FILE" ]; then
  echo "Error: No se encuentra el archivo $URL_FILE" >&2
  exit 1
fi

# Contadores
total_urls=0
urls_con_coincidencias=0
total_coincidencias=0

# Función para descargar URL con timeout (compatible con Bash antiguo)
download_with_timeout() {
  local url=$1
  local output=$2

  # Intentar con curl (si está disponible)
  if type curl >/dev/null 2>&1; then
    curl -m $TIMEOUT -s "$url" > "$output" 2>/dev/null &
    curl_pid=$!
    (sleep $TIMEOUT && kill -9 $curl_pid 2>/dev/null) &
    sleep_pid=$!
    wait $curl_pid 2>/dev/null
    kill $sleep_pid 2>/dev/null
    return 0
  fi

  # Intentar con wget (alternativa)
  if type wget >/dev/null 2>&1; then
    wget -T $TIMEOUT -q -O "$output" "$url" 2>/dev/null &
    wget_pid=$!
    (sleep $TIMEOUT && kill -9 $wget_pid 2>/dev/null) &
    sleep_pid=$!
    wait $wget_pid 2>/dev/null
    kill $sleep_pid 2>/dev/null
    return 0
  fi

  # Intentar con lynx (último recurso)
  if type lynx >/dev/null 2>&1; then
    lynx -source "$url" > "$output" 2>/dev/null &
    lynx_pid=$!
    (sleep $TIMEOUT && kill -9 $lynx_pid 2>/dev/null) &
    sleep_pid=$!
    wait $lynx_pid 2>/dev/null
    kill $sleep_pid 2>/dev/null
    return 0
  fi

  return 1  # No se encontró ningún método de descarga
}

# Procesar cada URL
while read url; do
  total_urls=`expr $total_urls + 1`
  tempfile="${TEMP_PREFIX}_${total_urls}.html"

  echo "Analizando URL $total_urls: $url"

  # Descargar con timeout
  download_with_timeout "$url" "$tempfile"

  # Verificar si la descarga fue exitosa
  if [ ! -s "$tempfile" ]; then
    echo "  -> Timeout o error después de $TIMEOUT segundos, saltando..." >&2
    rm -f "$tempfile"
    continue
  fi

  # Buscar "" en el contenido
  line_number=0
  found_in_url=0

  while read line; do
    line_number=`expr $line_number + 1`

    # Buscar coincidencia (método compatible con Bash antigu
    #
    #
    if echo "$line" | grep "$1"  >/dev/null; then
      if [ $found_in_url -eq 0 ]; then
        echo "----------------------------------------"
        echo "COINCIDENCIA ENCONTRADA EN: $url"
        urls_con_coincidencias=`expr $urls_con_coincidencias + 1`
        found_in_url=1
      fi

      # Mostrar línea (limitando a 120 caracteres)
      echo "  Línea $line_number: $(echo "$line" | cut -c 1-120 | sed 's/^[ \t]*//')"
      total_coincidencias=`expr $total_coincidencias + 1`
    fi
  done < "$tempfile"

  # Eliminar archivo temporal
  rm -f "$tempfile"
done < "$URL_FILE"

# Mostrar resumen final
echo "========================================"
echo "BÚSQUEDA COMPLETADA"
echo "URLs analizadas: $total_urls"
echo "URLs con coincidencias: $urls_con_coincidencias"
echo "Total de coincidencias 'select()': $total_coincidencias"

# Limpiar archivos temporales en caso de error
rm -f ${TEMP_PREFIX}_*
exit 0
