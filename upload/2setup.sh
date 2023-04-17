#!/bin/bash
export PATH="$PATH:/usr/sbin/"
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
sudo /usr/sbin/adduser -m $path

# 2. set disk/quota
#quotacheck -cugf /home

# 3. create user folder
sudo mkdir /home/$path/dbdata
sudo mkdir /home/$path/wpdata
#mkdir /home/$path/config
user_id=$(id -u ${path})
group_id=$(id -g ${path})
sudo chown -R $user_id:$group_id /home/$path/dbdata
sudo chown -R $user_id:$group_id /home/$path/wpdata
#chown -R $user_id:$group_id /home/$path/config
echo "Membuat user selesai"

# 4. copy file compose from template
sudo cp /home/template/docker-compose.yml /home/$path/

# 5. generate a random password
#passwd_user=$(openssl rand -base64 12)
#echo "${path}:${passwd_user}" | chpasswd
db_root_password=$(openssl rand -base64 9 | tr -dc 'a-zA-Z0-9!^()_' | head -c12)
db_user=$(openssl rand -base64 9 | tr -dc 'a-zA-Z0-9!^()_' | head -c12)
db_password=$(openssl rand -base64 9 | tr -dc 'a-zA-Z0-9!^()_' | head -c12)

# 6. print MYSQL_ROOT_PASSWORD line with the generated password to .env file

sudo sh -c 'echo "MYSQL_ROOT_PASSWORD='$db_root_password'" >> /home/'$path'/.env'
sudo sh -c 'echo "MYSQL_USER='$db_user'" >>/home/'$path'/.env'
sudo sh -c 'echo "MYSQL_PASSWORD='$db_password'" >> /home/'$path'/.env'
sudo sh -c 'echo "WP_DOMAIN_db='${pathtanpatitik}_db'" >> /home/'$path'/.env'
sudo sh -c 'echo "WP_DOMAIN_wp='${pathtanpatitik}_wp'" >> /home/'$path'/.env'
sudo sh -c 'echo "WP_DOMAIN_filebrowser='${pathtanpatitik}_filebrowser'" >> /home/'$path'/.env'
sudo sh -c 'echo "WP_DOMAIN_pma='${pathtanpatitik}_pma'" >> /home/'$path'/.env'
echo "Membuat random password selesai"

# 7. fix docker-compose.yml
sudo sed -i "s/_userdomain/$path/g" /home/$path/docker-compose.yml
sudo sed -i "s/_userid/$user_id/g" /home/$path/docker-compose.yml
sudo sed -i "s/_groupid/$group_id/g" /home/$path/docker-compose.yml

# 8. Case choice
#case $choice in
#    1)
#	$wp1
#	sed -i "s/_memlimit/1G/g" /home/$path/docker-compose.yml
#	sed -i "s/_cpulimit/1.0/g" /home/$path/docker-compose.yml
#	setquota -u $path 0 1024000 0 0 -a /home
#        ;;
#    2) $wp2
#	sed -i "s/_memlimit/2G/g" /home/$path/docker-compose.yml
#	sed -i "s/_cpulimit/2.0/g" /home/$path/docker-compose.yml
#	setquota -u $path 0 2048000 0 0 -a /home
#	;;
#    *) echo "Invalid option" ;;
#esac

if [ "$paket" == "p1" ]; then
	sudo sed -i "s/_memlimit/1G/g" /home/$path/docker-compose.yml
	sudo sed -i "s/_cpulimit/1.0/g" /home/$path/docker-compose.yml
	sudo setquota -u $path 0 1024000 0 0 -a /home
	sudo echo "User $path udah ditambahkan $paket"
elif [ "$paket" == "p2" ]; then
	sudo sed -i "s/_memlimit/2G/g" /home/$path/docker-compose.yml
	sudo sed -i "s/_cpulimit/2.0/g" /home/$path/docker-compose.yml
	sudo setquota -u $path 0 2048000 0 0 -a /home
	sudo echo "User $path sudah ditambahkan $paket"
else
	sudo echo "Paket salah. Masukkan p1 atau p2."
	sudo exit 1
fi

# 9. Fix port so it will generate random port in docker-compose.yml
number80=$(shuf -i 1000-2000 -n 1)
number81=$(shuf -i 2001-3000 -n 1)
number82=$(shuf -i 3001-4000 -n 1)
sudo sed -i "s/_random80/$number80/g" /home/$path/docker-compose.yml
sudo sed -i "s/_random81/$number81/g" /home/$path/docker-compose.yml
sudo sed -i "s/_random82/$number82/g" /home/$path/docker-compose.yml
echo "Setting docker compose selesai"

# 10. Start docker, final version
#sudo cd /home/$path/
sudo docker compose -f /home/$path/docker-compose.yml up -d
echo "Memulai kontainer"

# bersih-bersih + fix
#rm /home/$path/docker-compose.yml

# update quota
echo "Update Quota..."
sleep 10s
sudo quotacheck -ugmf /home

echo "Quota selesai"

# print
echo
echo "Domain: ${path}"
echo "Username: ${path}"
echo "DB WP: wordpress"
echo "Password root MySQL: ${db_root_password}"
echo
echo "Catatan:"
echo "Gunakan username: root dan password root MySQL untuk login ke phpMyAdmin"
sudo sh -c echo '"Password root MySQL: ${db_root_password}" >> /home/'$path'/info.txt'


# buat reverse proxy
echo "Buat reverse proxy"
user="root"
server="103.102.153.32"

# Set the text block to write to the file

#Use SSH to log in to the remote server and write the text block to the file
sudo ssh "$user@$server" "cp /etc/nginx/conf.d/template.conf.inc /etc/nginx/conf.d/$path.conf"
sudo ssh "$user@$server" "sed -i "s/_domain/$path/g" /etc/nginx/conf.d/$path.conf"
sudo ssh "$user@$server" "sed -i "s/_random80/$number80/g" /etc/nginx/conf.d/$path.conf"
sudo ssh "$user@$server" "sed -i "s/_random81/$number81/g" /etc/nginx/conf.d/$path.conf"
sudo ssh "$user@$server" "sed -i "s/_random82/$number82/g" /etc/nginx/conf.d/$path.conf"
sudo ssh "$user@$server" "systemctl restart nginx"
echo "Selesai. Docker aktif"
exit 1