VAGRANT_COMMAND = ARGV[0]

Vagrant.configure("2") do |config|
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true

  config.vm.box = "generic/ubuntu2004"

  config.vm.provider "virtualbox" do |v|
    v.cpus = 2
    v.memory = 2048
    config.vm.synced_folder ".", "/vagrant", type: "nfs"
    config.vbguest.auto_update = false if Vagrant.has_plugin?("vagrant-vbguest")
  end

  config.ssh.username = "reverser" if VAGRANT_COMMAND == "ssh"

  config.vm.define "default" do |node|
    node.vm.hostname = "reverser.local"
    node.vm.network :private_network, ip: "192.168.64.78"
    node.vm.network :forwarded_port, guest: 5432, host: 5432
  end

  config.vm.provision "shell", path: "vagrant/setup.sh"
end
