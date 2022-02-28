require "vagrant-aws"

# Check https://github.com/mitchellh/vagrant-aws/issues/566#issuecomment-580812210
class Hash
  def slice(*keep_keys)
    h = {}
    keep_keys.each { |key| h[key] = fetch(key) if has_key?(key) }
    h
  end unless Hash.method_defined?(:slice)
  def except(*less_keys)
    slice(*keys - less_keys)
  end unless Hash.method_defined?(:except)
end

Vagrant.configure("2") do |config|
  # config.vm.box = "ubuntu/impish64"
  config.vm.box = "dummy"
  config.vm.provider "aws" do |aws, override|
    # Keys distributed privately
    aws.access_key_id = "XXX"
    aws.secret_access_key = "XXX"
    aws.keypair_name = "Uni key"
    aws.ami ="ami-080badb0bf6503aee"
    aws.region = "eu-central-1"
    aws.instance_type = "t2.micro"
    aws.security_groups = ["uni-1-all-welcome"]

    override.ssh.username = "ubuntu"
    override.ssh.private_key_path = "./Unikey.pem"
   
  config.vm.synced_folder ".", "/home/ubuntu", type: "rsync" 
  config.vm.provision "shell", privileged: false, inline: <<-SHELL
         sudo apt-get --assume-yes update
         sudo apt-get --assume-yes install \
             ca-certificates \
             curl \
             gnupg \
             lsb-release \
             nodejs
         sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
         echo \
             "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
             $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
         sudo apt-get --assume-yes update
         sudo apt-get --assume-yes install docker-ce docker-ce-cli containerd.io
         sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
         sudo chmod +x /usr/local/bin/docker-compose
         pwd
         chmod 777 -R .
         sudo docker build -f docker/app/Dockerfile -t app .
         sudo docker-compose up
    SHELL
  end
end
