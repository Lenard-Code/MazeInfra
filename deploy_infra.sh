#!/bin/bash
set -e

cd terraform
terraform init
terraform apply -auto-approve

LAYER1_IPS=$(terraform output -json layer1_public_ips | jq -r '.[]')
readarray -t LAYER1_ARRAY <<<"$LAYER1_IPS"
SUBDOMAINS=()
for i in "${!LAYER1_ARRAY[@]}"; do
  SUBDOMAINS+=("proxy$((i+1))")
done

cd ..
python3 scripts/update_cloudflare_dns.py --subdomains "${SUBDOMAINS[@]}" --ips "${LAYER1_ARRAY[@]}"

echo "Deployment complete. Layer1 IPs: ${LAYER1_ARRAY[@]}"
