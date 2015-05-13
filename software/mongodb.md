
# mongodb

If you want a good modern database engine that makes development a breeze, but still requires good consideration to create schema yet without all the type restrictions?  Then mongodb is probably a good pick.

It offers decent scalability without all the extra planning that might be required of a mysql solution, though it isn't perfect itself it is very performance and much better for modern application development.


## why mongodb

**One of the major crossroads is to ask why you care so much about data integrity.**

In the past, the major concern was disk space.  Integrity ensured that duplicate content did not exist in multiple places, in context to a single record.  This practice also ensured that the data you pulled was consistent, which was an added benefit.

However, if you look at relational a database schema and then the website that gets generated using the data in that database, do you still recognize the data?  Changes are for anything even moderately complex you wouldn't.

With mongodb you can craft your data storage to match how your page displays.  Imagine if a single call to your database was all it took to get all the data for one page.  That's the objective of mongodb.

You have the power to choose whether to favor data integrity over ease of access and performance.  The effects of "eventual consistency" with mongodb are really no different than what happens when you have poor cache invalidation.

It also helps move us away from having "code in the database", things like triggers and data enforcement which lead to poor wrapper code, which leads to secondary injection, slow adaptation to rapidly changing code, and unpredictable behavior for anyone who isn't the database administrator.


## installing mongodb

By default debian wheezy (current stable) comes with version 2.0.x, and the latest stable is 2.6.x.  While you can install the `mongodb` package, it may be wise to add the mongodb repository and install the latest version.  There are many performance improvements and features introduced in the newer version.

**Adding mongodb-org repository:**

Let's start by adding their key:

    apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10

Next we'll add their sources:

    echo 'deb http://downloads-distro.mongodb.org/repo/debian-sysvinit dist 10gen' > /etc/apt/sources.list.d/mongodb.list

Now we wipe and reload aptitude packages:

    aptitude clean
    aptitude update

Finally, we can install the mongodb-org package:

    aptitude install -ryq mongodb-org

There are no special steps post-install.  By default it runs on port 27017.  A web status is run on port 28017 as well.  There is no password when accessing, nor do you need to supply a default username.  **If you have a sizable dataset it is recommended that you modify the configuration to update the mongodb storage path.**

The configuration file is `/etc/mongodb.conf`, and the default storage path is `/var/lib/mongodb/`.  The daemon configuration is at `/etc/mongod.conf`, and if you are sharding or doing anything complicated you will probably need to take a look at it.

_If you have concerns about version pinning, I recommend you check the official documentation for details._


## monit

A monit file can keep the mongodb daemon running.  Add this to `/etc/monit/monitrc.d/mongod`:

    check process mongod with pidfile /var/run/mongod.pid
        start program = "/etc/init.d/mongod start"
        stop program  = "/etc/init.d/mongod stop"
        group www-data
        if cpu > 80% for 5 cycles then restart
        if memory > 80% for 5 cycles then restart
        if 3 restarts within 8 cycles then timeout

Then symlink it to `/etc/monit/conf.d` and restart monit:

    ln -nsf ../mongorc.d/mongod /etc/monit/conf.d/mongod
    monit -t && service monit restart


# references

- [mongodb.sh](../../../scripts/linux/web/mongodb.sh)
- [mongodb instructions](http://docs.mongodb.org/manual/tutorial/install-mongodb-on-debian/)
- [mongodb ports](http://docs.mongodb.org/manual/reference/default-mongodb-port/)
