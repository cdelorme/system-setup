
# debian

This document covers three phases across two final use-cases, where the first phase is an initial all-purpose configured state, installing universally _valued_ tools and defaults.


## resources

While purpose and functionality may vary, the initial design should work well with approximately 512MB of RAM, and the development environment should run fine with 1GB.  Obviously more is rarely bad, but assume those are minimum requirements if creating a virtual machine or minimalist system.


## post-install state

I used to use LVM and create explicitly separated partitions for logs and temporary files, but I've taken to using [`btrfs`](#) in recent systems.  Assuming a modern system with UEFI support, a separate EFI partition (generally FAT32) will be needed.

I only ever install `System Utilities` during package installation at install-time.

This brings us to [post-installation efi configuration](#), where we make sure the boot EFI folder matches standards, and contains an EFI shell for emergencies.









## all old documentation

The first thing I install is the `netselect-apt` package, which allows me to update the mirrors to use the lowest latency mirrors.  This can reduce the overall package installation time by as much as a few minutes when we install a large number of packages, such as a desktop environment.

**There is a bug where the package can return invalid mirrors, so you need logic to capture an error and fallback to the original sources file.**

Next I install remote connection utilities, such as screen and tmux, the full vim editor, many version control softwares, bash completion and command-not-found to locate missing software, compresison and decompression tools, service monitoring software, network time protocol, network resolution configuration, the sudo package, file system tools, network access and test utilities.

I almost always want all of these installed either for sheer convenience, to enhance the shell experience, access normal files, or to aid with troubleshooting common issues.

I schedule [daily](data/etc/cron.daily/) and [weekly](data/etc/cron.weekly/), which include:

- disk maintenance
- system updates

Often longer running tasks will be run weekly, and simple maintenance daily.

If there are packages you do not want updated simply use the `aptitude hold` command to prevent them from being upgraded, but the system should apply security patches and updates regularly.

_In the future, I want to use `btrfs` to snapshot states and allow easy rollbacks in the event of errors._

If you use lvm, and a solid state drive, then you will want to set `issue_discards` inside `/etc/lvm/lvm.conf`.

**While you may see folks recommend the `discard` flag in `/etc/fstab`, this is the least-efficient implementation, and you should instead run `fstrim` weekly to reduce the performance overhead.**

Modern distributions create groups for each user, but the default UMASK is `022`, which means groups only have read and execute access.  To make sharing files more convenient, I override the UMASK to `002` inside `/etc/login.defs` and also adding `session optional pam_umask.so umask=002` to `/etc/pam.d/common-session`.

If you use sticky-bits for shared groups after those changes, it becomes exceptionally easy to create a shared folder that automatically sets proper ownership of files for services or other users with the same groups to access.

I use [`monit`](data/etc/monit/monitrc.d/) configuration files to keep tabs on the system overall and restart services that crash.  _With the recent advent of systemd it may not be necessary in the near future, as systemd is able to perform these same functions._  The `web` configuration is required to be able to use `monit status`.

The system timezone is usually set by default automatically, but it uses file copies.  I usually the copied file with a symlink.

You can easily set the hostname in `/etc/hostname` and load that with `hostname -F /etc/hostname`.  To ensure it recognizes itself, you will want to update the `/etc/hosts` file where `127.0.1.1` is listed to your `hostname` then also your `hostname.domainname`.

While I have yet to see `grub` automatically reboot the system, supposedly adding `panic=10` to the `GRUB_CMDLINE_LINUX_DEFAULT` parameter in `/etc/default/grub` will reboot 10 seconds after a kernel panic.  I add that just in case.  **It may also be necessary to add `nomodeset` to the same parameter if you have a discrete graphics card such as nvidia.**

Throwing preconfigured [`dot-files`](https://github.com/cdelorme/dot-files) into `/etc/skel/` can give new users a way better terminal experience.  I highly recommend doing this, they are only small text files.

If you are concerned about security you can set the default ssh port to a non-default value.  This reduces the amount of bots that will find and hit your public server in an attempt to access.  _Generally `pam.d` will handle temporary-lockouts for failed login attempts after a certain number._  Additional changes to `/etc/ssh/sshd_config` I recommend includes configuring ssh to only accept ssh keys and never passwords by setting `PasswordAuthentication no`, and also not to allow root logins by setting `PermitRootLogin no`.  **There are additional ssh optimizations to reduce latency caused by invalid or slow DNS.**

I have very explicit [iptables](data/etc/iptables/iptables.rules) defined to prevent unknown software from accessing, which also rate-limits ssh access.  While I used to modify default policies, unloading after modifying policies can lead to an inaccessible machine, and was significantly less "clean".  To auto-load the iptables, simply add a script to `/etc/network/if-up.d/` with `iptables-restore < /etc/iptables/iptables.rules`.  _Some may argue that this is a naive approach to loading iptables, but I have yet to encounter a scenario that proves this as an unacceptable method._

If you want to add or modify the `/etc/locale.gen` list, you can rebuild the locale files with ` locale-gen`.  Alternatively you can run `dpkg-reconfigure locales` to use the interactive menu.

I install the `watchdog` package as another fallback to capturing and dealing with locked up systems.  If the `/dev/watchdog` device exists then it has hardware support to checkin that the system is still responding every 60 seconds.  _In some cases you may need to reconfigure kernel support for this._  It really exists as another layer in addition to the grub panic and monit services.

Log accessibility is determined by the `adm` group, so adding users to `adm` should grant them read access to logs.  Some logs may not have the `adm` group by default, and you can check them by viewing the `/etc/logrotate.d/` configuration files.

Optionally I may install communication software, including [weechat](#) and [transmission bittorrent](#).

This concludes the template state/phase.

Stepping forward from the template state/phase, we can setup web server services.

None of my modern projects use older technologies, and I have begun moving away from systems that involve high complexity.

Common utilities I install include:

- [nginx](web/nginx.md)
- [mongodb](web/mongodb.md)
- [postgresql](web/postgresql.md)
- [msmtp mail server](web/msmtp.md)

Addiitonal optional configuration steps include:

- [ssl-ceritifcates](web/ssl-certificates.md)
- [bare git repositories](web/bare-git-repositories.md)
- [mariadb](web/mariadb.md)
- [php-fpm](web/php-fpm.md)

**I no longer install or configure php, mariadb, or mysql.  I can provide some basic instructions, but I do not automate it, and I don't recommend them for new projects.**

While mongodb works excellently as a single datastore or for rapid development, it has far too many edge-cases when speaking about performance at scale and growth that requires sharding.  All databases immediately begin to suck (as far as performance) when you add high-availability via replication.


The linux file system expects server contents to be served through `/srv/`.  By default this folder is empty.  I generally configure this folder with new groups, and stickybits on permissions.  Ether using the expected `www-data` group, or creating a `webdev` group, and a `gitdev` group (for bare git repositories), you can control ownership and access of files within these folders.  _As a side-note, php complicates ownership because it does not behave in a normal way._

For websites in the `/srv/` structure, I usually create a [websites logrotate configuration file](data/etc/logrotate.d/websites).  The use of `copytruncate` is necessary to prevent breaking nginx logging on rotate.

This concludes the webservice configuration phase.

Moving onto the last phase is a workstation phase, wherein decisions on whether to install development software and a desktop environment are present.  It can also be extended into whether to add [`gaming`](gaming/) to the mix.

First, we want to add to the installed packages for functionality.  This includes firmware packages, more filesystem and filesystem management packages, a complete suite of compression and decompression tools, hardware level sensors and control packages, multimedia libraries, wireless drivers including bluetooth, and a variety of support utilities.

For the desktop environment I install the openbox window manager, a variety of icons, menus, and theme packages, audio packages, xorg and xserver packages and utilities, a compositor, display utilities including status and menu bars, web browser, search tools, run-command, graphical sudo interface, graphical partition management, video players, recorders, and editors, image viewers and editors, graphical archival and thumbnailing software, font packages, and any dependencies for these packages.

For development I install the "essentials" packages, kernel compilation packages, optionally java, nodejs, and golang, and also python packages plus all dependencies and convenient extensions.

I install my [custom fonts](#), including a clean monoface font that is faily nice looking for the UI.

The initial configuration of [openbox](#) is complicated (reference all config files instead, also not "really" complicated).

Since the latest iteration uses systemd which has logind for access, to get proper access to resources with software in the openbox session (such as pcmanfm) you need to change how you launch the session from `~/.xinitrc` to include `exec ck-launch-session dbus-launch openbox-session`.

I generally update the default alternative packages using the `update-alternatives` command interface for the terminal emulator, web browser, and window/session manager (among others).

As a special note, when testing FPS performance, you need to set the `Xorg.conf` configuration files `SwapbuffersWait` to false or it has a fixed 60fps limit.

I use the `feh` command to set the desktop background to wallpaper, and for convenience created a one-liner [`~/.fehbg`](#) to initialize a loop that randomly cycles images from `~/.wallpaper/`.

Some applications do not like the `~/.Xdefaults` and search for `~/.Xresources`, so I symlink one to the other.  Additionally this file gets cached which may require a complete logout to see changes take effect, or you need to manually reload the xdg datastore.  I also like to install [`tabbedex`](#) for tab support within the `urxvt` terminal emulator.

I establish `conky` to depend on a composit manager for transparency support, and if there are multiple monitors we may wish to create two separate conky configurations so we have a file on each desktop.

Users need to be added to a myriad of groups depending on what services are actually installed.  This grants access to things like mounted drives and audio controls.

At boot the first-time with pulse you may need to run `set-default-sick` from `pactl` or `pacmd` (not sure what the difference between the two is really).

There are plenty of specific [`pcmanfm`](#) configuration steps:

- pcmanfm preferences
	- general
		- don't move files to trash can (just erase them)
		- default view mode: Thumbnail View (I wish this was extensible to allow classifying folder view by contents)
	- display
		- Size of Thumbnails: 256x256 (larger on big-screens would be nice)
		- Show thumbnails for remote files as well
		- increase size-limit on thumbnails (20k instead of 2k?), really we'd always want to generate a thumbnail
		- always show full file names
	- volume management
		- change to home folder instead of closing tabs on ejected device
	- advanced
		- archiver integration: xarchiver (preferred)

The `tumbler` and `ffmpegthumbnailer` packages are required to generate thumbnail images.  Unfortunately there is no parent-folder preview system.

To support drive-mounting access from pcmanfm or as part of the `plugdev` group, one must have an appropriately defined [policy-kit file](#).

To keep the monitor awake, I launch a [daemon](#) when openbox is loaded.

There are additional steps to [configuring sublime text](#) that should be followed afterwards.

First-run of google chrome and synchronizing your account is another post-install step.




- [iptables securing ssh](http://www.rackaid.com/blog/how-to-block-ssh-brute-force-attacks/)
- [best practices 2010: "Don’t set the default policy to DROP"](http://major.io/2010/04/12/best-practices-iptables/)
- [reject > drop](http://unix.stackexchange.com/questions/109459/is-it-better-to-set-j-reject-or-j-drop-in-iptables)
- [reject & drop equally susceptable to DoS](http://www.linuxquestions.org/questions/linux-security-4/drop-vs-reject-685942/)
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






## new revised "global" documentation





Screenshots for latest content!

![clipit](https://d2xxklvztqk0jd.cloudfront.net/images/git/clipit.png)

![pcmanfm general](https://d2xxklvztqk0jd.cloudfront.net/images/git/pcmanfm-general.png)
![pcmanfm display](https://d2xxklvztqk0jd.cloudfront.net/images/git/pcmanfm-display.png)
![pcmanfm layout](https://d2xxklvztqk0jd.cloudfront.net/images/git/pcmanfm-layout.png)
![pcmanfm volume management](https://d2xxklvztqk0jd.cloudfront.net/images/git/pcmanfm-volume-management.png)
![pcmanfm advanced](https://d2xxklvztqk0jd.cloudfront.net/images/git/pcmanfm-advanced.png)

