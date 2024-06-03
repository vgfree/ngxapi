cp mariadb-server.cnf /etc/my.cnf.d/mariadb-server.cnf
service mariadb restart

make -C tools/lua_pam
cp tools/lua_pam/pam_check /usr/bin/

rm -rf /opt/ownstor/ownstor-api
mkdir -p /opt/ownstor/ownstor-api
cp -r cfg.lua /opt/ownstor/ownstor-api/
cp -r open /opt/ownstor/ownstor-api/
cp -r account_manager /opt/ownstor/ownstor-api/

cp nginx.conf /etc/nginx/nginx.conf
/usr/sbin/nginx -s reload
