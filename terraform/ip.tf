resource "digitalocean_floating_ip_assignment" "public-ip" {
  ip_address = "157.245.21.206"
  droplet_id = digitalocean_droplet.minitwit-swarm-leader.id
}

output "public_ip" {
  value = "157.245.21.206"
}