rm -rf /opt/ownstor/ownstor-api
mkdir -p /opt/ownstor/ownstor-api
cp -r server_cfg.lua /opt/ownstor/ownstor-api/cfg.lua
cp -r open /opt/ownstor/ownstor-api/
cp -r manage_center /opt/ownstor/ownstor-api/

cp server_nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
make -C /opt/ownstor/ownstor-api/open/lib/
systemctl restart openresty
