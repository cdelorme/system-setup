#!/bin/bash

# install key, add repository source, then reload
apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db
echo "deb http://nyc2.mirrors.digitalocean.com/mariadb/repo/5.5/debian wheezy main" > /etc/apt/sources.list.d/mariadb.list
echo "deb-src http://nyc2.mirrors.digitalocean.com/mariadb/repo/5.5/debian wheezy main" >> /etc/apt/sources.list.d/mariadb.list
aptitude clean
aptitude update

# unattended installation requires modifications to debconf selections
echo "mariadb-server-5.5 mysql-server/root_password password root" | debconf-set-selections
echo "mariadb-server-5.5 mysql-server/root_password_again password root" | debconf-set-selections

# install mariadb
aptitude install -ryq mariadb-server

# reset root password
mysql -uroot -proot -e "SET PASSWORD = PASSWORD('');"

# reproduce `mysql_secure_installation` operations w/o interactive prompt
mysql -u root -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
mysql -u root -e "DELETE FROM mysql.user WHERE User='';"
mysql -u root -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';"
mysql -u root -e "FLUSH PRIVILEGES;"

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