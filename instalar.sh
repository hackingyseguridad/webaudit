apt-get install nmap
apt-get install 
apt-get install uniscan
apt-get install docutils git perl map sslscan
git clone https://github.com/golismero/golismero.git
cd golismero
pip install -r requirements.txt
cd ..
wget https://raw.githubusercontent.com/hackingyseguridad/fuzzer/master/diccionario.txt -q -O diccionario.txt
