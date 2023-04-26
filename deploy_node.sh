#!/bin/bash

echo
echo "Deploy Node Docker, server harus kosong"
echo "Pastikan server nginx reverse proxy dan named sudah tersedia dan dalam kondisi baru"
echo "Pastikan IP private Node Docker dan nginx reverse proxy sudah aktif dan dapat berkomunikasi"
echo
echo "CTRL + C jika:"
echo "- Ini bukan server kosong" 
echo "- Server nginx dan named belum ada"
echo "- IP private belum bisa terhubung"
echo
sleep 5
read -p "Masukkan IP private server Node Docker: " ipprivate_node
echo
read -p "Masukkan IP server nginx reverse proxy: " ip_nginx
read -p "Masukkan password root server nginx reverse proxy: " pass_nginx
echo
read -p "Masukkan IP server named: " ip_named
read -p "Masukkan password root server named: " pass_named
read -p "Masukkan ns1 yang akan named gunakan (format: ns1.domain.tld): " ns_named
echo
echo "Memulai proses..."
sleep 5

# install library
yum update -y
yum install quota wget nano curl vim lsof git sshpass -y

# Aktifkan quota di /home
line=$(grep "^UUID=.* /home " /etc/fstab)
new_line=$(echo "$line" | sed 's/defaults/&,usrjquota=aquota.user,grpjquota=aquota.group,jqfmt=vfsv1/')
sed -i "s|$line|$new_line|" /etc/fstab
mount -o remount /home
quotacheck -cugm /home
quotaon -v /home
quotaon -ap

# install docker
dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
dnf install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
systemctl enable docker
systemctl start docker

# install apache
yum install httpd php php-json -y

# fix permission dan sudo
usermod -a -G docker apache
usermod -a -G wheel apache
echo "%wheel        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers

# fix apache dan php
sed -i "s/^max_execution_time = .*$/max_execution_time = 600/" /etc/php.ini
echo "ProxyTimeout 600" >> /etc/httpd/conf/httpd.conf
sed -i 's/DirectoryIndex index\.html/DirectoryIndex index.php index.html/g' /etc/httpd/conf/httpd.conf
systemctl enable httpd
systemctl enable php-fpm
systemctl restart httpd
systemctl restart php-fpm

# fix firewall dan selinux
sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
firewall-cmd --zone=public --add-service=http --permanent
firewall-cmd --zone=public --add-service=https --permanent
firewall-cmd --reload

# buat ssh-keygen
ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa <<< y

echo "Selesai. Berikutnya download script lalu koneksikan server ini dengan nginx reverse proxy dan named..."
sleep 3

# deploy nginx
echo "Memulai deploy nginx..."
echo "Download script..."
echo "Menunggu input key ke github"
sleep 30
ssh-keyscan -t rsa github.com >> /root/.ssh/known_hosts
cd /home
git clone git@github.com:sheratan17/docker-wp.git
mv /home/docker-wp/template /home/template
cp /home/docker-wp/upload/*.sh /home/

# Masukkan IP private server

sed -i "s/_ipprivate_node/$ipprivate_node/g" /home/template/docker-compose.yml

# Membuat nginx reverse proxy dan named
echo
echo "Membuat nginx reverse proxy..."

ssh-keyscan -t rsa $ip_nginx >> /root/.ssh/known_hosts

sshpass -p "$pass_nginx" ssh-copy-id root@$ip_nginx
ssh root@$ip_nginx "yum install epel-release -y && exit"
ssh root@$ip_nginx "yum install nginx nano certbot python3-certbot-nginx -y && exit"

# download script dan update config di nginx reverse dan named
sed -i "s/_ipprivate_node/$ipprivate_node/g" /home/docker-wp/template-mandiri.conf.inc
sed -i "s/_ipprivate_node/$ipprivate_node/g" /home/docker-wp/template.conf.inc

scp /home/docker-wp/template-mandiri.conf.inc root@$ip_nginx:/etc/nginx/conf.d || exit 1
scp /home/docker-wp/template.conf.inc root@$ip_nginx:/etc/nginx/conf.d || exit 1

# ubah bash script agar menggunakan IP nginx
sed -i "s/_servernginx/$ip_nginx/g" /home/setup-php.sh
sed -i "s/_servernginx/$ip_nginx/g" /home/delete-php.sh

ssh root@$ip_nginx "systemctl enable nginx && exit"
ssh root@$ip_nginx "service nginx restart && exit"

echo "Nginx selesai."
echo
echo "Memulai deploy server DNS..."
sleep 3

today=$(date +"%Y%m%d")01

# Membuat named
echo
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

sed -i "s/_servernamed/$ip_named/g" /home/setup-php.sh
sed -i "s/_servernamed/$ip_named/g" /home/delete-php.sh

ssh root@$ip_named "systemctl enable named && exit"
ssh root@$ip_named "service named restart && exit"
echo "Server DNS selesai."
echo
echo "Menambahkan cronjob checkquota..."
echo "0 1 * * * /home/docker-wp/quotacheck.sh > /dev/null 2>&1" > /tmp/cronjob
crontab /tmp/cronjob
rm /tmp/cronjob

echo "Download image docker..."
docker image pull mysql:8.0.32
docker image pull wordpress:6.2-php8.2
docker image pull filebrowser/filebrowser
docker image pull phpmyadmin/phpmyadmin
echo "SCRIPT DEPLOY SELESAI."
echo "Mohon lakukan 'yum update' pada server Node Docker, nginx, serta DNS, lalu restart."
echo "Mohon menunggu 5-10 menit sebelum membuat container untuk melewati masa propagasi DNS Server"
echo
exit 1
