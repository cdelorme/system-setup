
# [dotdeb repository](http://www.dotdeb.org/)

**I used to use dotdeb repositories, but with the number of conflicts creating strife installing php components, mysql/mariadb, etc without conflicts breaking automation without quirky work-arounds I've decided to omit it from my standard practices.**

This is a separately maintained repository of web server software.

We need to add their key to our list:

    wget http://www.dotdeb.org/dotdeb.gpg
    cat dotdeb.gpg | apt-key add -
    rm dotdeb.gpg

Then we have to add them sources to `/etc/apt/sources.list.d/dotdeb.list`:

    deb http://packages.dotdeb.org wheezy all
    deb-src http://packages.dotdeb.org wheezy all

### [dotdeb.sh](../../../scripts/linux/web/dotdeb.sh)
