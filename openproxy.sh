echo
echo
sh openproxy.sh IP_open_proxy
echo
curl -x http://$1:8081 --insecure --silent http://hackingyseguridad.com//security.txt
