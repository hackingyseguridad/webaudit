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
               _                     _ _ _   
              | |                   | (_) |  
 __      _____| |__   __ _ _   _  __| |_| |_ 
 \ \ /\ / / _ \ '_ \ / _` | | | |/ _` | | __|
  \ V  V /  __/ |_) | (_| | |_| | (_| | | |_ 
   \_/\_/ \___|_.__/ \__,_|\__,_|\__,_|_|\__|
                       hackingyseguridad.con
INFO

if [ -z "$1" ]; then
        printf "${Amarillo}" ; echo
        echo "Test vulnerabilidades web."
        echo "Uso: $0 <URL>"; printf "${Normal}\n"
        exit 0
fi

echo
echo "==========================================="
echo "test sobre la url.: $1"
echo "==========================================="
echo

host $1
wget -O temp_aspnet_config_err --tries=1 $1/%7C~.aspx
wget -O temp_wp_check --tries=1 $1/wp-admin
wget -O temp_drp_check --tries=1 $1/user
wget -O temp_joom_check --tries=1 $1/administrator
uniscan -e -u $1
wafw00f $1
nmap -F --open -Pn $1
theharvester -l 50 -b google -d $1
dnsrecon -d $1
fierce -wordlist xxx -dns $1
dnswalk -d $1.
whois $1
nmap -p80 --script http-security-headers -Pn $1
nmap -p80,443 --script http-slowloris --max-parallelism 500 -Pn $1
sslyze --heartbleed $1
nmap -p443 --script ssl-heartbleed -Pn $1
nmap -p443 --script ssl-poodle -Pn $1
nmap -p443 --script ssl-ccs-injection -Pn $1
nmap -p443 --script ssl-enum-ciphers -Pn $1
nmap -p443 --script ssl-dh-params -Pn $1
sslyze --certinfo=basic $1
sslyze --compression $1
sslyze --reneg $1
sslyze --resum $1
lbd $1
golismero -e dns_malware scan $1
golismero -e heartbleed scan $1
golismero -e brute_url_predictables scan $1
golismero -e brute_directories scan $1
golismero -e sqlmap scan $1
dirb http://$1 -fi
xsser --all=http://$1
golismero -e sslscan scan $1
golismero -e zone_transfer scan $1
golismero -e nikto scan $1
golismero -e brute_dns scan $1
dnsenum $1
fierce -dns $1
dmitry -e $1
dmitry -s $1
nmap -p23 --open $1
nmap -p21 --open $1
nmap --script stuxnet-detect -p 445 $1
davtest -url http://$1
golismero -e fingerprint_web scan $1
uniscan -w -u $1
uniscan -q -u $1
uniscan -r -u $1
uniscan -s -u $1
uniscan -d -u $1
nikto -Plugins 'apache_expect_xss' -host $1
nikto -Plugins 'subdomain' -host $1
nikto -Plugins 'shellshock' -host $1
nikto -Plugins 'cookies' -host $1
nikto -Plugins 'put_del_test' -host $1
nikto -Plugins 'headers' -host $1
nikto -Plugins 'ms10-070' -host $1
nikto -Plugins 'msgs' -host $1
nikto -Plugins 'outdated' -host $1
nikto -Plugins 'httpoptions' -host $1
nikto -Plugins 'cgi' -host $1
nikto -Plugins 'ssl' -host $1
nikto -Plugins 'sitefiles' -host $1
nikto -Plugins 'paths' -host $1
dnsmap $1
nmap -p1433 --open -Pn $1
nmap -p3306 --open -Pn $1
nmap -p1521 --open -Pn $1
nmap -p3389 --open -sU -Pn $1
nmap -p3389 --open -sT -Pn $1
nmap -p1-65535 --open -Pn $1
nmap -p1-65535 -sU --open -Pn $1
nmap -p161 -sU --open -Pn $1
wget -O temp_aspnet_elmah_axd --tries=1 $1/elmah.axd
nmap -p445,137-139 --open -Pn $1
nmap -p137,138 --open -Pn $1
wapiti $1 -f txt -o temp_wapiti
nmap -p80 --script=http-iis-webdav-vuln -Pn $1
whatweb $1 -a 1"]
