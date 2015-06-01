
# transmission

An excellent torrent client, which has a headless mode, and easier configuration that `rtorrent`!


## installation

To install transmission as a daemon:

    aptitude install -ryq transmission-daemon

You may also install the gtk & qt interfaces:

    aptitude install -ryq transmission-gtk transmission-qt

_I generally don't use the UI, since I run it as a daemon._


## configuration

With transmission-daemon, we will automatically start up a torrent server with our system.

I have created a [preferred configuration](../data/etc/transmission-daemon/settings.json), but you are welcome to deviate as needed.

I chose to remove the whitelist by setting it to a wildcard, you may choose to do otherwise.  However, the port it runs on can be controlled by iptables, which is my preference for this particular service.

_To make changes to the `settings.json` file you must first stop the transmission-daemon, or it will overwrite those changes with the settings of the running daemon at shutdown._


## [iptables](../data/etc/iptables/iptables.rules)

You will want to add these rules to your iptables to allow traffic:

    # tranmission peer traffic
    -A INPUT -p udp -dport 51413 -j ACCEPT

    # secured transmission web interface (9091 default)
    -A INPUT -p tcp -s 10.0.1.0/24 -dport 9091 -j ACCEPT

_The second rule is optional, and dependent on your choice of transmission web interface port and whether you want to restrict access to the local network only, by restricting the range (in my case 10.0.1.0)._


## monit

If you intend to run transmission as a daemon, you will probably want to add a monit configuration file at `/etc/monit/conf.d/transmission-daemon` with:

    check process transmission-daemon match transmission-daemon
        start program = "/etc/init.d/transmission-daemon start"
        stop program = "/etc/init.d/transmission-daemon stop"
        if cpu usage > 80% for 15 cycles then restart
        if mem usage > 80% for 30 cycles then restart

_You may also consider adding the `debian-transmission` user to any additional groups for files it may need to access, such as a shared drive._
