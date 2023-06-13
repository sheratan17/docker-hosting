#!/bin/bash

while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        --d=*)
        path="${key#*=}"
        shift
        ;;
        --p=*)
        paket="${key#*=}"
        shift
        ;;
        --h)
	echo
        echo "Error: --d dan --p tidak boleh kosong"
	echo "Contoh: ./changepkg-php.sh --d=domain.com --p=p1"
	echo
        shift
        ;;
        *)
        echo
        echo "Error: --d dan --p tidak boleh kosong"
        echo "Contoh: ./changepkg-php.sh --d=domain.com --p=p1"
        echo
        exit 1
        ;;
    esac
done

if [ -z "$path" ]; then
    echo
    echo "Error: --d tidak boleh kosong"
    echo
    exit 1
fi

if [ -z "$paket" ]; then
    echo
    echo "Error: --p tidak boleh kosong"
    echo
    exit 1
fi

pathtanpatitik=$(echo "${path}" | sed 's/\.//g')

home_path="/home/$path"

# Check if folder exists
if [ ! -d "$home_path" ]; then
        echo "Domain tidak ditemukan. Cek input."
        exit 1
else
        echo "Docker ditemukan. Melanjukan proses..."
fi

if [ "$paket" == "p1" ]; then
        sudo docker update --memory "1g" --memory-swap "1g" --cpuset-cpus "1" ${pathtanpatitik}_web
        sudo docker update --memory "1g" --memory-swap "1g" --cpuset-cpus "1" ${pathtanpatitik}_db
        sudo docker update --memory "1g" --memory-swap "1g" --cpuset-cpus "1" ${pathtanpatitik}_pma
        sudo setquota -u $path 0 1024000 0 0 -a /home
        sudo echo "User $path sudah menggunakan $paket"
elif [ "$paket" == "p2" ]; then
        sudo docker update --memory "2g" --memory-swap "2g" --cpuset-cpus "2" ${pathtanpatitik}_web
        sudo docker update --memory "2g" --memory-swap "2g" --cpuset-cpus "2" ${pathtanpatitik}_db
        sudo docker update --memory "2g" --memory-swap "2g" --cpuset-cpus "2" ${pathtanpatitik}_pma
        sudo setquota -u $path 0 2048000 0 0 -a /home
        sudo echo "User $path sudah menggunakan $paket"
else
        sudo echo "Paket salah. Masukkan p1 atau p2."
        sudo exit 1
fi

