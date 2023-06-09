#!/bin/bash

# Variable
container_name=""
cpu_limit=""
ram_limit=""

# Parsing inputan
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        --d=*)
            container_name="${key#*=}"
            shift
            ;;
        --cpu=*)
            cpu_limit="${key#*=}"
            shift
            ;;
        --ram=*)
            ram_limit="${key#*=}"
            shift
            ;;
        *)
            echo "Invalid argument: $key"
            exit 1
            ;;
    esac
done

# sanity input
if [ -z "$container_name" ]; then
    echo "Usage: $0 --d=<container_name> [--cpu=<cpu_limit>] [--ram=<ram_limit>]"
    exit 1
fi

# hilangkan titik dari inputan
container_name="${container_name//.}"

# ganti cpu
if [ ! -z "$cpu_limit" ]; then
    docker update --cpuset-cpus="$cpu_limit" ${container_name}_web
        docker update --cpuset-cpus="$cpu_limit" ${container_name}_db
    if [ $? -eq 0 ]; then
        echo "CPU untuk '$container_name' sudah berubah menjadi $cpu_limit core(s)."
    else
        echo "Error: Addon gagal '$container_name'."
    fi
fi

# ganti RAM
if [ ! -z "$ram_limit" ]; then
    docker update --memory="$ram_limit" --memory-swap="$ram_limit" ${container_name}_web
docker update --memory="$ram_limit" --memory-swap="$ram_limit" ${container_name}_db
    if [ $? -eq 0 ]; then
        echo "RAM untuk '$container_name' sudah berubah menjadi $ram_limit."
    else
        echo "Error: Addon gagal '$container_name'."
    fi
fi
