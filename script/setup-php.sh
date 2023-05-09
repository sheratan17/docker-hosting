#!/bin/bash
export PATH="$PATH:/usr/sbin/"

BLUE='\033[0;36m'
NC='\033[0m' # No Color
echo
echo "--------------------------------"
echo "| Buat Hosting berbasis Docker |"
echo "---------------created by Andi--"
echo
echo "Paket yang tersedia:"
echo "1. P1 (1 Core, 1GB RAM, 10GB SSD)"
echo "2. P2 (2 Core, 2GB RAM, 20GB SSD)"
echo
echo "CMS yang tersedia:"
echo "1. Wordpress (wp)"
echo "2. Minio (minio)"


function show_help {
    echo
    echo "Perintah: ./setup-php.sh --cms=<cms> --d=<domain> --p=<package> --ssl=<ssl> --crtpath=<absolute path for crt> --keypath=<absolute path for key> [--h]"
    echo
    echo "Penjelasan:"
    echo "  --cms=<cms>             CMS yang akan dipasang, contoh: --cms=wp"
    echo "  --d=<domain>            Nama domain yang akan dipasang."
    echo "  --p=<package>           Paket hosting yang akan digunakan."
    echo "  --ssl=<ssl>             Status SSL, Gunakan "le" untuk Let's Encrypt, "mandiri" jika ada SSL sendiri, atau "nossl" jika tanpa SSL"
    echo "                          --crtpath dan --keypath harus ada jika pakai --ssl=mandiri"
    echo "  --crtpath=<alamat crt>  --crtpath dan --keypath haruslah alamat absolute, contoh /var/www/html/domain.crt"
    echo "  --keypath=<alamat key>  dan namanya harus domain.crt/.key, contoh qwords.co.id.crt | qwords.co.id.key"
    echo
    echo "  --h                     Tampilkan menu ini."
    echo
    exit 1
}

# Deklarasi variabel
path=""
paket=""
ssl=""
keypath=""
crtpath=""
cms=""

# Buat menu dan deteksi input
while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
	    --cms=*)
        cms="${key#*=}"
        shift
        ;;
        --d=*)
        path="${key#*=}"
        shift
        ;;
        --p=*)
        paket="${key#*=}"
        if [[ $paket != "p1" && $paket != "p2" ]]; then
            echo "Error: Input salah untuk --p. Gunakan p1 atau p2."
            exit 1
        fi
        shift
        ;;
        --ssl=*)
        ssl="${key#*=}"
        if [[ $ssl == "mandiri" ]]; then
            if [[ $# -lt 3 || "${2:0:2}" != "--" || "${3:0:2}" != "--" ]]; then
                echo "Error: --keypath dan --crtpath dibutuhkan saat --ssl=mandiri."
                exit 1
            fi
            keypath="${2#*=}"
            crtpath="${3#*=}"
            shift 2
        fi
        shift
        ;;
        --keypath=*)
        keypath="${key#*=}"
        shift
        ;;
        --crtpath=*)
        crtpath="${key#*=}"
        shift
        ;;
        --h)
        show_help
        shift
        ;;
        *)
        echo "Error: Input tidak dikenali '$key'"
        exit 1
	show_help
        ;;
    esac
done

# Cek input harus lengkap
if [[ -z $cms || -z $path || -z $paket || -z $ssl ]]; then
    echo "Error. Input tidak dikenali."
    show_help
    exit 1
fi


echo "CMS: $cms | Domain: $path, | Paket: $paket, | SSL: $ssl"
echo
echo "Input crt: $crtpath | Input key: $keypath"

# Setting path & add user
pathtanpatitik=$(echo "${path}" | sed 's/\.//g')
sudo /usr/sbin/adduser -m $path

# Copy file template sesuai kondisi CMS
if [ "$cms" == "wp" ]; then
	# RNG FTW
	db_root_password=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 9 | head -n 1)
	db_user=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 9 | head -n 1)
	db_password=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 9 | head -n 1)
	pmasecret=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
	number80=$(shuf -i 1000-5000 -n 1)
	number81=$(shuf -i 5001-9000 -n 1)
	number82=$(shuf -i 9001-12000 -n 1)
	echo "Membuat random password dan port selesai."
	# Buat folder
	sudo mkdir /home/$path/dbdata
	sudo mkdir /home/$path/sitedata
	sudo mkdir /home/$path/pma
	sudo mkdir /home/$path/pma/tmp
	user_id=$(id -u ${path})
	group_id=$(id -g ${path})
	sudo chown -R $user_id:$group_id /home/$path/dbdata
	sudo chown -R $user_id:$group_id /home/$path/sitedata
	echo "Membuat direktori user selesai."
	# Copy file template untuk phpMyAdmin
	sudo cp /home/docker-hosting/pma-template/config.inc.php /home/$path/pma/
	sudo cp /home/docker-hosting/pma-template/config.secret.inc.php /home/$path/pma/
	sudo cp /home/docker-hosting/pma-template/config.user.inc.php /home/$path/pma/
	sudo chown -R $user_id:$group_id /home/$path/pma
	echo "Copy file pma selesai."
	sudo cp /home/docker-hosting/wp-template/docker-compose.yml /home/$path/
	sudo cp /home/docker-hosting/wp-template/wordpress.ini /home/$path/
	echo "Copy file template selesai."
	# Masukkan RNG ke .env
	sudo sh -c 'echo "MYSQL_ROOT_PASSWORD='$db_root_password'" >> /home/'$path'/.env'
	sudo sh -c 'echo "MYSQL_USER='$db_user'" >>/home/'$path'/.env'
	sudo sh -c 'echo "MYSQL_PASSWORD='$db_password'" >> /home/'$path'/.env'
	sudo sh -c 'echo "SITE_DOMAIN_db='${pathtanpatitik}_db'" >> /home/'$path'/.env'
	sudo sh -c 'echo "SITE_DOMAIN_web='${pathtanpatitik}_web'" >> /home/'$path'/.env'
	sudo sh -c 'echo "SITE_DOMAIN_filebrowser='${pathtanpatitik}_filebrowser'" >> /home/'$path'/.env'
	sudo sh -c 'echo "SITE_DOMAIN_pma='${pathtanpatitik}_pma'" >> /home/'$path'/.env'
	sudo sed -i "s/_pma_secret/$pmasecret/g" /home/$path/pma/config.secret.inc.php
	sudo sed -i "s/_random80/$number80/g" /home/$path/docker-compose.yml
	sudo sed -i "s/_random81/$number81/g" /home/$path/docker-compose.yml
	sudo sed -i "s/_random82/$number82/g" /home/$path/docker-compose.yml
	echo "Setting docker compose selesai."
	echo
	echo "Membuat script backup..."
	sudo sh -c 'echo "docker exec _containerdb /usr/bin/mysqldump -u root --password=_containerpassword wordpress > /backup/'$path'.sql && zip -r /home/'$path'.zip /home/'$path'/sitedata && mv /home/'$path'.zip /backup &&  wait" >> /home/docker-hosting/script/backup.sh'
	sudo sed -i "s/_containerdb/${pathtanpatitik}_db/g" /home/docker-hosting/script/backup.sh
	sudo sed -i "s/_containerpassword/$db_root_password/g" /home/docker-hosting/script/backup.sh
	echo "Setting script backup selesai."
elif [ "$cms" == "minio" ]; then
	minio_pass=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 9 | head -n 1)
	sudo mkdir /home/$path/minio
	sudo mkdir /home/$path/minio/data
	user_id=$(id -u ${path})
	group_id=$(id -g ${path})
	sudo chown -R $user_id:$group_id /home/$path/minio
	sudo cp /home/docker-hosting/minio-template/docker-compose.yml /home/$path/
	echo "Copy file template selesai."
	sudo sh -c 'echo "SITE_DOMAIN_minio='${pathtanpatitik}_minio'" >> /home/'$path'/.env'
	sudo sh -c 'echo "MINIO_ROOT_PASSWORD='$minio_pass'" >> /home/'$path'/.env'
	numberminio=$(shuf -i 12001-14000 -n 1)
	numbermini=$(shuf -i 14001-16000 -n 1)
	sudo sed -i "s/_randomminio/$numberminio/g" /home/$path/docker-compose.yml
	sudo sed -i "s/_randommini/$numbermini/g" /home/$path/docker-compose.yml
fi


# Fix docker-compose.yml
sudo sed -i "s/_userdomain/$path/g" /home/$path/docker-compose.yml
sudo sed -i "s/_userid/$user_id/g" /home/$path/docker-compose.yml
sudo sed -i "s/_groupid/$group_id/g" /home/$path/docker-compose.yml

if [ "$paket" == "p1" ]; then
	sudo sed -i "s/_memlimit/1G/g" /home/$path/docker-compose.yml
	sudo sed -i "s/_cpulimit/1.0/g" /home/$path/docker-compose.yml
	sudo setquota -u $path 0 1024000 0 0 -a /home
	sudo echo "User $path sudah diaktifkan dan menggunakan $paket"
elif [ "$paket" == "p2" ]; then
	sudo sed -i "s/_memlimit/2G/g" /home/$path/docker-compose.yml
	sudo sed -i "s/_cpulimit/2.0/g" /home/$path/docker-compose.yml
	sudo setquota -u $path 0 2048000 0 0 -a /home
	sudo echo "User $path sudah diaktifkan dan menggunakan $paket"
else
	sudo echo "Paket salah. Masukkan p1 atau p2."
	sudo exit 1
fi

# Fix port di docker-compose.yml
#last80=999
#for i in {1000..2000}
#do
#  last=$((last+1))
#  echo $last80
#done >> last80.txt
# to do: port nya tidak bentrok

# Start docker, final version
sudo docker compose -f /home/$path/docker-compose.yml up -d
echo "Memulai kontainer..."

# update quota, tunggu 7 detik biar size nya ke update
echo "Update Quota..."
sleep 7s
sudo quotacheck -ugmf /home

echo "Quota selesai."

# print
echo
echo "Domain: ${path}"
echo "Script: ${cms}"
if [ "$cms" == "wp" ]; then
	echo "Database name: wordpress"
	echo "Password root MySQL: ${db_root_password}"
	echo
	echo "Catatan:"
	echo "Gunakan username: root dan password root MySQL untuk login ke phpMyAdmin"
	echo "Username dan password root MySQL bisa di cek di /home/$path/dbdata/info.txt"
	sudo sh -c 'echo "MYSQL_ROOT_PASSWORD='$db_root_password'" >> /home/'$path'/dbdata/info.txt'
	sudo sh -c 'echo "MYSQL_USER='$db_user'" >>/home/'$path'/dbdata/info.txt'
	sudo sh -c 'echo "MYSQL_PASSWORD='$db_password'" >> /home/'$path'/dbdata/info.txt'
	sudo sh -c 'echo "SITE_DOMAIN_db='${pathtanpatitik}_db'" >> /home/'$path'/dbdata/info.txt'
	sudo sh -c 'echo "SITE_DOMAIN_web='${pathtanpatitik}_web'" >> /home/'$path'/dbdata/info.txt'
	sudo sh -c 'echo "SITE_DOMAIN_filebrowser='${pathtanpatitik}_filebrowser'" >> /home/'$path'/dbdata/info.txt'
	sudo sh -c 'echo "SITE_DOMAIN_pma='${pathtanpatitik}_pma'" >> /home/'$path'/dbdata/info.txt'
elif [ "$cms" == "minio" ]; then
	echo "Username: admin"
	echo "Password: ${minio_pass}"
	echo "Minio console dapat diakses melalui ${path}"
	echo
fi

# buat reverse proxy
today=$(date +"%Y%m%d")01
echo "Membuat reverse proxy..."
user="root"
servernginx="_servernginx"
servernamed="_servernamed"
ipprivate_node="_ipprivate_node_"

sudo ssh "$user@$servernamed" "cp /etc/named/_domain.db /etc/named/$path.db && exit"
sudo ssh "$user@$servernamed" "sed -i "s/_domain/$path/g" /etc/named/$path.db && exit"
sudo ssh "$user@$servernamed" "sed -i "s/_soa/$today/g" /etc/named/$path.db && exit"

echo "Membuat input di DNS server..."
ssh "$user@$servernamed" "cat << EOF >> /etc/named.conf
# begin zone $path
zone "$path" {
      type master;
      file \"/etc/named/$path.db\";
      allow-query { any; };
};
# end zone $path
EOF"
sudo ssh "$user@$servernamed" "systemctl restart named"


# SSL GAES
if [[ "$cms" == "wp" && "$ssl" == "le" ]]; then
	sudo ssh "$user@$servernginx" "cp /etc/nginx/conf.d/wp-template.conf.inc /etc/nginx/conf.d/$path.conf && sed -i "s/_domain/$path/g" /etc/nginx/conf.d/$path.conf && sed -i "s/_random80/$number80/g" /etc/nginx/conf.d/$path.conf && sed -i "s/_random81/$number81/g" /etc/nginx/conf.d/$path.conf && sed -i "s/_random82/$number82/g" /etc/nginx/conf.d/$path.conf && sed -i "s/_ipprivate_node/$ipprivate_node/g" /etc/nginx/conf.d/$path.conf && exit"
	# dibawah ini adalah menu untuk aktifkan SSL yang staging vs beneran
	#sudo ssh "$user@$servernginx" "certbot --nginx --agree-tos --redirect --hsts --staple-ocsp --must-staple --no-eff-email --force-renewal --email andi.triyadi@qwords.co.id -d $path -d www.$path -d file.$path -d www.file.$path -d pma.$path -d www.$path && systemctl restart nginx"
	sudo ssh "$user@$servernginx" "certbot --nginx --agree-tos --redirect --hsts --staple-ocsp --must-staple --no-eff-email --staging --reinstall --email andi.triyadi@qwords.co.id -d $path -d www.$path -d file.$path -d www.file.$path -d pma.$path -d www.$path && systemctl restart nginx"
	sudo ssh "$user@$servernginx" "sed -i 's/listen 443 ssl;/listen 443 ssl http2;/g' /etc/nginx/conf.d/$path.conf && exit"
	sudo ssh "$user@$servernginx" "systemctl restart nginx && exit"
	echo "$path sudah terpasang Let's Encrypt"
elif [[ "$cms" == "wp" && "$ssl" == "mandiri" ]]; then
	echo "Membuat file config dan transfer key serta crt ke nginx reverse"
	sudo ssh "$user@$servernginx" "mkdir /home/$path && exit"
	sudo scp $crtpath ${user}@${servernginx}:/home/$path || exit 1
	sudo scp $keypath ${user}@${servernginx}:/home/$path || exit 1
	sudo rm -f $path.crt
	sudo rm -f $path.key
	sudo ssh "$user@$servernginx" "cp /etc/nginx/conf.d/wp-template-mandiri.conf.inc /etc/nginx/conf.d/$path.conf && exit"
	sudo ssh "$user@$servernginx" "sed -i "s/_domain/$path/g" /etc/nginx/conf.d/$path.conf && sed -i "s/_random80/$number80/g" /etc/nginx/conf.d/$path.conf && sed -i "s/_random81/$number81/g" /etc/nginx/conf.d/$path.conf && sed -i "s/_random82/$number82/g" /etc/nginx/conf.d/$path.conf && sed -i "s/_ipprivate_node/$ipprivate_node/g" /etc/nginx/conf.d/$path.conf && exit"
	sudo ssh "$user@$servernginx" sed -i "s/_ipprivate_node/$ipprivate_node/g" /etc/nginx/conf.d/$path.conf && exit
	sudo ssh "$user@$servernginx" "systemctl restart nginx && exit"
	echo "$path sudah terpasang SSL Mandiri (SSL Sendiri)"
elif [[ "$cms" == "wp" && "$ssl" == "nossl" ]]; then
	sudo sh -c echo '"no ssl" >> /home/'$path'/info.txt'
	sudo ssh "$user@$servernginx" "cp /etc/nginx/conf.d/wp-template.conf.inc /etc/nginx/conf.d/$path.conf && exit"
	sudo ssh "$user@$servernginx" "sed -i "s/_domain/$path/g" /etc/nginx/conf.d/$path.conf && sed -i "s/_random80/$number80/g" /etc/nginx/conf.d/$path.conf && sed -i "s/_random81/$number81/g" /etc/nginx/conf.d/$path.conf && sed -i "s/_random82/$number82/g" /etc/nginx/conf.d/$path.conf && exit"
	sudo ssh "$user@$servernginx" "systemctl restart nginx && exit"
	sudo rm -f $crtpath.crt
	sudo rm -f $keypath.key
	echo "$path tidak menggunakan SSL"
elif [[ "$cms" == "minio" && "$ssl" == "le" ]]; then	
	sudo ssh "$user@$servernginx" "cp /etc/nginx/conf.d/minio-template.conf.inc /etc/nginx/conf.d/$path.conf && sed -i "s/_domain/$path/g" /etc/nginx/conf.d/$path.conf && sed -i "s/_randomminio/$numberminio/g" /etc/nginx/conf.d/$path.conf && exit"
	sudo ssh "$user@$servernginx" "certbot --nginx --agree-tos --redirect --hsts --staple-ocsp --must-staple --no-eff-email --staging --reinstall --email andi.triyadi@qwords.co.id -d $path -d www.$path -d file.$path -d www.file.$path -d pma.$path -d www.$path && systemctl restart nginx"
	sudo ssh "$user@$servernginx" "sed -i 's/listen 443 ssl;/listen 443 ssl http2;/g' /etc/nginx/conf.d/$path.conf && exit"
	sudo ssh "$user@$servernginx" "systemctl restart nginx && exit"
	echo "$path sudah terpasang Let's Encrypt"
fi

sudo ssh "$user@$servernamed" "systemctl restart named"
sudo rm -f $path.crt
sudo rm -f $path.key
echo
echo "Selesai. Docker aktif."
echo
exit 1

