resource "local_file" "next_hops_list" {
  content  = templatefile("${path.module}/next_hops.list.tmpl", { next_hop_ips = var.next_hop_ips })
  filename = "${path.module}/next_hops.list"
}