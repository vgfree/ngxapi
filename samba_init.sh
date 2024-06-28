#!/bin/bash

mkdir -p /opt/data/var/lib/samba/private/
ln -s /opt/data/var/lib/samba /var/lib/samba
dnf install samba

setsebool -P samba_enable_home_dirs on
setsebool -P samba_export_all_rw on

setenforce 0
systemctl start smb
ausearch -m avc -ts recent | audit2allow -M smb_link_policy
semodule -r smb_link_policy
semodule -i smb_link_policy.pp
setenforce 1

systemctl restart smb

setenforce 0
systemctl start nmb
ausearch -m avc -ts recent | audit2allow -M nmb_link_policy
semodule -r nmb_link_policy
semodule -i nmb_link_policy.pp
setenforce 1

systemctl restart nmb
