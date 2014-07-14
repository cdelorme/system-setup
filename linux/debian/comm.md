
# comm server documentation
#### updated 2014-7-13

This documentation picks up where the template documentation leaves off, and is intended to work as a headless system.


## install packages

Here are the packages:

    aptitude clean
    aptitude update
    aptitude install -ryq samba samba-tools smbclient mdadm weechat-curses g++ libnetfilter-queue-dev zlib1g-dev libpcre3-dev libnetfilter-queue1 libnfnetlink0 transmission-daemon


## system configuration

We want to add a couple of new rules to our IPTables to allow Samba connections:

    # Samba Traffic (limited to internal network)
    -A INPUT -p udp -s 10.0.1.0/24 -m multiport --dports 137,138 -j ACCEPT
    -A INPUT -p tcp -s 10.0.1.0/24 -m multiport --dports 139,445 -j ACCEPT

    # tranmission peer traffic
    -A INPUT -p udp -dport 51413 -j ACCEPT

    # secured transmission web interface
    -A INPUT -p tcp -s 10.0.1.0/24 -dport 9010 -j ACCEPT

_It is highly recommended to use the intranet network address to ensure your services remain accessible only within a secure zone._


**Monit Additions:**

We will want to add monit configurations for samba and ipblock.  Ideally we want samba not to lockup, and to restart if it crashes, and we simply want ipblock to be running at boot time.

Add `/etc/monit/conf.d/samba` with:

    check process samba match smdb
        start program = "/etc/init.d/samba start"
        stop program = "/etc/init.d/samba stop"
        group sambashare
        if cpu usage > 80% for 15 cycles then restart
        if mem usage > 80% for 30 cycles then restart

Add `/etc/monit/conf.d/transmission-daemon` with:

    check process transmission-daemon match transmission-daemon
        start program = "/etc/init.d/transmission-daemon start"
        stop program = "/etc/init.d/transmission-daemon stop"
        group sambashare
        if cpu usage > 80% for 15 cycles then restart
        if mem usage > 80% for 30 cycles then restart


## configuring raid

I chose software raid, mdadm, as it provides the greatest flexibility, without relying on hardware which may or may not be available on the market in a few years.  It is compatible cross platform, and easily recoverable, and the performance difference with multicore systems is negligable.


**Understanding RAID:**

I have found that a large portion of the populace fails to understand how to benefit from RAID, and a lot of gamers expecially will go strait for RAID 0.

RAID 0 provides doubled write speeds and provides full drive space by splitting data across two or more disks.  While the full drive space is appealing for cost reasons, the increased write speed is only beneficial during installations or write heavy operations.  Most software and games are read-heavy post installation, which means read speed is of greater importance.  While read speeds are slightly increased calculations must determine which disk what content is on, which really kills the theoretical gain of two read-heads.

RAID 1 is the better approach because it has a higher likelyhood of delivering on the higher read speeds, at the cost of halfed disk space.

RAID 5 gives you parity to repair data on disk loss without devoting 50% of your storage to parity, and while useful is not great for high performance.

My personal favorite is RAID 10; requiring a minimum of 4 disks required it performs both mirroring and spanning.  In practice this gives you up to 4 read-heads and 2 write-heads, all of which can operate in parallel.  The best part is you can continue to increase its performance by adding disks in sets of 2 (4+2, 6x read, 3x write).  8 Disk RAID 10's have been known to outperform SATAII SSD's, which is rather exceptional.


**Creating a RAID10 MDADM Array:**

Identify the drives in `/dev` (generally sd*).

Start by taking the four drives and giving them partitions (in my case gpt lvm partitions):

    parted /dev/sda
    mklabel gpt
    mkpart lvm 0% 100%

Rinse and repeat for all four.  Then let's turn them into a working array:

    mdadm -v --create /dev/md0 --level=raid10 --raid-devices=4 /dev/sda1 /dev/sdb1 /dev/sdc1 /dev/sdd1

After that it will take a few hours for `/proc/mdstat` to finished setup.  You do not want to touch it before the synchronization is finished.  For me this took eight hours.  _In some cases it will not begin synchronizing.  If it says resync pending, you can force the synchronization via `mdadm --readwrite /dev/md0`._


**Mapping Folders:**

Since I will be sharing the contents here through samba, I tend to create a simple default mount point at `/media/samba` for a variety of folders:

    mkdir -p /media/samba
    cd /media/samba
    mkdir media games software backups torrents documents

I create LV's of appropriate sizes to match the above folders, and format them as ext4:

    lvcreate -L #G -n name group
    mkfs -t ext4 /dev/mapper/group-name

_Rinse & repeat for X LV's._

Finally I add records to `/etc/fstab` to mount them at boot time:

    # Samba Shares
    /dev/mapper/raid-backups    /media/samba/backups    ext4  defaults  0  0
    /dev/mapper/raid-documents  /media/samba/documents  ext4  defaults  0  0
    /dev/mapper/raid-games      /media/samba/games      ext4  defaults  0  0
    /dev/mapper/raid-media      /media/samba/media      ext4  defaults  0  0
    /dev/mapper/raid-software   /media/samba/software   ext4  defaults  0  0
    /dev/mapper/raid-torrent    /media/samba/torrent    ext4  defaults  0  0

_If you want added data reliability you could technically change the 0 to a 1 in the last column to perform a chkdsk at boot time, but this can cut into the boot times and is better left as a cronjob._


## samba configuration

My samba configuration (`/etc/smb/smb.conf`) looks like this:

    #======================= Global Settings =======================

    [global]

    # Naming
        workgroup = WORKGROUP
        server string = %h server
        netbios name = comm

    # Eliminate Printing
        load printers = no
        printing = bsd
        printcap name = /dev/null
        disable spoolss = yes

    # Security
        invalid users = nobody guest root
        encrypt passwords = true
        passdb backend = tdbsam
        obey pam restrictions = yes
        unix password sync = yes
        passwd program = /usr/bin/passwd %u
        passwd chat = *Enter\snew\s*\spassword:* %n\n *Retype\snew\s*\spassword:* %n\n *password\supdated\ssuccessfully* .
        pam password change = yes
        panic action = /usr/share/samba/panic-action %d
        syslog = 6
        log file = /var/log/samba/log.%m
        max log size = 1000
        disable netbios = yes

    # Optimizations
        bind interfaces only = yes
        interfaces = eth0
        socket options = TCP_NODELAY IPTOS_LOWDELAY SO_RCVBUF=65536 SO_SNDBUF=65536 SO_KEEPALIVE
        deadtime = 15
        getwd cache = yes
        dns proxy = no
        max connections = 30
        use sendfile = yes
        write cache size = 16384
        aio write size = 524288
        aio read size = 524288

    #======================= Share Definitions =======================

    [backups]
        create mask    = 0660
        directory mask = 0770
        group          = sambashare
        path           = /media/samba/backups
        read list      = @sambashare
        write list     = cdelorme

    [media]
        create mask    = 0660
        directory mask = 0770
        group          = sambashare
        path           = /media/samba/media
        read list      = @sambashare
        write list     = cdelorme

    [torrents]
        create mask    = 0660
        directory mask = 0770
        group          = sambashare
        path           = /media/samba/torrents
        read list      = @sambashare
        write list     = cdelorme

    [games]
        create mask    = 0660
        directory mask = 0770
        group          = sambashare
        path           = /media/samba/games
        read list      = @sambashare
        write list     = cdelorme

    [software]
        create mask    = 0660
        directory mask = 0770
        group          = sambashare
        path           = /media/samba/software
        read list      = @sambashare
        write list     = cdelorme

    [documents]
        create mask    = 0660
        directory mask = 0770
        path           = /media/samba/documents
        write list     = cdelorme

I won't go through all the details here, suffice to say there is a lot of stuff I would have to explain and most of this was achieved through trial and error not a comprehensive personal understanding.

The [official documentation](http://www.samba.org/samba/docs/) is actually incredibly detailed and a great resource.


## weechat configuration

Next using a registered account on freenode, let's configure weechat:

    /set irc.server.freenode.nicks "username, username_"
    /set irc.server.freenode.password "password"
    /set irc.server.freenode.autoconnect on
    /set weechat.history.max_buffer_lines_number 0
    /save
    /quit

With these changes you should now have infinite history.  You will be automatically connected to freenode at boot, and it will verify your identity with NickServ.

_This content will be moved to a separate file soon._


## torrent configuration

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

_If changes are made to the settings.json file while transmission-daemon is running it will overwrite it when restarted.  You have to follow special instructions to reload the config, and it is probably easier to stop the service before editing the file the first time._
