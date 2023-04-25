#!/bin/bash

ssh-keyscan -t rsa github.com >> /root/.ssh/known_hosts
cd /home
git clone git@github.com:sheratan17/docker-wp.git
mv /home/docker-wp/template /home/template
cp /home/docker-wp/upload/*.sh /home/

# Masukkan IP private server
read -p "Masukkan IP private server Node Docker: " ipprivate_node
sed -i "s/_ipprivate_node/$ipprivate_node/g" /home/template/docker-compose.yml

# Membuat nginx reverse proxy dan named
echo
echo "Membuat nginx reverse proxy"
echo
read -p "Masukkan IP server nginx reverse proxy: " ip_nginx
read -p "Masukkan password root server nginx reverse proxy: " pass_nginx
echo

ssh-keyscan -t rsa $ip_nginx >> /root/.ssh/known_hosts

sshpass -p "$pass_nginx" ssh-copy-id root@$ip_nginx

ssh root@$ip_nginx "yum install nginx -y && exit"

# download script dan update config di nginx reverse dan named
sed -i "s/_ipprivate_node/$ipprivate_node/g" /home/docker-wp/template-mandiri.conf.inc
sed -i "s/_ipprivate_node/$ipprivate_node/g" /home/docker-wp/template.conf.inc

scp /home/docker-wp/template-mandiri.conf.inc root@$ip_nginx:/etc/nginx/conf.d || exit 1
scp /home/docker-wp/template.conf.inc root@$ip_nginx:/etc/nginx/conf.d || exit 1

# ubah bash script agar menggunakan IP nginx dan named
sed -i "s/_servernginx/$ip_nginx/g" /home/2setup-php.sh
sed -i "s/_iservernamed/$ip_named/g" /home/2setup-php.sh
sed -i "s/_servernginx/$ip_nginx/g" /home/2delete-php.sh
sed -i "s/_iservernamed/$ip_named/g" /home/2delete-php.sh