# Automated Multi-Layer Proxy Infrastructure

## Overview

This repo provisions a two-layer proxy infrastructure on AWS, configures Nginx as a secure reverse proxy on each instance, and automates Cloudflare DNS record management for operational agility in red team/lab environments.

## Prerequisites

- AWS CLI configured with valid credentials.
- Terraform and Ansible installed.
- Python 3 and `requests` (for Cloudflare automation).
- Cloudflare API token, zone ID, and domain available as env vars.

## Quick Start

1. **Copy and configure variables:**
   ```bash
   cp terraform/terraform.tfvars.example terraform/terraform.tfvars
   # Edit terraform.tfvars with your environment details
   ```

2. **Export Cloudflare credentials:**
   ```bash
   export CF_API_TOKEN="your_token"
   export CF_ZONE_ID="your_zone_id"
   export CF_DOMAIN="yourdomain.com"
   ```

3. **Run deployment:**
   ```bash
   ./deploy_infra.sh
   ```

4. **(Optional) Update Nginx config with Ansible:**
   ```bash
   ansible-playbook -i <inventory> ansible/nginx_proxy.yml
   ```

## Notes

- No static secrets or org-identifying details are included.
- Destroy infra with `terraform destroy` when finished.
