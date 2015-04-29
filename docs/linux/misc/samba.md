
# samba

A file sharing solution that is cross-platform compatible, and very easy to both setup and secure.

_I no-longer use `samba` for file sharing, and so this document may no longer be maintained.  Follow it at your own risk._


## installation

We want to install the samba service plus some additional tools for management and access:

    aptitude install -ryq samba samba-tools smbclient


## iptables

We will need to add these to our iptables rules for traffic:

    # Samba Traffic (limited to internal network)
    -A INPUT -p udp -s 10.0.1.0/24 -m multiport --dports 137,138 -j ACCEPT
    -A INPUT -p tcp -s 10.0.1.0/24 -m multiport --dports 139,445 -j ACCEPT

_Note that in my example I restricted access to only the 10.0.1.0 address range, which prevents anyone outside that range from accessing, including access from outside the network.  However, you shouldn't have those ports open on your router either._


## configuration

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


## monit

Since we want to keep it running, we should add a monit configuration to `/etc/monit/conf.d/samba` with:

    check process samba match smdb
        start program = "/etc/init.d/samba start"
        stop program = "/etc/init.d/samba stop"
        group sambashare
        if cpu usage > 80% for 15 cycles then restart
        if mem usage > 80% for 30 cycles then restart
