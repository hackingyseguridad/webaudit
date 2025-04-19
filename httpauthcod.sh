#!/bin/bash
# Ejemplo de peticion web completa y bien formada con el comando curl
# Peticion http://192.168.1.254/index.html?
# Credenciales user=admin passwd=12345 codificadas en Base64
# www.hackingyseguridad.com

curl --insecure --silent --compressed \
-H "User-Agent: Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:62.0) Gecko/20100101 Firefox/62.0" \
-H "Accept: text/html, applicattion/xhtml+xml, application/xml;q=0.9,*/*;q=0.8" \
-H "Accept-Language: es-ES,es;q=0.8,en-US;q=0.5,en;q=0.3" \
-H "Accept-Encoding: gzip, deflate, br" \
-H "Connection: keep-alive" \
-H "Upgrade-Insecure-Requests: 1" \
-H "Authorization: Basic $( (echo -ne 'admin:12345'; ) | base64 -w 0 )" http://192.168.1.254/index.html?
