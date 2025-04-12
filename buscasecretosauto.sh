#!/bin/bash
# 
# hackingyseguridad.com 2025
#
# busca secretos en los portgales con url dentro del fichero: url.txt 
#

echo
echo "..."
echo
for S in `cat url.txt`; do echo $S; timeout 2 ./buscasecretos.sh $S;
done
