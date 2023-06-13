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
        echo "Error: Input tidak boleh kosong '$key'"
	echo "Contoh: ./suspend-php.sh --d=domain.com "
	echo
        exit 1
        ;;
    esac
done

# Check if domain is empty
if [[ -z $domain ]]; then
    echo
    echo "Error: --d tidak boleh kosong"
    echo "Contoh: ./suspend-php.sh --d=domain.com"
    echo
    exit 1
fi

home_path="/home/$domain"

# Check if folder exists
if [ ! -d "$home_path" ]; then
        echo "Domain tidak ditemukan. Cek input."
        exit 1
else
        echo "Docker ditemukan. Melanjukan proses..."
fi

echo "Menghentikan docker domain ${domain} yang diminta..."
sleep 3
cd /home/$domain
docker compose stop

sudo quotacheck -ugmf /home
echo "Docker dengan domain ${domain} sudah disuspend"

exit 1
