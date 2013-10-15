
# Web Server Template Documentation
#### Updated 10-13-2013

This template extends my Debian template configuration process, and is intended for use as a development web and DNS server.  Ideally one that could easily be cloned into production with a few minor security enhancements.

This document covers the following services extensively:

- nginx
- php-fpm
- mariadb
- monit
- nodejs
- sphinx
- bind9 (dns)

Other services may be involved as well, but these are the focus of this template.

We use nginx as the proxy for most of the services extending from this machine.

We can run php-fpm and nodejs behind nginx for web development or internal web services.

_The use of mariadb is as an optional drop-in replacement for MySQL, and is by no means a requirement, but currently seems to be the better choice given MySQL has been acquired by Oracle and has been stagnating since as it competes with their enterprise product._

We add more configurations to monit so it can check on our web server services, in addition to being an ideal approach to launching nodejs applications.

Sphinx indexer is a great tool to enhance search engines in our various web services, and is probably the fastest solution to this.

Finally, the purpose of bind9 may be for an internal or "intranet" based development services, such as local-only access to the web server using internally recognized domain names.

**All instructions are written under the assumption that you have root privielges.**

_I have not personally run thorough tests on the SSL instructions contained here-in, so it may be wise to wait for an update regarding SSL base setup.  I can say that if you are building any site with a login, you will want to add an SSL certificate, even if it is self-signed (just provide instructions for users to install it for safe logins)._

_While I use the bind9 configuration described below, setup has always been a bit of a pain and I have not thoroughly tested and debugged all the "gotcha" scenarios.  You may consider waiting for an update to that section before following my instructions, or if you encounter problems either add an issue to the issue tracker and wait for me to follow-up._


### Adding new Services

This section covers installing any new services and modifications that may be required.


**Adding DotDeb:**

Execute to add key:

    wget http://www.dotdeb.org/dotdeb.gpg
    cat dotdeb.gpg | apt-key add -
    rm dotdeb.gpg

Add the sources to `/etc/apt/sources.list`:

    deb http://packages.dotdeb.org wheezy all
    deb-src http://packages.dotdeb.org wheezy all

_The dotdeb repositories are a trusted and well maintained set of packages which are great for development and production use._


**MariaDB Sources:**

Register the key & add their repository:

    apt-get install python-software-properties
    apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db
    add-apt-repository 'deb http://mirror.jmu.edu/pub/mariadb/repo/5.5/debian wheezy main'


**Installing Services:**

    aptitude clean
    aptitude update
    aptitude install -y nginx-full ssl-cert php5 php5-fpm php5-cli php5-mcrypt php5-gd php5-mysqlnd php5-curl php5-xmlrpc php5-dev php5-intl php-pear php-apc php5-imagick php5-xsl msmtp-mta monit bind9 python-pip bpython sphinxsearch imagemagick graphicsmagick libgraphicsmagick1-dev mariadb-server mongodb msmtp-mta python-pip sphinxsearch bind9


**Installing nodejs:**

Safely download, build and install it off their site:

    cd /usr/src
    wget http://nodejs.org/dist/node-latest.tar.gz
    tar xf node-latest.tar.gz
    rm node-latest.tar.gz
    cd node-v*
    ./configure && make && make install

Ideally you should keep the source files for later in case you want to remove the installed contents.  Alternatively you can use checkinstall in place of make and make install, but you'll have to install that package first.

Node modules can be added on a per project basis using the node package manager `npm`.  For example, this will add mysql or mariadb support, and mongodb support to your project:

    npm install mysql mongodb


### Creating a Development Environment

I start by creating three new groups then adding my user to them:

    groupadd projectdev
    groupadd webdev
    groupadd gitdev
    usermod -aG projectdev username
    usermod -aG webdev username
    usermod -aG gitdev username

Since I want the workflow to be as smooth as possible I add `www-data` to the `webdev` group as well.

    usermod -aG webdev www-data

For a workspace I prefer using `/srv` as this is a server, so it makes sense.  I start by setting ownership and permissions:

    chown root:projectdev /srv
    chmod 2775 /srv

Next I create some subdirectories underneath:

    mkdir /srv/www
    mkdir /srv/git
    mkdir /srv/projects

I then set alternative ownership on these directories:

    chown username:webdev /srv/www
    chown username:gitdev /srv/git

_While the sticky-bit for group-id is helpful, ideally we should also make sure that nginx, php-fpm, and nodejs are all set to apply the webdev group to files (I will cover this per config section), and that pam.d has been told to use a umask default of `002` (as covered in the original template documentation)._


**Advanced Git Control:**

As a development machine we may as well host our own repositories, hence the `/srv/git` directory.  However, understanding the workflow is important to be productive.

Generally when working on a shared repository or branch you have to pull before pushing etc, or create your own branches to work in.  This is fine, but pushing to a remote everytime can be troublesome, whether due to having to run pull first, or simply poor internet connectivity, having a local repository can resolve a huge chunk of this pain.

Instead, create a bare repository to act as a second (or better yet a primary) remote, and add your internet remote (such as github or bitbucket) with the appropriate label.


**Creating/Cloning a Bare Repo:**

Usually you will be cloning a work repository, this makes things a bit easier:

    git --bare clone <remote> --shared=group

_The use of `--shared=group` will allow others with access to your vm to commit changes, which makes it possible to share a bare repository with a team on a development server, something worth adding._

If you are creating a brand new repository, you can do so (preferably from the `/srv/git` directory we created) via:

    mkdir project_name.git
    cd project_name.git
    git --bare init --shared=group

Then from your local machine you can clone it, or add it as a remote via:

    git remote add dev username@remote_ip:/srv/git/project_name.git

_Personally, I prefer making the `origin` remote my local dev repo, and creating github or bitbucket remotes._


**Adjusted Workflow:**

With the bare repository in place you can now set a remote origin to push to without having to worry.

Ideally you should rename the internet remotes according to their host (eg. github or bitbucket):

    git remote rename origin internet

Then add the bare repository as origin:

    git remote add origin username@remote_ip:/srv/git/project_name.git

Now you can push/pull without extra specification.  When you have a finished and tested set of changes you can easily run:

    git pull && git push internet


**Testing with rsync:**

If you want to test changes very quickly you can use rsync to synchronize any changed files between a local and remote directory.

If you are using Sublime Text 2 you can automatically execute an rsync script or command with the commandOnSave plugin, otherwise you can create a script and run it.

Here is an example shell script for rsync:

    #!/bin/sh

    if [ ! -f "rsync" ];
    then

        touch "rsync";

        # Sync Atom VM Files /w rsync (use full paths)
        SERVER="remote_ip";
        USERNAME="username";
        REMOTE_PATH="";
        LOCAL_PATH="";
        SSH_KEY_PATH="";

        # Excludes
        EXCLUDES=();
        EXCLUDES=(${EXCLUDES[*]} '.git');
        EXCLUDES=(${EXCLUDES[*]} '.gitignore');
        EXCLUDES=(${EXCLUDES[*]} '.settings');
        EXCLUDES=(${EXCLUDES[*]} 'composer.lock');
        EXCLUDES=(${EXCLUDES[*]} '*.gitignore');
        EXCLUDES=(${EXCLUDES[*]} '.buildpath');
        EXCLUDES=(${EXCLUDES[*]} '.project');
        EXCLUDES=(${EXCLUDES[*]} '.externalToolBuilders');
        EXCLUDES=(${EXCLUDES[*]} '.DS_Store');

        rsync -atvz -e "ssh -i $SSH_KEY_PATH" ${LOCAL_PATH} ${USERNAME}@${SERVER}:${REMOTE_PATH} `for i in ${EXCLUDES[@]}; do printf " --exclude ${i}"; done`

        rm "rsync";

    fi


### System Modifications

**IPTables Additions:**

Insert these rules after SSH rules inside `/etc/fireall.conf`:

    # Allow tcp traffic for  (HTTP, HTTPS)
    -A INPUT -p tcp -m multiport --dports 80,443 -m conntrack --ctstate NEW -j ACCEPT

    # Allow DNS
    -A INPUT -p tcp --dport 53 -j ACCEPT
    -A INPUT -p udp --dport 53 -j ACCEPT


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


### Configuring Monit

We will want to add several new configurations to monit.

Remember that monit can also be useful for firing up nodejs instances (a future release may contain exmaples).

Key services of concern:

- nginx
- php-fpm
- bind9
- mariadb

We want to make sure that these services continue to run, and will restart if they are locking up.

The format for the configurations is extremely human, and you should read through the [documentation](http://mmonit.com/monit/documentation/) at their website for more examples.  Here I will provide three basic examples we use in our production system (located in `/etc/monit/conf.d/`):

NGinx Monitor `/etc/monid/conf.d/nginx.conf`:

    check process nginx with pidfile /var/run/nginx.pid
        start program = "/etc/init.d/nginx start"
        stop program  = "/etc/init.d/nginx stop"
        group www-data

PHP Monitor `/etc/monid/conf.d/php.conf`:

    check process php5-fpm with pidfile /var/run/php5-fpm.pid
        start program = "/etc/init.d/php5-fpm start"
        stop program = "/etc/init.d/php5-fpm stop"
        group www-data

Bind9 Monitor `/etc/monid/conf.d/bind.conf`:

    check process named with pidfile /var/run/named/named.pid
        start program = "/etc/init.d/bind9 start"
        stop program = "/etc/init.d/bind9 stop"
        group www-data

MariaDB Monitor `/etc/monid/conf.d/mariadb.conf`:

    check process mysqld with pidfile /var/run/mysqld/mysqld.pid
        start program = "/etc/init.d/mysql start"
        stop program = "/etc/init.d/mysql stop"
        group www-data

These additions will ensure that these new services continue to run at all times.


#### Configuring the Mail Server

I'll be honest, I absolutely loath mail servers.  They have never been easy to configure and setup, which is why there are dozens of them out there instead of just a few really good ones.

Besides that, I feel that mail is the kind of technology we should leave to the groups doing it right, instead of trying to run our own.

If you want to setup exim4 for production, check out the [Linode's Library](https://library.linode.com/email/exim/send-only-mta-ubuntu-12.04-precise-pangolin).

Otherwise I recommend a simple SMTP mail forwarding service (msmpt-mta).


**(Optional) MSMTP for Development SendMail Only Server:**

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

    chmod 0600 /etc/msmtprc

_You can create multiple accounts and are not limited to just one, this allows you to change sender data accordingly._

By default installing msmtp will add a symlink to `/usr/sbin/sendmail` for the local mail protocol, meaning you should not need to change anything else.  However, you can also symlink `/usr/sbin/msmtp` to `/usr/bin/msmtp` if you want to be able to access it on normal user accounts.


#### Configuring the www-data user

This user will be responsible for most of the web activity going on, so we want to make sure they are setup properly.

We can start by giving them a real `/home` path:

    usermod -m -d /home/www-data www-data

_Check that the contents of `/etc/skel` did not create or add any unwanted files._


**Creating a (Passwordless) SSH key:**

For our `www-data` user to run certain automated operations, such as pulling from private repositories or otherwise as needed by composer for example, we will want to create an SSH key for this user without a password so it can run requests without interaction.

**However, as mentioned in the previous template documentation, any keys without a password should be limited to read-only access on the any remote contents to which they are added.**

To create a strong SSH key:

    ssh-keygen -t rsa -b 4096

Let it choose the default location for `~/.ssh/id_rsa` private and a public key.  You may then optionally enter a password, or nothing and hit enter to create it as a **passwordless** key.


#### Configuring PHP-FPM

We want to modify `/etc/php5/fpm/php.ini` to set your [timezone](http://php.net/manual/en/timezones.php):

    date.timezone = America/New_York


**Install Composer Globally:**

Execute these commands to install Composer globally:

    wget --no-check-certificate https://getcomposer.org/installer
    php installer
    rm installer
    mv composer.phar /usr/local/bin/composer


**Development Error Output:**

By default PHP5-FPM is configured to silence error output for production, but if you are running a development server and wish to see these errors from the browser to debug and correct them you will need to modify a line in `/etc/php5/fpm/php.ini`:

    display_errors = On


**PHP File Uploads:**

By default PHP allows 2 Megabytes at most, which is tiny by todays standards, so let's increase it:

    upload_max_filesize = 32M

Remember, you can enforce upload sizes in other ways, this simply makes it require less tweaking in the service itself.


**Add pecl Packages:**

We can only install mongodb and gmagick extensions for php using pecl, the pear package system.  To do so, let's run these commands:

    pecl install gmagick
    pecl install mongo

Next we need to tell php to load these modules.  We can do so the "proper" way by creating `/etc/php5/mods-available/gmagick.ini` and `/etc/php5/mods-available/mongodb.ini` with their extentions like so:

    echo "extension=gmagick.so" > /etc/php5/mods-available/gmagick.ini
    echo "extension=mongo.so" > /etc/php5/mods-available/mongodb.ini

Finally we can symlink these into `/etc/php5/conf.d`, and reboot php-fpm for the changes to take affect:

    cd /etc/php5/conf.d
    ln -s ../mods-available/gmagick.ini gmagick.ini
    ln -s ../mods-available/mongodb.ini mongodb.ini
    service php5-fpm restart


##### Optimization

Optimization can be tricky, and ideally you should optimize late instead of make it the focus of your build.  It **should** be according to the services you are delivering, but there are technically two approaches.

1. If you have an existing web service with statistics on requests per second you should optimize by traffic (this is the best approach because it lets you know whether you should be upgrading or downgrading your equipment).

2. If you have a fixed amount of equipment and a brand new service you can optimize the systems resources to that service.

_As you add more web serviers optimization becomes a complete balancing act._

Let's start by covering some of the configuration settings, which can be found inside `/etc/php5/fpm/pool.d/www.conf`:

- `pm.start_servers`
- `pm.min_spare_servers`
- `pm.max_spare_servers`
- `pm.max_children`
- `pm.max_requests`

The `fpm` stands for FastCGI Process Manager, and a `pm` manages a pool of php `servers`.  So the `start_servers` is the number it boots with.  Each server has `max_children` processes it can execute.

If you have 4 servers with 25 children you can handle 100 php requests at a time.  The spare servers are spun up as you hit that maximum to handle additional incoming requests.  So if you have a minimum of 2 and max of 6, then it will load another 50 processes allowing it to flexibly handle all the way up to 150 additional requests.

Optimization comes from balancing the children per php-server as best the hardware can handle while consuming the least amount of memory but responding evenly to all requests.


In the first scenario, you will look at statistics like requests per second (ex. 3000), time to handle each requests (ex. 0.02), and memory consumed per request (ex. 2MB).

PHP-FPM is running event driven, which means it will server per tick or "microsecond".  Take that 3000 multiply it by 0.02 and it becomes 60 requests at a time, roughly.

If I have 4 servers with 25 children, they can handle 100 requests, so we are within the threshold with some room to spare with regards to requests.

Next for memory, we look at the 2mb per request, and also the idle consumption of 4 php-servers with 25 children.  Let's set 88mb, so 22mb per server, plus 25*2 or 50mb per request, which means approx. 72mb per server under load.  Our 4 servers will consume an average of 308MB, so long as we have that much RAM spare and our CPU isn't being killed causing bad response time, then we are all set.  If response time is bad but memory is not a problem, we need more vcpu's.


In the second scenario let's say we have 4 cores or vcpus with 2GB of memory.  A base install of debian maybe consumes 180MB so we have roughly 1.8GB free.  If all we are doing is serving PHP contents we can safely choose to assign 40% or 720MB to PHP-FPM.

Ideally we would run something like [Seige](http://www.joedog.org/siege-home/), and using monit we can watch the memory consumed by our servers.  We build an average and slowly increase both the children and servers until we hit our limit.  Ideally we test various combinations to see where the best CPU and Memory consumption balance is.


Here are the settings I stick with:

    pm.max_children = 25
    pm.start_servers = 2
    pm.min_spare_servers = 2
    pm.max_spare_servers = 5
    pm.max_requests = 500

This tends to be plenty for development and testing, but obviously I would do the ground-work above if I wanted to make sure it was tailored to the service I was building.


Finally, after all of the above changes, we can try rebooting php-fpm, if it works we are all set, and we can verify the changes with phpinfo from nginx.

    service php5-fpm restart


#### Configuring NGinx

Let's move into `/etc/nginx`, remove the default template configurations and add some folders:

    cd /etc/nginx
    rm sites-available/default
    rm sites-enabled/default
    mkdir -p ssl conf.d scripts.d

Next we will create some scripts to be loaded per virtual host.

    cd scripts.d

Create `favicon.conf` with:

    # favicon 404 fix
    location /favicon.ico {
        access_log off;
        log_not_found off;
    }

Create `php.conf` with:

    # PHP Handler
    location ~ \.php$ {
        try_files $uri =404;
        include fastcgi_params;
        fastcgi_pass unix:/var/run/php5-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }

Next we can create `cache.conf`, but there are two approaches.  The best performance with the most headaches is to add one line `expires max;`, which we would then have to override for every file we don't want to be forever cached.  The best approach I have found is to be specific about the files we want their browser to cache, and to break it up according to specific types:

    location ~* \.(ico|gif|jpe?g|png)$ {
        expires max;
        add_header Pragma public;
        add_header Cache-Control "public, must-revalidate, proxy-revalidate";
    }

    location ~* \.(css|js)$ {
        expires 5m;
        add_header Pragma public;
        add_header Cache-Control "public, must-revalidate, proxy-revalidate";
    }

_You may consider also adding `access_log off;` and `log_not_found off;` to the static files._

Create a `hidden.conf` file with:

    location ~ /\. {
        access_log off;
        log_not_found off;
        deny all;
    }

This prevents users from seeing dot files and directories, such as `.git` folders.


##### Optimizng NGinx

We'll start with changes to `/etc/nginx/nginx.conf`.

We want to check the user line and make it read as follows:

    user www-data webdev;

This makes sure it runs as www-data and has the group webdev.

Next let's check `worker_processes` and `worker_connections`.  NGinx is a proxy server, it's very light-weight.  It is also multi-core tuned, so if you have 2 or more cores you should have 2 or more `worker_processes`.  The default for nginx should probably be 4, if you have 2 cores and know your scripts are lightweight, then this is fine, but if you are doign some heavy lifting you might consider dropping it to match the number of cores.

The `worker_processes` is how many processes will be handled per worker, and you are welcome to raise this number.  The default is between 768 and 1024, but you can probably go to 2048 without any significant changes.  Until you actually have over 8000 simultanious requests coming into the server you probably won't have any way to test the best configuration, so for development and even most production environments the default number tends to work just fine.

Inside the events brackets let's check for or add:

    multi_accept on;
    use epoll;

These are two features that enhance multi-core handling, but may have the adverse affect if your worker count is above the number of available cores.

Make sure these key settings exist:

    sendfile on;
    tcp_nopush on;

The first allows context switching and can greatly boost CPU performance, the second ensures that no HTTP headers are split into chunks and sent separately.

Locate `keepalive_timeout` and make sure it reads `keepalive_timeout 15;` to reduce the timeout duration to 15 seconds.

Finally we want to check that the line `include /etc/nginx/conf.d/*.conf;` exists within the http brackets, so we can visit that directory to add enhancements:

    cd conf.d

Let's start by creating `charset.conf` with:

    charset utf-8;

_This adds security by ensuring data types going in and out should be utf-8._

Create a `tokens.conf` file with:

    server_tokens off;

Create a `keepalive.conf` and set:

    keepalive_timeout 15s;

_This feature reduces headers in multiple requests, such as when a page also asks for images, js, and css files, but otherwise it is not that helpful.  The default is very long and can reduce the number of connections per second.  If it comes down to performance vs requests per second you may consider turning this off._

Create an `uploads.conf` with:

    client_max_body_size 32m;
    client_body_buffer_size 128k;

NGinx file uploads are by default limited to 1m, despite what php is set to.  If you plan to support file uploads you will want to choose a size and change it in both nginx and php.

Create `pma.conf` with:

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

_The pma.conf script secures phpmyadmin access to localhost only, and can be accessed using ssh tunneling, which gives you a nice GUI that is also secure:**

    ssh -f -N username@domain.com -L ####:localhost:####

_You will have to download a copy of phpmyadmin and place it at `/srv/www/pma` for the pma config above to work properly.  More details will be explained in the virtual hosts section._

For just a quick moment, to add pma.conf properly, we need to move to `/srv/www` and grab a copy of phpmyadmin so it can be accessed from `/srv/www/pma`:

    cd /srv/www
    wget "http://downloads.sourceforge.net/project/phpmyadmin/phpMyAdmin/4.0.8/phpMyAdmin-4.0.8-all-languages.zip?r=http%3A%2F%2Fwww.phpmyadmin.net%2Fhome_page%2Findex.php&ts=1381830040&use_mirror=superb-dca2" -O pma.zip
    unzip pma.zip
    mv php* pma

This prevents the http headers from being sent in chunks.

Let's also create `gzip.conf` with:

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


**Adding SSL:**

Let's talk about SSL Certificates.  Real ones cost money and are a requirement if you intend to serve any kind of secured and trusted contents, such as a store front.

Without SSL contents are sent as plain-text, including any logins sent through forms.  Any system where your visitors login should have ssl for security.

For testing or if your users don't care about the trustworthyness of the certificate (eg. the account and service has no connection to external things) then you can get around this using self-signed certificates.

We will create a snakeoil certificate, which is a self-signed certificate that can be used legitimately.  For starters backup the `/usr/share/ssl-cert/ssleay.cnf` file, as this is our template for the certificate.  We will make it look like this:

**Warning: The following changes are untested.**

    RANDFILE                = /dev/urandom

    [ req ]
    default_bits        = 4096
    default_keyfile     = privkey.pem
    distinguished_name  = req_distinguished_name
    prompt              = no
    policy              = policy_anything
    req_extensions      = v3_req
    x509_extensions     = v3_req

    [ req_distinguished_name ]
    countryName         = US
    stateOrProvinceName = NY
    localityName        = Rochester
    commonName          = *.domain.com
    emailAddress        = admin@domain.com

    [ v3_req ]
    basicConstraints        = CA:FALSE

Once saved we are ready to execute

    make-ssl-cert generate-default-snakeoil --force-overwrite

This will generate a key and pem file at:

    /etc/ssl/certs/ssl-cert-snakeoil.pem
    /etc/ssl/private/ssl-cert-snakeoil.key

We want to copy those into `/etc/nginx/ssl/` for our use.

**I will cover how to use these ssl keys in the virtual hosts section.**


##### Creating Virtual Hosts

While this name is more of an apache origin, the intended purpose is to catch requests to multiple addresses and route them accordingly.  The nginx term for "virtual hosts" is a "server block", and just like apache you can have as many as you like.

The configuration of server blocks is best done by separating them per site into properly named files.  Generally you place the actual files inside the sides-available directory, and symlink them to the sites-enabled directory.  This allows you to easily enable and disable sites and reboot the nginx service.

Here is a very basic example of a `domain.com` website, which we will place into `/etc/nginx/sites-available/domain.com`:

    # HTTP Config
    server {

        listen 80 default;

        server_name domain.com www.domain.com;
        access_log /srv/www/domain.com/logs/access.log;
        error_log /srv/www/domain.com/logs/error.log;

        root /srv/www/domain.com/public_html;
        index index.html index.php;
        rewrite_log on;

        # Include Configs
        include /etc/nginx/scripts.d/*.conf;

    }

The listen argument `default` says that if the user reaches this IP Address with an unmatched web address we display this site.  You can use that to display a totally different page if preferred.

We provide one or more space delimited addresses for the `server_name`, and can individually separate the error and access logs for easier debugging of site problems.  We specify the root address for the site, and what to consider the main page.  By default nginx does not allow directory browsing.  You can turn it on by adding `autoindex on;`, and you can even specify a location block if you want it to apply to specific sub-directories.

Location blocks can be added to separate specific content, and it does support rewrites (just like apache htaccess files), but usually the application should handle all of that, not the web server (a continuing mistake from arcane/dated technology).  If anything a single line to redirect all unfound paths to index would make sense.

Finally the include statement will load our script configurations, such as the favicon error blocker, and the php fastcgi parser.  These both use location blocks.  Note that these could be added globally to the `/etc/nginx/conf.d` if preferred as well, but the only performance change will be when the server is restarted, not during runtime as nginx puts together all that info when started, unlike apache which interprets configs at runtime.


**Easy & Efficient www Redirection:**

This can be done in either direction without using rewrites to ensure that SEO doesn't become jumbled due to the www prefix.  You simply create a server with the name you don't want used and force a 301 redirect:

    server {
        listen       80;
        server_name  domain.com;
        return       301 http://www.domain.com$request_uri;
    }

The `$request_uri` is a nginx variable that contains any paths that were sent, allowing you to cleanly redirect in the event that the url had an undesirable prefix but a valid path.  _Remember to do the same for https/443 versions of the domain._


**Configuring HTTPS/403 Hosts:**

Using the key files we generated earlier, we can move/copy them from `/etc/ssl/` into our `/etc/nginx/ssl` folder.  If we are creating a key per domain we may want to consider creating something like `/etc/nginx/ssl/domain.com/`.

    mkdir -p /etc/nginx/ssl/domain.com/
    cp /etc/ssl/certs/ /etc/nginx/ssl/domain.com/domain.com.crt
    cp /etc/ssl/private/ /etc/nginx/ssl/domain.com/domain.com.key

    cp /etc/ssl/certs/ssl-cert-snakeoil.pem /etc/nginx/ssl/domain.com/domain.com.crt
    cp /etc/ssl/private/ssl-cert-snakeoil.key /etc/nginx/ssl/domain.com/domain.com.key

Next we can define an SSL server block, which looks like this:

    server {
        listen 443 ssl;

        ssl_certificate /etc/nginx/ssl/domain.com/domain.com.crt;
        ssl_certificate_key /etc/nginx/ssl/domain.com/domain.com.key;

        server_name domain.com www.domain.com;
        access_log /srv/www/domain.com/logs/access.log;
        error_log /srv/www/domain.com/logs/error.log;

        root /srv/www/domain.com/public_html;
        index index.html index.php;
        rewrite_log on;

        # Tell FastCGI this is a secure line
        fastcgi_param HTTPS on;

        # Include Configs
        include /etc/nginx/scripts.d/*.conf;
    }

Notice the only prominent changes are the change to the listen property, and adding the certificate and key paths.  We still need all the same properties as we had before, preferably to match the other configuration file.


**Personally Encountered Problems:**

If your page contents include a large quantity of data, such as a bulky framework, personal experience with wordpress and a store system combined with ssl created contents too large for the fastcgi buffers, and as a result pages wouldn't load.  To resolve this you may have to add a line to your server config (but preferably not globally):

    fastcgi_buffers 8 32k;

Enlarged buffers solved the problem, no clue as to the exact details why, but other configuration options in the optimizations sections may have also resolved the problem in a cleaner way.  FastCGI buffers allocate memory on request, and this can eat substantial amounts of additional RAM if globally increased.  Ideally a large number of small buffers is preferred, as the buffers themselves are only useful if they are filled, otherwise it's just wasted memory.


**Example of a completely fleshed out file:**

Ideally we can place all of those server sections into the single named file, and we'll get something like the following:

    server {
        listen       80;
        server_name  www.domain.com;
        return       301 http://domain.com$request_uri;
    }

    server {
        listen       443 ssl;
        ssl_certificate /etc/nginx/ssl/domain.com/domain.com.crt;
        ssl_certificate_key /etc/nginx/ssl/domain.com/domain.com.key;
        server_name  www.domain.com;
        return       301 https://domain.com$request_uri;
    }

    # HTTP Config
    server {

        listen 80 default;

        server_name domain.com;
        access_log /srv/www/domain.com/logs/access.log;
        error_log /srv/www/domain.com/logs/error.log;

        root /srv/www/domain.com/public_html;
        index index.html index.php;
        rewrite_log on;

        # Include Configs
        include /etc/nginx/scripts.d/*.conf;

    }

    server {
        listen 443 ssl;

        ssl_certificate /etc/nginx/ssl/domain.com/domain.com.crt;
        ssl_certificate_key /etc/nginx/ssl/domain.com/domain.com.key;

        server_name domain.com;
        access_log /srv/www/domain.com/logs/access.log;
        error_log /srv/www/domain.com/logs/error.log;

        root /srv/www/domain.com/public_html;
        index index.html index.php;
        rewrite_log on;

        # Tell FastCGI this is a secure line
        fastcgi_param HTTPS on;

        # Include Configs
        include /etc/nginx/scripts.d/*.conf;
    }

Remember to create matching paths inside of our working web directory:

    mkdir -p /srv/www/domain.com/public_html /srv/www/domain.com/logs


**Turning it on and off:**

The layout of sites-available and sites-enabled gives us the ability to quickly disable a site and reboot the system if we need to take down a site or debug it.

To add a site we symlink it:

    ln -s /etc/nginx/sites-available/www.domain.com /etc/nginx/sites-enabled/www.domain.com

To remove that same site we just delete the symlink:

    rm /etc/nginx/sites-enabled/www.domain.com

After either change we reboot nginx:

    service nginx restart

_If you want to do things properly you might want to run `nginx -t` to test the configuration before rebooting._


#### Configuring MariaDB

AFAIK tuning MariaDB is the same as MySQL through the `my.cnf` file.

I generally leave this alone, if there are performance problems they can almost always be traced back to the code, not the dbms.

If you optimize your queries and properly index your tables and you'll be fine.


#### Configuring Bind9

For development environments on a local network where more than one person may be connecting it can help to add a DNS Server to your Web Server.  This allows you to distribute the addresses to projects across the local network.

Let's begin by installing the our DNS Server;


We can start the process by defining a zone and reverse lookup, I won't go into detail explaining these as that is not the goal of this guide, if you have questions Google is your friend.

Add content to the `/etc/bind/named.conf.local` similar to the following:

    // Primary Domain Zones File
    zone "domain.com" {
            type master;
            file "/etc/bind/zones/domain.com.db";
    };

    // Reverse Network Zones File
    zone "0.0.10.in-addr.arpa" {
            type master;
            file "/etc/bind/zones/0.0.10.rev";
    };

_Note: generally a DNS has a static IP, and the reverse lookup is used for the local network.  In the case above the 0.0.10 is the reverse of a Class A private network (10.0.0.0).  In many cases you will instead see `0.168.192`, a Class C network address._

Next we need to define the zone files.  Let's start with the forward lookup file named according to our domain (`/etc/bind/zones/domain.com.db`):

    $TTL    3600
    @       IN      SOA     domain.com. root.domain.com. (
                   2013051310           ; Serial
                         3600           ; Refresh [1h]
                          600           ; Retry   [10m]
                        86400           ; Expire  [1d]
                          600 )         ; Negative Cache TTL [1h]

    ;; Name Server
                               NS       domain.com.

    ;; CNAME Records
    www.domain.com.    IN    CNAME    domain.com.
    *.domain.com.      IN    CNAME    domain.com.

    ;; A Records (IPv4 addresses)
    domain.com.        IN    A        10.0.0.5

I won't go into detail here, just know that it works, just a few caveats.  First, the Serial format is often preferred as a date plus a 2 digit counter so you can make many changes in one day.  The Serial must increase every time you make a change and reload Bind, otherwise it will fail to take the changes.

The first two records are the zone (primary address), and owner of the domain (root aka root@domain.com).  It is generally best practice to include the calculated values in comments for the reader, for Expiration, Refresh, Retry, and Cache times etc...  This particular configuration is tailored for development systems and has very short durations for all settings.

Then like any other DNS configuration we have an @, marking the DNS server, followed by a mixture of A records and CNAME records, where A records hold an IP address and CNAME records are linked to the A records.

Finally, we want to add a reverse lookup, which is effectively all the addresses that the IP can resolve to:

    $TTL 3600
    @ IN SOA        domain.com. root.domain.com. (
                       2013010132           ; Serial
                             3600           ; Refresh [1h]
                              600           ; Retry   [10m]
                            86400           ; Expire  [1d]
                              600 )         ; Negative Cache TTL [1h]
    ;
    @       IN      NS      domain.com.
    5       IN      PTR     www.domain.com.

If you want to add more, entirely different, domains you can do so by simply creating more zones and configurations to match.  Generally it is easier to work off a single zones file with sub-domains; a common practice.

I will end configuring Bind with a [recommended reference](http://brian.serveblog.net/2011/07/31/how-to-setup-a-dns-server-on-debian/), which does far better than I can explaining all the details.

Now, if you restart the bind service (`service bind9 restart`) your system should now be broadcasting.  However, this alone means nothing unless someone knows to listen.

There are two ways you can put a development DNS to use.  First is by asking others to add the Development systems IP to their DNS statically.  Second is if you an control the local networks router, you can add the DNS servers it distributes via DHCP.  Just remember that _if_ you go with a Router solution any machines that have a client-assigned static IP must have the DNS added statically as well.  Also, order matters.  If your DNS Server is secondary any existing web domains will go to the external location, not the internal one.  If you are trying to override a real address for internal development, add your DNS server first (this is generally not wise if you ever want to access the real site as changing DNS afterwards can be a pain).
