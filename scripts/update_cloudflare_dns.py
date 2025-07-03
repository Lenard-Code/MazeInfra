import requests
import os
import argparse

CF_API_TOKEN = os.environ.get('CF_API_TOKEN')
CF_ZONE_ID = os.environ.get('CF_ZONE_ID')
CF_DOMAIN = os.environ.get('CF_DOMAIN')

def update_dns(subdomains, ips):
    headers = {
        "Authorization": f"Bearer {CF_API_TOKEN}",
        "Content-Type": "application/json"
    }
    for sub, ip in zip(subdomains, ips):
        url = f"https://api.cloudflare.com/client/v4/zones/{CF_ZONE_ID}/dns_records"
        payload = {
            "type": "A",
            "name": f"{sub}.{CF_DOMAIN}",
            "content": ip,
            "ttl": 120,
            "proxied": True
        }
        # Check if record exists, then update or create
        resp = requests.get(url, headers=headers, params={"name": f"{sub}.{CF_DOMAIN}"})
        result = resp.json()
        if result.get("result"):
            record_id = result["result"][0]["id"]
            requests.put(f"{url}/{record_id}", headers=headers, json=payload)
        else:
            requests.post(url, headers=headers, json=payload)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--subdomains', nargs='+', required=True, help='List of subdomains')
    parser.add_argument('--ips', nargs='+', required=True, help='List of IPs')
    args = parser.parse_args()
    update_dns(args.subdomains, args.ips)
