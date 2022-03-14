# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = 'digital_ocean'
  config.vm.box_url = "https://github.com/devopsgroup-io/vagrant-digitalocean/raw/master/box/digital_ocean.box"
  config.ssh.private_key_path = '~/ssh_keys/do_ssh_key'

  config.vm.synced_folder ".", "~/docker", type: "rsync"
  
#   config.vm.define "minitwit-elixir-db",  primary: true do |server|
#     server.vm.network "private_network", ip: "192.168.56.2"
#     server.vm.provider :digital_ocean do |provider|
#       provider.ssh_key_name = "do_ssh_key"
#       provider.token = ENV["DIGITAL_OCEAN_TOKEN"]
#       provider.image = 'docker-18-04'
#       provider.region = 'fra1'
#       provider.size = 's-1vcpu-1gb'
#       provider.privatenetworking = true
#     end
#     server.vm.hostname = "minitwit-elixir-db"
#     server.vm.provision "shell", inline: <<-SHELL
#
#     echo -e "\nVerifying that docker works ...\n"
#     docker run --rm hello-world
#     docker rmi hello-world
#
#     cd /docker
#     ls -la
#     docker run -p 5432:5432 --env-file=database.config.env -d postgres
#
#     echo -e "\nVagrant setup for db done ..."
#     SHELL
#   end



  config.vm.define "minitwit-elixir", primary: true do |server|
    server.vm.provider :digital_ocean do |provider|
      provider.ssh_key_name = "do_ssh_key"
      provider.token = ENV["DIGITAL_OCEAN_TOKEN"]
      provider.image = 'docker-18-04'
      provider.region = 'fra1'
      provider.size = 's-2vcpu-4gb-amd'
      provider.privatenetworking = true
    end

    server.vm.hostname = "minitwit-elixir"
    server.vm.provision "shell", inline: <<-SHELL

    echo -e "\nVerifying that docker works ...\n"
    docker run --rm hello-world
    docker rmi hello-world

    echo -e "\nOpening port for minitwit ...\n"
    ufw allow 4000

    echo -e "\nOpening port for minitwit ...\n"
    echo ". $HOME/.bashrc" >> $HOME/.bash_profile

    echo -e "\nConfiguring credentials as environment variables...\n"
    echo "export DOCKER_USERNAME='endritmegusta'" >> $HOME/.bash_profile
    echo "export DOCKER_PASSWORD='devops2022'" >> $HOME/.bash_profile
    source $HOME/.bash_profile
    cd ~/docker
    ls -la

    echo -e "\nVagrant setup for server done ..."
    echo -e "minitwit will later be accessible at http://$(hostname -I | awk '{print $1}'):4000"
    SHELL
  end
end