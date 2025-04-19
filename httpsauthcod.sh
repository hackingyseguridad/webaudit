#!/bin/bash
echo "Uso.: ./httpsauthcod.sh usuario password"
curl --cacert MyRootCA.crt -k -s -vvv \
-H "User-Agent: Mozilla/4.0 (compatible; MSIE 5.5;)" \
-H "Accept: text/html, applicattion/xhtml+xml, application/xml;q=0.9,*/*;q=0.8" \
-H "Accept-Language: es-ES,es;q=0.8,en-US;q=0.5,en;q=0.3" \
-H "Accept-Encoding: gzip, deflate, br" \
-H "Connection: keep-alive" \
-H "Upgrade-Insecure-Requests: 1" \
-H "Authorization: Basic $( (echo '$1:$2'; ) | base64 -w 0 )" https://fqdn/?
