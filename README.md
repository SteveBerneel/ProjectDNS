ProjectDNS
==========

Setup and configuration BIND DNS on CentOS 6
 Shell provisioning - vagrant

2 VM's get created:
1 A MasterDNS machine called Helium
2 A SlaveDNS machine called Lithium

Run the test script as root
 sudo bats/bin/bats /tmp/test/helium.chem.net.bats
