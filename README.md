# docker-wp
Docker + Wordpress + Let's Encrypt + Disk, CPU dan RAM Quota

1. Install Almalinux 8
2. Pastikan `/home` adalah partisi yang berbeda
3. Update OS
4. `yum install quota wget nano curl vim lsof`
4. Aktifkan quota, edit `/etc/fstab` pada bagian home tambahkan `usrjquota=aquota.user,grpjquota=aquota.group,jqfmt=vfsv1` setelah `defaults`
5. Reboot
6. Buat index `quotacheck -cugm /home`
7. Aktifkan quota `quotaon -v /home/`
8. Cek quota `quotaon -ap`
9. Install docker `dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo` `dnf install docker-ce docker-ce-cli containerd.io docker-compose-plugin git`
10. Enable service `systemctl enable docker` `systemctl start docker`
10. Jalankan `.setup.sh` untuk install dan `delete.sh` untuk hapus
11. JANGAN HAPUS FOLDER TEMPLATE

template.inc.conf diletakkan di /etc/nginx/conf.d server proxy