resource "aws_instance" "proxy" {
  count         = var.instance_count
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name      = var.key_name

  tags = merge(var.tags, {
    Name = "CD-${element(var.friendly_names, count.index)}"
  })

  user_data = var.user_data
}
