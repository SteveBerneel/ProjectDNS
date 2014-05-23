# !/bin/bash -eu
# provision.sh -- BIND DNS helium master

sudo rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6

# Install git, nano, bind
sudo yum install -y git nano bind bind-utils bind-libs

# sudo yum update -y

# Install Bats
sudo su root
git clone https://github.com/sstephenson/bats.git
bats/install.sh /usr/local

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
        listen-on port 53 { any; };
        listen-on-v6 port 53 { ::1; };
        directory "/var/named"; 
        dump-file "/var/named/data/cache_dump.db"; 
        statistics-file "/var/named/data/named_stats.txt"; 
        memstatistics-file "/var/named/data/named_mem_stats.txt"; 
        allow-query     { localnets; };
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
