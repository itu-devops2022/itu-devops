data "digitalocean_volume" "data-volume" {
  name   = "data-volume"
}

resource "digitalocean_volume_attachment" "data-volume" {
  droplet_id = digitalocean_droplet.minitwit-swarm-leader.id
  volume_id  = data.digitalocean_volume.data-volume.id

  # create a connection to the leader
  connection {
    user = "root"
    host = digitalocean_droplet.minitwit-swarm-leader.ipv4_address
    type = "ssh"
    private_key = file(var.pvt_key)
    timeout = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /mnt/data-volume",
      "mount -o discard,defaults,noatime /dev/disk/by-id/scsi-0DO_Volume_data-volume /mnt/data-volume",
      "cd /mnt",
      "chmod -R 777 data-volume",
    ]
  }
}