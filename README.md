# docker-wp
docker-wp
Docker + Wordpress + Let's Encrypt

1. Install Almalinux 8
2. Pastikan `/home` adalah partisi yang berbeda
3. Update OS
4. `yum install quota wget nano curl vim lsof`
4. Aktifkan quota, edit `/etc/fstab` pada bagian home tambahkan `',usrquota,grpquota'` setelah `defaults`
5. Reboot
6. Aktifkan quota `quotaon -u /home/` dan `quotaon -g /home/`
7. Cek quota `quotaon -ap`
8. Jalankan `/home/setup.sh` untuk install dan `delete.sh` untuk hapus
9. JANGAN HAPUS FOLDER TEMPLATE
