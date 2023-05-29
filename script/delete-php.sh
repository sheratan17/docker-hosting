#!/bin/bash

domain=""
cms=""
# Loop through all arguments
#while [[ $# -gt 0 ]]
#do
#    key="$1"
#    case $key in
#        --d=*)
#        domain="${key#*=}"
#        shift
#        ;;
#        *)
#	echo
#        echo "Error: Input --d tidak boleh kosong '$key'"
#	echo "Contoh: ./delete-php.sh --d=domain.com"
#	echo
#       exit 1
#        ;;
#    esac
#done


domain=""
cms=""
# Loop through all arguments
while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
        --d=*)
        domain="${key#*=}"
        shift
        ;;
        --cms=*)
        cms="${key#*=}"
        shift
        ;;
        *)
	echo
        echo "Error: Input tidak boleh kosong '$key'"
	echo "Contoh: ./delete-php.sh --d=domain.com --cms=wp"
	echo
        exit 1
        ;;
    esac
done

# Check if domain is empty
if [[ -z $domain ]]; then
    echo
    echo "Error: --d tidak boleh kosong"
    echo "Contoh: ./delete-php.sh --d=domain.com  --cms=wp"
    echo 
    exit 1
fi

PREFIX=$(echo "${domain}" | sed 's/\.//g')
#PREFIX_WEB = ${PREFIX}_web
#PREFIX_DB = ${PREFIX}_db
#PREFIX_PMA = ${PREFIX}_pma
#PREFIX_FILEBROWSER = ${PREFIX}_filebrowser
#PREFIX_MINIO = ${PREFIX}_minio
#PREFIX_WP_BACKEND = ${PREFIX}_wp-backend
#PREFIX_MINIO_BACKEND = ${PREFIX}_minio-backend

#docker container stop $(docker container ls -q --filter name=${PREFIX}_*)
#docker container rm $(docker ps -a -q --filter name=${PREFIX}_*)
#docker network rm $(docker network ls -q --filter name=${PREFIX}_*)

#echo "Menghentikan Docker yang diminta..."
#docker container stop ${PREFIX}_web
#docker container stop ${PREFIX}_db
#docker container stop ${PREFIX}_pma
#docker container stop ${PREFIX}_filebrowser
#docker container stop ${PREFIX}_minio

#echo "Menghapus Docker yang diminta..."
#docker container rm ${PREFIX}_web
#docker container rm ${PREFIX}_db
#docker container rm ${PREFIX}_pma
#docker container rm ${PREFIX}_filebrowser
#docker container rm ${PREFIX}_minio
#docker network rm ${PREFIX}_backend

#echo "Menghapus Network Docker yang diminta..."
#docker volume prune -f


if [ "$cms" == "wp" ]; then
	echo "Menghentikan Docker WP yang diminta..."
	sleep 3
	docker container stop "${PREFIX}_web"
	docker container stop "${PREFIX}_db"
	docker container stop "${PREFIX}_pma"
	docker container stop "${PREFIX}_filebrowser"
	echo "Menghapus Docker yang diminta..."
	sleep 3
	docker container rm "${PREFIX}_web"
	docker container rm "${PREFIX}_db"
	docker container rm "${PREFIX}_pma"
	docker container rm "${PREFIX}_filebrowser"
	echo "Menghapus Network Docker yang diminta..."
	docker network rm "${PREFIX}_wp-backend}"
elif [ "$cms" == "minio" ]; then
	echo "Menghentikan Docker Minio yang diminta..."
	docker container stop "${PREFIX}_minio"
	sleep 3
	echo "Menghapus Docker Minio yang diminta..."
	sleep 3
	docker container rm "${PREFIX}_minio"
	echo "Menghapus Network Docker yang diminta..."
	docker network rm "${PREFIX}_minio-backend"
fi

sudo userdel -r $domain
#sudo rm -rf /var/spool/mail/$domain
sudo quotacheck -ugmf /home
echo "Docker dan user dihapus"

echo "Hapus reverse proxy..."
user="root"
servernginx="103.102.153.85"
servernamed="103.102.153.86"
servernamedd="103.102.153.87"

sudo ssh "$user@$servernginx" "rm /etc/nginx/conf.d/$domain.conf && exit"
sudo ssh "$user@$servernginx" "rm -rf /home/$domain/ && exit"
sudo ssh "$user@$servernginx" "systemctl restart nginx && exit"
echo "Reverse proxy dihapus"
echo "Hapus DNS..."
sudo ssh "$user@$servernamed" "rm /etc/named/$domain.db && exit"
sudo ssh "$user@$servernamed" "sed -i '/# begin zone $domain/,/# end zone $domain/d' /etc/named.conf"
sudo ssh "$user@$servernamed" "systemctl restart named && exit"
sudo ssh "$user@$servernamedd" "rm /etc/named/$domain.db && exit"
sudo ssh "$user@$servernamedd" "sed -i '/# begin zone $domain/,/# end zone $domain/d' /etc/named.conf"
sudo ssh "$user@$servernamedd" "systemctl restart named && exit"
echo "DNS dihapus"
echo "Hapus Backup..."
sudo sed -i "/${PREFIX}_db/d" /home/docker-hosting/script/backup.sh
sudo rm -f /backup/$PREFIX.sql
sudo rm -f /backup/$PREFIX.zip
echo "Backup dihapus"
#systemctl restart php-fpm
#systemctl restart httpd
exit 1
