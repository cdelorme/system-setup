
# web

This document extends my [template](template.md) instructions, and you should review them first.

These instructions are intended for use to create a bare-bones web & proxy server.  _Additional services can be installed and configured afterwards (such as nodejs, php, etc)._

In my case I've moved away from almost all personal projects that involve a high degree of complication, so I don't include extra software in my configuration.


## services

This document will primarily cover creating folders and groups to keep and serve contents from in a manageable way.  The individual service documentation has been made separate.

Key utilities that will be covered:

- [nginx](web/nginx.md)
- [monit](http://mmonit.com/monit/)

_We will assume that `monit` has already been installed, given that we are working off of the template._  For a server it makes more sense to use something like `monit` to watch for whether services cease to run or begin behaving erratically, and either notify the maintainer or restart them automatically.

Supplemental services that you can review at your leisure:

- [ssl-ceritifcates](web/ssl-certificates.md)
- [bare git repositories](web/bare-git-repositories.md)
- [mongodb](web/mongodb.md)
- [php-fpm](web/php-fpm.md)
- [mariadb](web/mariadb.md)
- [msmtp mail server](web/msmtp.md)

All web services should run through nginx as a proxy and cache service, and it is especially efficient for static website delivery.


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

I recommend using [bare git repositories](web/bare-git-repositories.md) for servers.


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
        create 644 root adm
    }

This finds any `.log` files inside `logs/` folders inside `/srv/www` paths (for example `/srv/www/example.com/logs/`).

The configuration will keep the maximum size below 300k, and rotate it in sets of 3 files at a time.  The second oldest will always be compressed, giving you two files to search through.  It will run daily unless that size limit is exceeded.

Because nginx is connected to the file it logging to we use `copytruncate` to keep the file in-place and simply copy it's records elsewhere.  _This copy process can result on lost messages if they occur during the logrotate copy, but because our max size is small it should never occur (or at least very rarely)._


# references

- [sticky-bits](http://unix.stackexchange.com/questions/64126/why-does-chmod-1777-and-chmod-3777-both-set-the-sticky-bit)
- [modifying deb postinst dpkg packaging](https://yeupou.wordpress.com/2012/07/21/modifying-preinst-and-postinst-scripts-before-installing-a-package-with-dpkg/)
- [nginx optimization tips](http://tweaked.io/guide/nginx/)
- [generating ssl for websites](https://www.digitalocean.com/community/tutorials/how-to-create-a-ssl-certificate-on-nginx-for-ubuntu-12-04)
- [configuring nginx ssl](https://www.digicert.com/ssl-certificate-installation-nginx.htm)
