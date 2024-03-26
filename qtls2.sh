#!/bin/bash
# Simple bash script para consultar los protolos y cifrados permitidos en un host remoto

Normal=$(echo 'printf' '\033[39m')
Verde=$(echo 'printf' '\033[32m')
Blanco=$(echo 'printf' '\033[0m')

$Verde
cat << "INFO"
        _   _           _
       | | | |         | |
   __ _| |_| |___   ___| |__
  / _` | __| / __| / __| '_ \
 | (_| | |_| \__ \_\__ \ | | |
  \__, |\__|_|___(_)___/_| |_| v.2.0
     | |
     |_|
INFO
$Blanco
echo "         www.hackingyseguridad.com"
echo
$Blanco
if [ -z "$1" ]; then
        echo "Consulta protocolos SSL/TLS y cifrados, permitidos"
        echo "Uso: sh $0 <IP:443>"
        exit 0
fi

echo
openssl s_client -connect $1
