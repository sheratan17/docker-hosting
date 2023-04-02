#!/bin/bash
BLUE='\033[0;36m'
NC='\033[0m' # No Color
echo
echo "-----------------------------------------------"
echo -e "| Buat ${BLUE}Docker untuk Wordpress${NC} berbasis domain |"
echo "------------------------------created by Andi--"
echo
read -p "Masukkan nama domain: " path
cp -r /home/template/ /home/$path/
pathtanpatitik=$(echo "${path}" | sed 's/\.//g')

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


# fix nginx.conf
sed -i "s/server_name _;/server_name ${path} www.${path};/" /home/$path/nginx-conf/nginx.conf
sed -i "s/_domain/$path/g" /home/$path/docker-compose.yml

# start docker
cd /home/$path/
docker-compose up -d

# Ask for SSL
#sed -i "s/--staging/--force-renewal/g" /home/$path/docker-compose.yml
#cd /home/$path/
#docker-compose up --force-recreate --no-deps certbot

# update config nginx
#docker-compose stop webserver
#curl -sSLo /home/$path/nginx-conf/options-ssl-nginx.conf https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf
#rm /home/$path/nginx-conf/nginx.conf
#wget https://raw.githubusercontent.com/sheratan17/nginx-docker-config/main/nginx.conf -P /home/$path/nginx-conf/
#sed -i "s/_domain/$path/g" /home/$path/nginx-conf/nginx.conf

# fix docker-compose.yml
#sed -i '39a\      - "443:443"' /home/$path/docker-compose.yml

# start docker, final version
#cd /home/$path/
#docker-compose up -d --force-recreate --no-deps webserver
