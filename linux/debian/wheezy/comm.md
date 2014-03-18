
# Comm Server Documentation
#### Updated 2013-10-14

This documentation picks up where the template documentation leaves off.  It expects all tools, but no GUI environment.

**This documentation is no-where near a finished state, and following it blindly would be a very bad idea.  Incoming changes such as the ip filtration tool switching from iplist/ipblock to peerguardian, as well as a potentially new torrent server software will be some of the largest incoming changes.  These will affect the installed packages and monit configuration, as well as their respective documentation.  Also my samba configuration is not well documented which I hope to improve on going forward.**


## Install Packages

We'll start right away with getting the packages we will be using installed.

Add a new key for peerguardian:

    gpg --keyserver keyserver.ubuntu.com --recv-keys C0145138
    gpg --export --armor C0145138 | sudo apt-key add -

Then add these to `/etc/apt/sources.list`:

    deb http://moblock-deb.sourceforge.net/debian wheezy main
    deb-src http://moblock-deb.sourceforge.net/debian wheezy main

Install the new packages:

    aptitude clean
    aptitude update
    aptitude install -y samba samba-tools mdadm pgld pglcmd weechat-ncurses g++ libnetfilter-queue-dev zlib1g-dev libpcre3-dev libnetfilter-queue1 libnfnetlink0

_Some packages included here are subject to change with the addition of peergaurdian._


## System Configuration

We want to add a couple of new rules to our IPTables to allow Samba connections:

    # Samba Traffic
    -A INPUT -p udp -s 10.0.1.0/24 -m multiport --dports 137,138 -j ACCEPT
    -A INPUT -p tcp -s 10.0.1.0/24 -m multiport --dports 139,445 -j ACCEPT


**Monit Additions:**

We will want to add monit configurations for samba and ipblock.  Ideally we want samba not to lockup, and to restart if it crashes, and we simply want ipblock to be running at boot time.

Add `/etc/monit/conf.d/samba.conf` with:

    check process smbd with pidfile `/run/samba/smdb.pid`
        start program = "/etc/init.d/smbd start"
        stop program = "/etc/init.d/smbd stop"
        group samba
        if cpu usage > 80% for 15 cycles then restart
        if mem usage > 80% for 30 cycles then restart

**Plans to replace ipblock with peergaurdian, and the lack of a pid for ipblock has left me without a monit solution.  I will update this as soon as I get peergaurdian setup.**

_If you have a torrent service or global weechat instance you may also create configurations for them._


## Configuring RAID

I chose software raid, mdadm, as it provides the greatest flexibility, without relying on hardware which may or may not be available on the market in a few years.  It is compatible cross platform, and easily recoverable, and the performance difference with multicore systems is negligable.


**Understanding RAID:**

I have found that a large portion of the populace fails to understand how to benefit from RAID, and a lot of gamers expecially will go strait for RAID 0.

RAID 0 provides doubled write speeds and provides full drive space by splitting data across two or more disks.  While the full drive space is appealing for cost reasons, the increased write speed is only beneficial during installations or write heavy operations.  Most software and games are read-heavy post installation, which means read speed is of greater importance.  While read speeds are slightly increased calculations must determine which disk what content is on, which really kills the theoretical gain of two read-heads.

RAID 1 is the better approach because it has a higher likelyhood of delivering on the higher read speeds, at the cost of halfed disk space.

I used to like RAID 5, but parity bit calculation with software RAID and LVM (on Xen or otherwise) cuts the actual disk performance by a significant margin, enough that the cost of an extra disk to create RAID 10 is reasonable.

RAID 10 with four disks will give you 2 disks of space, but gives you full parity, as well as four read heads and two write heads, with the actual gains being only slightly below theoretical gains.  Additionally as you add disk pairs to a RAID 10 performance jumps even further, making it easily one of the best choices if you can afford the disks.

**A RAID 10 with 8+ 7200 RPM disks can compete with speeds seen on modern SSD's (for bulk content, and probably not SATA III).**


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


## Samba Configuration

My samba configuration looks like this:

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


## Weechat Configuration

Next I configured weechat with my registered account.  I ran these commands:

    /set irc.server.freenode.command "/msg NickServ identify password"
    /set irc.server.freenode.nicks "username, username_"
    /set irc.server.freenode.autoconnect on
    /set weechat.history.max_buffer_lines_number 0
    /save
    /quit

This will give you infinite history, and connect your registered freenode account when it starts.


## Torrent Configuration

**This section is very incomplete and subject to several changes, including a switch to peerguardian command line and a better torrent service.**

Currently I have tested most headless torrent server software and found them to be rather incomplete or lacking in ease of configuration or access.  One of the best being rtorrent, which has an obscure mixture of dbus configuration options, with the added negative of inconsistent functionality and an apache-only web interface.  Not to mention the last update came nearly a year ago.

I intend to build my own going forward, but in preparation you will want to install the `iplist` package to prevent tracking using the ipblock feature it includes.

Start by grabbing the [latest version](http://sourceforge.net/projects/iplist/files/).  Building it is tough, so try to get the premade .deb file:

    wget "http://downloads.sourceforge.net/project/iplist/iplist/0.29/iplist_0.29-1~squeeze_amd64.deb?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fiplist%2Ffiles%2Fiplist%2F0.29%2F&ts=1381773636&use_mirror=softlayer-dal" -O iplist.deb
    dpkg -i iplist.deb

If you get an error that is pretty normal, just run `aptitude update && aptitude upgrade` and it should automatically resolve missing dependencies.

If you cat the `/etc/ipblock.lists` file, there are prefixes attached to the url's that are used to reference the lists the blocker will use.

In the `/etc/ipblock.conf` file there is a BLOCK_LIST variable set to a string with space delimited references to the prefixes.

Here is my chosen block list:

    level1.gz ads-trackers-and-bad-pr0n.gz edu.gz Microsoft.gz spyware.gz spider.gz bogon.gz badpeers.gz

Finally, to make sure to starts on boot, you may have to add it to insserv manually via:

    insserv ipblock


## References

- [2011 Ubuntu Torrent Server](http://www.the-little-things.net/blog/2011/09/11/linux-headless-ubuntu-torrent-home-server/)
