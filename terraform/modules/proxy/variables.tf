variable "instance_count" {}
variable "instance_type" {}
variable "vpc_id" {}
variable "subnet_id" {}
variable "key_name" {}
variable "next_hop_ips" { type = list(string) }
variable "c2_ip" { type = string }
variable "layer_type" { type = string } # "layer1" or "layer2"
variable "tags" { type = map(string) }