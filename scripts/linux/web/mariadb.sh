#!/bin/bash

# verify desire to install
[ "$install_mariadb" = "y" ] || exit 0

# install key, add repository source, then reload
apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db
echo "deb http://ftp.utexas.edu/mariadb/repo/5.5/debian wheezy main" > /etc/apt/sources.list.d/mariadb.list
echo "deb-src http://ftp.utexas.edu/mariadb/repo/5.5/debian wheezy main" >> /etc/apt/sources.list.d/mariadb.list
aptitude clean
aptitude update

# install mariadb
aptitude install -ryq mariadb-server

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