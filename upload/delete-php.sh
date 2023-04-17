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
server="103.102.153.56"

sudo ssh "$user@$server" "rm /etc/nginx/conf.d/$domain.conf"
sudo ssh "$user@$server" "rm -rf /home/$domain/"
sudo ssh "$user@$server" "systemctl restart nginx"
echo "Reverse proxy dihapus"
systemctl restart php-fpm
systemctl restart httpd
exit 1
