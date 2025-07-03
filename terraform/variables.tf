variable "aws_region" {}
variable "vpc_id" {}
variable "subnet_id" {}
variable "key_name" {}
variable "proxy_instance_type" { default = "t3.micro" }
variable "layer1_count"       { default = 10 }
variable "layer2_count"       { default = 4 }
variable "layer2_private_ips" { type = list(string) }
variable "c2_private_ip"      { type = string }
