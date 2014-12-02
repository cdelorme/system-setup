
# dotdeb repository

This is a separately maintained repository of web server software.

We need to add their key to our list:

    wget http://www.dotdeb.org/dotdeb.gpg
    cat dotdeb.gpg | apt-key add -
    rm dotdeb.gpg

Then we have to add them sources to `/etc/apt/sources.list.d/dotdeb.list`:

    deb http://packages.dotdeb.org wheezy all
    deb-src http://packages.dotdeb.org wheezy all

_The dotdeb repositories are a trusted and well maintained set of packages which are great for development and production use._
