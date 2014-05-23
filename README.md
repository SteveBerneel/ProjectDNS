ProjectDNS
==========

* Setup and configuration BIND DNS on CentOS 6
 -Shell provisioning - vagrant

* 2 VM's get created:
 - 1 A MasterDNS machine called Helium    192.168.64.2
 - 2 A SlaveDNS machine called Lithium    192.168.64.3

* Both VM's will do a yum update before starting

Instructions   (windows)
============

1. open shell 
2. type: git clone https://github.com/SteveBerneel/ProjectDNS.git
3. type: cd ProjectDNS
4. type: vagrant up 
5. type: vagrant ssh helium for MasterDNS or vagrant ssh lithium for SlaveDNS machine

* Run the test script as root
 - type: sudo su root
 - type: bats/bin/bats helium.chem.net.bats
