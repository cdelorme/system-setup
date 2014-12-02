
# web server documentation

These steps extend my template configuration steps, and is intended for use as a bare-bones web & proxy server.  _Additional services can be installed and configured afterwards (such as nodejs, php, etc)._

In my case I've moved away from almost all personal projects that involve a high degree of complication, so I don't include extra software in my configuration.

Key utilities that will be covered:

- [nginx](http://wiki.nginx.org/Main)
- [monit](http://mmonit.com/monit/)

Separate documentation that is supplemental to the above tools includes:

- [mongodb](../misc/mongodb.md)
- [php-fpm](../misc/php-fpm.md)
- [mariadb](../misc/mariadb.md)
- [msmtp mail server](../misc/msmtp.md)

All web services should run through nginx as a proxy and cache service, and it is especially efficient for static website delivery.

For a server it makes more sense to use something like `monit` to watch for whether services cease to run or begin behaving erratically, and either notify the maintainer or restart them automatically.


## service installation

To install our new packages we want to add the [`dotdeb` repository](../misc/dotdeb.md), which will give us a more up-to-date version of nginx, since debian stability prevents newer versions.

Now we are ready to cleanup

    aptitude clean
    aptitude update
    aptitude install -ryq nginx-full

If you are concerned with stability of auto-updates you are welcome to put key packages on hold:

    aptitude hold nginx-full

With that in effect your system can upgrade other packages, but any new versions of `nginx-full` would be ignored.  This can be helpful if you are concerned with upgrades:

- introducing instability
- breaking backwards compatibility
- replacing configuration files

There are other options around it as well, but that tends to be a _prudent_ solution for a production server.  If you are using debian stable packages, then you usually won't have to worry about any instabilities being introduced.


## monit

I use monit for many things starting with basic system performance to workstation applications and services, as well as my server to keep things from locking up or overloading the system.  I have configuration for other utilities in my [workstation documentation](workstation.md).

For nginx, add these lines to `/etc/monit/monitrc.d/nginx`:

    check process nginx with pidfile /var/run/nginx.pid
        start program = "/etc/init.d/nginx start"
        stop program  = "/etc/init.d/nginx stop"
        group www-data
        if cpu > 80% for 5 cycles then restart
        if memory > 80% for 5 cycles then restart
        if 3 restarts within 8 cycles then timeout

It can also be used to make sure your website is up, and take action if it is not:

    check host example.com with address example.com
        restart program = "/etc/init.d/nginx restart"
        if failed port 80 protocol http for 2 cycles then restart
        if failed port 443 protocol https for 2 cycles then restart

We want to make sure that these services continue to run, and will restart if they are locking up or eating up more resources than they should be (aka erratic behavior).

The format for the configurations is extremely human, and you should read through the [documentation](http://mmonit.com/monit/documentation/) at their website for more examples.


## iptables

We only need to add one line, but this is required to enable http and https traffic (I use the keywords to be more explicit, but you can exchange them for ports 80,443):

    # Allow tcp traffic for  (HTTP, HTTPS)
    -A INPUT -p tcp -m multiport --dports http,https -m conntrack --ctstate NEW -j ACCEPT

_If you have additional services you want to run on non-standard ports, you will want to add additional rules to your iptables list._  Ideally you should use standard ports to avoid complications and increasing the number of entry-points.


## preparing a server environment

On many projects over the years I've found that permissions can be a plague.  Setting who has access rights, and creating some semblance of a standardized layout for projects can be a hassle.

One of the biggest concerns is automating git repositories without breaking the permissions because of who checked out the latest source.

My solution is to supply a default structure, and use the stickybit to enforce group and permissions that _should_ ensure things continue to run smoothly.

First, create the `www-data`, `webdev`, and `gitdev` groups if either does not yet exist.  Be sure to add your user to these groups, and any users you want to have access.  **This includes whatever user is running the nginx server, or processing content dynamically, or accessing the database.**  _Some languages make a real mess of this, like php, so be prepared for dealing with madness from time-to-time._

    groupadd www-data
    groupadd gitdev
    groupadd webdev
    usermod -aG webdev,gitdev username

Next, we can create the `/srv/www` folder and apply ownership changes and stickybit (`6775` or `2775` depending on needs) permissions for normal access:

    mkdir -p /srv/www
    mkdir -p /srv/git
    chown -R www-data:www-data /srv
    chown -R www-data:webdev /srv/www
    chown -R www-data:gitdev /srv/git
    chmod -R 6775 /srv

_The 2 and 6 are `sticky bits` which in binary represent specific functions.  2 is `010` which means permissions on the group are applied to all child objects created under that folder.  Similarly 6 translates to `110` which means group and owner permissions are passed down to all contained objects.  Using the sticky-bit ensures permissions are passed down to contained files and folders, and the group should not change from `webdev`, giving access to all developers, and also to the web server.  We can also choose when to compromise security and go to `7` for other on specific files (usually for php...)._

Next we can either use bare git repositories and a `post-receive` hook to automate deployment, _or_ for static content we can use a cronjob to pull from a git repository regularly and automate deployment.


### bare git repositories

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

You can now test on a local box by pushing changes there first:

    git push origin

Which should automate via a post-receive hook on that server, and once tested you can easily push and pull to the other remote (usually the public or shared repository):

    git pull internet
    git push internet

**Adding a post-receive hook:**

If you want to perform a specific action when new content has been received, you can do so by creating an executable file at the relative path `.git/hooks/post-receive`.

For example, assuming you serve your site from `/srv/www/` using nginx, you can checkout the latest source via:

    #!/bin/bash
    git --git-dir=/srv/git/site.com.git --work-tree=/srv/www/site.com checkout -f

_Obviously this example does not take into account alternative branches, since you'd need folders for each branch configured as well, but it is possible._

Alternatively you can have the server execute unit and integration tests as part of an entire deployment process.


## log rotation

Assuming our nginx service is configured to place logs with the websites inside our `/srv` environment then we will want to create a logrotation script to keep our drive from flooding.

Create a new logrotate configuration file `/etc/logrotate.d/websites` with these rules:

    /srv/www/*/logs/*.log {
        copytruncate
        daily
        missingok
        rotate 3
        compress
        delaycompress
        notifempty
        size 300k
    }

This finds ant `.log` files inside `logs/` folders inside `/srv/www` paths (for example `/srv/www/example.com/logs/`).

The configuration will keep the maximum size below 300k, and rotate it in sets of 3 files at a time.  The second oldest will always be compressed, giving you two files to search through.  It will run daily unless that size limit is exceeded.

Because nginx is connected to the file it logging to we use `copytruncate` to keep the file in-place and simply copy it's records elsewhere.  _This copy process can result on lost messages if they occur during the logrotate copy, but because our max size is small it should never occur (or at least very rarely)._


## nginx configuration and optimization

Our next goal is to configure and optimize nginx to serve content or websites from our `/srv/www` folders, as well as other running services (since it is a proxy server).

We'll want to remove the default site template and prepare an ssl directory and configuration plus script directories:

    rm /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
    mkdir -p /etc/nginx/ssl /etc/nginx/conf.d /etc/nginx/scripts.d

_This should let us organize our configuration files, and import them intelligently._

One wonderful thing about nginx is that it comes with completely sane defaults that will usually be performant without modification for your average website.  However, if you want to go the extra lengths to squeeze more out of your server, or if your working on an entirely different scale then you will want to change the defaults.


### nginx optimizations

I place all global optimization scripts inside `/etc/nginx/conf.d`, and import them from the primary configuration.

Per-site optimization scripts are placed into `/etc/nginx/scripts.d`, hence the separate path.


**Global Optimizations:**

Let's start with a modified base configuration file:

    user www-data webdev;
    worker_processes 4;
    pid /run/nginx.pid;

    events {
        worker_connections 1024;
        multi_accept on;
        use epoll;
    }

    http {

        ##
        # Basic Settings
        ##

        sendfile on;
        tcp_nopush on;
        tcp_nodelay on;
        keepalive_timeout 15;
        types_hash_max_size 2048;

        ##
        # Mime Types
        ##

        include /etc/nginx/mime.types;
        default_type application/octet-stream;


        ##
        # Logging Settings
        ##

        access_log /var/log/nginx/access.log;
        error_log /var/log/nginx/error.log;


        ##
        # Gzip Settings
        ##

        gzip on;
        gzip_disable "msie6";


        ##
        # Virtual Host Configs
        ##

        include /etc/nginx/conf.d/*.conf;
        include /etc/nginx/sites-enabled/*;
    }

The changes I made are non-breaking.  If the nginx package is auto-upgraded it will likely replace these changes, _which is another reason you may want to consider using `aptitude hold nginx-full` on a production box._

The `keepalive_timeout` is useful when serving a lot of dependencies per-page, by reducing the headers necessary for subsequent requests.  If you are serving a very large number of images, javascript, and css files then the default may be alright, but I turned it down to 15 from 65, which should be plenty.  _If you have a minimal number of css and js dependencies and serve images from a CDN it'd be worth considering turning it off to free up connections faster._

With these changes each worker will handle more connections, and have better concurrent processing (`multi_accept`) plus throughput (`epoll`).  The defaults nginx comes with are not only "sane" but also very performant, even on lesser machines such as virtual systems.  However if you have a high powered server you can probably increase the defaults quite a bit, and if you have heavy traffic you may also want to experiment with some of the optimizations I'm about to propose.


**Compression:**

I recommend the following added to `/etc/nginx/conf.d/gzip.conf`:

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

_The highest compression level reduces bandwidth at the cost of more CPU necessary to translate the response.  When dealing with mobile devices or very large files you may want to consider a lighter compression level (mobile devices are great at handling large chunks of traffic in bursts but don't have the greatest processors)._

By default it uses the `www-data` user and group.  My change tells it to use the `webdev` group, but with the sticky-bits set on our server content folder, we should have no problems either way.


**Character Sets:**

I highly recommend you enforce a character set, and the proxy-server is a good place to be sure transmissions proxied between services remains the same.  For that, create `/etc/nginx/conf.d/charset.conf` with:

    charset utf-8;


**Large Server Names:**

This is optional, but you if you have a long domain name, or need to set a lot of rules you may consider increasing the server name hash size by creating `/etc/nginx/conf.d/servernamehash.conf` with:

    server_names_hash_bucket_size 64;


**Turning off tokens:**

This is not a matter of security, but rather a way to reduce what gets sent with every http call.  Create `/etc/nginx/conf.d/tokens.conf` with:

    server_tokens off;

_This will reduce the number of headers that get sent on every request, which when serving a large number of requests can be a substantial savings._


**Uploads:**

Finally, if you expect to be handling file uploads, you will want to modify size restrictions to allow these.  To do so create `/etc/nginx/conf.d/uploads.conf` with these settings:

    client_max_body_size 32m;
    client_body_buffer_size 128k;

By default the file upload size supported by nginx is 1MB, in spite of what any proxied service limitations are.  By increasing the size here we lift a size constraint.  The second parameter is how much of client body from one or more transmissions is accepted before it gets placed into a temporary file.  By setting it to something sizable we can eliminate temporary file creation for small uploads (below that limit).


These changes should provide quite a boost to the core performance, but we also have configuration scripts that can be included on every website that can also greatly improve performance.

Therefore, let's move onto...

**Site Optimizations:**

Optimizations can be made per-site, which can be included in bulk from the `/etc/nginx/scripts.d` folder.  This makes it easy to host multiple sites and import all the settings with a single addition.


**Favicon:**

Create `/etc/nginx/scripts.d/favicon.conf` with:

    # favicon 404 fix
    location /favicon.ico {
        access_log off;
        log_not_found off;
    }

Even if your site has a favicon, without this line every single page load will either add an access message, or an error message for 404 (not found).  Usually, we don't care whether the favicon was available, or when it is loaded.


**Caching:**

In highly recommend placing the following inside `/etc/nginx/scripts.d/cache.conf`:

    location ~* \.(css|js|html|ico|gif|jpe?g|png|svg)$ {
        expires 5m;
        add_header Pragma public;
        add_header Cache-Control "public, must-revalidate, proxy-revalidate";
    }

For non-dynamic file types I specify a 5 minute expiration.  If your site is not receiving hits every 5 minutes, keeping those files in memory servers no purpose.  This also tends to yield a decent cache-invalidation time so you get updates from dynamic content.

_While I do include image extensions, I do not recommend storing images on your web server._  Those should generally be stored and delivered on a CDN, such as AWS S3.


**Hidden Files:**

Files and folders that start with a period, we usually don't want to serve those.  I recommend creating `/etc/nginx/scripts.d/hidden.conf` with:

Create a `hidden.conf` file with:

    location ~ /\. {
        access_log off;
        log_not_found off;
        deny all;
    }

This will prevent access to files and folders that start with a period.  I have also disabled any messages about whether the file existed or access was attempted.  No reason to clutter the logs if we've added this as a security measure, unless you want to verify whether it is working.

_There are situations where `.htaccess` or `.git/` may be in the public folders.  It is never ideal, but having something in place is helpful._


### ssl certificates

SSL allows HTTPS traffic on port 443, and enables content encryption between the server and client.  This is exceptionally beneficial if the site has a login or any administrative features.

There is absolutely no excuse not to have https on your sites today:

- [ssl certificates can be acquired for free](https://www.startssl.com/)
- [nginx SNI allows multiple ssl certificates per ip](https://www.digitalocean.com/community/tutorials/how-to-set-up-multiple-ssl-certificates-on-one-ip-with-nginx-on-ubuntu-12-04)

Configuring nginx for ssl literally takes 5 minutes.  Redirecting to it is 3 lines of configuration as well.


**Where to keey your keys:**

We created `/etc/nginx/ssl` for this purpose.  I recommend storing the main host key in that folder directly, but every websites signed ssl key can be placed into.


**Generating ssl certificates:**

There are two parts, a signed key, and a host key.  The host can can be re-used, but the signed key is either self-signed or needs to be provided by a service like startssl.

Start by creating a server key:

    openssl genrsa -des3 -out host.key 2048

You will be prompted for a password.  Next we will want to remove the passphrase from this key, so we can load it in nginx without entering a password everytime it restarts:

    openssl rsa -in host.key -out server.key

_You will need to enter the password for this._

We can now use the `host.key` to generate "certificate requests", and `server.key` can be used by nginx as the host key.

Let's create a signed certificate request:

    openssl req -new -key host.key -out example.com.csr

You will be prompted for the password for `host.key`, then a series of identification questions.  This information will likely be required for the request to be considered valid by the third party signee.  **If you need a wildcard certificate you will want to enter `*.example.com` as the common-name.**  Wildcard certificates are "free" through startssl, but you need to pay $60 for full identification and must supply them with two forms of ID.  If you need subdomains, that is the only option.

_This `.csr` file can now be supplied to a company such as startssl for a legitimate signed certificate._


**Self Signed Keys:**

This is an alternative, useful for testing but even then it can be a hassle.  An unsigned key will result in your web browser complaining every attempt to load it, and if you do not add the certificate to your local system as trusted it'll prevent you from making much use of it

However, in the event that you do need one temporarily, here is how to create it!

Using the passwordless server key, and the certificate request from the previous steps, we can generate a self-signed certificate.

Taking the host key we generated previously, we will feed it to a request for generating a self-signed certificate:

     openssl x509 -req -days 365 -in example.com.csr -signkey server.key -out example.com.crt

We can now use our self-signed `.crt` file for development.

**I will cover how to configure nginx with https next.**


### virtual hosts

As they were called in `apache`, virtualhosts allow you to point multiple domain names to a single IP Address, and have a single port and server pass along requests accordingly.

With nginx you can create new hosts in `/etc/nginx/sites-available/`.

Here is a good baseline example, let's assume we placed it into `/etc/nginx/sites-available/example.com`:

    # redirect to https (SECURITY)
    server {
        listen 80 default;
        server_name www.example.com example.com;
        return 301 https://www.example.com$request_uri;
    }

    # redirect to www prefix (SEO)
    server {
        listen 443;
        server_name www.cdelorme.com cdelorme.com caseydelorme.com;
        return 301 https://www.caseydelorme.com$request_uri;
    }

    # HTTPS config
    server {
        listen 443 default ssl;

        ssl_certificate ssl/example.com.crt;
        ssl_certificate_key ssl/server.key;

        server_name www.example.com;
        access_log /srv/www/example.com/logs/access.log;
        error_log /srv/www/example.com/logs/error.log;

        root /srv/www/example.com/public;
        index index.html;
        rewrite_log on;

        # generic configuration
        #include scripts.d/*.conf;
    }

While it is possible to perform all the redirects in a single block, it is significantly more efficient to create separate blocks to handle those cases.

If you have an SSL certificate and https is configured, you should always be using it.

It is highly recommended that you pick a prefix and stick with it consistently.  SEO advocates claim that the `www.` prefix is beneficial, so I usually add this redirect for https traffic.

The use of `default` assumes that you have no other sites, or that if someone enters the ip address they will see that site as the default.  It is not required, but if your server hosts many websites it may be wise to select a default.

You can use https without an ssl certificate by omitting the `ssl` option, but this can its own set of problems.

We specify the paths to the certificates for the server and the website.

The configuration assumes we own `example.com`, and requires `/srv/www/example.com` to exist, as well as `/srv/www/example.com/logs`, and `/srv/www/example.com/public`.  It will look for index.html in any folder paths within there.

Finally, we include all the configuration scripts we created earlier to optimize the behavior of our site.


**Enabling a website:**

The purpose behind having an enabled and available folder is that we can use symlinks to easily turn on or off a website.  This allows us to quickly take down a server without removing the actual configuration files for it.

So, to enable our `example.com` website, we need to run:

    ln -sf ../sites-available/example.com example.com

_This will force-create a relative-path symlink, but you can use full paths if you'd prefer._


**Test and Reboot!**

The final steps are to test the configuration and reboot nginx.  To test that your configuration is error-free run `nginx -t`.  If that works, go ahead and restart nginx `service nginx restart`.


# references

- [sticky-bits](http://unix.stackexchange.com/questions/64126/why-does-chmod-1777-and-chmod-3777-both-set-the-sticky-bit)
- [modifying deb postinst dpkg packaging](https://yeupou.wordpress.com/2012/07/21/modifying-preinst-and-postinst-scripts-before-installing-a-package-with-dpkg/)
- [nginx optimization tips](http://tweaked.io/guide/nginx/)
- [generating ssl for websites](https://www.digitalocean.com/community/tutorials/how-to-create-a-ssl-certificate-on-nginx-for-ubuntu-12-04)
- [configuring nginx ssl](https://www.digicert.com/ssl-certificate-installation-nginx.htm)
