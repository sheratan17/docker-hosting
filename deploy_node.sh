#!/bin/bash

echo "Deploy Node Docker, server harus kosong"
echo "Pastikan server nginx reverse proxy dan named sudah tersedia dan dalam kondisi baru"
echo "Pastikan IP private Node Docker dan nginx reverse proxy sudah aktif dan dapat berkomunikasi"
echo "CTRL + C sekarang jika ini bukan server kosong atau server nginx dan named belum ada atau IP private belum bisa berkomunikasi"
sleep 7
echo
echo "Memulai proses..."
sleep 3

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

# download script
#cd /home
#git clone git@github.com:sheratan17/docker-wp.git

echo "Selesai. Berikutnya download script lalu koneksikan server ini dengan nginx reverse proxy dan named"