cp mariadb-server.cnf /etc/my.cnf.d/mariadb-server.cnf
systemctl restart mariadb

#sh vsftpd_init.sh
mkdir -p /nfs

#make -C tools/lua_pam
#cp tools/lua_pam/pam_check /usr/bin/

rm -rf /opt/ownstor/ownstor-api
mkdir -p /opt/ownstor/ownstor-api
cp -r client_cfg.lua /opt/ownstor/ownstor-api/cfg.lua
cp -r open /opt/ownstor/ownstor-api/
cp -r account_manager /opt/ownstor/ownstor-api/
cp -r storage_manager /opt/ownstor/ownstor-api/

cp client_nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
make -C /opt/ownstor/ownstor-api/open/lib/
systemctl restart openresty

#sh samba_init.sh
cp smb.conf /etc/samba/smb.conf
mkdir -p /opt/data/etc/samba

systemctl restart smb
systemctl restart nmb
