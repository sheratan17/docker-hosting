# docker-wp
Docker + Wordpress + Let's Encrypt + Disk, CPU dan RAM Quota

1. Instal Almalinux 8
2. Pastikan semua partisi pakai ext4 dan /home memiliki partisi yang berbeda (tidak disatukan sama / )
3. Update OS
4. Install: `yum install quota wget nano curl vim lsof git`
5. Aktifkan quota, edit `/etc/fstab` tambahkan `usrjquota=aquota.user,grpjquota=aquota.group,jqfmt=vfsv1` pada `defaults` bagian /home sehingga hasil akhirnya seperti `... /home ... defaults,usrjquota=aquota.user,grpjquota=aquota.group,jqfmt=vfsv1`
6. Reboot
7. Buat index: `quotacheck -cugm /home`
8. Aktifkan quota: `quotaon -v /home`
9. Cek apa sudah aktif: `quotaon -ap`
10. Install docker: `dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo && dnf install docker-ce docker-ce-cli containerd.io docker-compose-plugin`
11. Aktifkan docker: `systemctl enable docker systemctl start docker`
12. Copy git punya andi: https://github.com/sheratan17/docker-wp
13. Pindahkan semua file di docker-wp ke `/home`
14. Pindahkan semua file di docker-wp/upload ke `/var/www/html`
15. Pastikan ip private sudah aktif, catat ip private nya
16. Sesuaikan ip docker-compose.yml dengan ip private yang aktif
17. Buat `ssh-keygen`
18. `ssh-copy-id` ke server nginx reverse
19. Matikan selinux
20. Add apache ke grup wheel
21. Add apache ke grup docker
22. Edit visudo, allow apache
23. Update php exec time ke 600
24. Update apache directory index tambahkan index.php
25. Tambah ProxyTimeout 600 di httpd.conf

##Setup server nginx reverse
1. Install Almalinux
2. Install nginx
3. Install epel-release
4. Install certbot python3-certbot-nginx
5. download `template.conf.inc` dan `template-mandiri.conf.inc` letakkan di `/etc/nginx/conf.d`
6. Restart nginx


## Pengembangan
1. Script untuk update paket
2. Script untuk update ssl dari le ke mandiri atau sebaliknya
