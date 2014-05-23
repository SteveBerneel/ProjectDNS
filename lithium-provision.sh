# !/bin/bash -eu
# provision.sh -- BIND DNS lithium slave

sudo rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6

# Install git, nano, bind
sudo yum install -y git nano bind bind-utils bind-libs

 sudo yum update -y

chmod 644 /etc/named.conf
chgrp root /etc/named.conf

# Create named.conf file
cat > /etc/named.conf << EOF
//
// named.conf
//
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
recursion yes;
dnssec-enable yes;
dnssec-validation yes;
dnssec-lookaside auto;
/* Path to ISC DLV key */
bindkeys-file "/etc/named.iscdlv.key";
managed-keys-directory "/var/named/dynamic";
};
logging {
        channel default_debug {
                file "data/named.run";
                severity dynamic;
        };
};
zone "." IN {
type hint;
file "named.ca";
};
zone"chem.net" IN {
type slave;
file "slaves/chem.net";
masters { 192.168.64.2; };
};
zone"64.168.192.in-addr.arpa" IN {
type slave;
file "slaves/64.168.192.in-addr.arpa";
masters { 192.168.64.2; };
};
include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";

EOF

# Make named running
service named start
chkconfig named on