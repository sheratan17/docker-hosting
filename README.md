# docker-hosting
Docker + Script + Let's Encrypt + Disk, CPU dan RAM Quota

Script yang tersedia:
1. Wordpress
2. Minio

# Petunjuk
1. Instal Almalinux 8
2. Untuk server Docker, pastikan semua partisi pakai ext4 dan /home memiliki partisi yang berbeda (tidak disatukan sama / )
3. Untuk server sisanya (nginx, DNS, Zabbix) partisi /home tidak perlu dibedakan
4. Update OS
5. Jalankan `deploy_node.sh` untuk menjalankan semua (sepertinya sih) perintah diatas atau `deploy_node_no_nginx_and_dns.sh` kalau sudah setup node nginx dan DNS (Jadi hanya setup + menghubungkan Node Docker saja)

# Pengembangan
1. Script untuk update ssl dari le ke mandiri atau sebaliknya
2. PHP GUI yang lebih baik
3. SELINUX :heavy_check_mark:
4. Integrasi dengan DNS  :heavy_check_mark:
5. Integrasi dengan nginx reverse proxy :heavy_check_mark:
6. Script untuk deploy server node, dns dan nginx :heavy_check_mark:
7. Integrasi dengan Redis / Memcached
8. Database untuk arsip dan pencatatan
9. Sistem backup - restore :heavy_check_mark:
10. Memastikan port random tidak duplikat
11. Hardening nginx reverse proxy :heavy_check_mark:
12. Antivirus
13. Custom image (Joomla, moodle, etc) :heavy_check_mark:
14. Stats menggunakan zabbix (CPU, RAM, dan Disk Usage) :heavy_check_mark:
15. Sanity input untuk aktivasi, suspend, unsuspend, dan delete :heavy_check_mark:

# API
1. curl JSON request create dengan SSL mandiri<br>
`curl -X POST -H 'Content-Type: application/json' -d '{"--d": "fikara.my.id", "--p": "p1", "--ssl": "mandiri", "--crtpath": "/var/www/html/fikara.my.id.crt", "--keypath": "/var/www/html/fikara.my.id.key"}' http://docker.fastcloud.id/api-create.php`
2. curl JSON request create dengan SSL Let's Encrypt (ganti le dengan nossl kalau tidak mau pakai ssl)<br>
`curl -X POST -H 'Content-Type: application/json' -d '{"--d": "fikara.my.id", "--p": "p1", "--ssl": "le"}' http://docker.fastcloud.id/api-create.php`
3. curl JSON request delete<br>
`curl -X POST -H 'Content-Type: application/json' -d '{"--d": "fikara.my.id"}' http://docker.fastcloud.id/api-delete.php`
4. curl JSON request ganti paket<br>
`curl -X POST -H 'Content-Type: application/json' -d '{"--d": "fikara.my.id", "--p": "p1"}' http://docker.fastcloud.id/api-changepkg.php`
