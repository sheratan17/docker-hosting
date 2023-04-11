#!/bin/bash
RED='\033[0;31m'
NC='\033[0m' # No Color
echo
echo -e "${RED}-----PERINGATAN-----${NC}"
echo "INI UNTUK DELETE DOCKER!!!" 
echo "JANGAN SALAH NAMA DOMAIN!!!"
echo "DOCKER YANG DIHAPUS TIDAK DAPAT KEMBALI!!!"
echo -e "${RED}-----PERINGATAN-----${NC}"
echo
read -p "Masukkan nama domain yang ingin dihapus: " domain
PREFIX=$(echo "${domain}" | sed 's/\.//g')

# Stop all containers that use volumes with the specified prefix
list_docker=$(docker container ls -q --filter "name=${PREFIX}_*" --format '{{.Names}}')
echo Berikut docker yang akan dihapus semua data file, database, etc dan networknya:
echo $list_docker
read -p "Cek lagi apa sudah benar? (y/n): " answer
if [ "$answer" == "y" ]; then
	docker container stop $(docker container ls -q --filter name=${PREFIX}_*)
	docker container rm $(docker ps -a -q --filter name=${PREFIX}_*)
	docker network rm $(docker network ls -q --filter name=${PREFIX}_*)
	docker volume prune -f
	userdel -r qw-${domain}
	rm -rf qw-${domain}
	rm -rf /var/spool/mail/qw-${domain}
	#rm /etc/nginx/conf.d/$domain.conf
	#quotaoff -v /home
	quotacheck -ugmf /home
	#quotaon -v /home
else
	echo "Input salah"
fi

user="root"
server="103.102.153.32"

ssh "$user@$server" "rm -f /etc/nginx/conf.d/$domain.conf"
ssh "$user@$server" "systemctl restart nginx"
