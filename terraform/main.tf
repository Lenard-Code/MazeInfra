provider "aws" {
  region = var.aws_region
}

# Layer 1 Proxies (public-facing, relay to Layer 2)
module "proxy_layer1" {
  source         = "./modules/proxy"
  instance_count = var.layer1_count
  instance_type  = var.proxy_instance_type
  vpc_id         = var.vpc_id
  subnet_id      = var.subnet_id
  key_name       = var.key_name
  next_hop_ips   = var.layer2_private_ips         # list of Layer 2 IPs for round-robin selection
  c2_ip          = ""                             # not used for Layer 1
  layer_type     = "layer1"
  tags           = { Layer = "1" }
}

# Layer 2 Proxies (private, relay to c2)
module "proxy_layer2" {
  source         = "./modules/proxy"
  instance_count = var.layer2_count
  instance_type  = var.proxy_instance_type
  vpc_id         = var.vpc_id
  subnet_id      = var.subnet_id
  key_name       = var.key_name
  next_hop_ips   = []                             # not used for Layer 2
  c2_ip          = var.c2_private_ip              # C2 IP for final forwarding
  layer_type     = "layer2"
  tags           = { Layer = "2" }
}

output "layer1_public_ips" {
  value = module.proxy_layer1.public_ips
}

output "layer2_private_ips" {
  value = module.proxy_layer2.private_ips
}