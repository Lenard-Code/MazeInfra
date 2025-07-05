#!/bin/bash
set -eux

apt-get update
apt-get install -y tinyproxy python3-pip curl

# Ensure logging directory and permissions
mkdir -p /var/log/tinyproxy
chown nobody:nogroup /var/log/tinyproxy

cat <<EOF >/etc/tinyproxy/tinyproxy.conf
User nobody
Group nogroup
Port 8888
Timeout 600
DefaultErrorFile "/usr/share/tinyproxy/default.html"
Logfile "/var/log/tinyproxy/tinyproxy.log"
LogLevel Info
PidFile "/run/tinyproxy/tinyproxy.pid"
MaxClients 100
ViaProxyName "tinyproxy"
ConnectPort 443
ConnectPort 80
# Upstream proxy configuration for Layer2 (route to C2)
%{ for ip in c2_ips ~}
Upstream http ${ip}:8888
%{ endfor ~}
EOF

systemctl restart tinyproxy
systemctl enable tinyproxy

# Place health check script for ubuntu user
mkdir -p /home/ubuntu/health_check
cat <<'PYEOF' >/home/ubuntu/health_check/health_check.py
import os
import requests
import socket
import time

DISCORD_WEBHOOK = "${discord_webhook}"
PROXY_PORT = 8888
CHECK_HOST = "127.0.0.1"
CHECK_TIMEOUT = 5

def check_tinyproxy():
    try:
        with socket.create_connection((CHECK_HOST, PROXY_PORT), CHECK_TIMEOUT) as sock:
            sock.sendall(b"CONNECT google.com:443 HTTP/1.1\r\n\r\n")
            resp = sock.recv(1024)
            if b"200 Connection established" in resp or b"407 Proxy Authentication Required" in resp:
                return True
    except Exception:
        return False
    return False

def report_discord(status):
    color = 3066993 if status else 15158332
    data = {
        "embeds": [
            {
                "title": f"Tinyproxy Health: {'UP' if status else 'DOWN'}",
                "description": f"Host: {os.uname()[1]}\nPort: {PROXY_PORT}",
                "color": color
            }
        ]
    }
    try:
        requests.post(DISCORD_WEBHOOK, json=data)
    except Exception:
        pass

if __name__ == "__main__":
    status = check_tinyproxy()
    report_discord(status)
    if not status:
        exit(1)
PYEOF

chown -R ubuntu:ubuntu /home/ubuntu/health_check
chmod +x /home/ubuntu/health_check/health_check.py
pip3 install requests boto3

# Add health check cron for ubuntu user
( sudo -u ubuntu crontab -l 2>/dev/null; echo "*/5 * * * * /usr/bin/python3 /home/ubuntu/health_check/health_check.py" ) | sort -u | sudo -u ubuntu crontab -
