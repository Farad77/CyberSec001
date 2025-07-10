Vagrant.configure("2") do |config|
  # Configuration de base Windows 11 - VM générique
  config.vm.box = "StefanScherer/windows_11"
  config.vm.box_version = "2021.12.09"
  config.vm.guest = :windows
  config.vm.communicator = "winrm"
  config.vm.hostname = "cybersec-base"
  
  # Configuration réseau - IP statique pour éviter les conflits DHCP
  config.vm.network "private_network", ip: "192.168.56.10"
  
  # Configuration VirtualBox
  config.vm.provider "virtualbox" do |vb|
    vb.gui = true
    vb.memory = "4096"  # Augmenté pour de meilleures performances
    vb.cpus = 2
    vb.name = "Cybersec-Base-VM"
  end
  
  # Configuration OpenVPN avec client1 par défaut
  config.vm.provision "shell", 
    path: "scripts/setup-vpn.ps1",
    privileged: true
end