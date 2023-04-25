#!/bin/bash

today=$(date +"%Y%m%d")01

# Membuat named
echo
echo "Membuat named"
echo
read -p "Masukkan IP server named: " ip_named
read -p "Masukkan password root server named: " pass_named
read -p "Masukkan ns1 yang akan named gunakan (format: ns1.domain.tld): " ns_named
domaintanpans=$(echo $ns_named | sed 's/ns1\.//')

sshpass -p "$pass_named" ssh-copy-id root@$ip_named

ssh root@$ip_named "yum install bind nano bind-utils -y && exit"

scp /home/docker-wp/_domain.db root@$ip_named:/etc/named || exit 1
scp /home/docker-wp/_dns.db root@$ip_named:/etc/named || exit 1
ssh root@$ip_named "mv /etc/named.conf /etc/named.conf.backup && exit"

ssh root@$ip_named "mv /etc/named/_dns.db /etc/named/$domaintanpans.db && exit"
scp /home/docker-wp/named.conf root@$ip_named:/etc/ || exit 1

# ubah bash script agar menggunakan IP nginx dan named
ssh "root@$ip_named" "sed -i "s/_dns/$domaintanpans/g" /etc/named/$domaintanpans.db"
ssh "root@$ip_named" "sed -i "s/_ipnamed/$ip_named/g" /etc/named/$domaintanpans.db"
ssh "root@$ip_named" "sed -i "s/_soa/$today/g" /etc/named/$domaintanpans.db"
ssh "root@$ip_named" "sed -i "s/_dns/$domaintanpans/g" /etc/named.conf"
ssh "root@$ip_named" "sed -i "s/_dns/$domaintanpans/g" /etc/named/_domain.db"

sed -i "s/_servernamed/$ip_named/g" /home/2setup-php.sh
sed -i "s/_servernamed/$ip_named/g" /home/2delete-php.sh

ssh root@$ip_named "service named restart && exit"