#!/bin/bash

domain=""

# Loop through all arguments
while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
        --d=*)
        domain="${key#*=}"
        shift
        ;;
        *)
	echo
        echo "Error: Input --d tidak boleh kosong '$key'"
	echo "Contoh: ./delete-php.sh --d=domain.com"
	echo
        exit 1
        ;;
    esac
done

# Check if domain is empty
if [[ -z $domain ]]; then
    echo
    echo "Error: --d tidak boleh kosong"
    echo "Contoh: ./delete-php.sh --d=domain.com"
    echo 
    exit 1
fi


PREFIX=$(echo "${domain}" | sed 's/\.//g')

docker container stop $(docker container ls -q --filter name=${PREFIX}_*)
docker container rm $(docker ps -a -q --filter name=${PREFIX}_*)
docker network rm $(docker network ls -q --filter name=${PREFIX}_*)
docker volume prune -f
sudo userdel -r $domain
#sudo rm -rf /var/spool/mail/$domain
sudo quotacheck -ugmf /home
echo "Docker dan user dihapus"

echo "Hapus reverse proxy..."
user="root"
servernginx="_servernginx"
servernamed="_servernamed"

sudo ssh "$user@$servernginx" "rm /etc/nginx/conf.d/$domain.conf && exit"
sudo ssh "$user@$servernginx" "rm -rf /home/$domain/ && exit"
sudo ssh "$user@$servernginx" "systemctl restart nginx && exit"
echo "Reverse proxy dihapus"
echo "Hapus DNS..."
sudo ssh "$user@$servernamed" "rm /etc/named/$domain.db && exit"
sudo ssh "$user@$servernamed" "sed -i '/# begin zone $domain/,/# end zone $domain/d' /etc/named.conf"
sudo ssh "$user@$servernamed" "systemctl restart named && exit"
echo "DNS dihapus"
echo "Hapus Backup..."
sudo sed -i "/${PREFIX}_db/d" /home/docker-hosting/script/backupsql.sh
sudo rm -f /backup/$PREFIX.sql
sudo rm -f /backup/$PREFIX.zip
echo "Backup dihapus"
systemctl restart php-fpm
systemctl restart httpd
exit 1
