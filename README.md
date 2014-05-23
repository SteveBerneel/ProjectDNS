ProjectDNS
==========

* Setup and configuration BIND DNS on CentOS 6
 -Shell provisioning - vagrant

* 2 VM's get created:
 - 1 A MasterDNS machine called Helium
 - 2 A SlaveDNS machine called Lithium

Instructions   (windows)
============

1. open shell 
2. type: git clone https://github.com/SteveBerneel/ProjectDNS.git
3. type: cd ProjectDNS
4. type: vagrant up helium for MasterDNS or vagrant up lithium for SlaveDNS machine

* Run the test script as root
 - type: sudo su root
 - type: bats/bin/bats helium.chem.net.bats
