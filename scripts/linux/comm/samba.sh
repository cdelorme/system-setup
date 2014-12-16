#!/bin/bash

# install packages
aptitude install -ryq samba samba-tools smbclient

# download samba config
[ -f "data/etc/samba/smb.conf" ] && cp "data/etc/samba/smb.conf" "/etc/samba/smb.conf"  || $dl_cmd "/etc/samba/smb.conf" "${remote_source}data/etc/samba/smb.conf"

# add user
usermod -aG sambashare $username

# add samba user
yes "${password}" | smbpasswd -sa "${username}"

# enable iptables rule but restrict to localhost (feel free to change -s 127.0.0.1 to -s 192.168.0.0/24 or similar)
sed -i "s/#-A INPUT -s 127.0.0.1 -p udp -m multiport --dports 137,138 -j ACCEPT/-A INPUT -s 127.0.0.1 -p udp -m multiport --dports 137,138 -j ACCEPT" /etc/iptables/iptables.rules
sed -i "s/#-A INPUT -s 127.0.0.1 -p tcp -m multiport --dports 139,445 -j ACCEPT/-A INPUT -s 127.0.0.1 -p tcp -m multiport --dports 139,445 -j ACCEPT" /etc/iptables/iptables.rules

# download & install samba monit
[ -f "data/etc/monit/monitrc.d/samba" ] && cp "data/etc/monit/monitrc.d/samba" "/etc/monit/monitrc.d/samba"  || $dl_cmd "/etc/monit/monitrc.d/samba" "${remote_source}data/etc/monit/monitrc.d/samba"
ln -nsf "../monitrc.d/samba" "/etc/monit/conf.d/samba"
monit -t && service monit restart