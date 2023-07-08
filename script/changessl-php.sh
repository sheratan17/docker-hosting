#!/bin/bash
export PATH="$PATH:/usr/sbin/"

user="root"
servernginx="_servernginx"

read -p "Masukkan domain yang ingin dipasang SSL Let's Encrypt: " path
read -p "Masukkan email milik klien yang domainnya ingin dipasang SSL Let's Encrypt: " email
read -p "Masukkan CMS yang dimiliki klien (wp/minio): " cms

#sudo ssh "$user@$servernginx" "certbot --nginx --agree-tos --redirect --hsts --no-eff-email --force-renewal --email $email -d $path -d www.$path -d file.$path -d www.file.$path -d pma.$path -d www.$path && systemctl restart nginx"

if [ "$cms" == "wp" ]; then
sudo ssh "$user@$servernginx" "certbot --nginx --agree-tos --redirect --hsts --no-eff-email --staging --reinstall --email $email -d $path -d www.$path -d file.$path -d www.file.$path -d pma.$path -d www.$path && systemctl restart nginx"
fi

if [ "$cms" == "minio" ]; then
sudo ssh "$user@$servernginx" "certbot --nginx --agree-tos --redirect --hsts --no-eff-email --staging --reinstall --email $email -d $path -d www.$path && systemctl restart nginx"
fi

sudo ssh "$user@$servernginx" "sed -i 's/listen 443 ssl;/listen 443 ssl http2;/g' /etc/nginx/conf.d/$path.conf && exit"

sudo ssh "$user@$servernginx" "systemctl restart nginx && exit"

echo "$path sudah terpasang Let's Encrypt"
