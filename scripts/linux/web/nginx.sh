#!/bin/bash

# testing from-source to build 1.6

# install dependencies
aptitude install -ryq libc6 libpcre3-dev zlib1g-dev

# checkout to /usr/src
if [ ! -d /usr/src/nginx ]
then

    # # download tar method
    # $dl_cmd /usr/src/nginx.tar.gz http://nginx.org/download/nginx-1.6.0.tar.gz
    # mkdir -p /usr/src/nginx && tar -xf /usr/src/nginx.tar.gz -C /usr/src/nginx --strip-components 1

    # # configure, build, and install
    # /usr/src/nginx/configure --prefix=/etc/nginx --sbin-path=/usr --conf-path=/etc/nginx/nginx.conf --with-http_ssl_module
    # (cd /usr/src/nginx && make && make install)

    # alternative involves cloning branch?  I have no idea how their source was intended to function...
    hg clone http://hg.nginx.org/nginx -r stable-1.6 /usr/src/nginx

    /usr/src/nginx/auto/configure --prefix=/etc/nginx --sbin-path=/usr --conf-path=/etc/nginx/nginx.conf --with-http_ssl_module
    (cd /usr/src/nginx && make && make install)
fi


# install nginx
# aptitude install -ryq nginx-full


# configure nginx layout
# rm /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
# mkdir -p /etc/nginx/ssl /etc/nginx/conf.d /etc/nginx/scripts.d

# download nginx configuration files
# [ -f "data/etc/nginx/nginx.conf" ] && cp "data/etc/nginx/nginx.conf" "/etc/nginx/nginx.conf"  || $dl_cmd "/etc/nginx/nginx.conf" "${remote_source}data/etc/nginx/nginx.conf"
# [ -f "data/etc/nginx/sites-available/example.com" ] && cp "data/etc/nginx/sites-available/example.com" "/etc/nginx/sites-available/example.com"  || $dl_cmd "/etc/nginx/sites-available/example.com" "${remote_source}data/etc/nginx/sites-available/example.com"
# [ -f "data/etc/nginx/conf.d/charset.conf" ] && cp "data/etc/nginx/conf.d/charset.conf" "/etc/nginx/conf.d/charset.conf"  || $dl_cmd "/etc/nginx/conf.d/charset.conf" "${remote_source}data/etc/nginx/conf.d/charset.conf"
# [ -f "data/etc/nginx/conf.d/gzip.conf" ] && cp "data/etc/nginx/conf.d/gzip.conf" "/etc/nginx/conf.d/gzip.conf"  || $dl_cmd "/etc/nginx/conf.d/gzip.conf" "${remote_source}data/etc/nginx/conf.d/gzip.conf"
# [ -f "data/etc/nginx/conf.d/servernamehash.conf" ] && cp "data/etc/nginx/conf.d/servernamehash.conf" "/etc/nginx/conf.d/servernamehash.conf"  || $dl_cmd "/etc/nginx/conf.d/servernamehash.conf" "${remote_source}data/etc/nginx/conf.d/servernamehash.conf"
# [ -f "data/etc/nginx/conf.d/uploads.conf" ] && cp "data/etc/nginx/conf.d/uploads.conf" "/etc/nginx/conf.d/uploads.conf"  || $dl_cmd "/etc/nginx/conf.d/uploads.conf" "${remote_source}data/etc/nginx/conf.d/uploads.conf"
# [ -f "data/etc/nginx/scripts.d/cache.conf" ] && cp "data/etc/nginx/scripts.d/cache.conf" "/etc/nginx/scripts.d/cache.conf"  || $dl_cmd "/etc/nginx/scripts.d/cache.conf" "${remote_source}data/etc/nginx/scripts.d/cache.conf"
# [ -f "data/etc/nginx/scripts.d/hidden.conf" ] && cp "data/etc/nginx/scripts.d/hidden.conf" "/etc/nginx/scripts.d/hidden.conf"  || $dl_cmd "/etc/nginx/scripts.d/hidden.conf" "${remote_source}data/etc/nginx/scripts.d/hidden.conf"
# [ -f "data/etc/nginx/scripts.d/favicon.conf" ] && cp "data/etc/nginx/scripts.d/favicon.conf" "/etc/nginx/scripts.d/favicon.conf"  || $dl_cmd "/etc/nginx/scripts.d/favicon.conf" "${remote_source}data/etc/nginx/scripts.d/favicon.conf"

# restart nginx if test is successful
# nginx -t && service nginx restart

# @todo download monit config & test/restart monit
# [ -f "data/etc/monit/monitrc.d/nginx" ] && cp "data/etc/monit/monitrc.d/nginx" "/etc/monit/monitrc.d/nginx"  || $dl_cmd "/etc/monit/monitrc.d/nginx" "${remote_source}data/etc/monit/monitrc.d/nginx"
# ln -nsf "../monitrc.d/nginx" "/etc/monit/conf.d/nginx"
# monit -t && service monit restart