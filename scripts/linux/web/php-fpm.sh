#!/bin/bash

# verify desire to install
[ "$install_phpfpm" = "y" ] || exit 0

# install php-fpm and all related/useful components
aptitude install -ryq php5 php5-fpm php5-cli php5-mcrypt php5-curl php5-xmlrpc php5-dev php5-intl php5-xsl php-pear php-apc

# set timezone on both fpm & cli
sed -i "s/;date.timezone.*/date.timezone = America\/New_York/" /etc/php5/fpm/php.ini
sed -i "s/;date.timezone.*/date.timezone = America\/New_York/" /etc/php5/cli/php.ini

# fix max upload size
sed -i "s/upload_max_filesize.*/upload_max_filesize = 32M/" /etc/php5/fpm/php.ini

# sed execution group
sed -i "s/group =.*/group = webdev/" /etc/php5/fpm/pool.d/www.conf

# download nginx php-fpm module
[ -f "data/etc/nginx/scripts.d/php-fpm.conf" ] && cp "data/etc/nginx/scripts.d/php-fpm.conf" "/etc/nginx/scripts.d/php-fpm.conf"  || $dl_cmd "/etc/nginx/scripts.d/php-fpm.conf" "${remote_source}data/etc/nginx/scripts.d/php-fpm.conf"

# install native mysql driver package
which mysqld && aptitude install -ryq php5-mysqlnd

# install mongo driver via pecl
if which mongo &>/dev/null
then
    yes "" | pecl install mongo
    echo "extension=mongo.so" > /etc/php5/mods-available/mongodb.ini
    ln -sf ../mods-available/mongodb.ini /etc/php5/conf.d/mongodb.ini
fi

# optionally add graphics processing utilities
if which gm &>/dev/null
then
    aptitude install -ryq php5-gd php5-imagick
    yes "" | pecl install gmagick
    echo "extension=gmagick.so" > /etc/php5/mods-available/gmagick.ini
    ln -sf ../mods-available/gmagick.ini /etc/php5/conf.d/gmagick.ini
fi

# optimizations (these are subject to server resources and tailored for a lightweight 1GB ram server)
sed -i "s/.*pm.max_children =.*/pm.max_children = 25/" /etc/php5/fpm/pool.d/www.conf
sed -i "s/.*pm.start_servers =.*/pm.start_servers = 2/" /etc/php5/fpm/pool.d/www.conf
sed -i "s/.*pm.min_spare_servers =.*/pm.min_spare_servers = 2/" /etc/php5/fpm/pool.d/www.conf
sed -i "s/.*pm.max_spare_servers =.*/pm.max_spare_servers = 5/" /etc/php5/fpm/pool.d/www.conf
sed -i "s/.*pm.max_requests =.*/pm.max_requests = 500/" /etc/php5/fpm/pool.d/www.conf

# restart services /w optimizations & added modules
service php5-fpm restart
nginx -t && service nginx restart

# install composer
$source_cmd https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# confirm public accessibility & modify iptables
if [ "$public_phpfpm" = "y" ]
then
    sed -i "s/#-A INPUT -p tcp -m tcp --dport 9000 -m conntrack --ctstate NEW -j ACCEPT/-A INPUT -p tcp -m tcp --dport 9000 -m conntrack --ctstate NEW -j ACCEPT/" /etc/iptables/iptables.rules
fi

# add monit config & test/restart monit
[ -f "data/etc/monit/monitrc.d/php-fpm" ] && cp "data/etc/monit/monitrc.d/php-fpm" "/etc/monit/monitrc.d/php-fpm"  || $dl_cmd "/etc/monit/monitrc.d/php-fpm" "${remote_source}data/etc/monit/monitrc.d/php-fpm"
ln -nsf "../monitrc.d/php-fpm" "/etc/monit/conf.d/php-fpm"
monit -t && service monit restart