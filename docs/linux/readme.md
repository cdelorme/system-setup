
# debian

This is my favorite linux distribution, both by familiarity and by functionality.

It is an incredibly solid OS for just about any kind of stable server configuration, whether serving files, website content, database content, or just storing logs, it is hands down one of the best fully-featured systems with great support, documentation, a vast community, and near-infinite list of packages.

Oddly I have found that neither Ubuntu or the Debian base Mint projects to satisfy my OS needs.  However, if you want a totally kickass distribution that is preconfigured without any of the nonsense in my documentation I highly recommend [Crunchbang](http://crunchbang.org/).  It is another totally awesome distribution based on Debian with a lightweight "get shit done" interface.  I went my own route for education and software preferences; afterall linux is about options.

I have been using debian since June 2003, and for many years used it exclusively without ever touching another linux distro.  My experience with debian may have led to a biased opinion, and if you are still on the fence you should certainly checkout fedora (for desktops) or centos (for servers) as a sound alternative.

A result of that experience means that almost all of my documentation for linux will be written for debian, but it should be (mostly) portable with a few changes to other releases.

## personal preferences

I have a lot of preferences.  Especially towards low resource consumption, lightweight packages and software, performance, and especially function.

In the past I'd used whatever GUI came with the platform for desktops, and gone headless for servers.  These days I use openbox as my window manager, and a myriad of hand-picked packages to go alongside it.

I am not tied to any particular version of debian, though my instructions will likely have been written for whichever is the current stable release.  Be sure to check the dates on my documentation and find the stable version at that time before assuming these instructions will work.


## currently active documentation

- [template](template.md)
- [web](web.md)
- [communications](comm.md)
- [gui](gui.md)

I had historically written documentation for Xen, but the upkeep for experimentation and rebuilding was too much and I have taken a break.  I may resume working with Xen in the future.

The web server is intended as a guideline for an nginx configuration, with additional instructions for php and nodejs.

The communications server targets the realm of samba file sharing, raid drives, an irc server, and torrent server.

The gui documentation is a custom mix of base desktop graphical interface packages and a myriad of software I use to get work done.
