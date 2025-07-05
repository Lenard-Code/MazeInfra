import os
import requests
import socket

DISCORD_WEBHOOK = "${discord_webhook}"
PROXY_PORT = 8888
CHECK_HOST = "127.0.0.1"
CHECK_TIMEOUT = 5

def get_metadata(path):
    try:
        url = f"http://169.254.169.254/latest/meta-data/{path}"
        return requests.get(url, timeout=2).text
    except Exception:
        return "Unavailable"

def get_instance_name():
    try:
        # Get instance ID first
        instance_id = get_metadata("instance-id")
        region = get_metadata("placement/region")
        # Try to get Name tag from AWS API
        import boto3
        ec2 = boto3.client("ec2", region_name=region)
        reservations = ec2.describe_instances(InstanceIds=[instance_id])["Reservations"]
        for r in reservations:
            for inst in r["Instances"]:
                for tag in inst.get("Tags", []):
                    if tag["Key"] == "Name":
                        return tag["Value"]
    except Exception:
        pass
    return os.uname()[1]

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

def report_discord(status, details):
    color = 3066993 if status else 15158332
    desc = (
        f"Host: {details['name']}\n"
        f"Health: {'UP' if status else 'DOWN'}\n"
        f"Public IP: {details['public_ip']}\n"
        f"Private IP: {details['private_ip']}\n"
        f"Port: {PROXY_PORT}"
    )
    data = {
        "embeds": [
            {
                "title": f"Tinyproxy Health: {'UP' if status else 'DOWN'}",
                "description": desc,
                "color": color
            }
        ]
    }
    try:
        requests.post(DISCORD_WEBHOOK, json=data)
    except Exception:
        pass

if __name__ == "__main__":
    details = {
        "name": get_instance_name(),
        "public_ip": get_metadata("public-ipv4"),
        "private_ip": get_metadata("local-ipv4"),
    }
    status = check_tinyproxy()
    report_discord(status, details)
    if not status:
        exit(1)
