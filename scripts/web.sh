#!/bin/bash

# load template
[ -f "scripts/template.sh" ] && . "scripts/template.sh" || . <($source_cmd "${remote_source}scripts/template.sh")

##
# web-specific operations
##

# conditionally install processing services
if [ "$install_processing_tools" = "y" ]
then
    aptitude install -ryq graphicsmagick imagemagick libgd-tools ffmpeg lame libvorbis-dev libogg-dev
fi

# add new groups, and to user
groupadd -f www-data
groupadd -f gitdev
groupadd -f webdev
usermod -aG webdev,gitdev $username

# create environment folders & set permissions /w sticky bits
mkdir -p /srv/{www,git}
chown -R www-data:www-data /srv
chown -R www-data:webdev /srv/www
chown -R www-data:gitdev /srv/git
chmod -R 6775 /srv

# download logrotate for websites
[ -f "data/etc/logrotate.d/websites" ] && cp "data/etc/logrotate.d/websites" "/etc/logrotate.d/websites"  || $dl_cmd "/etc/logrotate.d/websites" "${remote_source}data/etc/logrotate.d/websites"

# adjust iptables for http/https traffic
sed -i 's/#-A INPUT -p tcp -m multiport --dports 80,443 -m conntrack --ctstate NEW -j ACCEPT/-A INPUT -p tcp -m multiport --dports 80,443 -m conntrack --ctstate NEW -j ACCEPT/' /etc/iptables/iptables.rules


##
# modular scripts
##

# load dotdeb repository (disabled due to conflicts)
#[ -f "scripts/linux/web/dotdeb.sh" ] && . "scripts/linux/web/dotdeb.sh" || . <($source_cmd "${remote_source}scripts/linux/web/dotdeb.sh")

# include nginx script
[ -f "scripts/linux/web/nginx.sh" ] && . "scripts/linux/web/nginx.sh" || . <($source_cmd "${remote_source}scripts/linux/web/nginx.sh")

# include databases (mongodb & mariabd)
[[ "$install_mongodb" = "y" && -f "scripts/linux/web/mongodb.sh" ]] && . "scripts/linux/web/mongodb.sh" || . <($source_cmd "${remote_source}scripts/linux/web/mongodb.sh")
[[ "$install_mariadb" = "y" && -f "scripts/linux/web/mariadb.sh" ]] && . "scripts/linux/web/mariadb.sh" || . <($source_cmd "${remote_source}scripts/linux/web/mariadb.sh")

# install php
[[ "$install_phpfpm" = "y" && -f "scripts/linux/web/php-fpm.sh" ]] && . "scripts/linux/web/php-fpm.sh" || . <($source_cmd "${remote_source}scripts/linux/web/php-fpm.sh")

# msmtp mail server
[[ "$install_msmtp" = "y" && -f "scripts/linux/web/msmtp.sh" ]] && . "scripts/linux/web/msmtp.sh" || . <($source_cmd "${remote_source}scripts/linux/web/msmtp.sh")