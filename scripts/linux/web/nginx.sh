#!/bin/bash

# set dependent variables for stand-alone execution
[ -z "$dl_cmd" ] && dl_cmd="wget --no-check-certificate -O"
[ -z "$remote_source" ] && remote_source="https://raw.githubusercontent.com/cdelorme/system-setup/master/"

# install nginx
aptitude install -ryq nginx-full

# configure nginx folder layout
rm /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
mkdir -p /etc/nginx/ssl /etc/nginx/conf.d /etc/nginx/scripts.d

# download nginx configuration files
[ -f "data/etc/nginx/nginx.conf" ] && cp "data/etc/nginx/nginx.conf" "/etc/nginx/nginx.conf"  || $dl_cmd "/etc/nginx/nginx.conf" "${remote_source}data/etc/nginx/nginx.conf"
[ -f "data/etc/nginx/sites-available/example.com" ] && cp "data/etc/nginx/sites-available/example.com" "/etc/nginx/sites-available/example.com"  || $dl_cmd "/etc/nginx/sites-available/example.com" "${remote_source}data/etc/nginx/sites-available/example.com"
[ -f "data/etc/nginx/conf.d/charset.conf" ] && cp "data/etc/nginx/conf.d/charset.conf" "/etc/nginx/conf.d/charset.conf"  || $dl_cmd "/etc/nginx/conf.d/charset.conf" "${remote_source}data/etc/nginx/conf.d/charset.conf"
[ -f "data/etc/nginx/conf.d/gzip.conf" ] && cp "data/etc/nginx/conf.d/gzip.conf" "/etc/nginx/conf.d/gzip.conf"  || $dl_cmd "/etc/nginx/conf.d/gzip.conf" "${remote_source}data/etc/nginx/conf.d/gzip.conf"
[ -f "data/etc/nginx/conf.d/servernamehash.conf" ] && cp "data/etc/nginx/conf.d/servernamehash.conf" "/etc/nginx/conf.d/servernamehash.conf"  || $dl_cmd "/etc/nginx/conf.d/servernamehash.conf" "${remote_source}data/etc/nginx/conf.d/servernamehash.conf"
[ -f "data/etc/nginx/conf.d/uploads.conf" ] && cp "data/etc/nginx/conf.d/uploads.conf" "/etc/nginx/conf.d/uploads.conf"  || $dl_cmd "/etc/nginx/conf.d/uploads.conf" "${remote_source}data/etc/nginx/conf.d/uploads.conf"
[ -f "data/etc/nginx/scripts.d/cache.conf" ] && cp "data/etc/nginx/scripts.d/cache.conf" "/etc/nginx/scripts.d/cache.conf"  || $dl_cmd "/etc/nginx/scripts.d/cache.conf" "${remote_source}data/etc/nginx/scripts.d/cache.conf"
[ -f "data/etc/nginx/scripts.d/hidden.conf" ] && cp "data/etc/nginx/scripts.d/hidden.conf" "/etc/nginx/scripts.d/hidden.conf"  || $dl_cmd "/etc/nginx/scripts.d/hidden.conf" "${remote_source}data/etc/nginx/scripts.d/hidden.conf"
[ -f "data/etc/nginx/scripts.d/favicon.conf" ] && cp "data/etc/nginx/scripts.d/favicon.conf" "/etc/nginx/scripts.d/favicon.conf"  || $dl_cmd "/etc/nginx/scripts.d/favicon.conf" "${remote_source}data/etc/nginx/scripts.d/favicon.conf"

# restart nginx if test is successful
nginx -t && service nginx restart

# download monit config & test/restart monit
[ -f "data/etc/monit/monitrc.d/nginx" ] && cp "data/etc/monit/monitrc.d/nginx" "/etc/monit/monitrc.d/nginx"  || $dl_cmd "/etc/monit/monitrc.d/nginx" "${remote_source}data/etc/monit/monitrc.d/nginx"
ln -nsf "../monitrc.d/nginx" "/etc/monit/conf.d/nginx"
monit -t && service monit restart