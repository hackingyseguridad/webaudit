
Coleccion de simples NSE-script para nmap, para detectar Path Traversal y otras vulnerabilidades

git clone https://github.com/hackingyseguridad/webaudit

cp cve-2021-41773.nse /usr/share/nmap/scripts/

Uso.:

Por ejemplo:

nmap -Pn -p80,443 -sVC --script=cve-2021-41773.nse

