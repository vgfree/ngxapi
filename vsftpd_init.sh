#!/bin/bash

#安装vsftpd,pam
yum install -y vsftpd libdb-utils
echo "vsftpd安装成功"
sleep 1

#配置vsftpd的服务和开机自启动
systemctl start vsftpd
systemctl enable vsftpd
systemctl is-enabled vsftpd
echo "vsftpd服务配置成功"
sleep 1

#创建FTP服务的存储目录
mkdir -p /var/ftp/
mkdir -p /var/ftp/homeshare
chown -R ftp:ftp /var/ftp
chmod -R 755 /var/ftp
chmod -R 777 /var/ftp/homeshare
ls -l /var/ftp/
echo "完成FTP目录创建和目录权限配置"
sleep 1

#配置虚拟账号系统
cat > /tmp/vuser_passwd.conf << EOF
homeshare
123456
EOF

#将文本文件的帐号及密码编译为db4的数据库文件
mkdir -p /opt/data/etc/vsftpd
db_load -T -t hash -f /tmp/vuser_passwd.conf /opt/data/etc/vsftpd/vuser_passwd.db
echo "虚拟账号创建完成"
sleep 1

#配置vsftpd的pam，在文件中增加auth和account配置
mv -b /etc/pam.d/vsftpd /etc/pam.d/vsftpd.bak
cat > /etc/pam.d/vsftpd << EOF
#%PAM-1.0
auth required /lib64/security/pam_userdb.so db=/opt/data/etc/vsftpd/vuser_passwd
account required /lib64/security/pam_userdb.so db=/opt/data/etc/vsftpd/vuser_passwd
EOF
echo "PAM配置完成"
sleep 1

#创建用于FTP虚拟账号服务的操作系统用户，并禁止该用户登陆操作系统
userdel -rf vsftpd
useradd -g ftp -d /home/vsftpd -s /sbin/nologin vsftpd
echo "FTP服务器的操作系统账号创建完成，账号名为vsftpd"
sleep 1

#对vsftpd的配置文件进行备份
#配置vsftpd的配置文件
mv -b /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf.bak
cat > /etc/vsftpd/vsftpd.conf <<EOF
#不允许匿名访问
anonymous_enable=NO
#设定本地用户可以访问。注意：主要是为虚拟宿主用户，如果该项目设定为NO那么所有虚拟用户将无法访问
local_enable=YES
#允许写操作
write_enable=YES
#创建或上传后文件的权限掩码
local_umask=022
#禁止匿名用户上传
anon_upload_enable=NO
#禁止匿名用户创建目录
anon_mkdir_write_enable=NO
#进入目录时可以显示一些设定的信息，可以通过message_file=.message来设置
dirmessage_enable=YES
#开启日志
xferlog_enable=YES
#主动连接的端口号
connect_from_port_20=YES
#设定禁止上传文件更改宿主
chown_uploads=NO
#日志路径，需要对日志文件授权chown vsftpd.vsftpd /var/log/vsftpd.log
xferlog_file=/var/log/xferlog
#格式化日志
xferlog_std_format=YES
#禁止vsftpd账号登陆，因此写vsftpd或系统内nobody
nopriv_user=vsftpd
#设定支持异步传输功能
async_abor_enable=YES
#设定支持ASCII模式的上传
ascii_upload_enable=YES
#设定支持ASCII模式的上传
ascii_download_enable=YES
#登陆欢迎语
ftpd_banner=Welcome to ownstor FTP service.
#限定用户在个人目录内访问。
chroot_local_user=YES
chroot_list_enable=YES
allow_writeable_chroot=YES
#限定在个人目录内访问的用户信息列表
chroot_list_file=/etc/vsftpd/chroot_list
#以standalone方式启动
listen=YES
#/etc/pam.d/下的vsftpd文件
pam_service_name=vsftpd
#在/etc/vsftpd/user_list中的用户将不能使用FTP
userlist_enable=YES
#启用虚拟用户功能
guest_enable=YES
#虚拟用户权限所对应的宿主用户，宿主用户为linux操作系统用户
guest_username=vsftpd
#虚拟用户的vsftpd配置文件存放路径。
virtual_use_local_privs=YES
#vsftpd_config是目录，里面存放的文件名和虚拟用户名必须完全一致。
user_config_dir=/opt/data/etc/vsftpd/vuser_conf
EOF
echo "创建vsftpd的主配置文件，并完成配置"
sleep 1

#创建chroot_list文件并写入文件内容
rm -rf /etc/vsftpd/chroot_list
touch /etc/vsftpd/chroot_list
echo vsftpd > /etc/vsftpd/chroot_list
echo "禁止FTP账号访问上级目录的配置完成"

#创建虚拟用户的配置文件存放的路经
rm -rf /opt/data/etc/vsftpd/vuser_conf
mkdir -p /opt/data/etc/vsftpd/vuser_conf

#为homeshare用户创建vsftpd的配置文件
cat > /opt/data/etc/vsftpd/vuser_conf/homeshare << EOF
local_root=/var/ftp/homeshare
write_enable=NO
anon_umask=022
anon_world_readable_only=YES
anon_upload_enable=NO
anon_mkdir_write_enable=NO
anon_other_write_enable=NO
EOF
echo "FTP服务账号创建并配置完成，创建共享账号为homeshare"
sleep 1

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

echo "完成SELINX和Firewalld的配置"
sleep 1

#重新启动vsftpd服务
systemctl restart vsftpd
echo "FTP Service is OK"
