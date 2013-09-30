
# Web Server
#### Updated 9-29-2013

This is the complete and detailed configuration process we use in a live production server, plus or minus a few activities.

If you follow all of these steps you will have a supercharged, service filled, rock-solid web server capable of doing anything from development to production.


---

**Setup Development Area:**

Run these commands to prepare a structured development corner, and be sure to add all users to the newly created group:

    groupadd developers
    usermod -aG developers cdelorme
    cd /srv
    mkdir git
    mkdir www
    chgrp -R dev ./
    chmod -R 755 ./


**Add DotDeb:**

Add to `/etc/apt/sources.list`:

    deb http://packages.dotdeb.org wheezy all
    deb-src http://packages.dotdeb.org wheezy all

Execute to add key:

    wget http://www.dotdeb.org/dotdeb.gpg
    cat dotdeb.gpg | sudo apt-key add -
    rm dotdeb.gpg

Clean & Update Aptitutde:

    sudo aptitude clean && sudo aptitude update


**Installing NGinx:**

Starting with the package manager:

    aptitude install nginx-full

Next let's configure it:

    cd /etc/nginx
    rm sites-enables/default

Create `favicon_conf` with:

    # favicon 404 fix
    location /favicon.ico {
        access_log off;
        log_not_found off;
    }

Create `php_conf` with:

    # PHP Handler
    location ~ \.php$ {
        try_files $uri =404;
        include fastcgi_params;
        #fastcgi_pass 127.0.0.1:9000
        fastcgi_pass unix:/var/run/php5-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }

Create a basic configuration easily identified by domain name in `/etc/nginx/sites-available/www.domain.dev` with contents like this:

    # HTTP Config
    server {

        listen 80 default;

        server_name domain.dev www.domain.dev;
        access_log /srv/www/domain.dev/logs/access.log;
        error_log /srv/www/domain.dev/logs/error.log;

        root /srv/www/domain.dev/public_html;
        index index.html index.php;
        rewrite on;

        # favicon error prevention
        include /etc/nginx/favicon_conf;

        # PHP Handler
        include /etc/nginx/php_conf;

    }

Next we want to add a symlink to `/etc/nginx/sites-enabled`, as this structure allows us to remove a site without deleting its configuration:

    sudo ln -s /etc/nginx-sites-available/www.domain.dev /etc/nginx/sites-enabled/www.domain.dev

We can now test our configurations validity by running `sudo nginx -t`.  If everything checks out you can restart nginx with `sudo service nginx restart`, and then using the IP Address you should get your above site (if listen is default), otherwise adding the domain to the client machines hosts file will let you access your new development site.


**(Optional) NGinx Optimizations:**

Secure NGinx by adding to its configuration (`/etc/nginx/nginx.conf`) inside the http brackets `charset utf-8;` for all content to and from.  This will set the HTTP header automatically, and convert incoming content automatically as well.

Optimize NGinx by adding `expires max;` as a default for all content to be cached.  Explicitly asking content to not be cached when necessary is much more efficient, and php sessions automatically adjust the headers solving most problems.

Optimize NGinx gzip configuration by creating a `gzip.conf` with:

    # Compress all Proxied requests too
    gzip_proxied any;

    # Comprehensive Mime-Type List
    gzip_types
        text/css
        text/plain
        text/javascript
        application/javascript
        application/json
        application/x-javascript
        application/xml
        application/xml+rss
        application/xhtml+xml
        application/x-font-ttf
        application/x-font-opentype
        application/vnd.ms-fontobject
        image/svg+xml
        image/x-icon
        application/rss+xml
        application/atom_xml;

    # Maximum Compression Level (Cost of CPU for Bandwidth)
    gzip_comp_level 9;

    # Compress HTML 1.0 too not just 1.1:
    gzip_http_version 1.0;

    # Non-IE6 Compatible Proxy Accept-Encoding header:
    gzip_vary on;

    # Larger Buffer Size
    gzip_buffers 16 16k;

    # Increase minimum length for gzip to avoid wasting compression cycles:
    gzip_min_length 50;

Create a `static_files` section:

    location ~* \.(ico|css|js|gif|jpe?g|png)$ {
        expires max;
        add_header Pragma public;
        add_header Cache-Control "public, must-revalidate, proxy-revalidate";
    }

Load all configurations using a wildcards argument:

Consider wildcard includes to a common dir inside nginx.

    include /etc/nginx/common/*.conf;


NGinx file uploads are limited to 1m by default, despite what php is set to, if you expect people to be uploading files you will want to set an nginx limit:

Create an `uploads.conf` with:

    client_max_body_size 32m;


**(Optional) NGinx SSL Transmission & Buffered Response Data:**

NGinx FastCGI buffers can more efficiently handle larger sets of data transmitted instead of writing them to disk.  These transmissions are often a problem when supplying highly encrypted content, such as 4096 bit ssl certificates, in which case a larger buffer size is required.

To solve this you can add the following line to either `/etc/nginx/fastcgi_params` or on a per-server configuration basis:

    fastcgi_buffers 12 32k;

This will create 8 buffers of 32k in size, for a grand total of (32 + 12 * 32) 416k.  Anything larger than that amount will be pushed to the disk while preparing a response.

Buffers are prepared per-request, and buffers significantly larger than the response content will just consume extra memory needlessly.  It would be ideal to test your response sizes and make sure you need a larger buffer before adding such a modification.  However, if you have memory to spare, this is a good fail-safe for ssl transmission.


**Installing PHP-FPM:**

In my case I want the whole package, but you can obviously pick and choose desirable components at your leisure:

    aptitude install -y php5-fpm php5-cli php5-mcrypt php5-gd php5-mysqlnd php5-curl php5-xmlrpc php5-dev php-pear php-apc

_DotDeb's version of php5-fpm finally has a working socket, which means it will be faster, more secure, and no more modification is required!_

We will also want to modify `/etc/php5/fpm/php.ini` to set your [timezone](http://php.net/manual/en/timezones.php):

    date.timezone = America/New_York

Add a phpinfo page to your test site, and add the php_conf to your nginx site configuration, reboot nginx and verify it all works.


**(Optional) Install Composer:**

Execute these commands to install Composer globally:

    wget --no-check-certificate https://getcomposer.org/installer
    php installer
    rm installer
    sudo mv composer.phar /usr/local/bin/composer


**(Optional) PHP-FPM Optimizations:**

You can optimize PHP5-FPM according to your anticipated workload and available resources.  Here is an example of changes that can be made to `/etc/php5/fpm/pool.d/www.conf`:

    pm.max_children = 25
    pm.start_servers = 4
    pm.min_spare_servers = 2
    pm.max_spare_servers = 10
    pm.max_requests = 500


**(Optional) Development Error Output:**

By default PHP5-FPM is configured to silence error output for production, but if you are running a development server and wish to see these errors from the browser to debug and correct them you will need to modify a line in `/etc/php5/fpm/php.ini`:

    display_errors = On


**(Optional) PHP File Uploads:**

By default PHP allows 2 Megabytes at most, which is tiny by todays standards, so let's increase it:

    upload_max_filesize = 32M

Remember, you can enforce upload sizes in other ways, this simply makes it require less tweaking in the service itself.


**MariaDB 10.0:**

Add MariaDB Package Source:

    sudo aptitude install python-software-properties
    sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db

Add to `/etc/apt/sources.list`:

    # http://mariadb.org/mariadb/repositories/
    deb http://ftp.osuosl.org/pub/mariadb/repo/10.0/debian wheezy main
    deb-src http://ftp.osuosl.org/pub/mariadb/repo/10.0/debian wheezy main

Now clean & update our sources:

    sudo aptitude clean
    sudo aptitude update

Finally, install mariadb-server:

    sudo aptitude install mariadb-server

You should be all set, feel free to try accessing or creating a PDO connection script from PHP.


**Installing MongoDB (NoSQL):**

This can be done via the package manager:

    sudo aptitude install mongodb

The following packages will add support for PHP (requires php-pear for pecl):

    sudo pecl install mongo

Now we have to make sure it loads inside php5-fpm by adding a line at the bottom of `/etc/php5/fpm/php.ini`:

    extension=mongo.so

Reboot php5-fpm and all will be good:

    sudo service php5-fpm restart


**Installing Node:**

Download, Build and Install it off their site:

    wget http://nodejs.org/dist/node-latest.tar.gz
    tar xf node-latest.tar.gz
    rm node-latest.tar.gz
    cd node-v*
    ./configure && make && make install

Obviously if you want to keep the source and folder for later you can do so by moving it to the /usr/local/src folder and running the install from there.

Alternatively you can use checkinstall in place of make and make install, but you'll have to install that package first.

Node modules can be added on a per project basis using the node package manager `npm`.  For example, this will add mysql or mariadb support, and mongodb support to your project:

    sudo npm install mysql mongodb


**Secured phpMyAdmin:**

Create a new host file in sites-available with these contents:

    # PHP My Admin SSH Forwarded Service
    server {

        listen ####;
        server_name localhost 127.0.0.1;
        root /srv/www/pma;
        index index.php;

        # Access Rights
        allow 127.0.0.1;
        deny all;

        # PHP Handler
        include /etc/nginx/php_conf;

    }

This will limit all access to phpMyAdmin to localhost only, allowing you to use ssh port forwarding to access it securely:

    ssh -f -N username@domain.com -L ####:localhost:####


**Mail Server Configuration:**

There are two options entirely different dependent on your situation.

A production environment should ideally setup Exim4, and you can find instructions on [Linode's Library](https://library.linode.com/email/exim/send-only-mta-ubuntu-12.04-precise-pangolin).

For a personal development server you may wish to use something less robust for outgoing mail only, in which case I recommend msmtp.


**(Optional) MSMTP for Development SendMail Only Server:**

Install the package:

    aptitude install msmtp-mta

Now we want to create a file at `/etc/msmtprc`, and add configuration data similar to:

    # Set default values for all following accounts.
    defaults
    tls on
    tls_trust_file /etc/ssl/certs/ca-certificates.crt

    # Default Account
    account gmail
    host smtp.gmail.com
    port 587
    auth on
    user username
    password password
    from username@gmail.com

    # Set a default account
    account default : gmail

Since this file will carry a raw password you will want to secure it by adjusting permissions:

    sudo chmod 0600 /etc/msmtprc

Note that you can create multiple accounts and are not limited to just one, this allows you to change sender data accordingly.

By default installing msmtp will add a symlink to `/usr/sbin/sendmail` for the local mail protocol, meaning you should not need to change anything else.  However, you can also symlink `/usr/sbin/msmtp` to `/usr/bin/msmtp` if you want to be able to access it on normal user accounts.


**Python & pip:**

Python 2.7.3 comes by default with Debian Wheezy.  Simply execute this command to add pip to the system:

    sudo aptitude install python-pip


**Secure with IPTables:**

We add these new rules to the IPTables outlined in the debian template:

    # Allow tcp traffic for  (HTTP, HTTPS)
    -A INPUT -p tcp -m multiport --dports 80,443 -m conntrack --ctstate NEW -j ACCEPT

    # DNS - outgoing
    -A INPUT -p udp -i eth0 --sport 53 -j ACCEPT


Assuming the firewall configuration is located at `/etc/firewall.conf` create a script at `/etc/network/if-up.d/iptables` with the following lines:

    #!/bin/sh
    iptables -F
    iptables-restore < /etc/firewall.conf

_Despite several guides claiming the use of `if-pre-up.d` as the correct directory, I have only had success using `if-up.d`._

Be sure to set the executable flag on `/etc/network/if-up.d/iptables`.

Reboot, and check that it works with:

    iptables -L

Obviously the services you choose to make accessible are up to you, and you do not need to log denied access, but it would be wise to consider, and the less open services the more secure your platform will be.


**Server Website Logs:**

Create a new file in `/etc/logrotate.d/` with these contents:

    /srv/www/*/logs/*.log {
       daily
       missingok
       rotate 3
       compress
       delaycompress
       notifempty
       sharedscripts
       prerotate
          if [ -d /etc/logrotate.d/httpd-prerotate ]; then \
          run-parts /etc/logrotate.d/httpd-prerotate; \
       fi; \
       endscript
       postrotate
       [ ! -f /var/run/nginx.pid ] || kill -USR1 `cat /var/run/nginx.pid`
       endscript
    }

This will ensure that our log files inside the /srv/www development area will be rotated instead of filling up.


**Installing Monit:**

Install the monit package:

    aptitude install monit

This tool will give you a web interface with which you can monitor basic information such as up-time, CPU Usage, Memory Usage and more.  The web interface may only be helpful if you are running a development server, as most hosting services will provide an external monitoring service.

However, the real benefit of monit lies in its flexibility.  It allows you to not only watch the system status, but also individual services.  This allows you to automate restarting services that may crash, such as node.js programs, php, nginx, ssh, and more.

The format for the configurations is extremely human, and you should read through the [documentation](http://mmonit.com/monit/documentation/) at their website for more examples.  Here I will provide three basic examples we use in our production system (located in `/etc/monit/conf.d/`):

NGinx Monitor:

    check process nginx with pidfile /var/run/nginx.pid
        start program = "/etc/init.d/nginx start"
        stop program  = "/etc/init.d/nginx stop"
        group www-data

PHP Monitor:

    check process php5-fpm with pidfile /var/run/php5-fpm.pid
        start program = "/etc/init.d/php5-fpm start"
        stop program = "/etc/init.d/php5-fpm stop"
        group www-data

SSH Monitor:

    check process sshd with pidfile /var/run/sshd.pid
        start program = "/etc/init.d/ssh start"
        stop program  = "/etc/init.d/ssh stop"
        if cpu > 80% for 5 cycles then restart
        if totalmem > 200.00 MB for 5 cycles then restart
        if 3 restarts within 8 cycles then timeout

System Monitor:

    check system localhost
        if loadavg (1min) > 10 then alert
        if loadavg (5min) > 8 then alert
        if memory usage > 80% then alert
        if cpu usage (user) > 70% for 2 cycles then alert
        if cpu usage (system) > 50% for 2 cycles then alert
        if cpu usage (wait) > 50% for 2 cycles then alert
        if loadavg (1min) > 20 for 3 cycles then exec "/sbin/reboot"
        if loadavg (5min) > 15 for 5 cycles then exec "/sbin/reboot"
        if memory usage > 97% for 3 cycles then exec "/sbin/reboot"

The last one is for the system as a whole, if some service is running wild eating resources or killing our CPU we will receive a notification and in the worst case the system will restart.

Finally, we can configure and secure the web accessible front-end by creating another configuration file:

    # Establish Web Server on a custom port and restrict access to localhost
    set httpd port ####
        allow 127.0.0.1

This will only listen to localhost and is obfuscated by a self-defined listening port.  As with the phpMyAdmin instructions you can gain access using SSH Forwarding:

    ssh -f -N username@domain.com -L ####:localhost:####

If you receive errors with monit from `insserv` you may wish to remove the LSB Comment line with `# Should-Stop:       $all`, as this line is invalid.


**Installing Bind DNS:**

For development environments on a local network where more than one person may be connecting it can help to add a DNS Server to your Web Server.  This allows you to distribute the addresses to projects across the local network.

Let's begin by installing the our DNS Server;

    sudo aptitude install bind9

We can start the process by defining a zone and reverse lookup, I won't go into detail explaining these as that is not the goal of this guide, if you have questions Google is your friend.

Add content to the `/etc/bind/named.conf.local` similar to the following:

    // Primary Domain Zones File
    zone "domain.dev" {
            type master;
            file "/etc/bind/zones/domain.dev.db";
    };

    // Reverse Network Zones File
    zone "0.0.10.in-addr.arpa" {
            type master;
            file "/etc/bind/zones/0.0.10.rev";
    };

_Note: generally a DNS has a static IP, and the reverse lookup is used for the local network.  In the case above the 0.0.10 is the reverse of a Class A private network (10.0.0.0).  In many cases you will instead see `0.168.192`, a Class C network address._

Next we need to define the zone files.  Let's start with the forward lookup file named according to our domain (`/etc/bind/zones/domain.dev.db`):

    $TTL    3600
    @       IN      SOA     domain.dev. root.domain.dev. (
                   2013051310           ; Serial
                         3600           ; Refresh [1h]
                          600           ; Retry   [10m]
                        86400           ; Expire  [1d]
                          600 )         ; Negative Cache TTL [1h]

    ;; Name Server
                               NS       domain.dev.

    ;; CNAME Records
    www.domain.dev.    IN    CNAME    domain.dev.
    *.domain.dev.      IN    CNAME    domain.dev.

    ;; A Records (IPv4 addresses)
    domain.dev.        IN    A        10.0.0.5

I won't go into detail here, just know that it works, just a few caveats.  First, the Serial format is often preferred as a date plus a 2 digit counter so you can make many changes in one day.  The Serial must increase every time you make a change and reload Bind, otherwise it will fail to take the changes.

The first two records are the zone (primary address), and owner of the domain (root aka root@domain.dev).  It is generally best practice to include the calculated values in comments for the reader, for Expiration, Refresh, Retry, and Cache times etc...  This particular configuration is tailored for development systems and has very short durations for all settings.

Then like any other DNS configuration we have an @, marking the DNS server, followed by a mixture of A records and CNAME records, where A records hold an IP address and CNAME records are linked to the A records.

Finally, we want to add a reverse lookup, which is effectively all the addresses that the IP can resolve to:

    $TTL 3600
    @ IN SOA        example.dev. root.example.dev. (
                       2013010132           ; Serial
                             3600           ; Refresh [1h]
                              600           ; Retry   [10m]
                            86400           ; Expire  [1d]
                              600 )         ; Negative Cache TTL [1h]
    ;
    @       IN      NS      example.dev.
    5       IN      PTR     www.example.dev.

If you want to add more, entirely different, domains you can do so by simply creating more zones and configurations to match.  Generally it is easier to work off a single zones file with sub-domains; a common practice.

I will end configuring Bind with a [recommended reference](http://brian.serveblog.net/2011/07/31/how-to-setup-a-dns-server-on-debian/), which does far better than I can explaining all the details.

Now that you have another service to worry about, it may be wise to add it to monit (`/etc/monit/conf.d/bind9`):

    check process named with pidfile /var/run/named/named.pid
        start program = "/etc/init.d/bind9 start"
        stop program = "/etc/init.d/bind9 stop"

If you have iptables active as well you will want to add an exception for TCP & UDP traffic on port 53, either before or after the ssh port:

    #Enable Bind DNS (TCP & UDP Port 53)
    -A INPUT -p tcp --dport 53 -j ACCEPT
    -A INPUT -p udp --dport 53 -j ACCEPT

Now, if you restart the bind service (`sudo service bind9 restart`) your system should now be broadcasting.  However, this alone means nothing unless someone knows to listen.

There are two ways you can put a development DNS to use.  First is by asking others to add the Development systems IP to their DNS statically.  Second is if you an control the local networks router, you can add the DNS servers it distributes via DHCP.  Just remember that _if_ you go with a Router solution any machines that have a static IP must have the DNS set manually.  Remember that order matters, listing your local development DNS first can improve response time and if you are overriding external domains it will be required first.

