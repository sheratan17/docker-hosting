#!/bin/bash

path=""
# Loop through all arguments
while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
        --d=*)
        path="${key#*=}"
        shift
        ;;
        *)
        echo
        echo "Error: Input tidak boleh kosong '$key'"
        echo "Contoh: ./delete-php.sh --d=domain.com"
        echo
        exit 1
        ;;
    esac
done

# Check if domain is empty
if [[ -z $path ]]; then
    echo
    echo "Error: --d tidak boleh kosong"
    echo "Contoh: ./delete-php.sh --d=domain.com"
    echo
    exit 1
fi

home_path="/home/$path"

# Check if folder exists
if [ ! -d "$home_path" ]; then
        echo "Domain tidak ditemukan. Cek input."
        exit 1
else
        echo ""
        echo "Docker ditemukan. 5 DETIK SAFETY BUFFER. CTRL-C SEKARANG JIKA SALAH INPUT."
fi
sleep 5
echo "Melanjutkan proses..."
cd /home/$path
docker compose down

sudo userdel -r $path
sudo quotacheck -ugmf /home
echo "Docker dan user dihapus"

echo "Hapus reverse proxy..."
user="root"

servernginx="_servernginx"
servernamed="_servernamed"
servernamedd="_servernameed"

delete_aktivasi_query="USE docker; DELETE FROM aktivasi WHERE domain = '$path'"
delete_resource_query="USE docker; DELETE FROM resource WHERE domain = '$path'"


sudo ssh "$user@$servernginx" "rm /etc/nginx/conf.d/$path.conf && exit"
sudo ssh "$user@$servernginx" "rm -rf /home/$path/ && exit"
sudo ssh "$user@$servernginx" "systemctl restart nginx && exit"
echo "Reverse proxy dihapus"
echo "Hapus DNS..."
sudo ssh "$user@$servernamed" "rm /etc/named/$path.db && exit"
sudo ssh "$user@$servernamed" "sed -i '/# begin zone $path/,/# end zone $path/d' /etc/named.conf"
sudo ssh "$user@$servernamed" "systemctl restart named && exit"
sudo ssh "$user@$servernamedd" "rm /etc/named/$path.db && exit"
sudo ssh "$user@$servernamedd" "sed -i '/# begin zone $path/,/# end zone $path/d' /etc/named.conf"
sudo ssh "$user@$servernamedd" "systemctl restart named && exit"
echo "DNS dihapus"
echo "Hapus Backup..."
sudo sed -i "/${PREFIX}_db/d" /home/docker-hosting/script/backup.sh
sudo rm -f /backup/$PREFIX.sql
sudo rm -f /backup/$PREFIX.zip
echo "Backup dihapus"
echo "Hapus data di MySQL..."
mysql --login-path=client -e "$delete_aktivasi_query"
mysql --login-path=client -e "$delete_resource_query"
echo "Data di MySQL dihapus"
#systemctl restart php-fpm
#systemctl restart httpd
exit 1

