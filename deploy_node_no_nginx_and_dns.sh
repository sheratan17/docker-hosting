#!/bin/bash

echo
echo "Script untuk deploy Node Docker, server harus kosong dalam kondisi baru"
echo "Pastikan IP private pada seluruh server sudah aktif dan dapat berkomunikasi"
echo "Script ini akan membuat direktori /backup , pastikan direktori /backup tidak ada di server"
echo
echo "CTRL + C jika:"
echo "- Semua server bukan server baru/kosong" 
echo "- Server belum lengkap"
echo "- IP private belum bisa terhubung"
echo
read -p "Masukkan IP PRIVATE server Node Docker: " ipprivate_node
echo
read -p "Masukkan IP PUBLIC server nginx reverse proxy: " ip_nginx
read -p "Masukkan password root server nginx reverse proxy: " pass_nginx
echo
read -p "Masukkan IP PUBLIC server DNS-1: " ip_named
read -p "Masukkan password root server DNS-1: " pass_named
echo
read -p "Masukkan IP PUBLIC server DNS-2: " ip_nameed
read -p "Masukkan password root server DNS-2: " pass_nameed
echo
#read -p "Masukkan ns1 yang akan DNS gunakan (format: ns1.domain.tld): " ns_named
echo "Input lengkap. Memulai proses..."
sleep 5
echo
echo "Proses dimulai"
sleep 3


# install library
yum update -y
yum install quota wget nano curl vim lsof git sshpass epel-release zip policycoreutils-python-utils -y

# Aktifkan quota di /home
grep -q "usrjquota=aquota.user,grpjquota=aquota.group,jqfmt=vfsv1" /etc/fstab

if [ $? -eq 0 ]; then
  echo "/etc/fstab terdeteksi sudah ada quota."
  else  
  line=$(grep "^UUID=.* /home " /etc/fstab)
  new_line=$(echo "$line" | sed 's/defaults/&,usrjquota=aquota.user,grpjquota=aquota.group,jqfmt=vfsv1/')
  sed -i "s|$line|$new_line|" /etc/fstab
  mount -o remount /home
  quotacheck -cugm /home
  quotaon -v /home
  quotaon -ap
fi

# install docker
dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
dnf install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
systemctl enable docker
systemctl start docker

# Install zabbix-agent2
wget -P /root https://repo.zabbix.com/zabbix/6.4/rhel/8/x86_64/zabbix-release-6.4-1.el8.noarch.rpm
rpm -Uvh /root/zabbix-release-6.4-1.el8.noarch.rpm
dnf clean all
dnf install zabbix-agent2 zabbix-agent2-plugin-* -y
systemctl enable zabbix-agent2

# Install Fail2Ban
dnf install fail2ban fail2ban-firewalld -y
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
mv /etc/fail2ban/jail.d/00-firewalld.conf /etc/fail2ban/jail.d/00-firewalld.local
touch /etc/fail2ban/jail.d/sshd.local
cat << EOF >> /etc/fail2ban/jail.d/sshd.local
# 3x Gagal, ban 1 jam 
[sshd]
enabled = true
bantime = 1h
maxretry = 3
EOF
systemctl enable fail2ban
systemctl restart fail2ban

# install apache
#yum install httpd php php-json -y

# fix permission dan sudo
#usermod -a -G docker apache
#usermod -a -G wheel apache
#echo "%wheel        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers

# fix apache dan php
#sed -i "s/^max_execution_time = .*$/max_execution_time = 600/" /etc/php.ini
#echo "ProxyTimeout 600" >> /etc/httpd/conf/httpd.conf
#sed -i 's/DirectoryIndex index\.html/DirectoryIndex index.php index.html/g' /etc/httpd/conf/httpd.conf
#systemctl enable httpd
#systemctl enable php-fpm
#systemctl restart httpd
#systemctl restart php-fpm

# fix firewall dan selinux
#sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
firewall-cmd --zone=public --add-service=http --permanent
firewall-cmd --zone=public --add-service=https --permanent
firewall-cmd --reload

# buat ssh-keygen
#ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa <<< y

systemctl daemon-reload

echo "Selesai. Berikutnya download script lalu koneksikan server ini dengan nginx reverse proxy dan named..."
sleep 3

# deploy file docker-hosting
echo "Memulai deploy script docker-hosting..."
echo "Download script..."
echo "Menunggu input key ke github"
#sleep 30
ssh-keyscan -t rsa github.com >> /root/.ssh/known_hosts
cd /home
git clone git@github.com:sheratan17/docker-hosting.git
mv /home/docker-hosting/script/setup-php.sh /home/
mv /home/docker-hosting/script/delete-php.sh /home/
mv /home/docker-hosting/script/changepkg-php.sh /home/
mv /home/docker-hosting/script/suspend-php.sh /home/
mv /home/docker-hosting/script/unsuspend-php.sh /home/
mv /home/docker-hosting/script/changessl-php.sh /home/
mkdir /etc/zabbix/scripts
mv /home/docker-hosting/script/user_quota.sh /etc/zabbix/scripts
chmod +x /etc/zabbix/scripts/user_quota.sh

# Edit file config zabbix-agent2
hostname=$(hostname)
echo "UserParameter=quota.usage,/etc/zabbix/scripts/user_quota.sh" >> "/etc/zabbix/zabbix_agent2.conf"
sed -i "s/Hostname=Zabbix server/Hostname=$hostname/" /etc/zabbix/zabbix_agent2.conf

# Setting port zabbix-agent di node docker
firewall-cmd --zone=public --add-port=10050/tcp --permanent
firewall-cmd --reload

# Masukkan IP private server
sed -i "s/_ipprivate_node/$ipprivate_node/g" /home/docker-hosting/*-template/docker-compose.yml

# Membuat nginx reverse proxy
echo
echo "Membuat nginx reverse proxy..."

ssh-keyscan -t rsa $ip_nginx >> /root/.ssh/known_hosts

sshpass -p "$pass_nginx" ssh-copy-id root@$ip_nginx
#ssh root@$ip_nginx "yum update -y && yum install epel-release -y && exit"
#ssh root@$ip_nginx "yum install nginx nano lsof certbot python3-certbot-nginx policycoreutils-python-utils -y && exit"

# download script dan update config di nginx reverse
#sed -i "s/_ipprivate_node/$ipprivate_node/g" /home/docker-hosting/server-template/*.conf.inc
#scp /home/docker-hosting/server-template/*.conf.inc root@$ip_nginx:/etc/nginx/conf.d || exit 1
#ssh root@$ip_nginx 'sed -i "/http {/a \    server_tokens off;" /etc/nginx/nginx.conf && exit'

# ubah bash script agar menggunakan IP nginx
sed -i "s/_servernginx/$ip_nginx/g" /home/setup-php.sh
sed -i "s/_ipprivate_node_/$ipprivate_node/g" /home/setup-php.sh
sed -i "s/_servernginx/$ip_nginx/g" /home/delete-php.sh
sed -i "s/_servernginx/$ip_nginx/g" /home/changessl-php.sh

# pasang modsec
#scp -r /home/docker-hosting/server-template/modsec root@$ip_nginx:/etc/nginx/ || exit 1
#scp -r /home/docker-hosting/server-template/modules root@$ip_nginx:/etc/nginx/ || exit 1
#scp -r /home/docker-hosting/server-template/rules root@$ip_nginx:/etc/nginx/ || exit 1
#ssh root@$ip_nginx "echo -e 'Include /etc/nginx/modsec/crs-setup.conf\nInclude /etc/nginx/rules/*.conf' >> /etc/nginx/modsec/modsecurity.conf"
#ssh root@$ip_nginx "sed -i 's#/var/log/modsec_audit.log#/var/log/nginx/modsec_audit.log#' && exit"
#ssh root@$ip_nginx "touch /var/log/modsec_audit.log && exit"
#ssh root@$ip_nginx "systemctl enable nginx && exit"
#ssh root@$ip_nginx "service nginx restart && exit"

#ssh root@$ip_nginx "firewall-cmd --zone=public --add-service=http --permanent"
#ssh root@$ip_nginx "firewall-cmd --zone=public --add-service=https --permanent"
#ssh root@$ip_nginx "firewall-cmd --reload && exit"
#ssh root@$ip_nginx "systemctl enable nginx && exit"
#echo "Nginx selesai."
#echo

# Membuat DNS Server
# bagian ini dibuang
#echo "Memulai deploy server DNS..."
#sleep 3

#today=$(date +"%Y%m%d")01

#echo
#domaintanpans=$(echo $ns_named | sed 's/ns1\.//')

ssh-keyscan -t rsa $ip_named >> /root/.ssh/known_hosts
sshpass -p "$pass_named" ssh-copy-id root@$ip_named

ssh-keyscan -t rsa $ip_nameed >> /root/.ssh/known_hosts
sshpass -p "$pass_nameed" ssh-copy-id root@$ip_nameed

#ssh root@$ip_named "yum install bind nano lsof bind-utils -y && exit"

#scp /home/docker-hosting/server-template/_domain.db root@$ip_named:/etc/named || exit 1
#scp /home/docker-hosting/server-template/_dns.db root@$ip_named:/etc/named || exit 1
#ssh root@$ip_named "mv /etc/named.conf /etc/named.conf.backup && exit"
#ssh root@$ip_named "mv /etc/named/_dns.db /etc/named/$domaintanpans.db && exit"
#scp /home/docker-hosting/server-template/named.conf root@$ip_named:/etc/ || exit 1

# ubah bash script agar menggunakan IP DNS Server
#ssh "root@$ip_named" "sed -i "s/_dns/$domaintanpans/g" /etc/named/$domaintanpans.db"
#ssh "root@$ip_named" "sed -i "s/_ipnamed/$ip_named/g" /etc/named/$domaintanpans.db"
#ssh "root@$ip_named" "sed -i "s/_soa/$today/g" /etc/named/$domaintanpans.db"
#ssh "root@$ip_named" "sed -i "s/_dns/$domaintanpans/g" /etc/named.conf"
#ssh "root@$ip_named" "sed -i "s/_dns/$domaintanpans/g" /etc/named/_domain.db"

sed -i "s/_servernamed/$ip_named/g" /home/setup-php.sh
sed -i "s/_servernameed/$ip_nameed/g" /home/setup-php.sh
sed -i "s/_servernamed/$ip_named/g" /home/delete-php.sh
sed -i "s/_servernameed/$ip_nameed/g" /home/delete-php.sh

#ssh root@$ip_named "systemctl enable named && exit"
#ssh root@$ip_named "service named restart && exit"
#echo "Server DNS selesai."
#cho

echo "Menambahkan cronjob backup dan checkquota..."
chmod +x /home/docker-hosting/script/quotacheck.sh
chmod +x /home/docker-hosting/script/backup.sh
(crontab -l ; echo "*/5 * * * * /home/docker-hosting/script/quotacheck.sh > /var/log/quotacheck.txt 2>&1") | crontab -
(crontab -l ; echo "0 2 * * * /home/docker-hosting/script/backup.sh > /var/log/backup.txt 2>&1") | crontab -

mkdir /backup

echo "Download image docker..."
docker image pull mariadb:11.0.2-jammy
docker image pull wordpress:6.2.2-php8.2
docker image pull filebrowser/filebrowser:v2-s6
docker image pull phpmyadmin:5.2.1-apache
docker image pull minio/minio:latest
echo
echo "SCRIPT DEPLOY SELESAI."
echo
echo "Mohon jalankan 'yum update' pada server Node Docker, MySQL, nginx, serta DNS, lalu restart."
echo "Mohon menunggu 5-10 menit sebelum membuat container untuk melewati masa propagasi DNS Server."
echo "Untuk proses installasi server Zabbix, silahkan cek petunjuk yang telah dibuat"
echo
exit 1
