
# mariadb

The developers of mysql moved to mariadb, a (mostly) backwards compatible fork of mysql, after it had been taken over by oracle.

Installation requires adding a third-party repository.

**MariaDB Sources:**

Register the key & add their repository:

    apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db
    echo "deb http://nyc2.mirrors.digitalocean.com/mariadb/repo/5.5/debian wheezy main" > /etc/apt/sources.list.d/mariadb.list
    echo "deb-src http://nyc2.mirrors.digitalocean.com/mariadb/repo/5.5/debian wheezy main" >> /etc/apt/sources.list.d/mariadb.list
    aptitude clean
    aptitude update

**Pinning Sources (_for dotdeb users_):**

If you are using the [dotdeb repository](dotdeb.md), then you may encounter conflicting packages, and need to add pinnging to `/etc/apt/preferences.mariadb` to override that:

    echo "Package: libmysqlclient18" > /etc/apt/preferences.d/mariadb
    echo "Pin: origin nyc2.mirrors.digitalocean.com" >> /etc/apt/preferences.d/mariadb
    echo "Pin-Priority: 900" >> /etc/apt/preferences.d/mariadb

**debconf modifications for unattended install:**

If you are attempting an unattended install you will need to modify debconf selections to override the password entry prompt:

    echo 'mariadb-server-5.5 mysql-server/root_password password ""' | debconf-set-selections
    echo 'mariadb-server-5.5 mysql-server/root_password_again password ""' | debconf-set-selections

_In recent attempts I found that an empty string may fail, so to work around this the alternative is to set it to something, like this:_

    echo "mariadb-server-5.5 mysql-server/root_password password root" | debconf-set-selections
    echo "mariadb-server-5.5 mysql-server/root_password_again password root" | debconf-set-selections

**Installation:**

    aptitude install mariadb-server

Post install you may want to tune it, but I don't have any documentation or advice in that area.

If you used the debconf settings but could not use an empty string you can change the password to an empty string via:

    mysql -uroot -proot -e "SET PASSWORD = PASSWORD('');"


## monit

You may want to add this to your monit scripts at `/etc/monit/monitrc.d/mariadb`:

    check process mysqld with pidfile /var/run/mysqld/mysqld.pid
        start program = "/etc/init.d/mysql start"
        stop program = "/etc/init.d/mysql stop"
        group www-data
        if cpu > 90% for 5 cycles then restart
        if memory > 80% for 5 cycles then restart
        if 3 restarts within 8 cycles then timeout


## securing post-installation

The following lines roughly reproduce the steps of running `mysql_secure_installation` after installing:

    mysql -u root -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
    mysql -u root -e "DELETE FROM mysql.user WHERE User='';"
    mysql -u root -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';"
    mysql -u root -e "FLUSH PRIVILEGES;"

_I am not as concerned about login access as I am about table and remote access security._  By restricting access to local only for root, then the same barrier they have to accessing your code is in place (usually ssh).


## personal bias

Recent history of experience with both mariadb and mysql have shown both to be somewhat unstable and resource hungry, even under moderately small loads, and in spite of every attempt to tune them.

With the advent of databases that store any content and organize it by page instead of a type-restricted normalized form, I haven't had a need for relational databases in recent projects.


## iptables

Like `mysql`, the `mariadb` package runs on port 3306, so this line will enable external access to the dbms if you wanted to host it separately or grant access to it over the network:

    -A INPUT -p tcp -m tcp --dport 3306 -m conntrack --ctstate NEW -j ACCEPT


# references

- [mariadb.sh](../../../scripts/linux/web/mariadb.sh)
- [installation instructions](https://downloads.mariadb.org/mariadb/repositories/#mirror=ut-austin&distro=Debian&distro_release=wheezy&version=5.5)
