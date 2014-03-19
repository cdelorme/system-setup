
# Debian Wheezy OpenBox UI
#### Updated 2014-3-18

Tentative instructions for creating a [crunchbang-like](http://crunchbang.org/) debian install, with many preference based changes.

**This is still a work in progress!**

Packages in addition to (or alternative to) raspberry pi's listings:

- openbox-themes
- conky-all (instead of **just** conky)

It is also quite likely that I can re-use most of the instructional steps from the raspberry pi (and inversely patch them with whatever changes I have tested here).


---

List of tasks:


Remaining Openbox Tasks:

- volume control research

volume reference (in case xfce4 is not enough): https://bbs.archlinux.org/viewtopic.php?id=73020
another volume reference: http://urukrama.wordpress.com/2007/12/19/managing-sound-volumes-in-openbox/
seems xfce4 was a mistake, what I need is openbox volume hotkeys AND the volumetray-alsa package: http://softwarebakery.com/maato/volumeicon.html

Remove the items from this list, then get to work with the volumeicon package:

    Get: 1 http://ftp.us.debian.org/debian/ wheezy/main libxfce4util-common all 4.8.2-1 [95.3 kB]
    Get: 2 http://ftp.us.debian.org/debian/ wheezy/main libxfce4util4 amd64 4.8.2-1 [75.7 kB]
    Get: 3 http://ftp.us.debian.org/debian/ wheezy/main libxfce4util-bin amd64 4.8.2-1 [50.7 kB]
    Get: 4 http://ftp.us.debian.org/debian/ wheezy/main xfconf amd64 4.8.1-1 [155 kB]
    Get: 5 http://ftp.us.debian.org/debian/ wheezy/main libxfconf-0-2 amd64 4.8.1-1 [79.0 kB]
    Get: 6 http://ftp.us.debian.org/debian/ wheezy/main xfce4-volumed amd64 0.1.13-3 [15.6 kB]

Cool [slim info](http://slim.berlios.de/manual.php), username as halt, reboot, or exit and root password will execute the desired operation!  No extra buttons necessary.

- volume control research (see above notes)
- openbox theme (custom colors & design)
    - rc.xml config
    - menu.xml config
- pcmanfm configuration & theme to match openbox
- urxvt configuration & theme to match openbox
- tint2 configuration & theme to match openbox
- slim config (if necessary, bg perhaps?)
- conky slim-bar config for raspberry pi (low-profile lightweight conky config, easier on resources)
- conky add hotkeys to list & theme to match openbox
- conky lua enhancement for radius edges of bg script
- conky radial lua script (for kickass high-end display multi-core systems!)
- investigate multiple keyboard layouts (mapped per keyboard id)
- lightson daemon script to keep the xscreensaver from doing things while certain progs are running
- look into fixing `whitey` or building my own with a gui for preview images
- test bluetooth adapter & connect my spare apple bt keyboard (maybe my touchpad too?)
- push new `linux/raspbian/media.md` file to system-setup project
- OSX 10.9 **MUST BE FINISHED & RELEASED BEFORE GOING FORWARD**
- switch system-setup master branch as default on github and bitbucket
- add all my script data to `setup` file in system-setup (post-pre-release tag with osx)
- refine openbox for debian desktop documentation and push!


---

investigate pipelight for debian to play netflix?


I should probably also add this to my gui.md packages:

- flashplugin-nonfree



Install all xorg video drivers:

    aptitude install -r xserver-xorg-video-all


We will need to add users to all of these groups now:

- fuse
- scanner
- bluetooth
- netdev
- audio
- video
- adm

Apparently this can be done via a **single** command line:

    usermod -aG adm,audio,video,fuse,scanner,netdev,bluetooth cdelorme





# Massive Reverse Engineered Package List

I am still working through all of these, and a lot of them won't "make the cut", but the task itself is pending.

Window System (Required for basically any window manager platform):

- xorg


Screen Manager:

- arandr (gui frontend for xrandr which comes with xorg)


Window Manager:

- openbox (Window Manager)
    - obconf (gui to edit entire ob theme)
    - obmenu (gui alternative to editing menu.xml)

_The gui editors are optional installs, as everything can be done via the configuration scripts._


Taskbar:

- tint2 (lightweight taskbar)


System Monitor:

- conky (sweet lightweight, and heavily customizable)


Application Launcher:

- gmrun (launch from desktop via ctrl+enter then type/auto-complete)


Screensaver:

- xscreensaver


Laptop Power Management Features:

- xfce4-power-manager


Terminal:

- rxvt-unicode (light & powerful)
    - yeahconsole (to popup the terminal like guake)
- terminator (heavy-weight alternative)


Clipboard Manager:

- clipit (lightweight)


Keyboard Switcher (probably desirable?):

- fbxkb (X11 keyboard indicator/switcher)


Wallpaper Software:

- feh (lightweight /w full cli, but also a previewer etc)
- nitrogen (heavy-weight gui desktop switcher)

_With `feh`, as a command line tool, it is possible to easily swap wallpaper on a timer, such as using a anacrontab to randomly pick a background image in a folder.  It should also be easy to add a right click command to set a desktop background when picking images._


Theme Switcher:

- lxappearance (theme switcher for gtk+, has problems, theme name is a simple config changes via text)

_Theme selection is also technically offered through obconf, although that may be for openbox, while gtk+ themes are for any other application that may be run on my desktop._



Notification Daemon:

- xfce4-notifyd (simple, visually appealing)


File Search:

- catfish (supports many engines)


Sudo Prompt:

- gksu (preferred)



Login Service:

- slim (super lightweight)


Recommended Desktop Utilities:

- desktop-base


File Managers:

- pcmanfm (ultimate lightweight, also desktop wallpaper setting power, and desktop icons)
- thunar (xfce file manager)
    - thunar-volman
    - thunar-archive-plugin
    - thunar-dropbox-plugin
    - thunar-media-tags-plugin


GUI Audio Controls:

- pnmixer (Does not exist in debian packages)
- xfce4-mixer (May or may not do all the things pnmixer does?)
- pavucontrol (another?)
- xfce4-volumed (volume hotkeys?)


Image Viewing Software:

- [viewnior](https://github.com/xsisqox/Viewnior) (not packaged for debian)


Proprietary DVD Support:

- libdvdcss2 (not packages for debian)


Screenshot Utility:

- xfce4-screenshooter


Calculator:

- galculator


Window Manager Command Tools:

- suckless-tools


Shell Scripted GUI Dialog Support:

- zenity


Monitor Utility:

- conky-all
- cpufrequtils
- htop


General theme Packages:

- dmz-cursor-theme
- gtk2-engines-murrine
- gnome-icon-theme
- gnome-icon-theme-extras
- gtrayicon


Graphical Disk Management Utility:

- gparted


Keyboard Management:

- xinput


VNC Client:

- xtightvncviewer


Configuration utilities:

- debconf-utils


Optional Package Manager Information Index:

- apt-xapian-index


Boot-Time Wallpaper Support Software:

- hsetroot


X Clipboard Access:

- xsel


---

**Add to GUI install (pre openbox/gnome):**

Multimedia tools:

- alsa-base
- lame
- ffmpeg
- pulseaudio
- vlc
- flashplugin-nonfree


Universally helpful font packages:

- ttf-freefont
- ttf-liberation
- ttf-droid
- ttf-mscorefonts-installer
- fonts-takao


Bittorrent Client:

- transmission-gtk
- transmission-cli


Communication Software (IRC Client):

- weechat-curses


Image Software:

- gimp
- gimp-plugin-registry
- evince

**Highly recommend compiling [viewnior](http://xsisqox.github.io/Viewnior/) from source.**


# Optional (probably moved to gui)

The list below is a series of utilities I either do not want, or would not benefit from having.


Optional Window Manager Menu Synchronizer:

- menu


Optional Wireless & Network Firmware:

- firmware-ralink
- firmware-iwlwifi
- firmware-ipw2x00
- firmware-b43-installer
- firmware-realtek


Optional Utilities for Wireless Network Management:

- network-manager-gnome
- network-manager-openvpn-gnome
- network-manager-pptp-gnome
- network-manager-vpnc-gnome
- avahi-utils
- avahi-daemon
- libnss-mdns
- wireless-tools


Optional File System Support Packages:

- xfsprogs
- reiserfsprogs
- reiser4progs
- jfsutils


Optional GUI Package Manager Utilities (doesn't aptitude have a gui?):

- synaptic
- gdebi
