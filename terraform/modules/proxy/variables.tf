variable "instance_count" {}
variable "instance_type" {}
variable "vpc_id" {}
variable "subnet_id" {}
variable "key_name" {}
variable "next_hop_ips" { type = list(string) }
variable "tags" { type = map(string) }
variable "friendly_names" { type = list(string) }
variable "ami_id" { type = string }
variable "security_group_ids" { type = list(string) }

variable "user_data" {
  type    = string
  default = ""
}
