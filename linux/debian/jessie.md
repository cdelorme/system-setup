
# debian jessie

**I love debian.**

After trying a number of distributions (ubuntu, mint, fedora, centos, arch, etc...) I found myself coming back to debian every time for rock-solid stability and its familiar, agreeable, toolstack.

This document is a brief overview of how I install and configure my systems [via automation](debian-jessie.sh).


## [installation](#)

For best results, 512MB of RAM and 10GB of disk space are required for a desktop installation, not counting any files or software you add or execute; _If installed as a headless server you can expect 256MB of RAM and 1GB of disk to suffice, not counting any significant load your software may add to that._

From a net-install media, installation of only system utilities should take about 10 minutes from start to finish.  _I recommend using a [preseed](#) from a usb-installer._

I highly recommend using the [`btrfs`](software/btrfs.md) file system.  It replaces traditional LVM/ext4 combinations that provide shrink/expand functionality, as well as a myriad of other features.

All of my systems are installed on EFI capable hardware, which is also supported by virtualbox with appropriate [post-install instructions](virtualization/uefi-config.md).

I also recommend using [debian mirrors](http://http.debian.net/) for best package installation results.  It's a portable solution that will identify the closest mirrors when running the package manager.


## configuration

I have organized various [configuration files and fonts](data/) into folders that can be directly copied based on what is being installed.

- global configuration into `/etc/`
- [custom fonts](../software/fonts.md) into `/usr/share/fonts/`
- desktop application launchers into `/usr/share/applications/`
- helpful executables into `/usr/local/bin/`
- user configuration files into `/etc/skel`


## optimizations

I make a bunch of general optimizations to any system I provision, which includes:

- set lvm trim support via `issue_discards`
- set 022 as default UMASK in `/etc/login.defs` and `/etc/pam.d/common-session`
- set timezone to US/Eastern
- set grub to auto-reboot on kernel panic and use `nomodeset` to fix nvidia video
- optimize ssh to prevent DNS-related latency
- securing ssh to prevent root login and only accept ssh keys instead of passwords
- secure network by loading iptables with good defaults
- install my [dot-files](https://github.com/cdelorme/dot-files) globally
- install enhancements to vim and bash globally
- update locales and fonts and rebuild desktop applications list
- enabling watchdog to reboot unresponsive systems
- replace capslock with control (because honestly...)

_The original UMASK defaults come from before linux created a group per user, and is no-longer a necessary restriction.  To modify it reduces the overhead of sharing files between users later, especially when using stickybits._

Hardware specific changes are wrapped in conditions that look for that hardware first.


## cronjobs

There are two things I automate:

- package updates
- disk maintenance

With debain, you can rely on stable package updates plus a stream of security patches, so it's highly beneficial to automate these.  **If you have specific packages you are concerned about, you can use `aptitude hold` to prevent them and their dependencies from being modified.**  It is also possible to automate btrfs snapshots for rollbacks.

Whether you are using ext4 or btrfs, general disk maintenance are valuable to run daily or weekly.  _With ext4 file systems I would `e4defrag` and `fstrim`, and with btrfs I would `scrub`, `defragment`, and `balance`._

Some jobs are also setup for the provisioned user depending on software installed:

- automatically update authorized_keys from github
- automatically load torrents from `~/Downloads`

_Automatic key updates is the absolute best for retaining access to remote machines, although the current implementation is not flexible enough to add and revoke keys with multiple files and simply does a complete replacement._  If you need to trust keys that are not your own, you'll want to use another solution; for example aws s3 is an inexpensive alternative, but then you have to maintain the list somehow.


## software

I install various software, depending on the functionality of the system:

- weechat for irc
- transmission-daemon for torrents
- nginx for webserver and proxy functionality
- msmtp as a superior simple mail server
- openbox desktop environment with completely customized tooling
- sublime text for editing
- google chrome for browsing the web


## nginx

When `nginx` is installed I automatically configure folders and a basic permission structure around `/srv/` as the expected file path for serving content.

It is setup for loading and automating (bare) git repositories, as well as websites, including a logrotate file setup to recursively scan `/srv/www/`.

It also comes with a few files to setup sane-defaults for nginx configuration, both for static website files and proxying to pools of locally running services.


### desktop

**In my experience `openbox` is the best desktop environment.**

It has the smallest footprint among all solutions I've tested, no dependence on 3D Acceleration making it absolutely fabulous for virtualization, and its simplicity makes me more productive than I've ever been.

_The hotkey customization is also amazing, and is something I miss every time I go back to using a laptop running OSX._

My tooling includes:

- `feh` for background management cycling `~/Pictures/wallpaper`
- `urxvt` for a terminal and a guake-like dropdown script (`urxvtq`)
- numerous enhancements to X applications using `~/.Xdefaults`/`~/.Xresources`
- `pcmanfm` for file browsing
	- automount support for usb devices
	- thumbnailers for images and videos
- `conky` for system monitoring
- `mplayer` and `vlc` for video/audio playback

_This doesn't mention all the other useful things that get loaded in the background, but checkout my script if you want to know about all that._


## support

I have also created support documentation for:

- [ssl certificates](software/ssl-certificates.md)
- [bare git repositories](software/bare-git-repositories.md)
- [virtualbox console dimensions](software/grub-vm-resolution.md)
- [virtualbox networking](virtualization/virtual-network-adapters.md)
- **[gaming](gaming/)**


## notes

If you intend to do any kind of graphics development where framerate metrics are necessary, be aware that `Xorg.conf` has a setting called `SwapBuffersWait` which needs to be set to `false` to prevent builtin 60fps limits.


# references

It would be hardly fair to say I accomplished my script on my own; I obviously had help from ma great number of resources:

- [iptables securing ssh](http://www.rackaid.com/blog/how-to-block-ssh-brute-force-attacks/)
- [best practices 2010: "Don’t set the default policy to DROP"](http://major.io/2010/04/12/best-practices-iptables/)
- [reject > drop](http://unix.stackexchange.com/questions/109459/is-it-better-to-set-j-reject-or-j-drop-in-iptables)
- [reject & drop equally susceptible to DoS](http://www.linuxquestions.org/questions/linux-security-4/drop-vs-reject-685942/)
- [debian WhereIsIt reference doc](https://wiki.debian.org/WhereIsIt)
- [sticky-bits](http://unix.stackexchange.com/questions/64126/why-does-chmod-1777-and-chmod-3777-both-set-the-sticky-bit)
- [modifying deb postinst dpkg packaging](https://yeupou.wordpress.com/2012/07/21/modifying-preinst-and-postinst-scripts-before-installing-a-package-with-dpkg/)
- [nginx optimization tips](http://tweaked.io/guide/nginx/)
- [generating ssl for websites](https://www.digitalocean.com/community/tutorials/how-to-create-a-ssl-certificate-on-nginx-for-ubuntu-12-04)
- [configuring nginx ssl](https://www.digicert.com/ssl-certificate-installation-nginx.htm)
- [wallpapers wa](http://wallpaperswa.com/)
- [google repo info](https://www.google.com/linuxrepositories/)
- [google deb sources list](https://sites.google.com/site/mydebiansourceslist/)
- [volume management](http://urukrama.wordpress.com/2007/12/19/managing-sound-volumes-in-openbox/)
- [slim manual](http://slim.berlios.de/manual.php)
- [pipelight](https://launchpad.net/pipelight)
- [viewnior](https://github.com/xsisqox/Viewnior)
- [gmrun in openbox](http://naniland.wordpress.com/2011/10/25/alt-f2-on-openbox/)
- [openbox pulseaudio through amixer adjusted hotkeys](https://wiki.archlinux.org/index.php/openbox#Pulseaudio)
- [urxvt popup options](https://bbs.archlinux.org/viewtopic.php?id=57202)
- [urxvt kuake scripts](https://bbs.archlinux.org/viewtopic.php?id=71789&p=1)
- [urxvt geometry](https://bbs.archlinux.org/viewtopic.php?id=72515)
- [slim themes and testing](https://wiki.archlinux.org/index.php/SLiM#Theming)
- [inserting lines with sed](http://unix.stackexchange.com/questions/35201/how-to-insert-a-line-into-text-document-right-before-line-containing-some-text-i)
- [inserting with sed or awk](http://www.theunixschool.com/2012/06/insert-line-before-or-after-pattern.html)
- [openbox themes](http://capn-damo.deviantart.com/gallery/37736739/Openbox)
- [good documentation on customizing openbox](http://melp.nl/2011/01/10-must-have-key-and-mouse-binding-configs-in-openbox/)
- [another good resource](http://openbox.org/wiki/Help:Configuration)
- [list of actions](http://openbox.org/wiki/Help:Actions)
- [bindings for mouse](http://openbox.org/wiki/Help:Bindings#Mouse_bindings)
- [usb device connection](https://www.ab9il.net/linux/pcmanfm-usb-mount.html)
- [adding screenshot scripts](https://wiki.archlinux.org/index.php/Taking_a_screenshot)
- [getting active window coordinates](http://unix.stackexchange.com/questions/14159/how-do-i-find-the-window-dimensions-and-position-accurately-including-decoration)
- [disable capslock globally](http://emacswiki.org/emacs/MovingTheCtrlKey#toc9)
