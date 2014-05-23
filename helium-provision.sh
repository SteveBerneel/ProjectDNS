# !/bin/bash -eu
# provision.sh -- BIND DNS helium master

sudo rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6

# Install git, nano, bind
sudo yum install -y git nano bind bind-utils bind-libs

sudo yum update -y

# Install Bats
sudo su root
git clone https://github.com/sstephenson/bats.git
bats/install.sh /usr/local

cat > /tmp/test/helium.chem.net.bats << 'EOF'
#! /usr/bin/env bats
# Vim: set ft=sh
#
# Test suite for helium.chem.net, a DNS server
#

IP=192.168.64.2

@test "my IP address should be ${IP}" {
result="$(facter ipaddress_eth1)"
[ "${result}" = "${IP}" ]
}

# I need ssh!
@test "port 22 should be listening" {
result="$(netstat -lnt | awk '$6 == "LISTEN" && $4 ~ ":22"')"
[ -n "${result}" ] # output should not be empty
}

# Install necessary packages: bind and bind-utils (the latter for testing with 
# the host command)
@test "package bind should be installed" {
result="$(rpm -q bind)"
# If the package is installed, this regex will not match
[[ ! "${result}" =~ 'not installed' ]]
}

@test "package bind-utils should be installed" {
result="$(rpm -q bind-utils)"
# If the package is installed, this regex will not match
[[ ! "${result}" =~ 'not installed' ]]
}

# Check config files

CONF=/etc/named.conf
ZONE=chem.net
ZONE_FILE=/var/named/${ZONE}
REVERSE_ZONE=64.168.192.in-addr.arpa
REVERSE_ZONE_FILE=/var/named/${REVERSE_ZONE}

@test "${CONF} should exist and have correct permissions" {
[ -f "${CONF}" ]
result="$(stat -c %U:%G:%a ${CONF})"
[ "${result}" = "root:root:644" ]
}

@test "${CONF} should be syntactically correct" {
named-checkconf
}

@test "${CONF} should contain a zone definition" {
result="$(grep zone.*${ZONE} ${CONF})"
[ -n "${result}" ]
}

@test "${CONF} should contain a reverse zone definition" {
result="$(grep zone.*${REVERSE_ZONE} ${CONF})"
[ -n "${result}" ]
}

@test "BIND zone file for chem.net should exist and have correct permissions" {
[ -f "${ZONE_FILE}" ]
result="$(stat -c %U:%G:%a ${ZONE_FILE})"
[ "${result}" = "root:named:640" ]
}

@test "BIND reverse zone file for chem.net should exist and have correct permissions" {
[ -f "${REVERSE_ZONE_FILE}" ]
result="$(stat -c %U:%G:%a ${REVERSE_ZONE_FILE})"
[ "${result}" = "root:named:640" ]
}

@test "BIND zone file should be syntactically correct" {
result="$(named-checkzone ${ZONE}. ${ZONE_FILE} | tail -1)"
[ "${result}" = "OK" ]
}

@test "BIND reverse zone file should be syntactically correct" {
result="$(named-checkzone ${REVERSE_ZONE}. ${REVERSE_ZONE_FILE} | tail -1)"
[ "${result}" = "OK" ]
}

# Check service

@test "port 53 should be listening on TCP" {
result="$(netstat -lnt | awk '$6 == "LISTEN" && $4 ~ ":53"')"
[ -n "${result}" ] # output should not be empty
}

@test "port 53 should be listening on UDP" {
result="$(netstat -lnu | awk '$4 ~ ":53"')"
[ -n "${result}" ] # output should not be empty
}

@test "named should be running" {
result="$(service named status | grep '^named.*is running\.\.\.$')"
[ -n "${result}" ] # output should not be empty
}

# Interact with the DNS server, ask for all A, CNAME, SRV, PTR records

@test "Looking up hydrogen should return the correct address" {
result="$(host hydrogen.${ZONE} ${IP} | grep 'has address')"
[[ "${result}" =~ "192.168.64.1" ]] 
}


@test "Looking up helium should return the correct address" {
result="$(host helium.${ZONE} ${IP} | grep 'has address')"
[[ "${result}" =~ "192.168.64.2" ]] 
}

@test "Looking up lithium should return the correct address" {
result="$(host lithium.${ZONE} ${IP} | grep 'has address')"
[[ "${result}" =~ "192.168.64.3" ]] 
}

@test "Looking up beryllium should return the correct address" {
result="$(host beryllium.${ZONE} ${IP} | grep 'has address')"
[[ "${result}" =~ "192.168.64.4" ]] 
}

@test "Looking up boron should return the correct address" {
result="$(host boron.${ZONE} ${IP} | grep 'has address')"
[[ "${result}" =~ "192.168.64.5" ]] 
}

@test "Looking up carbon should return the correct address" {
result="$(host carbon.${ZONE} ${IP} | grep 'has address')"
[[ "${result}" =~ "192.168.64.6" ]] 
}

@test "Looking up nitrogen should return the correct address" {
result="$(host nitrogen.${ZONE} ${IP} | grep 'has address')"
[[ "${result}" =~ "192.168.64.7" ]] 
}

@test "Looking up oxygen should return the correct address" {
result="$(host oxygen.${ZONE} ${IP} | grep 'has address')"
[[ "${result}" =~ "192.168.64.8" ]] 
}

@test "Looking up fluorine should return the correct address" {
result="$(host fluorine.${ZONE} ${IP} | grep 'has address')"
[[ "${result}" =~ "192.168.64.9" ]] 
}

@test "Looking up neon should return the correct address" {
result="$(host neon.${ZONE} ${IP} | grep 'has address')"
[[ "${result}" =~ "192.168.64.10" ]] 
}

@test "Looking up alias ns1 should return the correct host" {
result="$(host ns1.${ZONE} ${IP} | grep alias)"
[[ "${result}" =~ "helium.${ZONE}" ]]
}

@test "Looking up alias ns2 should return the correct host" {
result="$(host ns2.${ZONE} ${IP} | grep alias)"
[[ "${result}" =~ "lithium.${ZONE}" ]] 
}

@test "Looking up alias www should return the correct host" {
result="$(host www.${ZONE} ${IP} | grep alias)"
[[ "${result}" =~ "boron.${ZONE}" ]] 
}

@test "Looking up alias mail-in should return the correct host" {
result="$(host mail-in.${ZONE} ${IP} | grep alias)"
[[ "${result}" =~ "carbon.${ZONE}" ]] 
}

@test "Looking up alias mail-out should return the correct host" {
result="$(host mail-out.${ZONE} ${IP} | grep alias)"
[[ "${result}" =~ "carbon.${ZONE}" ]] 
}

@test "Looking up domain name should return mail handler and level (10)" {
result="$(host ${ZONE} ${IP} | grep mail)"
[ "${result}" = "${ZONE} mail is handled by 10 carbon.${ZONE}." ]
}

@test "Looking up service ftp should return the correct host and priority/weight/port (10 0 21)" {
result="$(host -t SRV _ftp._tcp.${ZONE} ${IP} | grep SRV)"
[[ "${result}" =~ "10 0 21 nitrogen.${ZONE}" ]] 
}

NET_IP=192.168.64

@test "Looking up ${NET_IP}.1 should return the correct host" {
result="$(host ${NET_IP}.1 ${IP} | grep pointer)"
[ "${result}" = "1.${REVERSE_ZONE} domain name pointer hydrogen.chem.net." ]
}

@test "Looking up ${NET_IP}.2 should return the correct host" {
result="$(host ${NET_IP}.2 ${IP} | grep pointer)"
[ "${result}" = "2.${REVERSE_ZONE} domain name pointer helium.chem.net." ]
}

@test "Looking up ${NET_IP}.3 should return the correct host" {
result="$(host ${NET_IP}.3 ${IP} | grep pointer)"
[ "${result}" = "3.${REVERSE_ZONE} domain name pointer lithium.chem.net." ]
}

@test "Looking up ${NET_IP}.4 should return the correct host" {
result="$(host ${NET_IP}.4 ${IP} | grep pointer)"
[ "${result}" = "4.${REVERSE_ZONE} domain name pointer beryllium.chem.net." ]
}

@test "Looking up ${NET_IP}.5 should return the correct host" {
result="$(host ${NET_IP}.5 ${IP} | grep pointer)"
[ "${result}" = "5.${REVERSE_ZONE} domain name pointer boron.chem.net." ]
}

@test "Looking up ${NET_IP}.6 should return the correct host" {
result="$(host ${NET_IP}.6 ${IP} | grep pointer)"
[ "${result}" = "6.${REVERSE_ZONE} domain name pointer carbon.chem.net." ]
}

@test "Looking up ${NET_IP}.7 should return the correct host" {
result="$(host ${NET_IP}.7 ${IP} | grep pointer)"
[ "${result}" = "7.${REVERSE_ZONE} domain name pointer nitrogen.chem.net." ]
}

@test "Looking up ${NET_IP}.8 should return the correct host" {
result="$(host ${NET_IP}.8 ${IP} | grep pointer)"
[ "${result}" = "8.${REVERSE_ZONE} domain name pointer oxygen.chem.net." ]
}

@test "Looking up ${NET_IP}.9 should return the correct host" {
result="$(host ${NET_IP}.9 ${IP} | grep pointer)"
[ "${result}" = "9.${REVERSE_ZONE} domain name pointer fluorine.chem.net." ]
}

@test "Looking up ${NET_IP}.10 should return the correct host" {
result="$(host ${NET_IP}.10 ${IP} | grep pointer)"
[ "${result}" = "10.${REVERSE_ZONE} domain name pointer neon.chem.net." ]
}
EOF

#45  Give named.conf the correct permissions and set group to root
chmod 644 /etc/named.conf
chgrp root /etc/named.conf

#  Create named.conf file 
//{
cat > /etc/named.conf << EOF
// 
// named.conf // 
// Provided by Red Hat bind package to configure the ISC BIND named(8) DNS
// server as a caching only nameserver (as a localhost DNS resolver only). 
// 
// See /usr/share/doc/bind*/sample/ for example named configuration files. 
//

options {
        listen-on port 53 { 127.0.0.1; 192.168.64.2; };
        listen-on-v6 port 53 { ::1; };
        directory "/var/named"; 
        dump-file "/var/named/data/cache_dump.db"; 
        statistics-file "/var/named/data/named_stats.txt"; 
        memstatistics-file "/var/named/data/named_mem_stats.txt"; 
        allow-query     { localhost; localnets; 192.168.0.0/16; };
        allow-transfer  { localhost; 192.168.64.3; };
        recursion yes; 
        dnssec-enable yes; 
        dnssec-validation yes; 
        dnssec-lookaside auto;

        /* Path to ISC DLV key */
        bindkeys-file "/etc/named.iscdlv.key";

        managed-keys-directory "/var/named/dynamic";
};

logging { channel default_debug {
                  file "data/named.run";
                  severity dynamic;
                 };
        };

zone "." IN {
        type hint;
        file "named.ca";
};

zone "chem.net" IN {                    # Zone definition
        type master;
        file "chem.net";
        allow-update { none; };
};

zone "64.168.192.in-addr.arpa" IN {      # REVERSE Zone definition 
        type master;
        file "64.168.192.in-addr.arpa";
        allow-update { none; };
};

include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";
EOF
//}

#65  Create new zone file chem.net in /var/named/   and set permissions and group   
//{
cat > /var/named/chem.net << 'EOF'
$ORIGIN chem.net.
$TTL 86400
@   IN  SOA     helium.chem.net. root.chem.net. (
        2013042201  ;Serial
        3600        ;Refresh = 1hour
        1800        ;Retry  = 30minutes
        604800      ;Expire  = 1week
        86400 )     ;Minimum TTL
;
;
; Specify our two nameservers
@       IN  NS      helium.chem.net.
@       IN  NS      lithium.chem.net.
@       IN  A       192.168.64.2
@       IN  A       192.168.64.3
        IN  MX   10 carbon.chem.net.
; Resolve nameserver hostnames to IP
hydrogen    IN  A       192.168.64.1  
helium      IN  A       192.168.64.2
lithium     IN  A       192.168.64.3
beryllium   IN  A       192.168.64.4  
boron       IN  A       192.168.64.5  
carbon      IN  A       192.168.64.6  
nitrogen    IN  A       192.168.64.7  
oxygen      IN  A       192.168.64.8
fluorine    IN  A       192.168.64.9
neon        IN  A       192.168.64.10
ns1        IN  CNAME   helium.chem.net.
ns2        IN  CNAME   lithium.chem.net.
www        IN  CNAME   boron.chem.net.
ftp        IN  CNAME   nitrogen.chem.net.
mail-in    IN  CNAME   carbon.chem.net.
mail-out   IN  CNAME   carbon.chem.net.
_ftp._tcp       IN  SRV    10 0 21 nitrogen.chem.net.
EOF
//}
chmod 640 /var/named/chem.net
chgrp named /var/named/chem.net

#71  Create reverse zone file for chem.net and set correct permissions and group
//{
cat > /var/named/64.168.192.in-addr.arpa << 'EOF'
$ORIGIN 64.168.192.in-addr.arpa.
$TTL 86400
@   IN  SOA     helium.chem.net. root.chem.net. (
        2011071003  ;Serial
        3600        ;Refresh
        1800        ;Retry
        604800      ;Expire
        86400   )   ;Minimum TTL
;
@        IN  NS     helium.chem.net.
@        IN  NS     lithium.chem.net.
@        IN  PTR    chem.net.
hydrogen    IN  A      192.168.64.1
helium      IN  A      192.168.64.2
lithium     IN  A      192.168.64.3
beryllium   IN  A      192.168.64.4
boron       IN  A      192.168.64.5
carbon      IN  A      192.168.64.6
nitrogen    IN  A      192.168.64.7
oxygen      IN  A      192.168.64.8
fluorine    IN  A      192.168.64.9
neon        IN  A      192.168.64.10
1      IN  PTR    hydrogen.chem.net.
2      IN  PTR    helium.chem.net.
3      IN  PTR    lithium.chem.net.
4      IN  PTR    beryllium.chem.net.
5      IN  PTR    boron.chem.net.
6      IN  PTR    carbon.chem.net.
7      IN  PTR    nitrogen.chem.net.
8      IN  PTR    oxygen.chem.net.
9      IN  PTR    fluorine.chem.net.
10     IN  PTR    neon.chem.net.
EOF
//}
chmod 640 /var/named/64.168.192.in-addr.arpa
chgrp named /var/named/64.168.192.in-addr.arpa

#97  make named running
service named start
chkconfig named on

# to run the test script
#  bats/bin/bats /tmp/test/helium.chem.net.bats
