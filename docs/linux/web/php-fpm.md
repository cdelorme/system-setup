
# php-fpm

If you have not already, it is advisable that you prepare the [dotdeb repository](dotdeb.md).

To install the packages:

    aptitude install -ryq php5 php5-fpm php5-cli php5-mcrypt php5-gd php5-mysqlnd php5-curl php5-xmlrpc php5-dev php5-intl php-pear php-apc php5-imagick php5-xsl

This installs php5, plus a number of dependent packages we may use for a number of other purposes.


## configuring php-fpm

**Timezone:**

We want to modify `/etc/php5/fpm/php.ini` to set your [timezone](http://php.net/manual/en/timezones.php):

    date.timezone = America/New_York


**Development Error Output:**

By default PHP5-FPM is configured to silence error output for production, but if you are running a development server and wish to see these errors from the browser to debug and correct them you will need to modify a line in `/etc/php5/fpm/php.ini`:

    display_errors = On


**PHP File Uploads:**

By default PHP allows 2 Megabytes at most, which is tiny by todays standards, so let's increase it:

    upload_max_filesize = 32M

Remember, you can enforce upload sizes in other ways, this simply makes it require less tweaking in the service itself.


**Install Composer Globally:**

Execute these commands to install Composer globally:

    curl -sS https://getcomposer.org/installer | php
    mv composer.phar /usr/local/bin/composer


**Add pecl Packages:**

If you want to connect to mongodb or graphics magick, among other things, then you will need to use `pecl` to do so.

    pecl install gmagick
    pecl install mongo

Next we need to tell php to load these modules.  We can do so the "proper" way by creating `/etc/php5/mods-available/gmagick.ini` and `/etc/php5/mods-available/mongodb.ini` with their extentions like so:

    echo "extension=gmagick.so" > /etc/php5/mods-available/gmagick.ini
    echo "extension=mongo.so" > /etc/php5/mods-available/mongodb.ini

Finally we can symlink these into `/etc/php5/conf.d`, and reboot php-fpm for the changes to take affect:

    ln -sf ../mods-available/gmagick.ini /etc/php5/conf.d/gmagick.ini
    ln -sf ../mods-available/mongodb.ini /etc/php5/conf.d/mongodb.ini
    service php5-fpm restart


## optimization

Optimization can be tricky, and ideally you should optimize late instead of make it the focus of your build.  Further, optimization should match the services you are delivering.  There are two approaches you can take.

1. If you have an existing web service with statistics on requests per second you should optimize by traffic (this is the best approach because it lets you know whether you should be upgrading or downgrading your equipment).

2. If you have a fixed amount of equipment and a brand new service you can optimize the systems resources to that service.

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


**My preferences:**

Here are the settings I stick with:

    pm.max_children = 25
    pm.start_servers = 2
    pm.min_spare_servers = 2
    pm.max_spare_servers = 5
    pm.max_requests = 500

This tends to be plenty for development and testing, but obviously I would do the ground-work above if I wanted to make sure it was tailored to the service I was building.

Finally, after all of the above changes, we can try rebooting php-fpm, if it works we are all set, and we can verify the changes with phpinfo from nginx.

    service php5-fpm restart


## nginx script

To make it easier to process php files from multiple virtual-hosts, I usually place a dynamic script in `/etc/nginx/scripts.d/php-fpm.conf` with script includes:

    # PHP Handler
    location ~ \.php$ {
        try_files $uri =404;
        include fastcgi_params;
        fastcgi_pass unix:/var/run/php5-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }

If you're already using the import line, then this will add php support without any additional steps, besides rebooting nginx anyways.


## monit

To ensure php continues running and doesn't kill your system you may want to add this to `/etc/monit/monitrc.d/php-fpm`:

    check process php5-fpm with pidfile /var/run/php5-fpm.pid
        start program = "/etc/init.d/php5-fpm start"
        stop program = "/etc/init.d/php5-fpm stop"
        group www-data
        if cpu > 90% for 5 cycles then restart
        if memory > 80% for 5 cycles then restart
        if 3 restarts within 8 cycles then timeout


# references

- [php composer](https://getcomposer.org/doc/00-intro.md#globally)
