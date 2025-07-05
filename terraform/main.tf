provider "aws" {
  region = var.aws_region
}

# Layer 1 Proxies - Bird Names
module "proxy_layer1" {
  source         = "./modules/proxy"
  instance_count = var.layer1_count
  instance_type  = var.proxy_instance_type
  vpc_id         = var.vpc_id
  subnet_id      = var.subnet_id
  key_name       = var.key_name
  next_hop_ips   = var.layer2_private_ips
  tags           = { Layer = "1" }
  friendly_names = [
    "robin", "crow", "eagle", "hawk", "falcon",
    "owl", "finch", "wren", "heron", "crane"
  ]
  ami_id              = var.proxy_ami_id
  security_group_ids  = var.proxy_security_group_ids
  user_data = templatefile("${path.root}/layer1-bootstrap.sh.tpl", {
    layer2_ips      = var.layer2_private_ips
    discord_webhook = var.discord_webhook
  })
}

# Layer 2 Proxies - Cat Names
module "proxy_layer2" {
  source         = "./modules/proxy"
  instance_count = var.layer2_count
  instance_type  = var.proxy_instance_type
  vpc_id         = var.vpc_id
  subnet_id      = var.subnet_id
  key_name       = var.key_name
  next_hop_ips   = []
  tags           = { Layer = "2" }
  friendly_names = [
    "tiger", "lion", "panther", "cheetah"
  ]
  ami_id              = var.proxy_ami_id
  security_group_ids  = var.proxy_security_group_ids
  user_data = templatefile("${path.root}/layer2-bootstrap.sh.tpl", {
    c2_ips         = [var.c2_private_ip]
    discord_webhook = var.discord_webhook
  })
}

# C2 Instance
module "c2" {
  source         = "./modules/c2"
  vpc_id         = var.vpc_id
  subnet_id      = var.subnet_id
  key_name       = var.key_name
  private_ip     = var.c2_private_ip
  tags           = { Role = "C2" }
}
