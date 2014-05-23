# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = '2'
hosts = [
  { name: 'helium', ip: '192.168.64.2' },
  { name: 'lithium', ip: '192.168.64.3' }
]

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = 'alphainternational/centos-6.5-x64'
  hosts.each do |host|
    config.vm.define host[:name] do |node|
      node.vm.hostname = host[:name]
      node.vm.network :private_network,
        ip: host[:ip],
        netmask: '255.255.255.0'
	  node.vm.synced_folder "ProjectFiles", "/tmp/test"

      node.vm.provider :virtualbox do |vb|
        vb.name = host[:name]
      end

      # Provisioning with shell script
      node.vm.provision 'shell', path: host[:name] + '-provision.sh'
  
      end
    end
  end

