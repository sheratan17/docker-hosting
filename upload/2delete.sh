#!/bin/bash
path=$1


if [ -z "$1" ]; then
  echo "Error: masukkan domain"
  exit 1
fi


PREFIX=$(echo "${path}" | sed 's/\.//g')

docker container stop $(docker container ls -q --filter name=${PREFIX}_*)
docker container rm $(docker ps -a -q --filter name=${PREFIX}_*)
docker network rm $(docker network ls -q --filter name=${PREFIX}_*)
docker volume prune -f
sudo userdel -r $path
#sudo rm -rf /var/spool/mail/$path
sudo quotacheck -ugmf /home
echo "Docker dan user dihapus"

echo "Hapus reverse proxy"
user="root"
server="103.102.153.32"

sudo ssh "$user@$server" "rm /etc/nginx/conf.d/$path.conf"
sudo ssh "$user@$server" "rm -rf /home/$path/"
sudo ssh "$user@$server" "systemctl restart nginx"
echo "reverse proxy dihapus"
exit 1
