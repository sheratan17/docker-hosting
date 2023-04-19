#!/bin/bash

user="root"
server="103.102.153.56"

sudo ssh "$user@$server" "rm /etc/named/asd && exit"
exit 1
