dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
dnf install https://dl.fedoraproject.org/pub/epel/epel-next-release-latest-9.noarch.rpm
dnf install https://mirrors.aliyun.com/rpmfusion/free/el/rpmfusion-free-release-9.noarch.rpm
wget https://openresty.org/package/centos/openresty2.repo -O /etc/yum.repos.d/openresty.repo
dnf repolist --all
dnf config-manager --set-enabled crb
dnf install vim
cat > ~/.vimrc << EOF
set termencoding=utf-8
set fileformats=unix
EOF
dnf install make
dnf install gcc
dnf install autoconf automake libtool
dnf install pacman
dnf install fakeroot
dnf install lua-basexx luajit-devel
dnf install shadow util-linux
dnf install openssl
dnf install pcp-system-tools net-tools
dnf install libuuid-devel
dnf install libdb-utils

dnf install openresty openresty-opm
opm get SkyLothar/lua-resty-jwt
opm get fffonion/lua-resty-openssl

dnf install mariadb-server
dnf install mariadb-devel
#mysql_secure_installation
systemctl start mariadb

dnf install vsftpd
systemctl start vsftpd

mkdir -p /opt/data/var/lib/samba/private/
ln -s /opt/data/var/lib/samba /var/lib/samba
dnf install samba
systemctl start smb
systemctl start nmb
