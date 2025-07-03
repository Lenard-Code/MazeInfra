provider "aws" {
  region = var.aws_region
}

module "proxy_layer1" {
  source         = "./modules/proxy"
  instance_count = var.layer1_count
  instance_type  = var.proxy_instance_type
  vpc_id         = var.vpc_id
  subnet_id      = var.subnet_id
  key_name       = var.key_name
  next_hop_ips   = var.layer2_private_ips
  tags           = { Layer = "1" }
}

module "proxy_layer2" {
  source         = "./modules/proxy"
  instance_count = var.layer2_count
  instance_type  = var.proxy_instance_type
  vpc_id         = var.vpc_id
  subnet_id      = var.subnet_id
  key_name       = var.key_name
  next_hop_ips   = [var.c2_private_ip]
  tags           = { Layer = "2" }
}

output "layer1_public_ips" {
  value = module.proxy_layer1.public_ips
}

output "layer2_private_ips" {
  value = module.proxy_layer2.private_ips
}
