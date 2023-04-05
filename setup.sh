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

# setting path
pathtanpatitik=$(echo "${path}" | sed 's/\.//g')
useradd -m $path

# set disk/quota
setquota -u $path 277865 277865 0 0 /home
quotaoff -v /home
quotacheck -cum /home
quotaon -v /home

# create user folder
mkdir /home/$path/dbdata
mkdir /home/$path/wpdata
mkdir /home/$path/certbot

user_id=$(id -u $path)
group_id=$(id -g $path)
chown -R $user_id:$group_id /home/$path/

# copy file from template
cp -r /home/template/* /home/$path/

# generate a random 12-character password
db_root_password=$(openssl rand -base64 9 | tr -dc 'a-zA-Z0-9!^()_' | head -c12)
db_user=$(openssl rand -base64 9 | tr -dc 'a-zA-Z0-9!^()_' | head -c12)
db_password=$(openssl rand -base64 9 | tr -dc 'a-zA-Z0-9!^()_' | head -c12)

# print MYSQL_ROOT_PASSWORD line with the generated password to .env file
echo "MYSQL_ROOT_PASSWORD=$db_root_password" >> /home/$path/.env
echo "MYSQL_USER=$db_user" >>/home/$path/.env
echo "MYSQL_PASSWORD=$db_password" >> /home/$path/.env
echo "WP_DOMAIN_db=${pathtanpatitik}_db" >> /home/$path/.env
echo "WP_DOMAIN_wp=${pathtanpatitik}_wp" >> /home/$path/.env
echo "WP_DOMAIN_nginx=${pathtanpatitik}_nginx" >> /home/$path/.env
echo "WP_DOMAIN_certbot=${pathtanpatitik}_certbot" >> /home/$path/.env

# fix nginx.conf and docker-compose.yml
sed -i "s/server_name _;/server_name ${path} www.${path};/" /home/$path/nginx-conf/nginx.conf
sed -i "s/_userdomain/$path/g" /home/$path/docker-compose.yml
sed -i "s/_userid/$user_id/g" /home/$path/docker-compose.yml
sed -i "s/_groupid/$group_id/g" /home/$path/docker-compose.yml

# case paket
case $choice in
    1)
	$wp1
	sed -i "s/_memlimit/1G/g" /home/$path/docker-compose.yml
	sed -i "s/_cpulimit/1.0/g" /home/$path/docker-compose.yml
	setquota -u $path 0 1024000 0 0 /home
        ;;
    2) $wp2
	sed -i "s/_memlimit/2G/g" /home/$path/docker-compose.yml
	sed -i "s/_cpulimit/2.0/g" /home/$path/docker-compose.yml
	setquota -u $path 0 2048000 0 0 /home
	;;
    *) echo "Invalid option" ;;
esac

# start docker
cd /home/$path/
docker compose up -d

# Ask for SSL
#sed -i "s/--staging/--force-renewal/g" /home/$path/docker-compose.yml
sed -i "s/_domain/$path/g" /home/$path/docker-compose.yml
cd /home/$path/
docker compose up --force-recreate --no-deps certbot

# update config nginx
docker compose stop webserver
wget https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf -P /home/$path/nginx-conf/
rm /home/$path/nginx-conf/nginx.conf
wget https://raw.githubusercontent.com/sheratan17/nginx-docker-config/main/nginx.conf -P /home/$path/nginx-conf/
sed -i "s/_domain/$path/g" /home/$path/nginx-conf/nginx.conf

# fix port agar random docker-compose.yml
number443=$(( $RANDOM % 720 + 81 ))
number80=$(( $RANDOM % 1200 + 801 ))
sed -i '44a\      - "$number443:443"' /home/$path/docker-compose.yml
sed -i "s/80:80/$number80:80/g" /home/$path/docker-compose.yml

# start docker, final version
chown -R $path:$path /home/$path/certbot
cd /home/$path/
docker compose up -d --force-recreate --no-deps webserver
#docker compose up --force-recreate --no-deps certbot
quotaoff -v /home
quotacheck -cum /home
quotaon -v /home
