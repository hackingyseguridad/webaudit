#!/bin/bash
Negro='\033[0;30m'
Rojo='\033[0;31m'
Verde='\033[0;32m'
Amarillo='\033[0;33m'
Azul='\033[0;34m'
Purpura='\033[0;35m'
Cyan='\033[0;36m'
Blanco='\033[0;37m'
Normal='\033[0m'
cat << "INFO"
  __           _                         _ _ _
 / _| __ _  __| |_ __     __ _ _   _  __| (_) |_
| |_ / _` |/ _` | '_ \   / _` | | | |/ _` | | __|
|  _| (_| | (_| | | | | | (_| | |_| | (_| | | |_
|_|  \__, |\__,_|_| |_|  \__,_|\__,_|\__,_|_|\__| V 1.0
        |_|      http://www.hackingyseguridad.com

$$$$$$ $$$$$ $$$$  $$$ $$$$  $$$     $$$$     $$$$$$ $$$$$ $$$$$$$$$ $$$$$$$$$
INFO

if [ -z "$1" ]; then
        printf "${Amarillo}" ; echo
        echo "Test vulnerabilidades API."
        echo "Uso: $0 <fqdn URI>"; printf "${Normal}\n"
        exit 0
fi
echo
echo "================================================="
echo "test sobre la el fqdn de la URI.: $1"
echo "================================================="
echo
echo -e "\e[00;32m# Informacion del host ########################################################\e[00m"
echo
host $1
echo
echo -e "\e[00;32m# Versiones HTTP soportadas por el  servidor web ####@@##########################\e[00m"
echo
curl -Is --http1.0 https://$1 | head -1
curl -Is --http1.1 https://$1 | head -1
curl -Is --http2-prior-knowledge $1 | head -1
echo
whatweb $1
echo
HEAD $1
echo
curl -I -v https://$1
echo
echo -e "\e[00;32m# Detecta firewall o balanceador ########################################################\e[00m"
echo
lbd $1
echo
echo -e "\e[00;32m# Detecta firewall WAF ########################################################\e[00m"
echo
wafw00f $1
echo
echo -e "\e[00;32m#Vulnerabilidades SSL, certificado ######################################################\e[00m"
echo
sslyze --heartbleed $1
sslyze --certinfo $1
sslyze --compression $1
sslyze --reneg $1
sslyze --resum $1
echo
echo -e "\e[00;32m# Metodos HTTP ##########################################################\e[00m"
echo
echo "GET";  curl -ks https://$1 -L -H 'User-Agent: Mozilla/5.0' -X GET -I
echo "POST"; curl -ks https://$1 -L -H 'User-Agent: Mozilla/5.0' -X POST -I
echo "PUT";  curl -ks https://$1 -L -H 'User-Agent: Mozilla/5.0' -X PUT -I
echo "PATCH"; curl -ks https://$1 -L -H 'User-Agent: Mozilla/5.0' -X PATCH -I
echo "DELETE"; curl -ks https://$1 -L -H 'User-Agent: Mozilla/5.0' -X DELETE -I
echo "HEAD"; curl -ks https://$1 -L -H 'User-Agent: Mozilla/5.0' -X HEAD -I
echo "TRACE"; curl -ks https://$1 -L -H 'User-Agent: Mozilla/5.0' -X TRACE -I
echo
echo -e "\e[00;32m# Vulnerabilidades web con Nikto ########################################################\e[00m"
echo
nikto -Plugins 'cookies' -host https://$1
nikto -Plugins 'headers' -host https://$1
nikto -Plugins 'msgs' -host https://$1
nikto -Plugins 'httpoptions' -host https://$1
nikto -Plugins 'ssl' -host https://$1
echo
echo -e "\e[00;32m# Escaneo con Nmap de puertos web habituales ########################################################\e[00m"
echo
nmap $1 -Pn -p 80,81,443,4443,7443,8000,8080,8081,8443,8888,9443,10443 --script=http-enum --script=http-security-headers --script=http-methods --script=ssl* --open -sC -O
echo
echo -e "\e[00;32m# Descubre directorios por fuerza bruta ########################################################\e[00m"
echo
echo "Fuzz de: " $1
echo "--- -----------"
echo "Cod Significado"
echo "--- -----------"
echo "200 OK"
echo "301 Movido permamentemente"
echo "302 Encontrado"
echo "304 No modificado"
echo "400 Solicitud incorrecta"
echo "400 No autorizado"
echo "403 Prohibido"
echo "404 No encontrado"
echo "410 Ya no esta disponible"
echo "500 Error interno en el servidor"
echo
dirb  https://$1 diccionario.txt -N 302 204 307 400 401 403 409 500 503 -b -f -w -S -z 99 -a "User-Agent: Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:62.0) Gecko/20100101 Firefox/62.0" -H "Accept: text/html, applicattion/xhtml+xml, application/xml;q=0.9,*/*;q=0.8"
echo

