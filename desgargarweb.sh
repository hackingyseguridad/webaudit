#!/bin/bash
# Simple script para descargar paginas web completas
# hackingyseguridad.com 2025

Normal=$(echo 'printf' '\033[39m')
Verde=$(echo 'printf' '\033[32m')
Blanco=$(echo 'printf' '\033[0m')

$Verde
cat << "INFO"
      _                                       __          __  _     
     | |                                      \ \        / / | |    
   __| | ___  ___  ___ __ _ _ __ __ _  __ _ _ _\ \  /\  / /__| |__  
  / _` |/ _ \/ __|/ __/ _` | '__/ _` |/ _` | '__\ \/  \/ / _ \ '_ \ 
 | (_| |  __/\__ \ (_| (_| | | | (_| | (_| | |   \  /\  /  __/ |_) |
  \__,_|\___||___/\___\__,_|_|  \__, |\__,_|_|    \/  \/ \___|_.__/  v 1.0
                                 __/ |                              
                                |___/                             
INFO
$Blanco
echo "                                          www.hackingyseguridad.com"
echo
$Blanco
if [ -z "$1" ]; then
        echo "Descarga pagina web completa: "
        echo "Uso: sh $0 <URL>"
        exit 0
fi

echo
wget --limit-rate=100k --no-clobber --convert-links --random-wait -r -p -E -e robots=off -U mozilla $1  --no-check-certificate
