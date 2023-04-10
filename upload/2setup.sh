#!/bin/bash
BLUE='\033[0;36m'
NC='\033[0m' # No Color
#echo
#echo "-----------------------------------------------"
#echo -e "| Buat ${BLUE}Docker untuk Wordpress${NC} berbasis domain |"
#echo "------------------------------created by Andi--"
#echo
#read -p "Masukkan nama domain: " path
#echo
#echo "Paket yang tersedia:"
#echo "1. WP1 (1 Core, 1GB RAM, 1GB SSD)"
#echo "2. WP2 (2 Core, 2GB RAM, 2GB SSD)"
#echo
#read -p "Pilih Paket (1/2): " choice

if [ $# -ne 2 ]; then
	echo
    	echo "Input: $0 <path> <p1|p2>"
	echo
	echo "Dimana path adalah domain dan paket adalah p1 atau p2"
	echo
	echo "Contoh: /2setup.sh qwords.com p1"
    	exit 1
fi

path=$1
paket=$2

echo "Input domain: $path, paket: $paket"

# 1. setting path & add user
pathtanpatitik=$(echo "${path}" | sed 's/\.//g')
/usr/sbin/useradd -m qw-$path

# 2. set disk/quota
#quotacheck -cugf /home

# 3. create user folder
mkdir /home/qw-$path/dbdata
mkdir /home/qw-$path/wpdata
#mkdir /home/qw-$path/config
user_id=$(id -u qw-${path})
group_id=$(id -g qw-${path})
chown -R $user_id:$group_id /home/qw-$path/dbdata
chown -R $user_id:$group_id /home/qw-$path/wpdata
#chown -R $user_id:$group_id /home/qw-$path/config
echo "Membuat user selesai"

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
echo "WP_DOMAIN_filebrowser=${pathtanpatitik}_filebrowser" >> /home/qw-$path/.env
echo "Membuat random password selesai"

# 7. fix docker-compose.yml
sed -i "s/_userdomain/$path/g" /home/qw-$path/docker-compose.yml
sed -i "s/_userid/$user_id/g" /home/qw-$path/docker-compose.yml
sed -i "s/_groupid/$group_id/g" /home/qw-$path/docker-compose.yml

# 8. Case choice
#case $choice in
#    1)
#	$wp1
#	sed -i "s/_memlimit/1G/g" /home/qw-$path/docker-compose.yml
#	sed -i "s/_cpulimit/1.0/g" /home/qw-$path/docker-compose.yml
#	setquota -u qw-$path 0 1024000 0 0 -a /home
#        ;;
#    2) $wp2
#	sed -i "s/_memlimit/2G/g" /home/qw-$path/docker-compose.yml
#	sed -i "s/_cpulimit/2.0/g" /home/qw-$path/docker-compose.yml
#	setquota -u qw-$path 0 2048000 0 0 -a /home
#	;;
#    *) echo "Invalid option" ;;
#esac


if [ "$paket" == "p1" ]; then
	sed -i "s/_memlimit/1G/g" /home/qw-$path/docker-compose.yml
	sed -i "s/_cpulimit/1.0/g" /home/qw-$path/docker-compose.yml
	setquota -u qw-$path 0 1024000 0 0 /home
	echo "User $path udah ditambahkan $paket"
elif [ "$paket" == "p2" ]; then
	sed -i "s/_memlimit/2G/g" /home/qw-$path/docker-compose.yml
	sed -i "s/_cpulimit/2.0/g" /home/qw-$path/docker-compose.yml
	setquota -u qw-$path 0 2048000 0 0 /home
	echo "User $path sudah ditambahkan $paket"
else
	echo "Paket salah. Masukkan p1 atau p2."
	exit 1
fi

# 9. Fix port so it will generate random port in docker-compose.yml
number80=$(shuf -i 1000-3000 -n 1)
number81=$(shuf -i 3001-4000 -n 1)
sed -i "s/_random80/$number80/g" /home/qw-$path/docker-compose.yml
sed -i "s/_random81/$number81/g" /home/qw-$path/docker-compose.yml
echo "Setting docker compose selesai"

# 10. Start docker, final version
cd /home/qw-$path/
docker compose up -d
echo "Memulai kontainer"

# bersih-bersih + fix
#rm /home/qw-$path/docker-compose.yml

# update quota
echo "Update Quota..."
sleep 10s
quotacheck -cugf /home

echo "Quota selesai"

# print
#echo
#echo "Domain: ${path}"
#echo "Username: qw-${path}"
#echo "Password: ${passwd_user}"
#echo

# buat reverse proxy
user="root"
server="103.102.153.32"

# Set the text block to write to the file

#Use SSH to log in to the remote server and write the text block to the file
ssh "$user@$server" "cp /etc/nginx/conf.d/template.conf.inc /etc/nginx/conf.d/$path.conf"
ssh "$user@$server" "sed -i "s/_domain/$path/g" /etc/nginx/conf.d/$path.conf"
ssh "$user@$server" "sed -i "s/_random80/$number80/g" /etc/nginx/conf.d/$path.conf"
ssh "$user@$server" "sed -i "s/_random81/$number81/g" /etc/nginx/conf.d/$path.conf"
ssh "$user@$server" "systemctl restart nginx"
