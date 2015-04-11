
# dev

This document extends my [template](template.md) instructions, and you should review them first.

The goal of these instructions is to provide you with a highly customized development workstation, with features to enhance productivity and convenience.

While this is a more feature-filled set of instructions, the resulting system is likely still much more light-weight than a standard "full" install, especially if you opt not to install a graphical environment, _however the gains you'll get from having one generally outweight the pros of space saved not doing so_.


## packages

Packages will be sectioned into three areas:

- workstation
- graphical environment
- development

Packages in each area may be grouped with supplemental information to describe their purpose.

There will be explicitly labeled "optional" packages in each area as well, which is related to the automated installation scripts which this document exists to supplement.

_I also have a file on [`gaming`](misc/gaming.md), which may be additional steps one could follow._


### workstation

These are packages that should enhance your system as a terminal-based workstation, including a focus on driver support, and hardware monitoring packages.

**Firmware packages for non-standard devices:**

- firmware-linux
- firmware-linux-free
- firmware-linux-nonfree

**Hardware and file system utilities:**

- usbutils
- uuid-runtime
- gvfs-fuse
- exfat-fuse
- exfat-utils
- fuse-utils
- sshfs
- fusesmb
- e2fsprogs
- parted
- os-prober

**Non-standard compression utilities:**

- lzop
- p7zip-full
- p7zip-rar
- zip
- unrar
- unace
- rzip
- unalz
- zoo
- arj

**Support utilities:**

- pastebinit
- anacron
- miscfiles
- markdown
- asciidoc

_The `asciidoc` package has a 1GB "recommended" package, so it is highly advisable **not** to install it with recommended packages included._

**Sensors and monitoring utilities:**

- lm-sensors
- cpufrequtils

**Multimedia libraries:**

- lame
- ffmpeg
- libfaac-dev
- libx264-dev
- imagemagick
- graphicsmagick
- libexif-dev
- libogg-dev
- libvorbis-dev
- vorbis-tools
- libavcodec-dev
- libavbin-dev
- libavfilter-dev
- libavdevice-dev
- libavutil-dev
- libav-tools
- youtube-dl

_The `libfaac-dev` package exists on jessie, but not on wheezy._

_The `youtube-dl` package also only exists on jessie, but can be installed manually on wheezy._

**Wireless utilities (_optional_):**

- avahi-utils
- avahi-daemon
- libnss-mdns
- wireless-tools
- bluez
- bluez-utils
- bluez-tools
- bluez-firmware
- bluez-hcidump

If you have bluetooth or wireless you will likely want these packages installed to access and manage the service layers for that hardware.

**Transmission bittorrent (_optional_):**

- transmission
- transmission-cli
- transmission-daemon

**Weechat irc (_optional_):**

- weechat-ncurses

**Samba file sharing (_optional_):**

- samba
- samba-tools
- smbclient


### graphical environment

I prefer the `openbox` environment, similar to [crunchbang](http://crunchbang.org/), which is highly recommended as an alternative to my own scripts if you just want a system that **installs and is ready to get stuff done.**

**Window manager and theming:**

- openbox
- obconf
- obmenu
- menu
- openbox-themes
- dmz-cursor-theme
- gnome-icon-theme
- gnome-icon-theme-extras
- lxappearance

The window manager is the core container that displays the initial graphical environment and is responsible for any applications displayed "inside" it.  This makes it one of the most vital components of your graphical desktop.  Choosing a lightweight package like `openbox` gives you exceptionally low resource consumption and a high degree of flexibility with regards to what goes inside it.

**Audio packages:**

- alsa-base
- alsa-utils
- pulseaudio
- volumeicon-alsa

The volumeicon package gives us an icon in the tint2 menu bar that allows us to adjust the volume from the graphical environment.

**Xorg Packages:**

- xorg
- xserver-xorg-video-all
- x11-xserver-utils
- xinit
- xinput
- suckless-tools
- x11-utils

**Window manager features:**

- compton
- desktop-base
- xdg-user-dirs
- shared-mime-info
- tint2
- conky-all
- chromium
- zenity
- zenity-common
- pcmanfm
- feh
- hsetroot
- rxvt-unicode
- gmrun
- arandr
- clipit
- xsel
- gksu
- catfish
- fbxkb
- xtightvncviewer
- gparted
- vlc
- gtk-recordmydesktop
- openshot
- flashplugin-nonfree
- gimp
- gimp-plugin-registry
- evince
- viewnior
- xarchiver

These packages include base functionality such as a file browser, file search, elevated prompt, executable quick-launcher, clipboard management, system status & display, terminal emulator, and much more.  Effectively it's a set of loosely coupled packages that can be used within the `openbox` environment remaining as lightweight as possible, while still being packed with essential features.  _Some of the packages in this list may only exist in jessie._

**Font enhancements:**

- fontconfig
- fontconfig-config
- fonts-droid
- fonts-freefont-ttf
- fonts-liberation
- fonts-takao
- ttf-mscorefonts-installer

_Check this list against the packages above to ensure I have no duplicates, and also no missing, packages._

**Compton dependencies (optional):**

- libdrm-dev
- libdbus-1-dev
- libx11-dev
- libxcomposite-dev
- libxdamage-dev
- libxfixes-dev
- libxext-dev
- libxrender-dev
- libxrandr-dev
- libxinerama-dev
- libgl1-mesa-dev
- x11proto-core-dev
- libxml2-utils
- xsltproc

These are _required_ to build compton from source, but not really used for anything else in my particular configuration, so they are placed here.  If you have debian jessie then compton is available through the package manager.


### development

If you plan to use your system for development, I recommend simply installing all of the packages in this area.  In addition, you may want to conditionally install web server services, extending my [web](web.md) documentation.

**Development support utilities:**

- git-flow
- debhelper
- debconf-utils
- kernel-package
- fakeroot
- htop
- linux-headers-$(uname -r)

_The last package will install kernel headers, and uses a command to determine the kernel version that should find a matching package name (since headers haev full version names and numbers in them)._

**Core development packages:**

- build-essential
- openjdk-7-jre
- pkg-config
- devscripts
- bpython
- python-dev
- python-pip
- python3-dev
- python3-pip
- libncurses5-dev
- libmcrypt-dev
- libperl-dev
- libconfig-dev
- libpcre3-dev

These provide very important development components, such as basic compiling utilities and libraries, in addition to any new languages, and component development packages.

_The `compton` compositor package depends on a number of these development packages to build as well._


### graphics card troubleshooting

Since drivers for graphics cards varies, I won't be able to cover all cases.  It should be noted that the opensource drivers will generally only work well for 2D applications, any 3D processing will likely require the proprietary binaries for acceptable performance.

If you follow these instructions and `startx` does not load any visual for you, then you may need to look elsewhere for troubleshooting support specific to your graphics configuration.


## [youtube downloader](https://github.com/rg3/youtube-dl)

This is a really cool command line utility that you can use to download (the highest quality) youtube videos without any GUI utilities.  It includes asynchronous processing and even spits out the percent status.

If you are using Wheezy it is a python package, and you will need to [download and build and install it](../../../scripts/linux/workstation/youtube-dl.sh).  With Jessie you can install it from the package manager.


## [custom fonts](shared/custom-fonts.md)

I install custom fonts, and set them as defaults in other tools later.


## [golang](../shared/golang.md)

This is a wonderful programming language with a modern outlook.

While you can install the packaged version, it will likely be several releases out of date.

To build it from source depends on the `gcc`, `libc6-dev`, `libc6-dev-i386`, and `mercurial` packages.  To use it regularly you will also want the `bzr`, `git`, and `subversion` packages; it uses version control for dependency resolution, and depending on where your dependencies are you will need different utilities.

Post installation you can grab the vim plugin from the install path.  You should also set a `GOPATH` environment variable with a local path to install source files.


## optional

it is often said that linux is about choice, and while wonderful it can sometimes be a burden.  While I encourage everyone to do their homework, test different services, and decide what they think works best, I have put together a simplified list of optional packages:

- samba
- weechat
- transmission
- openbox (and all that sits atop it)


### [samba](../../../scripts/linux/comm/samba.sh)

This is the current best choice for cross platform compatible file sharing, with authentication.

While you are welcome to try `nfs` as an alternative with potentially higher performance, securing that can be much more difficult and I have yet to get it to work properly cross platform.

I also have a [nice configuration file](../../../data/etc/samba/smb.conf) that I use as a base for samba these days (which may not be 4.0 compatible, yet).


### [weechat](../../../scripts/linux/comm/weechat.sh)

A light weight terminal irc program.  If you use irc, and you probably will if you develop on linux, then you should probably install and try it out.


### [torrent service](../../../scripts/linux/comm/transmission.sh)

While there are services like [rtorrent](http://rakshasa.github.io/rtorrent/), I have been quite pleased with the progress of [transmission](https://www.transmissionbt.com/) and highly recommend it.

You can install the default transmission package, a cli package for command line controls, and also a daemon for running it like a server in the background.



### [openbox](../../../scripts/linux/gui/openbox.sh)

In some cases openbox will not be your default window or session manager.  It would be wise to fix this first.

We can start by copying the default files found in `/etc/xdg/openbox/` to `~/.config/openbox/`.

You will then want to replace the contents of [`~/.config/openbox/autostart`](../../../data/home/.config/openbox/autostart) with whatever needs to get launched with your openbox session.

To configure the main drop-menu that openbox uses, we'll want to modify [`~/.config/openbox/menu.xml`](../../../data/home/.config/openbox/menu.xml) and either add, remove, or change values.  _Some operations for example may require privileges, you can remove them or add gksu to execute the command with sudo privileges asking for a password from the UI._  I usually simply add the File Manager and change the order of the top few items.

For desktop, openbox themes, application control, and more you'll want to modify [`~/.config/openbox/rc.xml`](../../../data/home/.config/openbox/rc.xml).  This configuration file is very large so I won't go into detail; I recommend visitng the official documentation.

You can find a list of named themes available to your system in `/usr/share/themes/`, which can be set in `~/.config/openbox/rc.xml`.  If you want to create a custom theme you should place it there or in `~/.local/share/themes/` and then update `rc.xml` to reflect the name.


#### [startx](../../../data/home/.xinitrc)

We want the `startx` command to load openbox, which means we have to tell startx what to do using the `~/.xinitrc` file.  Simply add `exec openbox-session` to `~/.xinitrc`.

It would be wise to use `update-alternatives` to set the default window manager and session manager as well.


#### xorg

By default, xorg will restrict framerates to a maximum of 60fps.  This limit is generally useful in preventing choppy video or "tearing".  However, it does not accurately reflect runtime performance if you happen to be benchmarking or testing.

I recommend disabling it if you intend to ever test frames per second in graphical development.  The best way to do this is to generate an `xorg.conf` file, and then set `SwapbuffersWait` to false.


#### feh

This super light utility allows you to set a background to a wallpaper.  I have created a script [`~/.fehbg`](../../../data/home/.fehbg) that will cycle wallpaper every 5 minutes, which can be called during openbox's autostart script.

To use the script, simply create a `~/.wallpaper` folder and load it up with images.


#### urxvt

This is a light weight terminal emulator with unicode support.  It's about as bare as a terminal emulator can get, and does not have any specific environment dependencies that alternatives may be tied to.

The urxvt configuration is done through [`~/.Xdefaults`](../../../data/home/.Xdefaults).  I prefer a dark background and transparency.  Some applications look to `~/.Xresources`, which you can work-around by creating a symlink to `~/.Xdefaults`.

While the default tabbed enhancement works, I prefer to have the tabs menu hidden if there is only one.  For this you'll want to download and install [`tabbedex`](https://raw.githubusercontent.com/shaggytwodope/tabbedex-urxvt/master/tabbedex).

I also added a hotkey to openbox's `rc.xml` that calls a [`urxvtq` script](../../../data/etc/.bin/urxvtq) which pops down a window from the top of the screen.  This allows us to get a persistent, on-demand terminal window.


#### [conky](../../../data/home/.conkyrc)

This is a utility that lets us quickly glance at system status, such as cpu, hard drive, and memory usage, among a myriad of other more complicated specs.  More importantly it can be displayed cleanly on the desktop with live-updates.

My configuration includes the latest system log file output.  Enough transparency so as to remain readable but not ruin background images as well.

_To acheive transparency you will want a compositor, and while `xcompmgr` will do the job and can be installed from a package it is jank and broken in several ways.  I highly recommend using `compton`._

Whitespace in conky output matters, so be aware of that when modifying the configuration file.

If you are using multiple monitors and want conky to display on each you will need to run two instances of conky, and will need two conky configuration files.


#### [clipit](../../../data/home/.config/clipit/clipitrc)

If no configuration exists the first time you run it you will be asked to adjust the settings.  An icon for this utility will appear in `tint2`.


#### user configuration

For full privileges users should belong to these groups:

- fuse
- scanner
- bluetooth
- netdev
- audio
- video
- plugdev

Many of these groups are assigned by default when a new user is created through the UI.  They should grant access to additional devices and services, _but may need to be supplemented by additional policy kit configuration files._


##### pulseaudio

For whatever reason pulse-audio refuses to play nicely until you have copied the default configuration file from it's global location to your user folder.  The result is a wonky, and often unresponsive or breaking experience.

It is neither mentioned during the package installation, nor is it easy to find anything to explain the phenomina that happen when you don't, hence why this step is here.  It would be very nice if it would create a copy on first-execution for any user automatically, instead of just exhibiting unexpected behavior.

**On bare hardware you may have to perform some additional steps to set the default audio device.  This varies by system, fortunately the `pactl` command is very easy to run from command line and get the system configured.**  In particular, you will probably have to run `set-default-sink`.


##### pcmanfm

I set the following settings for my file browser:

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

The `tumbler` and `ffmpegthumbnailer` packages are used to generate thumbnails; _unfortunately there is no folder-preview thumbnailer_.


##### drive mounting

For the user to have drive mounting access, such as from terminal or even `pcmanfm` (the file browser) a policy kit configuration file must be added, and that user must be added to the `plugdev` group.

The policy kit file should be placed at [`/etc/polkit-1/localauthority/50-local.d/55-storage.pkla`](../../../data/etc/polkit-1/localauthority/50-local.d/55-storage.pkla)

This should give any user privileges needed to mount, eject, read, and modify connected drives such as usb drives.


#### keeping the monitor awake

By default the Xorg/xserver is configured to turn off after inactivity of a fixed duration.  Unfortunately it decides what "inactivity" means, and that is effectively keyboard and mouse interaction.

When you have installed a graphical environment and are running a web browser, or playing a video (as simple examples) it will decide to shut off the display if you haven't tapped the keyboard or jiggled the mouse in roughly the past hour.

I created a [daemon](../../../data/home/.bin/nosleep-daemon) that will execute a [script](../../../data/home/.bin/nosleep) to check for specific applications and prevent the screen from sleeping if they exist.

While you can setup the script to run under a cronjob, this will just waste resources if there is no active window manager and just a terminal.  Therefore I decided a daemon made more sense, since it can be closed with openbox as a child-process from its autostart.

The alternative is installing an ultra-complicated screensaver utility, which I find to be silly.


#### [google chrome](../../../scripts/linux/gui/chrome.sh)

While I usually prefer the dev channel, even google chrome stable has caused my debian wheezy system to crash on occassion.  As such, while I still recommend chrome, I recommend the stable version to avoid problems.

The easiest way to install it is to download a `.deb` from their site and manually install it with `dpkg -i`, but you can also add their repository manually as an alternative.

The google talk plugin may depend on a newer libc6, which is not available to debian wheezy, but should work fine with jessie.


#### [sublime text](https://github.com/cdelorme/system-setup/tree/master/shared_config/sublime_text.md)

Since installing and configuring sublime text is nearly identical between platforms I've moved its instructions to a more centralized location.  Click the header link to read it!


## incomplete

I have several areas of configuration I have not yet finished researching or trying to setup and would like to.


### [viewnoir](https://github.com/xsisqox/Viewnior)

The viewnior program is a superb lightweight image viewer with quick previews, outmatching most competator image-viewer software.  Unfortunately this software requires newer packages than are available to debian, and attempts to build it have been unsuccessful.  I would like to try previous versions, or in the worst case scenario plan to install it when Debian Jessie is released as the new stable.


### [omxplayer](https://github.com/huceke/omxplayer)

This is a totally awesome lightweight video player without all the insane codecs that seems to support most video files, and works a far cry better than VLC has for playback.
  Unfortunately it does not appear to have a debian wheezy package.


### [pipelight](http://pipelight.net/cms/installation.html)

This is supposedly a silverlight alternative for linux.  While not required, it might be nice if you want to use netflix on your desktop.

_I have not tried to install or use this yet, and may not simply due to a lack of support with newer versions of chrome/chromium._


### multiple keyboard layout configuration

Keyboard layouts are managed by xorg currently, and utilities like `fbxkb` may allow us to interact with layout options somehow.  I would like to investigate a way to toggle layouts in a lightweight environment without loading up a bunch of additional tools.


# references

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
- [usb device connection](https://www.ab9il.net/linux/pcmanfm-usb-mount.html)
- [openbox themes](http://capn-damo.deviantart.com/gallery/37736739/Openbox)
