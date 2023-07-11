#!/bin/bash
export PATH="$PATH:/usr/sbin/"

BLUE='\033[0;36m'
NC='\033[0m' # No Color

function show_help {
    echo
    echo "--------------------------------"
    echo "| Buat Hosting berbasis Docker |"
    echo "---------------created by Andi--"
    echo
    echo "Paket yang tersedia:"
    echo "1. p1 (1 Core, 1GB RAM, 10GB SSD)"
    echo "2. p2 (2 Core, 2GB RAM, 25GB SSD)"
    echo
    echo "CMS yang tersedia:"
    echo "1. Wordpress (wp)"
    echo "2. Minio (minio)"
    echo
    echo "Perintah: ./setup-php.sh --cms=<cms> --d=<domain> --p=<package> [--h]"
    echo
    echo "Penjelasan:"
    echo "  --cms=<cms>             CMS yang akan dipasang, contoh: --cms=wp"
    echo "  --d=<domain>            Nama domain yang akan dipasang."
    echo "  --p=<package>           Paket hosting yang akan digunakan."
    echo "  --h                     Tampilkan menu ini."
    echo
    exit 1
}

# Deklarasi variabel
path=""
paket=""
cms=""

# Buat menu dan deteksi input
while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
	--cms=*)
        cms="${key#*=}"
        if [[ $cms != "wp" && $cms != "minio" ]]; then
            echo "Error: Input salah untuk --cms"
            exit 1
        fi
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
if [[ -z $cms || -z $path || -z $paket ]]; then
    echo "Error. Input tidak dikenali."
    show_help
    exit 1
fi

# Deklarasi variabel 2
home_path="/home/$path"
named_folder="/etc/named"
named_file="${path}.db"
nginx_folder="/etc/nginx/conf.d"
nginx_file="${path}.conf"
servernginx="_servernginx"
servernamed="_servernamed"
servernamedd="_servernameed"
ipprivate_node="_ipprivate_node_"
search_path="$path"
user="root"

echo ""
echo "Sanity input. Cek apakah direktori atau file konfigurasi sudah aktif..."

# Check if folder exists
if [ -d "$home_path" ]; then
    echo "Domain/direktori di /home ditemukan. Akun sudah aktif. Cek input."
	echo ""
    exit 1
else
	echo "Domain/direktori di /home tidak ditemukan. Akun belum aktif. Melanjutkan proses..."
fi

# Cek apa sudah ada file config nginx
ssh "$user@$servernginx" "[ -f $nginx_folder/$nginx_file ]" > /dev/null 2>&1
nginx_exist=$?

if [ $nginx_exist -eq 0 ]; then
	echo "Domain/direktori nginx ditemukan. Akun sudah aktif. Cek input."
	echo ""
	exit 1
else
	echo "Domain/direktori nginx tidak ditemukan. Akun belum aktif. Melanjutkan proses..."
fi

# Cek apa sudah ada file config named
ssh "$user@$servernamed" "[ -f $named_folder/$named_file ]" > /dev/null 2>&1
named_exist=$?

output=$(ssh "$user@$servernamed" "grep -q '$search_path' '$named_folder/$named_file' && echo found || echo not_found")

if [ $named_exist -eq 0 ]; then
	echo "Domain/direktori named ditemukan. Cek record DNS..."
	if [ "$output" = "found" ]; then
	echo "Record DNS '$search_path' sudah ditemukan di file, cek input."
	exit 1
	fi
else
	echo "Domain/direktori named atau Record DNS tidak ditemukan. Akun belum aktif. Melanjutkan proses..."
fi

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
	echo "Membuat script backup..."
	sudo sh -c 'echo "docker exec _containerdb /usr/bin/mysqldump -u root --password=_containerpassword wordpress > /backup/'$path'.sql" >> /home/docker-hosting/script/backup.sh'
	sudo sh -c 'echo "zip -r /home/'$path'.zip /home/'$path'/sitedata && mv /home/'$path'.zip /backup &&  wait" >> /home/docker-hosting/script/backup.sh '
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
	sudo setquota -u $path 0 10240000 0 0 -a /home
	sudo echo "User $path sudah diaktifkan dan menggunakan $paket"
elif [ "$paket" == "p2" ]; then
	sudo sed -i "s/_memlimit/2G/g" /home/$path/docker-compose.yml
	sudo sed -i "s/_cpulimit/2.0/g" /home/$path/docker-compose.yml
	sudo setquota -u $path 0 25600000 0 0 -a /home
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
echo "Memulai kontainer..."
sudo docker compose -f /home/$path/docker-compose.yml up -d

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

sudo ssh "$user@$servernamed" "cp /etc/named/_domain.db /etc/named/$path.db && exit"
sudo ssh "$user@$servernamed" "sed -i "s/_domain/$path/g" /etc/named/$path.db && exit"
sudo ssh "$user@$servernamed" "sed -i "s/_soa/$today/g" /etc/named/$path.db && exit"

echo "Membuat input di DNS-1 server..."
ssh "$user@$servernamed" "cat << EOF >> /etc/named.conf
# begin zone $path
zone "$path" {
      type master;
      file \"/etc/named/$path.db\";
};
# end zone $path
EOF"

if [ "$cms" == "wp" ]; then
echo "Membuat record DNS di DNS-1 server..."
ssh "$user@$servernamed" "cat << EOF >> /etc/named/$path.db
$path.					IN      A       $servernginx
www                     IN      CNAME   $path.
pma                     IN      A       $servernginx
file                    IN      A       $servernginx
www.pma                 IN      CNAME   pma.$path.
www.file                IN      CNAME   file.$path.
EOF"
fi

if [ "$cms" == "minio" ]; then
echo "Membuat record DNS di DNS-1 server..."
ssh "$user@$servernamed" "cat << EOF >> /etc/named/$path.db
$path.					IN      A       $servernginx
www                     IN      CNAME   $path.
s3.$path.				IN		A		$servernginx
www.s3					IN		CNAME	$path.
EOF"
fi

sudo ssh "$user@$servernamed" "systemctl restart named"

sudo ssh "$user@$servernamedd" "cp /etc/named/_domain.db /etc/named/$path.db && exit"
sudo ssh "$user@$servernamedd" "sed -i "s/_domain/$path/g" /etc/named/$path.db && exit"
sudo ssh "$user@$servernamedd" "sed -i "s/_soa/$today/g" /etc/named/$path.db && exit"

echo "Membuat input di DNS-2 server..."
ssh "$user@$servernamedd" "cat << EOF >> /etc/named.conf
# begin zone $path
zone "$path" {
      type slave;
      file \"/etc/named/$path.db\";
      masters { $servernamedd; };
};
# end zone $path
EOF"

sudo ssh "$user@$servernamedd" "systemctl restart named"

# Aktivasi template nginx
if [ "$cms" == "wp" ]; then
	sudo ssh "$user@$servernginx" "cp /etc/nginx/conf.d/wp-template.conf.inc /etc/nginx/conf.d/$path.conf && exit"
	sudo ssh "$user@$servernginx" "sed -i "s/_domain/$path/g" /etc/nginx/conf.d/$path.conf && sed -i "s/_random80/$number80/g" /etc/nginx/conf.d/$path.conf && sed -i "s/_random81/$number81/g" /etc/nginx/conf.d/$path.conf && sed -i "s/_random82/$number82/g" /etc/nginx/conf.d/$path.conf && exit"
	sudo ssh "$user@$servernginx" "systemctl restart nginx && exit"
fi
if [ "$cms" == "minio" ]; then
	sudo ssh "$user@$servernginx" "cp /etc/nginx/conf.d/minio-template.conf.inc /etc/nginx/conf.d/$path.conf && sed -i "s/_domain/$path/g" /etc/nginx/conf.d/$path.conf && sed -i "s/_randomminio/$numberminio/g" /etc/nginx/conf.d/$path.conf && sed -i "s/_randommini/$numbermini/g" /etc/nginx/conf.d/$path.conf && exit"
	sudo ssh "$user@$servernginx" "systemctl restart nginx && exit"
fi

echo
echo "Selesai. Docker aktif."
echo
exit 1

