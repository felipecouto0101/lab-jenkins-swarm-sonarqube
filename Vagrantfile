Vagrant.configure("2") do |config|
	config.vbguest.auto_update = false if Vagrant.has_plugin?("vagrant-vbguest")
	config.vm.provision "shell", inline: "echo  Config docker swarm cluster"
	config.vm.define "manager" do |manager|
		manager.vm.box = "ubuntu/focal64"
		manager.vm.hostname = "manager"
		manager.vm.provision "shell", path: "provision.sh"
		manager.vm.network "private_network", ip: "192.168.56.10"
		manager.vm.network "forwarded_port", guest: 80, host: 8090
	end

	config.vm.define "worker1" do |worker1|
		worker1.vm.box = "ubuntu/focal64"
		worker1.vm.hostname = "worker1"
		worker1.vm.provision "shell", path: "provision.sh"
		worker1.vm.network "private_network", ip: "192.168.56.11"
		worker1.vm.network "forwarded_port", guest: 80, host: 8091
	end

    config.vm.define "worker2" do |worker2|
		worker2.vm.box = "ubuntu/focal64"
		worker2.vm.hostname = "worker2"
		worker2.vm.provision "shell", path: "provision.sh"
		worker2.vm.network "private_network", ip: "192.168.56.12"
		worker2.vm.network "forwarded_port", guest: 80, host: 8092
	end

end