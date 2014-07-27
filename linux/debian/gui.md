
# Debian Wheezy GUI Documentation
#### Updated 2014-7-27

These are the instructions for setting up a customized OpenBox window manager, and various role supporting software, as well as a number of utility and development applications.

It assumes that work picks up where the template documentation left off.


## troubleshooting

A graphics card will be required, though driver installation varies wildly and won't be covered here.  If you install the packages below and cannot run startx or telinit 3 into the slim, then you may have to look elsewhere for future guides.


## install packages

**Here is a detailed breakdown of packages grouped by intended purpose or function.**

Desktop Package:

- desktop-base

Window Manager:

- openbox
- obconf
- obmenu
- menu

Menu Subsystem:

- tint2

Monitoring Tools:

- conky-all

Web Browser:

- chromium

Terminal Triggered Popups:

- zenity
- zenity-common

File Browser:

- pcmanfm

Terminal Audio Packages:

- alsa-base
- alsa-utils
- pulseaudio

Desktop Background Utilities:

- feh
- hsetroot

Lightweight Unicode Terminal:

- rxvt-unicode

Graphical Login Manager:

- slim

Xorg Packages:

- xorg
- xserver-xorg-video-all
- x11-server-utils
- xinit
- xinput
- xtightvncviewer
- suckless-tools

Lightweight Launcher:

- gmrun

Graphical Monitor Size & Position Management:

- arandr

Clipboard Utilities:

- clipit
- xsel

Graphical Privileged Prompt:

- gksu

Theming Packages:

- openbox-themes
- dmz-cursor-theme
- gnome-icon-theme
- gnome-icon-theme-extras
- lxappearance

GUI file search tool:

- catfish

_I think this is totally useful and should have an openbox hotkey._

GUI Keyboard Layout Toggle:

- fbxkb

_This package is a gui overlay that shows up in the menu with a flag to coordinate with languages, and is an interface to the xserver keyboard layouts.  It's a very nice lightweight language switcher._


##### commands

_Run to install all packages:

    aptitude install -ryq desktop-base openbox obconf obmenu menu tint2 conky-all chromium zenity zenity-common pcmanfm alsa-base alsa-utils pulseaudio volumeicon-alsa feh hsetroot rxvt-unicode slim xorg xserver-xorg-video-all x11-server-utils xinit xinput xtightvncviewer suckless-tools gmrun arandr clipit xsel gksu catfish fbxkb openbox-themes dmz-cursor-theme gnome-icon-theme gnome-icon-theme-extras lxappearance gparted vlc gtk-recordmydesktop chromium transmission transmission-cli openshot flashplugin-nonfree lame ffmpeg shared-mime-info fontconfig fontconfig-config fonts-droid fonts-droid fonts-freefont fonts-liberation fonts-takao ttf-mscorefonts-installer gimp gimp-plugin-registry evince bpython libX11-dev libmcrypt-dev python-dev python3-dev libperl-dev openjdk-7-jre yeahconsole xdg-user-dirs


## system configuration

In some cases the installed packages are not configured, in other cases I preferred alternative configurations.


### installing custom fonts

This part is entirely optional, but I have some favorite fonts that I usually install:

- [ForMateKonaVe](https://github.com/cdelorme/system-setup/raw/develop/data/fonts/ForMateKonaVe.ttf)
- [epkyouka](https://github.com/cdelorme/system-setup/raw/develop/data/fonts/epkyouka.ttf)

Custom fonts can be installed globally into `/usr/share/fonts/`, or per-user at `~/.fonts/`; simply copy the font files into those folders.

After copying the files you will need to refresh the font cache using the `fc-cache` utility.


##### commands

_Run this to rebuild font cache:_

    fc-cache -fr


### configuring & theming slim

Slim is a UI that can be configured to run when the system starts and give you a UI to login with.  It is both lightweight and customizable.

_I often find myself using the terminal exclusively when accessing my system, so I don't really make use of slim, but if you want a system with multiple users or a graphical login it is excellent._

You may have to set it to boot at startup.

The theme configuration file can be found at `/`.


#### tips when using slim

To shutdown the system enter `halt` as the username followed by the root password.  Similarly to reboot the system use `reboot` as the username.


##### commands

_Run to activate slim at boot time:_

    update-rc.d slim defaults

_my preferred slim configuration (`/`):_

    INCOMPLETE


### startx launch openbox

This is my preferred approach to loading openbox.  It's an alternative to using slim where you login through the console like normal, but use `startx` to launch the graphical interface.

This also allows you to exit openbox and drop back into terminal when desired.

Simply add `exec openbox-session` to `~/.xinitrc`.


##### commands

_Adding openbox to xinitrc:_

    echo "exec openbox-session" > ~/.xinitrc


### configuring & theming openbox

In some cases openbox will not be your default window or session manager.  It would be wise to fix this first.

We can start by copying the default files found in `/etc/xdg/openbox/` to `~/.config/openbox/`.

You will then want to replace



Files of importance:

- rc.xml config
- menu.xml config





##### comamnds

**Set openbox as default window & session manager:**

    update-alternatives --set x-window-manager /usr/bin/openbox
    update-alternatives --set x-session-manager /usr/bin/openbox-session

**Copy default files:**

    mkdir -p ~/.config/openbox
    cp /etc/xdg/openbox/* ~/.config/openbox/

_Replace contents in `~/.config/openbox/autostart` with (this is an executable file):_

    #!/bin/sh
    which xdg-user-dirs-update &> /dev/null && (xdg-user-dirs-update) &
    which hsetroot &> /dev/null && (hsetroot -solid "#2E3436") &
    [ -f "$HOME/.fehbg" ] && [ -d "$HOME/.wallpaper/" ] && [ $(find ~/.wallpaper/ -type f | wc -l) -gt 0 ] && . "$HOME/.fehbg"
    which tint2 &> /dev/null && (tint2) &
    which clipit &> /dev/null && (clipit) &
    which xset &> /dev/null && (xset r rate 250 25 & xset b off) &
    which volumeicon &> /dev/null && (volumeicon) &
    which conky &> /dev/null && (conky -d -q) &
    which yeahconsole &> /dev/null && (yeahconsole) &


### fehbg (optional)

If you want to set a wallpaper background, or better year cycle a set of wallpapers, then `fehbg` is the tool you're looking for!  It has incredibly simple syntax, and is cli friendly.


##### commands

_Throw a bunch of preferred images into `~/.wallpaper/` and create `~/.fehbg` with:_

    (while true; do feh -q --no-fehbg --bg-fill $(find "${HOME}/.wallpaper" -type f | sort -R | tail -1) && sleep 10; done;) &

_Or adjust the directorie to pull pictures from as desired._


### urxvt configuration

This is a basic terminal emulator with unicode support and is very popular.

Configuring it is quite a task, but once you have it you have an excellent utility at your fingertips.


##### commands

**Set default terminal emulator:**

    update-alternatives --set x-terminal-emulator /usr/bin/urxvt

**Configuration to append to `~/.Xdefaults`:**

    INCOMPLETE


### yeahconsole

This is a utility that can be used to make an instantly accessible urxvt console pop down from the top of the screen.  This can be incredibly helpful, so I have installed it.


##### commands

_YeahConsole configuration append to `~/.Xdefaults`:_

    ! yeahconsole config
    yeahconsole*term: urxvt
    yeahconsole*toggleKey: Win+t
    yeahconsole*toggleFull: None+F11
    yeahconsole*consoleHeight: 20
    yeahconsole*aniDelay: 0
    yeahconsole*stepSize: 10

_FYI: These toggle keys are not virtualbox friendly._


### configuring pcmanfm




### configuring & theming conky

I usually have two conky processes running as it allows me to separately print out certain sets of data, and at different intervals.  For example log output does not need to be as commonly parsed, and separating it lets me reduce the amount of processing necessary.

_I may also use a lua script to enable transparency effects._





### configuring & theming tint2





### configuring & theming urxvt

Currently using this (it's pretty but not full-featured or matching my choice theme):

    !-------------------------------------------------------------------------------
    ! Xft settings
    !-------------------------------------------------------------------------------

    Xft.dpi:                    96
    Xft.antialias:              false
    Xft.rgba:                   rgb
    Xft.hinting:                true
    Xft.hintstyle:              hintslight

    !-------------------------------------------------------------------------------
    ! URxvt settings
    ! Colours lifted from Solarized (http://ethanschoonover.com/solarized)
    ! More info at:
    ! http://pod.tst.eu/http://cvs.schmorp.de/rxvt-unicode/doc/rxvt.1.pod
    !-------------------------------------------------------------------------------

    URxvt.depth:                32
    URxvt.geometry:             90x30
    URxvt.transparent:          false
    URxvt.fading:               0
    ! URxvt.urgentOnBell:         true
    ! URxvt.visualBell:           true
    URxvt.loginShell:           true
    URxvt.saveLines:            50
    URxvt.internalBorder:       3
    URxvt.lineSpace:            0

    ! Fonts
    URxvt.allow_bold:           false
    /* URxvt.font:                 -*-terminus-medium-r-normal-*-12-120-72-72-c-60-iso8859-1 */
    URxvt*font: xft:Monospace:pixelsize=14
    URxvt*boldFont: xft:Monospace:pixelsize=14

    ! Fix font space
    URxvt*letterSpace: -1

    ! Scrollbar
    URxvt.scrollStyle:          rxvt
    URxvt.scrollBar:            false

    ! Perl extensions
    URxvt.perl-ext-common:      default,matcher
    URxvt.matcher.button:       1
    URxvt.urlLauncher:          firefox

    ! Cursor
    URxvt.cursorBlink:          true
    URxvt.cursorColor:          #657b83
    URxvt.cursorUnderline:      false

    ! Pointer
    URxvt.pointerBlank:         true

    !!Source http://github.com/altercation/solarized

    *background: #002b36
    *foreground: #657b83
    !!*fading: 40
    *fadeColor: #002b36
    *cursorColor: #93a1a1
    *pointerColorBackground: #586e75
    *pointerColorForeground: #93a1a1

    !! black dark/light
    *color0: #073642
    *color8: #002b36

    !! red dark/light
    *color1: #dc322f
    *color9: #cb4b16

    !! green dark/light
    *color2: #859900
    *color10: #586e75

    !! yellow dark/light
    *color3: #b58900
    *color11: #657b83

    !! blue dark/light
    *color4: #268bd2
    *color12: #839496

    !! magenta dark/light
    *color5: #d33682
    *color13: #6c71c4

    !! cyan dark/light
    *color6: #2aa198
    *color14: #93a1a1

    !! white dark/light
    *color7: #eee8d5
    *color15: #fdf6e3

    ! transparency
    URxvt.transparent:   true
    URxvt.shading:       20


Found this on the web, may tailor to my liking:

    # these three lines enable clicking on links to open them ;)
    ## if you want to enable tab support, append ,tabbed to the next line
    ## then use shift+down arrow to create tabs and shift+{left,right} arrows to switch between them
    URxvt*perl-ext-common: default,matcher,-option-popup,-selection-popup,-realine
    URxvt*matcher.button: 1
    # don't forget to change this to your favorite browser
    URxvt*urlLauncher: chromium

! open urls
urxvt*perl-ext-common: tabbed,default,matcher,-option-popup,-selection-popup,-realine
urxvt*url-launcher: x-www-browser
urxvt*matcher.Button: 1
URxvt.colorUL: #4682B4


Urxvt*perl-lib:    /usr/lib/urxvt/perl/




### user configuration

For full privileges users should belong to these groups:

- fuse
- scanner
- bluetooth
- netdev
- audio
- video
- adm
- pulse-access

Many of these groups are assigned by default when a new user is created through the UI.

The `adm` group is necessary for log access; fuse gives the user mounting privileges.  The `pulse-access` group is intended for specific volume controls.  The others are all rather self-explanitory.


##### commands

_This can be done via a **single** command line:_

    usermod -aG adm,audio,video,fuse,scanner,netdev,bluetooth,pulse-access username


### gui volume controls with pulse and alsa

This uses the `volumeicon-alsa` package, and requires the user to be in the `pulse-access` group in order to modify the volume state.

Preferred volume config (`~/.???`):

    [StatusIcon]
    stepsize=3
    lmb_slider=false
    mmb_mute=false
    use_horizontal_slider=true
    show_sound_level=true
    onclick=urxvt -e 'alsamixer'
    theme=Default

    [Hotkeys]
    up_enabled=true
    down_enabled=true
    mute_enabled=true
    up=XF86AudioRaiseVolume
    down=XF86AudioLowerVolume
    mute=XF86AudioMute

    [Alsa]
    card=default

**The volumeicon package provides a UI component, but is not required to adjust the volume by hotkeys.**

**Still researching the volume controls via `XF86`.**


## [Youtube Downloader](https://github.com/rg3/youtube-dl)

This is a really cool command line utility that you can use to download (the highest quality) youtube videos without any GUI utilities.  It includes asynchronous processing and even spits out the percent status.


##### Commands

_Run these commands to download and install the `youtube-dl` command:_

    git clone https://github.com/rg3/youtube-dl
    cd youtube-dl
    sudo python setup.py install
    cd ..
    rm -rf youtube-dl


## Google Chrome Dev Channel

I prefer the dev channel of google chrome.  The easy way to install it is to go to your current web browser, search "Google Chrome Dev Channel" and then download the `.deb` and install it with `sudo dpkg -i`.

It should ask to be set as the default browser at first launch.


##### Commands

_Register google's apt key:_

    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -

_Create a file at `/etc/apt/sources.list.d/google` with these lines:_

    # Google Chrome repo http://www.google.com/linuxrepositories/
    deb http://dl.google.com/linux/chrome/deb/ stable main
    deb http://dl.google.com/linux/talkplugin/deb/ stable main
    deb http://dl.google.com/linux/earth/deb/ stable main
    deb http://dl.google.com/linux/musicmanager/deb/ stable main

_Run these commands to update aptitude:_

    sudo aptitude clean
    sudo aptitude update

_Install these packages:_

    sudo aptitude install -ryq google-chrome-stable google-chrome-unstable google-talkplugin

_Set as default browser:_

    update-alternatives --set x-www-browser /usr/bin/google-chrome-stable


### [sublime text](https://github.com/cdelorme/system-setup/tree/master/shared_config/sublime_text.md)

Since installing and configuring sublime text is nearly identical between platforms I've moved its instructions to a more centralized location.  Click the header link to read it!


## still investigating

I have a lot of software that I have not yet finished researching or have not successfully setup and want to add it to my list someday.


### multiple keyboard layout configuration

This depends on `xorg` currently, but I have a lot of details to work out still.


### pipelight

For linux this is the alternative to silverlight.  You can run a browser in linux while it connects silverlight plugin through a wine bottle.

I have not yet tested this.


### [viewnoir](https://github.com/xsisqox/Viewnior)

Most other viewing or previewing software is extremely bad in either speed or simplicity.

Unfortunately this software requires newer packages than are available to debian, and attempts to build it have been unsuccessful.  I would like to try previous versions, or in the worst case scenario plan on installing it when Debian Jessie is released as the new stable.







# References

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
