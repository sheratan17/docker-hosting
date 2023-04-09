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
echo "1. WP1 (1 Core, 1GB RAM, 5GB)"
echo "2. WP2 (2 Core, 2GB RAM, 10GB)"
echo
read -p "Pilih Paket (1/2): " choice

# 1. setting path & add user
pathtanpatitik=$(echo "${path}" | sed 's/\.//g')
useradd -m qw-$path

# 2. set disk/quota
quotacheck -cugf /home

# 3. create user folder
mkdir /home/qw-$path/dbdata
mkdir /home/qw-$path/wpdata
user_id=$(id -u qw-${path})
group_id=$(id -g qw-${path})
chown -R $user_id:$group_id /home/qw-$path/dbdata
chown -R $user_id:$group_id /home/qw-$path/wpdata

# 4. copy file compose from template
cp /home/template/docker-compose.yml /home/qw-$path/

# 5. generate a random password
passwd_user=$(openssl rand -base64 12)
echo "qw-${path}:${passwd_user}" | chpasswd
db_root_password=$(openssl rand -base64 9 | tr -dc 'a-zA-Z0-9!^()_' | head -c12)
db_user=$(openssl rand -base64 9 | tr -dc 'a-zA-Z0-9!^()_' | head -c12)
db_password=$(openssl rand -base64 9 | tr -dc 'a-zA-Z0-9!^()_' | head -c12)

# 6. print MYSQL_ROOT_PASSWORD line with the generated password to .env file
echo "MYSQL_ROOT_PASSWORD=$db_root_password" >> /home/qw-$path/.env
echo "MYSQL_USER=$db_user" >>/home/qw-$path/.env
echo "MYSQL_PASSWORD=$db_password" >> /home/qw-$path/.env
echo "WP_DOMAIN_db=${pathtanpatitik}_db" >> /home/qw-$path/.env
echo "WP_DOMAIN_wp=${pathtanpatitik}_wp" >> /home/qw-$path/.env

# 7. fix docker-compose.yml
sed -i "s/_userdomain/$path/g" /home/qw-$path/docker-compose.yml
sed -i "s/_userid/$user_id/g" /home/qw-$path/docker-compose.yml
sed -i "s/_groupid/$group_id/g" /home/qw-$path/docker-compose.yml

# 8. Case choice
case $choice in
    1)
	$wp1
	sed -i "s/_memlimit/1G/g" /home/qw-$path/docker-compose.yml
	sed -i "s/_cpulimit/1.0/g" /home/qw-$path/docker-compose.yml
	setquota -u qw-$path 0 1024000 0 0 -a /home
        ;;
    2) $wp2
	sed -i "s/_memlimit/2G/g" /home/qw-$path/docker-compose.yml
	sed -i "s/_cpulimit/2.0/g" /home/qw-$path/docker-compose.yml
	setquota -u qw-$path 0 2048000 0 0 -a /home
	;;
    *) echo "Invalid option" ;;
esac

# 9. Fix port so it will generate random port in docker-compose.yml
number80=$(shuf -i 1000-3000 -n 1)
sed -i "s/_random80/$number80/g" /home/qw-$path/docker-compose.yml

# 10. Start docker, final version
cd /home/qw-$path/
docker compose up -d

# bersih-bersih + fix
rm /home/qw-$path/docker-compose.yml

# update quota
quotacheck -cugf /home

# print
#echo
#echo "Domain: ${path}"
#echo "Username: qw-${path}"
#echo "Password: ${passwd_user}"
#echo

# buat reverse proxy
#user="root"
#server="103.102.153.32"

# Set the text block to write to the file

#Use SSH to log in to the remote server and write the text block to the file
#ssh "$user@$server" "cp /etc/nginx/conf.d/template.conf.inc /etc/nginx/conf.d/$path.conf"
#ssh "$user@$server" "sed -i "s/_domain/$path/g" /etc/nginx/conf.d/$path.conf"
#ssh "$user@$server" "sed -i "s/_random80/$number80/g" /etc/nginx/conf.d/$path.conf"
#ssh "$user@$server" "systemctl restart nginx"
