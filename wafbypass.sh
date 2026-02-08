#!/bin/sh

# Analisis automatizado de urls en fichero  url.txt
# lee del fichero url por url y la  analiza 
# @antonio_taboada
#

while read url; do
    ./wafbypass.py -u "$url"
done < url.txt
