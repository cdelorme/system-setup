
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

The configuration file can be found in `/etc/transmission-daemon/settings.json`, and is in JSON format.  Here are my recommended settings:

    {
        "alt-speed-down": 50,
        "alt-speed-enabled": false,
        "alt-speed-time-begin": 540,
        "alt-speed-time-day": 127,
        "alt-speed-time-enabled": false,
        "alt-speed-time-end": 1020,
        "alt-speed-up": 50,
        "bind-address-ipv4": "0.0.0.0",
        "bind-address-ipv6": "::",
        "blocklist-enabled": false,
        "blocklist-url": "http://www.example.com/blocklist",
        "cache-size-mb": 4,
        "dht-enabled": true,
        "download-dir": "/tmp",
        "download-limit": 100,
        "download-limit-enabled": 0,
        "download-queue-enabled": true,
        "download-queue-size": 5,
        "encryption": 2,
        "idle-seeding-limit": 60,
        "idle-seeding-limit-enabled": true,
        "incomplete-dir": "/tmp",
        "incomplete-dir-enabled": true,
        "lazy-bitfield-enabled": true,
        "lpd-enabled": false,
        "max-peers-global": 200,
        "message-level": 2,
        "peer-congestion-algorithm": "",
        "peer-limit-global": 240,
        "peer-limit-per-torrent": 60,
        "peer-port": 51413,
        "peer-port-random-high": 65535,
        "peer-port-random-low": 49152,
        "peer-port-random-on-start": false,
        "peer-socket-tos": "default",
        "pex-enabled": true,
        "port-forwarding-enabled": false,
        "preallocation": 1,
        "prefetch-enabled": 1,
        "queue-stalled-enabled": true,
        "queue-stalled-minutes": 30,
        "ratio-limit": 2,
        "ratio-limit-enabled": true,
        "rename-partial-files": true,
        "rpc-authentication-required": true,
        "rpc-bind-address": "0.0.0.0",
        "rpc-enabled": true,
        "rpc-password": "anything-turns-into-hash-on-first-run",
        "rpc-port": 9010,
        "rpc-url": "/bt/",
        "rpc-username": "username",
        "rpc-whitelist": "*",
        "rpc-whitelist-enabled": true,
        "scrape-paused-torrents-enabled": true,
        "script-torrent-done-enabled": false,
        "script-torrent-done-filename": "",
        "seed-queue-enabled": false,
        "seed-queue-size": 10,
        "speed-limit-down": 3000,
        "speed-limit-down-enabled": true,
        "speed-limit-up": 80,
        "speed-limit-up-enabled": true,
        "start-added-torrents": true,
        "trash-original-torrent-files": false,
        "umask": 2,
        "upload-limit": 100,
        "upload-limit-enabled": 0,
        "upload-slots-per-torrent": 14,
        "utp-enabled": true,
        "watch-dir-enabled": true
    }

I chose to remove the whitelist by setting it to a wildcard, you may choose to do otherwise.  However, the port it runs on can be controlled by iptables, which is my preference for this particular service.

_To make changes to the `settings.json` file you must first stop the transmission-daemon, or it will overwrite those changes with the settings of the running daemon at shutdown._


## iptables

You will want to add these rules to your iptables to allow traffic:

    # tranmission peer traffic
    -A INPUT -p udp -dport 51413 -j ACCEPT

    # secured transmission web interface
    -A INPUT -p tcp -s 10.0.1.0/24 -dport 9010 -j ACCEPT

_The second rule is optional, and dependent on your choice of transmission web interface port and whether you want to restrict access to the local network only, by restricting the range (in my case 10.0.1.0)._


## monit

If you intend to run transmission as a daemon, you will probably want to add a monit configuration file at `/etc/monit/conf.d/transmission-daemon` with:

    check process transmission-daemon match transmission-daemon
        start program = "/etc/init.d/transmission-daemon start"
        stop program = "/etc/init.d/transmission-daemon stop"
        if cpu usage > 80% for 15 cycles then restart
        if mem usage > 80% for 30 cycles then restart

_You may also consider changing the group that transmission runs as, as a daemon, so that access privileges remain sane.  In my case I have an mdadm samba share and add `group sambashare` to my monit configuration._
