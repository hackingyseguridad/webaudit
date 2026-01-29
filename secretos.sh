# busca en el codigo secretos: credenciales, tokens, claves

cat index.html | grep -aoP "(?<=(\"|\'|\`))\/[a-zA-Z0-9_?&=\/\-\#\.]*(?=(\"|\'|\`))" | sort -u

cat index.html | grep  -Hrn "user" 
cat index.html | grep  -Hrn "http*" 
cat index.html | grep  -Hrn "token*" 
cat index.html | grep  -Hrn "password*" 
cat index.html | grep  -Hrn "auth" 
cat index.html | grep  -Hrn "api" 
cat index.html | grep  -Hrn "sql" 
cat index.html | grep  -Hrn "Digest" 
cat index.html | grep  -Hrn "email" 
cat index.html | grep  -Hrn "ouath2" 
cat index.html | grep  -Hrn "UserName" 
cat index.html | grep  -Hrn "Passorwd" 
cat index.html | grep  -Hrn "User" 
