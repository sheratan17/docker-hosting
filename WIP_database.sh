#!/bin/bash

# Function to display usage instructions
usage() {
  echo "Usage: $0"
  echo "This script will prompt for the necessary input."
  exit 1
}

# Function to prompt for input with a specific message
prompt_input() {
  local message=$1
  read -p "$message: " value
  echo "$value"
}

# Check if any command-line arguments are provided
if [[ $# -gt 0 ]]; then
  usage
fi

read -p "Domain: " domain
read -p "CMS: " cms
read -p "Paket: " pkg
read -p "SSL: " encrypt

# Execute the setup-php.sh command with the provided arguments
sh setup-php.sh --d="$domain" --cms="$cms" --p="$pkg" --ssl="$encrypt"

# MySQL credentials
mysql_host="localhost"
mysql_user="root"
mysql_password="????"

# MySQL create table query
create_table_query="CREATE TABLE IF NOT EXISTS aktivasi (id INT AUTO_INCREMENT, domain VARCHAR(255), cms VARCHAR(255), package VARCHAR(255), cert VARCHAR(255), PRIMARY KEY (id));"

# MySQL insert query
insert_query="INSERT INTO aktivasi (domain, cms, package, cert) VALUES ('$domain', '$cms', '$pkg', '$encrypt');"

# Execute the MySQL insert query
mysql -u "$mysql_user" -p"$mysql_password" -D data_host -h"$mysql_host" -e "$create_table_query"
mysql -u "$mysql_user" -p"$mysql_password" -D data_host -h"$mysql_host" -e "$insert_query"
