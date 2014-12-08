
# [nginx](http://wiki.nginx.org/Main)

This is a proxy server, which can cache and deliver static files, or go between other applications running on the server.  It offers a myraid of extremely useful features, and uses a high performance event model.

This makes it leagues better than it's alternatives (apache, tomcat, iis).

It's lightweight, and has very simple configuration.


## installation

To install our new packages we want to add the [`dotdeb` repository](dotdeb.md), which will give us a more up-to-date version of nginx, since debian stability prevents newer versions.

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

## configuration and optimization

Our next goal is to configure and optimize nginx to serve content or websites from our `/srv/www` folders, as well as other running services (since it is a proxy server).

We'll want to remove the default site template and prepare an ssl directory and configuration plus script directories:

    rm /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
    mkdir -p /etc/nginx/ssl /etc/nginx/conf.d /etc/nginx/scripts.d

_This should let us organize our configuration files, and import them intelligently._

One wonderful thing about nginx is that it comes with completely sane defaults that will usually be performant without modification for your average website.  However, if you want to go the extra lengths to squeeze more out of your server, or if your working on an entirely different scale then you will want to change the defaults.


### optimizations

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


**You will want to visit my section on [ssl-certificates](ssl-certificates.md) for https support.**


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
        server_name www.example.com example.com example.com;
        return 301 https://www.example.com$request_uri;
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

We only need to add one line, but this is required to enable http and https traffic (it is also acceptable to use the strings "http,https" in place of "80,443", which can be more humanly readable):

    # Allow tcp traffic for  (HTTP, HTTPS)
    -A INPUT -p tcp -m multiport --dports 80,443 -m conntrack --ctstate NEW -j ACCEPT

_If you have additional services you want to run on non-standard ports, you will want to add additional rules to your iptables list._  Ideally you should use standard ports to avoid complications and increasing the number of entry-points.
