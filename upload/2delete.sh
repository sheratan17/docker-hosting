#!/bin/bash
domain=$1

PREFIX=$(echo "${domain}" | sed 's/\.//g')

docker container stop $(docker container ls -q --filter name=${PREFIX}_*)
docker container rm $(docker ps -a -q --filter name=${PREFIX}_*)
docker network rm $(docker network ls -q --filter name=${PREFIX}_*)
docker volume prune -f
sudo /usr/sbin/userdel --remove $domain
sudo rm -rf /var/spool/mail/$domain
sudo quotacheck -ugmf /home
echo "Docker dan user dihapus"

user="root"
server="103.102.153.32"

sudo ssh "$user@$server" "rm -f /etc/nginx/conf.d/$domain.conf"
sudo ssh "$user@$server" "systemctl restart nginx"
echo "reverse proxy dihapus"
exit 1
