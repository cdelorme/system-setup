
# [nginx](http://wiki.nginx.org/Main)

This is a proxy server, which can both cache and deliver static files extremely fast, and also terminate ssl and pass messages to other running services (eg. databases and running services by port or socket).

It's very light weight, simple to configure, and has performance that is leagues ahead of apache, tomcat, and iis.


## installation

I recommend that you install the complete package with all plugins:

    aptitude install -ryq nginx-full


## configuration and optimization

Our next goal is to configure and optimize nginx to serve content or websites from our `/srv/www` folders, as well as other running services (since it is a proxy server).

We'll want to remove the default site template and prepare an ssl directory and configuration plus script directories:

    rm /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
    mkdir -p /etc/nginx/ssl /etc/nginx/conf.d /etc/nginx/scripts.d

_This should let us organize our configuration files, and import them intelligently._

One wonderful thing about nginx is that it comes with completely sane defaults that will usually be performant without modification for your average website.  However, if you want to go the extra lengths to squeeze more out of your server, or if your working on an entirely different scale then you will want to change the defaults.


### optimizations

The [global configuration](../data/extras/etc/nginx/nginx.conf) is very basic.  Be aware that when you update nginx it may ask whether to replace this file.

I place all global optimization scripts inside `/etc/nginx/conf.d`, and import them from the primary configuration:

- [charset.conf](../data/extras/etc/nginx/conf.d/charset.conf)
- [gzip.conf](../data/extras/etc/nginx/conf.d/gzip.conf)
- [servernamehash.conf](../data/extras/etc/nginx/conf.d/servernamehash.conf)
- [ssl.conf](../data/extras/etc/nginx/conf.d/ssl.conf)
- [tokens.conf](../data/extras/etc/nginx/conf.d/tokens.conf)
- [uploads.conf](../data/extras/etc/nginx/conf.d/uploads.conf)

Optional optimizations and settings on a per-site basis are added to `/etc/nginx/scripts.d`:

- [cache.conf](../data/extras/etc/nginx/scripts.d/cache.conf)
- [favicon.conf](../data/extras/etc/nginx/scripts.d/favicon.conf)
- [hidden.conf](../data/extras/etc/nginx/scripts.d/hidden.conf)

The separation of available and enabled sites allows you to keep the configuration of a site and quickly enable or disable any site by deleting or adding symbolic links.


### elaboration of settings

The `keepalive_timeout` is useful when serving a lot of dependencies per-page, by reducing the headers necessary for subsequent requests.  If you are serving a very large number of images, javascript, and css files then the default may be alright, but I turned it down to 15 from 65, which should be plenty.  _If you have a minimal number of css and js dependencies and serve images from a CDN it'd be worth considering turning it off to free up connections faster._

With these changes each worker will handle more connections, and have better concurrent processing (`multi_accept`) plus throughput (`epoll`).  The defaults nginx comes with are not only "sane" but also very performant, even on lesser machines such as virtual systems.  However if you have a high powered server you can probably increase the defaults quite a bit, and if you have heavy traffic you may also want to experiment with some of the optimizations I'm about to propose.

The highest compression level reduces bandwidth at the cost of more CPU necessary to translate the response.  For desktops this is almost always a net-gain, but it becomes a concern with mobile devices.  Mobile devices are great at handling bursty loads, but have much less powerful CPU's, making compression a negative for mobile users.  _While my implementation does not change according to mobile usage, you may consider moving the gzip file into `scripts.d/` and making it optional dependent on mobile-access._

I highly recommend setting utf8 (or utf16) consistently acroess you entire application.

Long domain names can actually break identification, and I have run into this problem, so I suggest increasing the server name hash size.

Turning off server tokens is not for security, but rather to reduce the amount of content being sent during every http call.  It is a micro-optimization but it effects basically every communication going through nginx via http.

The default upload size with nginx is 1mb, which can conflict with proxied service limitations (eg. php's 2mb size).  The body buffer size is how much data before a temporary file is created, and increasing that can reduce disk IO thereby improving the speed at which uploads are handled.

By default you will log 404 errors for favicon files, so I added a bypass that disables logs when favicon.ico does not exist.  This has, in my experience, never broken a website, only decreased the amount of logged errors.

I highly recommend taking advantage of nginx caching, even if only for 5 minutes, any binary blobs or css and javascript you cache can dramatically reduce load times.  _If you're smart you probably already moved static files to a CDN to handle this._  More complicated caching can be enabled between proxied requests as well, but that's not a topic I'll cover here.

It's generally bad to allow anyone to access files or folders that start with a period, so you should always exclude those by hiding them from users (deny access, and disable logs).

**You will want to visit my section on [ssl-certificates](ssl-certificates.md) for https support.**  Usually I place these inside the `/etc/nginx/ssl/` path.


### virtual hosts

As they were called in `apache`, virtualhosts allow you to point multiple domain names to a single IP Address, and have a single port and server pass along requests accordingly.

With nginx you can create new hosts in `/etc/nginx/sites-available/`.

I have included a [good example](../data/extras/etc/nginx/sites-available/example.com) to get yor started.

It redirects http access to the https address, fixes missing prefix (www) for SEO purposes, and provides a decent example of how you might create an api proxy and also deliver static files under the same domain name.

Because no symlink to this file exists, you can simply copy it and leave the original as a reference in `sites-available/`.

Once you have a website you want to enable, you can do so via:

    ln -sf ../sites-available/example.com example.com

To verify your configuration is error-free, run `nginx -t` as root, then restart the nginx service to load the new system.


## iptables

We only need to add one line, but this is required to enable http and https traffic (it is also acceptable to use the strings "http,https" in place of "80,443", which can be more humanly readable):

    # Allow tcp traffic for  (HTTP, HTTPS)
    -A INPUT -p tcp -m multiport --dports 80,443 -m conntrack --ctstate NEW -j ACCEPT

_If you have additional services you want to run on non-standard ports, you will want to add additional rules to your iptables list._  Ideally you should use standard ports to avoid complications and increasing the number of entry-points.
