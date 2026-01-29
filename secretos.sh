#!/bin/bash

# busca online en el codigo secretos: credenciales, tokens, claves
# uso.: secretos.sh URL 
# cat index.html | grep -aoP "(?<=(\"|\'|\`))\/[a-zA-Z0-9_?&=\/\-\#\.]*(?=(\"|\'|\`))" | sort -u
# hackingyseguridad.com 2026
# @antonio_taboada

curl -s $1 $2 | grep -aoP "(?<=(\"|\'|\`))\/[a-zA-Z0-9_?&=\/\-\#\.]*(?=(\"|\'|\`))" | sort -u
curl -s $1 $2 | grep -Ei "user|token|password|auth|api|sql|digest|email|oauth2"



