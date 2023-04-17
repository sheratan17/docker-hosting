#!/bin/bash
BLUE='\033[0;36m'
NC='\033[0m' # No Color
echo
echo "-----------------------------------------------"
echo -e "| Buat ${BLUE}Docker untuk Wordpress${NC} berbasis domain |"
echo "------------------------------created by Andi--"
echo
read -p "Masukkan nama domain: " path
echo
echo "Paket yang tersedia:"
echo "1. WP1 (1 Core, 1GB RAM, 1GB SSD)"
echo "2. WP2 (2 Core, 2GB RAM, 2GB SSD)"
echo
read -p "Pilih Paket (1/2): " choice

# 1. setting path & add user
pathtanpatitik=$(echo "${path}" | sed 's/\.//g')
useradd -m $path

# 2. set disk/quota
#quotacheck -cugf /home

# 3. create user folder
mkdir /home/$path/dbdata
mkdir /home/$path/wpdata
mkdir /home/$path/pma
#mkdir /home/$path/config
user_id=$(id -u ${path})
group_id=$(id -g ${path})
chown -R $user_id:$group_id /home/$path/dbdata
chown -R $user_id:$group_id /home/$path/wpdata
touch /home/$path/pma/config.user.inc.php
chown -R $user_id:$group_id /home/$path/pma

#chown -R $user_id:$group_id /home/$path/config

# 4. copy file compose from template
cp /home/template/docker-compose.yml /home/$path/

# 5. generate a random password
#passwd_user=$(openssl rand -base64 12)
#echo "${path}:${passwd_user}" | chpasswd
db_root_password=$(openssl rand -base64 9 | tr -dc 'a-zA-Z0-9!^()_' | head -c12)
db_user=$(openssl rand -base64 9 | tr -dc 'a-zA-Z0-9!^()_' | head -c12)
db_password=$(openssl rand -base64 9 | tr -dc 'a-zA-Z0-9!^()_' | head -c12)

# 6. print MYSQL_ROOT_PASSWORD line with the generated password to .env file
echo "MYSQL_ROOT_PASSWORD=$db_root_password" >> /home/$path/.env
echo "MYSQL_USER=$db_user" >>/home/$path/.env
echo "MYSQL_PASSWORD=$db_password" >> /home/$path/.env
echo "WP_DOMAIN_db=${pathtanpatitik}_db" >> /home/$path/.env
echo "WP_DOMAIN_wp=${pathtanpatitik}_wp" >> /home/$path/.env
echo "WP_DOMAIN_filebrowser=${pathtanpatitik}_filebrowser" >> /home/$path/.env
echo "WP_DOMAIN_pma=${pathtanpatitik}_pma" >> /home/$path/.env

# 7. fix docker-compose.yml
sed -i "s/_userdomain/$path/g" /home/$path/docker-compose.yml
sed -i "s/_userid/$user_id/g" /home/$path/docker-compose.yml
sed -i "s/_groupid/$group_id/g" /home/$path/docker-compose.yml

# 8. Case choice
case $choice in
    1)
	$wp1
	sed -i "s/_memlimit/1G/g" /home/$path/docker-compose.yml
	sed -i "s/_cpulimit/1.0/g" /home/$path/docker-compose.yml
	setquota -u $path 0 1024000 0 0 -a /home
        ;;
    2) $wp2
	sed -i "s/_memlimit/2G/g" /home/$path/docker-compose.yml
	sed -i "s/_cpulimit/2.0/g" /home/$path/docker-compose.yml
	setquota -u $path 0 2048000 0 0 -a /home
	;;
    *) echo "Invalid option" 
       exit 1 ;;
esac

# 9. Fix port so it will generate random port in docker-compose.yml
number80=$(shuf -i 1000-2000 -n 1)
number81=$(shuf -i 2001-3000 -n 1)
number82=$(shuf -i 3001-4000 -n 1)
sed -i "s/_random80/$number80/g" /home/$path/docker-compose.yml
sed -i "s/_random81/$number81/g" /home/$path/docker-compose.yml
sed -i "s/_random82/$number82/g" /home/$path/docker-compose.yml

# 10. Start docker, final version
cd /home/$path/
docker compose up -d

# bersih-bersih + fix
#rm /home/$path/docker-compose.yml

# update quota
quotacheck -ugmf /home

# print
echo
echo "Domain: ${path}"
echo "Username: ${path}"
echo "Username DB WP: ${db_user}"
echo "Password DB WP: ${db_password}"
echo "DB WP: wordpress"
echo "Password root MySQL: ${db_root_password}"
echo
echo "Catatan:"
echo -e "Gunakan username: ${BLUE}root${NC} dan password root MySQL untuk login ke phpMyAdmin"
echo "Password root MySQL: ${db_root_password}" >> /home/$path/info.txt

# buat reverse proxy
echo "Buat reverse proxy"
user="root"
server="103.102.153.32"

# Set the text block to write to the file

#Use SSH to log in to the remote server and write the text block to the file
ssh "$user@$server" "cp /etc/nginx/conf.d/template.conf.inc /etc/nginx/conf.d/$path.conf"
ssh "$user@$server" "sed -i "s/_domain/$path/g" /etc/nginx/conf.d/$path.conf"
ssh "$user@$server" "sed -i "s/_random80/$number80/g" /etc/nginx/conf.d/$path.conf"
ssh "$user@$server" "sed -i "s/_random81/$number81/g" /etc/nginx/conf.d/$path.conf"
ssh "$user@$server" "sed -i "s/_random82/$number82/g" /etc/nginx/conf.d/$path.conf"
ssh "$user@$server" "systemctl restart nginx"
echo "Selesai. Docker aktif"
exit 1
