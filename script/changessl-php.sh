#!/bin/bash
export PATH="$PATH:/usr/sbin/"

user="root"
servernginx="_servernginx"

read -p "Masukkan domain yang ingin dipasang SSL Let's Encrypt: " path
read -p "Masukkan email milik klien yang domainnya ingin dipasang SSL Let's Encrypt: " email

#sudo ssh "$user@$servernginx" "certbot --nginx --agree-tos --redirect --hsts --staple-ocsp --must-staple --no-eff-email --force-renewal --email $email -d $path -d www.$path -d file.$path -d www.file.$path -d pma.$path -d www.$path && systemctl restart nginx"

sudo ssh "$user@$servernginx" "certbot --nginx --agree-tos --redirect --hsts --staple-ocsp --must-staple --no-eff-email --staging --reinstall --email $email -d $path -d www.$path -d file.$path -d www.file.$path -d pma.$path -d www.$path && systemctl restart nginx"

sudo ssh "$user@$servernginx" "sed -i 's/listen 443 ssl;/listen 443 ssl http2;/g' /etc/nginx/conf.d/$path.conf && exit"

sudo ssh "$user@$servernginx" "systemctl restart nginx && exit"

echo "$path sudah terpasang Let's Encrypt"