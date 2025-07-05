variable "aws_region" {}
variable "vpc_id" {}
variable "subnet_id" {}
variable "key_name" {}
variable "proxy_instance_type" { default = "t3.micro" }
variable "layer1_count"       { default = 10 }
variable "layer2_count"       { default = 4 }
variable "layer2_private_ips" { type = list(string) }
variable "c2_private_ip"      { type = string }
variable "proxy_ami_id" {
  description = "AMI ID for proxy EC2 instances"
  type        = string
}

variable "proxy_security_group_ids" {
  description = "List of security group IDs for proxy EC2 instances"
  type        = list(string)
}
variable "discord_webhook" {
  type        = string
  description = "Discord webhook URL for health checks"
}
