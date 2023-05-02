#!/bin/bash

echo
echo "Script untuk deploy Node Docker, server harus kosong."
echo
echo "Pastikan server nginx reverse proxy dan DNS sudah tersedia dan dalam kondisi baru"
echo "Pastikan IP private Node Docker dan nginx reverse proxy sudah aktif dan dapat berkomunikasi"
echo "Script ini membutuhkan direktori /backup , pastikan direktori /backup sudah ada di server"
echo
echo "CTRL + C jika:"
echo "- Ini bukan server kosong" 
echo "- Server nginx dan DNS belum ada"
echo "- IP private belum bisa terhubung"
echo
sleep 5
read -p "Masukkan IP private server Node Docker: " ipprivate_node
echo
read -p "Masukkan IP server nginx reverse proxy: " ip_nginx
read -p "Masukkan password root server nginx reverse proxy: " pass_nginx
echo
read -p "Masukkan IP server DNS: " ip_named
read -p "Masukkan password root server DNS: " pass_named
read -p "Masukkan ns1 yang akan DNS gunakan (format: ns1.domain.tld): " ns_named
echo
echo "Memulai proses..."
sleep 5

# install library
yum update -y
yum install quota wget nano curl vim lsof git sshpass epel-release zip -y

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
#ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa <<< y

echo "Selesai. Berikutnya download script lalu koneksikan server ini dengan nginx reverse proxy dan named..."
sleep 3

# deploy nginx
echo "Memulai deploy nginx..."
echo "Download script..."
echo "Menunggu input key ke github"
#sleep 30
ssh-keyscan -t rsa github.com >> /root/.ssh/known_hosts
cd /home
git clone git@github.com:sheratan17/docker-hosting.git
mv /home/docker-hosting/script/setup-php.sh /home/
mv /home/docker-hosting/script/delete-php.sh /home/
mv /home/docker-hosting/script/changepkg-php.sh /home/

# Masukkan IP private server
sed -i "s/_ipprivate_node/$ipprivate_node/g" /home/docker-hosting/wp-template/docker-compose.yml

# Membuat nginx reverse proxy
echo
echo "Membuat nginx reverse proxy..."

ssh-keyscan -t rsa $ip_nginx >> /root/.ssh/known_hosts

sshpass -p "$pass_nginx" ssh-copy-id root@$ip_nginx
ssh root@$ip_nginx "yum install epel-release -y && exit"
ssh root@$ip_nginx "yum install nginx nano lsof certbot python3-certbot-nginx -y && exit"

# download script dan update config di nginx reverse
# pindahkan ke setup-php.sh, tambahkan cp
#scp /home/docker-hosting/server-template/template-mandiri.conf.inc root@$ip_nginx:/etc/nginx/conf.d || exit 1
#scp /home/docker-hosting/server-template/template.conf.inc root@$ip_nginx:/etc/nginx/conf.d || exit 1

# ubah bash script agar menggunakan IP nginx
sed -i "s/_servernginx/$ip_nginx/g" /home/setup-php.sh
sed -i "s/_servernginx/$ip_nginx/g" /home/delete-php.sh
sed -i "s/_ipprivate_node/$ipprivate_node/g" /home/delete-php.sh

# pasang modsec
#scp -r /home/docker-hosting/server-template/modsec root@$ip_nginx:/etc/nginx/ || exit 1
#scp -r /home/docker-hosting/server-template/modules root@$ip_nginx:/etc/nginx/ || exit 1
#scp -r /home/docker-hosting/server-template/rules root@$ip_nginx:/etc/nginx/ || exit 1
#ssh root@$ip_nginx "echo -e 'Include /etc/nginx/modsec/crs-setup.conf\nInclude /etc/nginx/rules/*.conf' >> /etc/nginx/modsec/modsecurity.conf"
#ssh root@$ip_nginx "sed -i 's#/var/log/modsec_audit.log#/var/log/nginx/modsec_audit.log#' && exit"
#ssh root@$ip_nginx "touch /var/log/modsec_audit.log && exit"
#ssh root@$ip_nginx "systemctl enable nginx && exit"
#ssh root@$ip_nginx "service nginx restart && exit"

echo "Nginx selesai."
echo

# Membuat DNS Server
# bagian ini dibuang
echo "Memulai deploy server DNS..."
sleep 3

today=$(date +"%Y%m%d")01

echo
domaintanpans=$(echo $ns_named | sed 's/ns1\.//')

sshpass -p "$pass_named" ssh-copy-id root@$ip_named

ssh root@$ip_named "yum install bind nano lsof bind-utils -y && exit"

scp /home/docker-hosting/server-template/_domain.db root@$ip_named:/etc/named || exit 1
scp /home/docker-hosting/server-template/_dns.db root@$ip_named:/etc/named || exit 1
ssh root@$ip_named "mv /etc/named.conf /etc/named.conf.backup && exit"
ssh root@$ip_named "mv /etc/named/_dns.db /etc/named/$domaintanpans.db && exit"
scp /home/docker-hosting/server-template/named.conf root@$ip_named:/etc/ || exit 1

# ubah bash script agar menggunakan IP DNS Server
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

# Membuat backup
echo "Menambahkan cronjob backup dan checkquota..."
chmod +x /home/docker-hosting/script/quotacheck.sh
chmod +x /home/docker-hosting/script/backup.sh
(crontab -l ; echo "0 1 * * * /home/docker-hosting/script/quotacheck.sh > /var/log/quotacheck.txt 2>&1") | crontab -
(crontab -l ; echo "0 2 * * * /home/docker-hosting/script/backup.sh > /var/log/backup.txt 2>&1") | crontab -

#mkdir /backup

echo "Download image docker..."
docker image pull mariadb:10.11.2-jammy
docker image pull wordpress:6.2-php8.2
docker image pull filebrowser/filebrowser:v2-s6
docker image pull phpmyadmin:5.2.1-apache
echo
echo "SCRIPT DEPLOY SELESAI."
echo
echo "Mohon lakukan 'yum update' pada server Node Docker, nginx, serta DNS, lalu restart."
echo "Mohon menunggu 5-10 menit sebelum membuat container untuk melewati masa propagasi DNS Server."
echo
exit 1
