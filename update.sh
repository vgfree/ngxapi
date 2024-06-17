cp mariadb-server.cnf /etc/my.cnf.d/mariadb-server.cnf
systemctl restart mariadb
cp vsftpd.conf /etc/vsftpd/vsftpd.conf
echo -e "#%PAM-1.0\n\nauth required pam_userdb.so db=/etc/vsftpd/vusers\naccount required  pam_userdb.so db=/etc/vsftpd/vusers" > /etc/pam.d/vsftpd.vu
systemctl restart vsftpd

#make -C tools/lua_pam
#cp tools/lua_pam/pam_check /usr/bin/

rm -rf /opt/ownstor/ownstor-api
mkdir -p /opt/ownstor/ownstor-api
cp -r cfg.lua /opt/ownstor/ownstor-api/
cp -r open /opt/ownstor/ownstor-api/
cp -r account_manager /opt/ownstor/ownstor-api/

cp nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
make -C /opt/ownstor/ownstor-api/open/lib/
systemctl restart openresty
