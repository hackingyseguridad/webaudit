echo
echo "Instalando ..."
echo
apt-get install nikto
echo
apt-get install nmap
echo
apt-get install dirb
echo
apt-get install gobuster
echo
apt-get install wapiti
echo
echo "... actualizando diccionarios ...  (R) 2025 hackingyseguridad.com "
echo
wget https://raw.githubusercontent.com/hackingyseguridad/diccionarios/refs/heads/master/ficheros.txt -q -O diccionario.txt  --inet4-only
wc -l diccionario.txt
echo ".."
echo "..."
wget https://raw.githubusercontent.com/hackingyseguridad/diccionarios/refs/heads/master/ficheros2.txt -q -O diccionario2.txt  --inet4-only
wc -l diccionario2.txt
echo "...."
echo "....."
echo
echo "actualizado !!! "
apt-get install uniscan
apt-get install docutils git perl map sslscan
git clone https://github.com/golismero/golismero.git
cd golismero
pip install -r requirements.txt
cd ..

