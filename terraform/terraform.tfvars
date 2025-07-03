# Example variable definitions, copy to terraform.tfvars and fill in for use

aws_region        = "us-east-1"
vpc_id            = "vpc-xxxxxxxx"
subnet_id         = "subnet-xxxxxxxx"
key_name          = "your-keypair"
proxy_instance_type = "t3.micro"
layer1_count      = 10
layer2_count      = 4
layer2_private_ips = ["10.0.2.10", "10.0.2.11", "10.0.2.12", "10.0.2.13"]
c2_private_ip     = "10.0.2.100"
