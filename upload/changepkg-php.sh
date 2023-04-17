#!/bin/bash
path=$1
paket=$2

if [ $# -ne 2 ]; then
  echo "Error: Incorrect number of arguments. Please provide two arguments."
  exit 1
fi

pathtanpatitik=$(echo "${path}" | sed 's/\.//g')

if [ "$paket" == "p1" ]; then
	sudo docker update --memory "1g" --cpuset-cpus "1" ${pathtanpatitik}_wp
	sudo docker update --memory "1g" --cpuset-cpus "1" ${pathtanpatitik}_db
	sudo docker update --memory "1g" --cpuset-cpus "1" ${pathtanpatitik}_pma
        sudo setquota -u $path 0 1024000 0 0 -a /home
        sudo echo "User $path sudah menggunakan $paket"
elif [ "$paket" == "p2" ]; then
	sudo docker update --memory "2g" --cpuset-cpus "2" ${pathtanpatitik}_wp
        sudo docker update --memory "2g" --cpuset-cpus "2" ${pathtanpatitik}_db
        sudo docker update --memory "2g" --cpuset-cpus "2" ${pathtanpatitik}_pma
        sudo setquota -u $path 0 2048000 0 0 -a /home
        sudo echo "User $path sudah menggunakan $paket"
else
        sudo echo "Paket salah. Masukkan p1 atau p2."
        sudo exit 1
fi

