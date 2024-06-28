
#mkdir -p /nfs

#安全性配置：SELinux Firewalld
systemctl is-enabled firewalld
firewall-cmd --permanent --zone=public --add-service=ftp
firewall-cmd --reload
echo "防火墙策略为："
firewall-cmd --zone=public --list-all
sleep 1

echo "SELINUX的运行状态为："
sestatus
setsebool -P ftpd_anon_write off
setsebool -P ftpd_full_access on
echo "SELINUX关于ftp的布尔值为："
getsebool -a | grep ftp
sleep 1

setsebool -P samba_enable_home_dirs on
setsebool -P samba_export_all_rw on
semodule -i smb_link_policy.pp
echo "完成SELINX和Firewalld的配置"
sleep 1



systemctl restart mariadb
systemctl restart vsftpd
systemctl restart smb
systemctl restart openresty
