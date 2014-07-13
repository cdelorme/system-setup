
# Debian Wheezy OpenBox UI
#### Updated 2014-6-14

Tentative instructions for creating a [crunchbang-like](http://crunchbang.org/) debian install, with many preference based changes.

**This is still a work in progress!**

Packages in addition to (or alternative to) raspberry pi's listings:


It is also quite likely that I can re-use most of the instructional steps from the raspberry pi (and inversely patch them with whatever changes I have tested here).

    aptitude install -ryq desktop-base openbox obconf obmenu menu tint2 conky-all chromium zenity zenity-common pcmanfm alsa-base alsa-utils pulseaudio volumeicon-alsa feh hsetroot rxvt-unicode slim xorg xserver-xorg-video-all x11-server-utils xinit xinput xtightvncviewer suckless-tools gmrun arandr clipit xsel gksu catfish fbxkb openbox-themes dmz-cursor-theme gnome-icon-theme gnome-icon-theme-extras lxappearance


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


## configuring & theming conky



## configuring & theming tint2



## configuring & theming urxvt

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


Found this on the web, may tailor to my liking:

    # these three lines enable clicking on links to open them ;)
    ## if you want to enable tab support, append ,tabbed to the next line
    ## then use shift+down arrow to create tabs and shift+{left,right} arrows to switch between them
    URxvt*perl-ext-common: default,matcher,-option-popup,-selection-popup,-realine
    URxvt*matcher.button: 1
    # don't forget to change this to your favorite browser
    URxvt*urlLauncher: chromium



## configuring & theming slim



### using slim

To shutdown the system enter `halt` as the username followed by the root password.  Similarly to reboot the system use `reboot` as the username.



## configuring & theming openbox

Files of importance:

- rc.xml config
- menu.xml config


## configuring pcmanfm



## multiple keyboard layout configuration

This depends on `xorg` currently, but I have a lot of details to work out still.



## pipelight

For linux this is the alternative to netflix.  You can run a browser in linux while it connects silverlight plugin through a wine bottle.

_Details pending._



## viewnior

Because most other software absolutely sucks, I want to get the best possible high performance low profile image viewer available, and viewnior is exactly that.

_Still looking into the build process, as it depends on too many newer things._


## gui volume controls with pulse and alsa

- volumeicon-alsa

Add user to the `pulse-access` group, in order to access and modify volume state.

Preferred volume config:

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

**The volumeicon package is technically not necessary, as the hotkeys to run the amixer commands can be done entirely from the openbox configuration.**

_I am still working on updating the hotkeys, since `XF86` doesn't really exist on my keyboards._


# references

- [volume management](http://urukrama.wordpress.com/2007/12/19/managing-sound-volumes-in-openbox/)
- [slim manual](http://slim.berlios.de/manual.php)
- [pipelight](https://launchpad.net/pipelight)
- [viewnior](https://github.com/xsisqox/Viewnior)
- [gmrun in openbox](http://naniland.wordpress.com/2011/10/25/alt-f2-on-openbox/)
- [openbox pulseaudio through amixer adjusted hotkeys](https://wiki.archlinux.org/index.php/openbox#Pulseaudio)
- [urxvt popup options](https://bbs.archlinux.org/viewtopic.php?id=57202)


## Tools to Compare & Investigate


A potential `rxvt-unicode` enhancer:

- yeahconsole

It may be possible yet to get urxvt to popup without `yeahconsole`, so I'm going to investigate it further still.  If I fail to acheive my goal I will install and test `yeahconsole`.

