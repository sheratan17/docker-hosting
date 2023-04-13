#!/bin/bash
export PATH="$PATH:/usr/sbin/"

path=$1
paket=$2
ssl=$3

echo "Input domain: $path, paket: $paket, ssl: $ssl"

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

if [ "$paket" == "p1" ]; then
	sudo sed -i "s/_memlimit/1G/g" /home/$path/docker-compose.yml
	sudo sed -i "s/_cpulimit/1.0/g" /home/$path/docker-compose.yml
	sudo setquota -u $path 0 1024000 0 0 -a /home
	sudo echo "User $path sudah menggunakan $paket"
elif [ "$paket" == "p2" ]; then
	sudo sed -i "s/_memlimit/2G/g" /home/$path/docker-compose.yml
	sudo sed -i "s/_cpulimit/2.0/g" /home/$path/docker-compose.yml
	sudo setquota -u $path 0 2048000 0 0 -a /home
	sudo echo "User $path sudah menggunakan $paket"
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
echo "Username dan password root MySQL bisa di cek di /home/namadomain/info.txt"

# buat reverse proxy
echo "Buat reverse proxy"
user="root"
server="103.102.153.32"

# Set the text block to write to the file
# Use SSH to log in to the remote server and write the text block to the file

if [ "$ssl" == "le" ]; then
	sudo ssh "$user@$server" "cp /etc/nginx/conf.d/template.conf.inc /etc/nginx/conf.d/$path.conf && sed -i "s/_domain/$path/g" /etc/nginx/conf.d/$path.conf && sed -i "s/_random80/$number80/g" /etc/nginx/conf.d/$path.conf && sed -i "s/_random81/$number81/g" /etc/nginx/conf.d/$path.conf && sed -i "s/_random82/$number82/g" /etc/nginx/conf.d/$path.conf && exit"
        sudo ssh "$user@$server" "certbot --nginx --agree-tos --redirect --staging --hsts --staple-ocsp --must-staple --reinstall --email andi.triyadi@qwords.co.id -d $path -d www.$path -d file.$path -d www.file.$path -d pma.$path -d www.$path && systemctl restart nginx" 
	sudo ssh "$user@$server" "sed -i 's/listen 443 ssl;/listen 443 ssl http2;/g' /etc/nginx/conf.d/$path.conf && exit"
	sudo ssh "$user@$server" "systemctl restart nginx && exit"
elif [ "$ssl" == "mandiri" ]; then
	sudo ssh "$user@$server" "mkdir /home/$path && exit"
	sudo scp /var/www/html/$path-crt.crt ${user}@${server}:/home/$path || exit 1
	sudo scp /var/www/html/$path-key.key ${user}@${server}:/home/$path || exit 1
	#sudo rm -f /var/www/html/$path-crt.crt
	#sudo rm -f /var/www/html/$path-key.key
        sudo openssl dhparam -out /home/$path/ssl-dhparams.pem 2048
        sudo scp /home/$path/ssl-dhparams.pem ${user}@${server}:/home/$path || exit 1
	sudo ssh "$user@$server" "cp /etc/nginx/conf.d/template-mandiri.conf.inc /etc/nginx/conf.d/$path.conf && exit"
	sudo ssh "$user@$server" "sed -i "s/_domain/$path/g" /etc/nginx/conf.d/$path.conf && sed -i "s/_random80/$number80/g" /etc/nginx/conf.d/$path.conf && sed -i "s/_random81/$number81/g" /etc/nginx/conf.d/$path.conf && sed -i "s/_random82/$number82/g" /etc/nginx/conf.d/$path.conf && exit"
	sudo ssh "$user@$server" "systemctl restart nginx && exit"
else
	sudo sh -c echo '"no ssl" >> /home/'$path'/info.txt'
	sudo ssh "$user@$server" "cp /etc/nginx/conf.d/template.conf.inc /etc/nginx/conf.d/$path.conf && exit"
	sudo ssh "$user@$server" "sed -i "s/_domain/$path/g" /etc/nginx/conf.d/$path.conf && sed -i "s/_random80/$number80/g" /etc/nginx/conf.d/$path.conf && sed -i "s/_random81/$number81/g" /etc/nginx/conf.d/$path.conf && sed -i "s/_random82/$number82/g" /etc/nginx/conf.d/$path.conf && exit"
	sudo ssh "$user@$server" "systemctl restart nginx && exit"
fi
sudo rm -f /var/www/html/$path-crt.crt
sudo rm -f /var/www/html/$path-key.key
echo "Selesai. Docker aktif"
