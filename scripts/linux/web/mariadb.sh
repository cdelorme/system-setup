#!/bin/bash

# install key, add repository source, then reload
apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db
echo "deb http://nyc2.mirrors.digitalocean.com/mariadb/repo/5.5/debian wheezy main" > /etc/apt/sources.list.d/mariadb.list
echo "deb-src http://nyc2.mirrors.digitalocean.com/mariadb/repo/5.5/debian wheezy main" >> /etc/apt/sources.list.d/mariadb.list
aptitude clean
aptitude update

# to resolve dotdeb conflicts
echo "Package: libmysqlclient18" > /etc/apt/preferences.d/mariadb
echo "Pin: origin nyc2.mirrors.digitalocean.com" >> /etc/apt/preferences.d/mariadb
echo "Pin-Priority: 900" >> /etc/apt/preferences.d/mariadb

# unattended installation requires modifications to debconf selections for automated password entry
echo 'mariadb-server-5.5 mysql-server/root_password password ""' | debconf-set-selections
echo 'mariadb-server-5.5 mysql-server/root_password_again password ""' | debconf-set-selections

# my beliefs on database access:
#  root access should never be allowed remote
#  passwords should be mandatory for external access

# install mariadb
aptitude install -ryq mariadb-server

# reproduce `mysql_secure_installation` operations w/o interactive prompt
# temporarily disabled (this disabled root access on localhost...)
# mysql -u root -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
# mysql -u root -e "DELETE FROM mysql.user WHERE User='';"
# mysql -u root -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';"
# mysql -u root -e "FLUSH PRIVILEGES;"

# configure mariadb (I don't have any optimizations to apply here)

# confirm public accessibility & modify iptables
if [ "$public_mariadb" = "y" ]
then
    sed -i "s/#-A INPUT -p tcp -m tcp --dport 3306 -m conntrack --ctstate NEW -j ACCEPT/-A INPUT -p tcp -m tcp --dport 3306 -m conntrack --ctstate NEW -j ACCEPT/" /etc/iptables/iptables.rules
fi

# add monit config & test/restart monit
[ -f "data/etc/monit/monitrc.d/mysqld" ] && cp "data/etc/monit/monitrc.d/mysqld" "/etc/monit/monitrc.d/mysqld"  || $dl_cmd "/etc/monit/monitrc.d/mysqld" "${remote_source}data/etc/monit/monitrc.d/mysqld"
ln -nsf "../monitrc.d/mysqld" "/etc/monit/conf.d/mysqld"
monit -t && service monit restart