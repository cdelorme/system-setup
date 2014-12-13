#!/bin/bash

# install packages
aptitude install -ryq samba samba-tools smbclient

# download samba config
[ -f "data/etc/samba/smb.conf" ] && cp "data/etc/samba/smb.conf" "/etc/samba/smb.conf"  || $dl_cmd "/etc/samba/smb.conf" "${remote_source}data/etc/samba/smb.conf"

# add user
usermod -aG sambashare $username

# download & install samba monit
[ -f "data/etc/monit/monitrc.d/samba" ] && cp "data/etc/monit/monitrc.d/samba" "/etc/monit/monitrc.d/samba"  || $dl_cmd "/etc/monit/monitrc.d/samba" "${remote_source}data/etc/monit/monitrc.d/samba"
ln -nsf "../monitrc.d/samba" "/etc/monit/conf.d/samba"