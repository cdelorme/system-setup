
# gui documentation

These are the instructions for setting up a customized OpenBox window manager, and various role supporting software, as well as a number of utility and development applications.

It assumes that work picks up where the template documentation left off.


## troubleshooting

A graphics card will be required, though driver installation varies wildly and won't be covered here.  If you install the packages below and cannot run startx, then you may have to look elsewhere.


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

Composite Manager (Transparency etc):

- xcompmgr
- compton (many dependencies but better than xcompmgr)

Terminal Audio Packages:

- alsa-base
- alsa-utils
- pulseaudio

Desktop Background Utilities:

- feh
- hsetroot

Lightweight Unicode Terminal:

- rxvt-unicode

Xorg Packages:

- xorg
- xserver-xorg-video-all
- x11-xserver-utils
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

GUI Keyboard Layout Toggle:

- fbxkb

Documentation Generator:

- asciidoc


##### commands

_Run to install all packages:

    aptitude install -ryq desktop-base openbox obconf obmenu menu tint2 conky-all chromium zenity zenity-common pcmanfm alsa-base alsa-utils pulseaudio volumeicon-alsa feh hsetroot rxvt-unicode xorg xserver-xorg-video-all x11-xserver-utils xinit xinput xtightvncviewer suckless-tools gmrun arandr clipit xsel gksu catfish fbxkb openbox-themes dmz-cursor-theme gnome-icon-theme gnome-icon-theme-extras lxappearance gparted vlc gtk-recordmydesktop chromium transmission transmission-cli openshot flashplugin-nonfree lame ffmpeg shared-mime-info fontconfig fontconfig-config fonts-droid fonts-droid fonts-freefont-ttf fonts-liberation fonts-takao ttf-mscorefonts-installer gimp gimp-plugin-registry evince bpython libX11-dev libmcrypt-dev python-dev python3-dev libperl-dev openjdk-7-jre xdg-user-dirs libconfig-dev libx11-dev libxcomposite-dev libxdamage-dev libxfixes-dev libxext-dev libxrender-dev libxrandr-dev libXinerama-dev x11-utils libpcre3-dev libdrm-dev libdbus-1-dev libgl1-mesa-dev asciidoc bluez bluez-utils bluez-tools


## system configuration

In some cases the installed packages are not configured; in other cases I preferred alternative configurations.


### installing custom fonts

This part is entirely optional, but I have some favorite fonts that I usually install:

- [ForMateKonaVe](https://github.com/cdelorme/system-setup/raw/develop/data/fonts/ForMateKonaVe.ttf)
- [epkyouka](https://github.com/cdelorme/system-setup/raw/develop/data/fonts/epkyouka.ttf)

Custom fonts can be installed globally into `/usr/share/fonts/`, or per-user at `~/.fonts/`; simply copy the font files into those folders.

After copying the files you will need to refresh the font cache using the `fc-cache` utility.


##### commands

_Run this to rebuild font cache:_

    fc-cache -fr


### startx configuration

We want the `startx` command to load openbox, which means we have to tell startx what to do using the `~/.xinitrc` file.  Simply add `exec openbox-session` to `~/.xinitrc`.

It would be wise to use `update-alternatives` to set the default window manager and session manager as well.


##### commands

_Adding openbox to xinitrc:_

    echo "exec openbox-session" > ~/.xinitrc


### configuring & theming openbox

In some cases openbox will not be your default window or session manager.  It would be wise to fix this first.

We can start by copying the default files found in `/etc/xdg/openbox/` to `~/.config/openbox/`.

You will then want to replace the contents of `~/.config/openbox/autostart` with whatever needs to get launched with your openbox session.

To configure the main drop-menu that openbox uses, we'll want to modify `~/.config/openbox/menu.xml` and either add, remove, or change values.  _Some operations for example may require privileges, you can remove them or add gksu to execute the command with sudo privileges asking for a password from the UI._  I usually simply add the File Manager and change the order of the top few items.

For desktop, openbox themes, application control, and more you'll want to modify `~/.config/openbox/rc.xml`.  This configuration file is very large so I won't go into detail; I recommend visitng the official documentation.  You can find a list of named themes available to your system in `/usr/share/themes/`, which can be set in `~/.config/openbox/rc.xml`.


##### comamnds

**Set openbox as default window & session manager:**

    update-alternatives --set x-window-manager /usr/bin/openbox
    update-alternatives --set x-session-manager /usr/bin/openbox-session

**Copy default files:**

    mkdir -p ~/.config/openbox
    cp /etc/xdg/openbox/* ~/.config/openbox/

_Replace contents in `~/.config/openbox/autostart` with (this is an executable file):_

    #!/bin/sh
    which xrdb &> /dev/null && [ -f "$HOME/.Xresources" ] || [ -L "$HOME/.Xresources" ] && xrdb -merge "$HOME/.Xresources"
    which xdg-user-dirs-update &> /dev/null && (xdg-user-dirs-update) &
    which compton &> /dev/null && (compton -c) &
    which hsetroot &> /dev/null && (hsetroot -solid "#001E27") &
    which xset &> /dev/null && (xset r rate 250 25 & xset b off & xset m 7 5 & xset -dpms & xset s off) &
    [ -f "$HOME/.fehbg" ] && [ -d "$HOME/.wallpaper/" ] && [ $(find ~/.wallpaper/ -type f | wc -l) -gt 0 ] && . "$HOME/.fehbg"
    which clipit &> /dev/null && (sleep 2 && clipit) &
    which tint2 &> /dev/null && (sleep 3 tint2) &
    which conky &> /dev/null && (sleep 10 && conky -d -q) &

_My preferred `~/.config/openbox/menu.xml`:_

    <?xml version="1.0" encoding="UTF-8"?>
    <openbox_menu xmlns="http://openbox.org/"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://openbox.org/
        file:///usr/share/openbox/menu.xsd">
        <menu id="root-menu" label="Openbox 3">
            <item label="web"><action name="Execute"><execute>x-www-browser</execute></action></item>
            <item label="editor"><action name="Execute"><execute>subl</execute></action></item>
            <item label="cli"><action name="Execute"><execute>x-terminal-emulator</execute></action></item>
            <item label="files"><action name="Execute"><execute>pcmanfm</execute></action></item>
            <menu id="/Debian" />
            <separator />
            <menu id="client-list-menu" />
            <separator />
            <item label="ObConf"><action name="Execute"><execute>obconf</execute></action></item>
            <item label="Reconfigure"><action name="Reconfigure" /></item>
            <item label="Exit"><action name="Exit"><prompt>no</prompt></action></item>
        </menu>
    </openbox_menu>

_My preferred `~/.config/openbox/rc.xml`:_

    <?xml version="1.0" encoding="UTF-8"?>
    <openbox_config xmlns="http://openbox.org/3.4/rc" xmlns:xi="http://www.w3.org/2001/XInclude">
        <resistance><strength>10</strength><screen_edge_strength>20</screen_edge_strength></resistance>
        <focus><focusNew>yes</focusNew><followMouse>no</followMouse><focusLast>yes</focusLast><underMouse>no</underMouse><focusDelay>200</focusDelay><raiseOnFocus>no</raiseOnFocus></focus>
        <placement><policy>Smart</policy><center>yes</center><monitor>Primary</monitor><primaryMonitor>1</primaryMonitor></placement>
        <theme>
            <name>Mire_v2_orange</name>
            <titleLayout>NLIMC</titleLayout>
            <keepBorder>yes</keepBorder>
            <animateIconify>yes</animateIconify>
            <font place="ActiveWindow"><name>ForMateKonaVe</name><size>8</size><weight>bold</weight><slant>normal</slant></font>
            <font place="InactiveWindow"><name>ForMateKonaVe</name><size>8</size><weight>bold</weight><slant>normal</slant></font>
            <font place="MenuHeader"><name>ForMateKonaVe</name><size>9</size><weight>normal</weight><slant>normal</slant></font>
            <font place="MenuItem"><name>ForMateKonaVe</name><size>9</size><weight>normal</weight><slant>normal</slant></font>
            <font place="ActiveOnScreenDisplay"><name>ForMateKonaVe</name><size>9</size><weight>bold</weight><slant>normal</slant></font>
            <font place="InactiveOnScreenDisplay"><name>ForMateKonaVe</name><size>9</size><weight>bold</weight><slant>normal</slant></font>
        </theme>
        <desktops><number>3</number><firstdesk>1</firstdesk><names></names><popupTime>875</popupTime></desktops>
        <resize><drawContents>yes</drawContents><popupShow>Nonpixel</popupShow><popupPosition>Center</popupPosition><popupFixedPosition><x>10</x><y>10</y></popupFixedPosition></resize>
        <margins><top>0</top><bottom>0</bottom><left>0</left><right>0</right></margins>
        <dock><position>TopLeft</position><floatingX>0</floatingX><floatingY>0</floatingY><noStrut>no</noStrut><stacking>Above</stacking><direction>Vertical</direction><autoHide>no</autoHide><hideDelay>300</hideDelay><showDelay>300</showDelay><moveButton>Middle</moveButton></dock>
        <keyboard>
            <chainQuitKey>C-g</chainQuitKey>
            <keybind key="C-A-Left"><action name="GoToDesktop"><to>left</to><wrap>no</wrap></action></keybind>
            <keybind key="C-A-Right"><action name="GoToDesktop"><to>right</to><wrap>no</wrap></action></keybind>
            <keybind key="C-A-Up"><action name="GoToDesktop"><to>up</to><wrap>no</wrap></action></keybind>
            <keybind key="C-A-Down"><action name="GoToDesktop"><to>down</to><wrap>no</wrap></action></keybind>
            <keybind key="S-A-Left"><action name="SendToDesktop"><to>left</to><wrap>no</wrap></action></keybind>
            <keybind key="S-A-Right"><action name="SendToDesktop"><to>right</to><wrap>no</wrap></action></keybind>
            <keybind key="S-A-Up"><action name="SendToDesktop"><to>up</to><wrap>no</wrap></action></keybind>
            <keybind key="S-A-Down"><action name="SendToDesktop"><to>down</to><wrap>no</wrap></action></keybind>
            <keybind key="C-1"><action name="GoToDesktop"><to>1</to></action></keybind>
            <keybind key="C-2"><action name="GoToDesktop"><to>2</to></action></keybind>
            <keybind key="C-3"><action name="GoToDesktop"><to>3</to></action></keybind>
            <keybind key="W-d"><action name="ToggleShowDesktop"/></keybind>
            <keybind key="A-F4"><action name="Close"/></keybind>
            <keybind key="A-Escape"><action name="Lower"/><action name="FocusToBottom"/><action name="Unfocus"/></keybind>
            <keybind key="A-space"><action name="ShowMenu"><menu>client-menu</menu></action></keybind>
            <keybind key="A-Tab"><action name="NextWindow"><finalactions><action name="Focus"/><action name="Raise"/><action name="Unshade"/></finalactions></action></keybind>
            <keybind key="A-S-Tab"><action name="PreviousWindow"><finalactions><action name="Focus"/><action name="Raise"/><action name="Unshade"/></finalactions></action></keybind>
            <keybind key="C-A-Tab"><action name="NextWindow"><panels>yes</panels><desktop>yes</desktop><finalactions><action name="Focus"/><action name="Raise"/><action name="Unshade"/></finalactions></action></keybind>
            <keybind key="W-S-Right"><action name="DirectionalCycleWindows"><direction>right</direction></action></keybind>
            <keybind key="W-S-Left"><action name="DirectionalCycleWindows"><direction>left</direction></action></keybind>
            <keybind key="W-S-Up"><action name="DirectionalCycleWindows"><direction>up</direction></action></keybind>
            <keybind key="W-S-Down"><action name="DirectionalCycleWindows"><direction>down</direction></action></keybind>
            <keybind key="W-w"><action name="Execute"><command>x-www-browser</command></action></keybind>
            <keybind key="W-t"><action name="Execute"><command>x-terminal-emulator</command></action></keybind>
            <keybind key="W-grave"><action name="Execute"><execute>urxvtq</execute></action></keybind>
            <keybind key="W-e"><action name="Execute"><command>subl</command></action></keybind>
            <keybind key="W-f"><action name="Execute"><command>pcmanfm</command></action></keybind>
            <keybind key="W-m"><action name="Execute"><command>vlc</command></action></keybind>
            <keybind key="W-space"><action name="Execute"><command>gmrun</command></action></keybind>
            <keybind key="W-Tab"><action name="ShowMenu"><menu>root-menu</menu></action></keybind>
            <keybind key="W-x"><action name="Exit"><prompt>no</prompt></action></keybind>
        </keyboard>
        <mouse>
            <dragThreshold>1</dragThreshold>
            <doubleClickTime>200</doubleClickTime>
            <screenEdgeWarpTime>400</screenEdgeWarpTime>
            <screenEdgeWarpMouse>false</screenEdgeWarpMouse>
            <context name="Frame">
                <mousebind button="A-Left" action="Press"><action name="Focus"/><action name="Raise"/></mousebind>
                <mousebind button="A-Left" action="Click"><action name="Unshade"/></mousebind>
                <mousebind button="A-Left" action="Drag"><action name="Move"/></mousebind>
                <mousebind button="A-Right" action="Press"><action name="Focus"/><action name="Raise"/><action name="Unshade"/></mousebind>
                <mousebind button="A-Right" action="Drag"><action name="Resize"/></mousebind>
                <mousebind button="A-Middle" action="Press"><action name="Lower"/><action name="FocusToBottom"/><action name="Unfocus"/></mousebind>
                <mousebind button="A-Up" action="Click"><action name="GoToDesktop"><to>previous</to></action></mousebind>
                <mousebind button="A-Down" action="Click"><action name="GoToDesktop"><to>next</to></action></mousebind>
                <mousebind button="C-A-Up" action="Click"><action name="GoToDesktop"><to>previous</to></action></mousebind>
                <mousebind button="C-A-Down" action="Click"><action name="GoToDesktop"><to>next</to></action></mousebind>
                <mousebind button="A-S-Up" action="Click"><action name="SendToDesktop"><to>previous</to></action></mousebind>
                <mousebind button="A-S-Down" action="Click"><action name="SendToDesktop"><to>next</to></action></mousebind>
            </context>
            <context name="Titlebar">
                <mousebind button="Left" action="Drag"><action name="Move"/></mousebind>
                <mousebind button="Left" action="DoubleClick"><action name="ToggleMaximize"/></mousebind>
                <mousebind button="Up" action="Click"><action name="if"><shaded>no</shaded><then><action name="Shade"/><action name="FocusToBottom"/><action name="Unfocus"/><action name="Lower"/></then></action></mousebind>
                <mousebind button="Down" action="Click"><action name="if"><shaded>yes</shaded><then><action name="Unshade"/><action name="Raise"/></then></action></mousebind>
            </context>
            <context name="Titlebar Top Right Bottom Left TLCorner TRCorner BRCorner BLCorner">
                <mousebind button="Left" action="Press"><action name="Focus"/><action name="Raise"/><action name="Unshade"/></mousebind>
                <mousebind button="Middle" action="Press"><action name="Lower"/><action name="FocusToBottom"/><action name="Unfocus"/></mousebind>
                <mousebind button="Right" action="Press"><action name="Focus"/><action name="Raise"/><action name="ShowMenu"><menu>client-menu</menu></action></mousebind>
            </context>
            <context name="Top">
                <mousebind button="Left" action="Drag"><action name="Resize"><edge>top</edge></action></mousebind>
            </context>
            <context name="Left">
                <mousebind button="Left" action="Drag"><action name="Resize"><edge>left</edge></action></mousebind>
            </context>
            <context name="Right">
                <mousebind button="Left" action="Drag"><action name="Resize"><edge>right</edge></action></mousebind>
            </context>
            <context name="Bottom">
                <mousebind button="Left" action="Drag"><action name="Resize"><edge>bottom</edge></action></mousebind>
                <mousebind button="Right" action="Press"><action name="Focus"/><action name="Raise"/><action name="ShowMenu"><menu>client-menu</menu></action></mousebind>
            </context>
            <context name="TRCorner BRCorner TLCorner BLCorner">
                <mousebind button="Left" action="Press"><action name="Focus"/><action name="Raise"/><action name="Unshade"/></mousebind>
                <mousebind button="Left" action="Drag"><action name="Resize"/></mousebind>
            </context>
            <context name="Client">
                <mousebind button="Left" action="Press"><action name="Focus"/><action name="Raise"/></mousebind>
                <mousebind button="Middle" action="Press"><action name="Focus"/><action name="Raise"/></mousebind>
                <mousebind button="Right" action="Press"><action name="Focus"/><action name="Raise"/></mousebind>
            </context>
            <context name="Icon">
                <mousebind button="Left" action="Press"><action name="Focus"/><action name="Raise"/><action name="Unshade"/><action name="ShowMenu"><menu>client-menu</menu></action></mousebind>
                <mousebind button="Right" action="Press"><action name="Focus"/><action name="Raise"/><action name="ShowMenu"><menu>client-menu</menu></action></mousebind>
            </context>
            <context name="AllDesktops">
                <mousebind button="Left" action="Press"><action name="Focus"/><action name="Raise"/><action name="Unshade"/></mousebind>
                <mousebind button="Left" action="Click"><action name="ToggleOmnipresent"/></mousebind>
            </context>
            <context name="Shade">
                <mousebind button="Left" action="Press"><action name="Focus"/><action name="Raise"/></mousebind>
                <mousebind button="Left" action="Click"><action name="ToggleShade"/></mousebind>
            </context>
            <context name="Iconify">
                <mousebind button="Left" action="Press"><action name="Focus"/><action name="Raise"/></mousebind>
                <mousebind button="Left" action="Click"><action name="Iconify"/></mousebind>
            </context>
            <context name="Maximize">
                <mousebind button="Left" action="Press"><action name="Focus"/><action name="Raise"/><action name="Unshade"/></mousebind>
                <mousebind button="Middle" action="Press"><action name="Focus"/><action name="Raise"/><action name="Unshade"/></mousebind>
                <mousebind button="Right" action="Press"><action name="Focus"/><action name="Raise"/><action name="Unshade"/></mousebind>
                <mousebind button="Left" action="Click"><action name="ToggleMaximize"/></mousebind>
                <mousebind button="Middle" action="Click"><action name="ToggleMaximize"><direction>vertical</direction></action></mousebind>
                <mousebind button="Right" action="Click"><action name="ToggleMaximize"><direction>horizontal</direction></action></mousebind>
            </context>
            <context name="Close">
                <mousebind button="Left" action="Press"><action name="Focus"/><action name="Raise"/><action name="Unshade"/></mousebind>
                <mousebind button="Left" action="Click"><action name="Close"/></mousebind>
            </context>
            <context name="Desktop">
                <mousebind button="Up" action="Click"><action name="GoToDesktop"><to>previous</to></action></mousebind>
                <mousebind button="Down" action="Click"><action name="GoToDesktop"><to>next</to></action></mousebind>
                <mousebind button="A-Up" action="Click"><action name="GoToDesktop"><to>previous</to></action></mousebind>
                <mousebind button="A-Down" action="Click"><action name="GoToDesktop"><to>next</to></action></mousebind>
                <mousebind button="C-A-Up" action="Click"><action name="GoToDesktop"><to>previous</to></action></mousebind>
                <mousebind button="C-A-Down" action="Click"><action name="GoToDesktop"><to>next</to></action></mousebind>
                <mousebind button="Left" action="Press"><action name="Focus"/><action name="Raise"/></mousebind>
                <mousebind button="Right" action="Press"><action name="Focus"/><action name="Raise"/></mousebind>
            </context>
            <context name="Root">
                <mousebind button="Middle" action="Press"><action name="ShowMenu"><menu>client-list-combined-menu</menu></action></mousebind>
                <mousebind button="Right" action="Press"><action name="ShowMenu"><menu>root-menu</menu></action></mousebind>
            </context>
            <context name="MoveResize">
                <mousebind button="Up" action="Click"><action name="GoToDesktop"><to>previous</to></action></mousebind>
                <mousebind button="Down" action="Click"><action name="GoToDesktop"><to>next</to></action></mousebind>
                <mousebind button="A-Up" action="Click"><action name="GoToDesktop"><to>previous</to></action></mousebind>
                <mousebind button="A-Down" action="Click"><action name="GoToDesktop"><to>next</to></action></mousebind>
            </context>
        </mouse>
        <menu><file>/var/lib/openbox/debian-menu.xml</file><file>menu.xml</file><hideDelay>200</hideDelay><middle>no</middle><submenuShowDelay>100</submenuShowDelay><submenuHideDelay>400</submenuHideDelay><applicationIcons>yes</applicationIcons><manageDesktops>no</manageDesktops></menu>
        <applications>
            <application name="urxvtq"><decor>no</decor><position force="yes"><x>center</x><y>0</y></position><desktop>all</desktop><layer>above</layer><skip_pager>yes</skip_pager><skip_taskbar>yes</skip_taskbar><maximized>Horizontal</maximized></application>
        </applications>
    </openbox_config>


### fehbg

If you want to set a wallpaper background, or better year cycle a set of wallpapers, then `fehbg` is the tool you're looking for!  It has incredibly simple syntax, and is cli friendly.


##### commands

_Throw a bunch of preferred images into `~/.wallpaper/` and create `~/.fehbg` with:_

    (while true; do feh -q --no-fehbg --bg-fill $(find "${HOME}/.wallpaper" -type f | sort -R | tail -1) && sleep 300; done;) &

_Or adjust the directorie to pull pictures from as desired._


### urxvt configuration

This is a basic terminal emulator with unicode support and is very popular.  Configuring it is quite a task, but once you have it you have an excellent utility at your fingertips.

The urxvt configuration is done through `~/.Xdefaults`.  I prefer a dark background and transparency.  I have tmux, so I don't use or enable tabs.

Initially I used `yeahconsole` as a means of creating a drop-down accessible terminal, but I ended up going with an alternative approach due to the short-comings of yeahconsole.


##### commands

**Set default terminal emulator:**

    update-alternatives --set x-terminal-emulator /usr/bin/urxvt

**Configuration to append to `~/.Xdefaults`:**

    ! xft (font)
    Xft.dpi:                    96
    Xft.antialias:              true
    Xft.rgba:                   rgb
    Xft.hinting:                true
    Xft.hintstyle:              hintslight

    ! urxvt (terminal)
    URxvt.depth:                32
    URxvt.geometry:             80x24
    URxvt.fading:               0
    URxvt.loginShell:           true
    URxvt.saveLines:            1000000
    URxvt.internalBorder:       3
    URxvt.lineSpace:            0
    URxvt.scrollStyle:          rxvt
    URxvt.scrollBar:            false
    URxvt.cursorBlink:          true
    URxvt.cursorColor:          #657b83
    URxvt.cursorUnderline:      false
    URxvt.pointerBlank:         true
    URxvt*font:                 xft:ForMateKonaVe:pixelsize=14
    URxvt*letterSpace:          -1
    URxvt.perl-ext-common:      default,matcher
    URxvt.matcher.button:       1
    URxvt.urlLauncher:          x-www-browser

    ! real-transparency
    URxvt*background:           [30]#001E27

    ! psuedo-transparency
    !URxvt.transparent:          true
    !URxvt.shading:              20

    !!
    ! Solarized High Contrast Dark
    !!
    *background:                #001E27
    *foreground:                #9CC2C3
    *fadeColor:                 #002832
    *cursorColor:               #F34F00
    *pointerColorBackground:    #003747
    *pointerColorForeground:    #9CC2C3
    *color0:                    #002831
    *color1:                    #D11C24
    *color2:                    #6CBE6C
    *color3:                    #A57706
    *color4:                    #2176C7
    *color5:                    #C61C6F
    *color6:                    #259286
    *color7:                    #EAE3CB
    *color8:                    #006488
    *color9:                    #F5163B
    *color10:                   #51EF84
    *color11:                   #B27E28
    *color12:                   #178EC8
    *color13:                   #E24D8E
    *color14:                   #00B39E
    *color15:                   #FCF4DC

_For forward compatibility, symlink `~/.Xdefaults` to `~/.Xresources`:_

    ln -s ~/.Xdefaults ~/.Xresources

_To give openbox a means of showing & hiding a true-transparency urxvt instance on demand, I wrote `~/bin/urxvtq`:_

    #!/bin/bash
    if [ $(ps aux | grep -v grep | grep -c "urxvt -name urxvtq") -eq 0 ]
    then
        rm -f /tmp/.urxvtq
        urxvt -name urxvtq -geometry 200x24 &
    fi
    while [ -z "$wid" ]; do wid=$(xdotool search --name urxvtq); done
    if [ -f "/tmp/.urxvtq" ]
    then
        xdotool windowunmap $wid
        rm -f /tmp/.urxvtq
    else
        xdotool windowmap --sync $wid
        xdotool windowfocus $wid
        xdotool windowactivate $wid &> /dev/null
        touch /tmp/.urxvtq
    fi


### configuring & theming conky

I like to have a lightweight conky script running that displays general system status.

I prefer a transparent background to aid in readability, which is helpful when using a dynamically changing background or wallpaper.

There are two ways to acheive transparency.  Conky does not have built-in transparency and requires a compositor be loaded with openbox (such as `xcompmgr` or `compton`).  While `xcompmgr` comes prepackaged, `compton` addresses many bugs with `xcompmgr`.

If you don't want to run a composite manager you can use a lua script with a cairo package dependency to redraw a background for you.  This can be helpful if your system doesn't have a compositor as well (such as a raspberry pi).  _However, it will cause a problem with changing wallpapers where it will keep the old wallpaper for the section where the lua script box exists, until the conky refresh triggers._


##### commands

_Create a directory and file for conky configuration, and symlink it as the default:_

    mkdir -p ~/.conkyrc.d/scripts/lua
    touch ~/.conkyrc.d/slim
    ln -s ~/.conkyrc.d/slim ~/.conkyrc

_Create `~/.conkyrc.d/scripts/lua/bg` with:_

    -- dependencies
    require 'cairo'

    -- settings
    bg_colour = 0x000000
    bg_alpha = 0.35
    corner_r = 10

    -- rgb converter
    function rgb_to_r_g_b(colour,alpha)
        return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
    end

    -- primary bg function
    function conky_draw_bg()
        if conky_window == nil then return end
        local w = conky_window.width
        local h = conky_window.height

    -- create starting point (x/y)
        local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, w, h)
        cr = cairo_create(cs)

    -- draw a box to fill
        cairo_move_to(cr, corner_r, 0)
        cairo_line_to(cr, w-corner_r, 0)
        cairo_curve_to(cr, w, 0, w, 0, w, corner_r)
        cairo_line_to(cr, w, h-corner_r)
        cairo_curve_to(cr, w, h, w, h, w-corner_r, h)
        cairo_line_to(cr, corner_r, h)
        cairo_curve_to(cr, 0, h, 0, h, 0, h-corner_r)
        cairo_line_to(cr, 0, corner_r)
        cairo_curve_to(cr, 0, 0, 0, 0, corner_r, 0)
        cairo_close_path(cr)

    -- set fill color and fill
        cairo_set_source_rgba(cr, rgb_to_r_g_b(bg_colour, bg_alpha))
        cairo_fill(cr)

    end

_Populate ~/.conkyrc.d/slim` with:_

    ##
    # Conky-Slim
    # @author Casey DeLorme <cdelorme@gmail.com>
    ##
    background yes
    update_interval 1.0
    cpu_avg_samples 5
    net_avg_samples 5
    diskio_avg_samples 5
    alignment tm
    gap_y 0
    gap_x 0
    use_xft yes
    xftalpha 0.2
    xftfont ForMateKonaVe:size=9
    uppercase no
    override_utf8_locale yes
    default_color 6CBE6C
    double_buffer yes
    own_window yes
    own_window_hints undecorated,below,sticky,skip_taskbar,skip_pager

    # real transparency
    own_window_transparent no
    own_window_argb_visual yes
    own_window_argb_value 120

    # non-composite psuedo-transparency
    #own_window_transparent yes
    #lua_load ~/.conkyrc.d/scripts/lua/bg
    #lua_draw_hook_pre draw_bg

    ##
    # content
    ##
    TEXT
    cpu ${cpu cpu0}% ${cpubar cpu0 8,120}           ${alignc}mem (${memperc}%) ${mem}/${memmax} ${membar 5,120}          ${alignr}/     (${fs_used_perc /}%) ${fs_bar 5,120 /}
    uptime ${uptime}${alignc}         network address ${addr eth1}${alignr}/home  (${fs_used_perc /home}%) ${fs_bar 5,120 /home}

_Spacing matters and will effect formatting/display.  With these files in place, simply running conky should take care of the rest._


### configuring clipit

First run will ask you some questions and setup some defaults.  You can modify them afterwards by clicking its icon in the `tint2` menubar.


##### commands

_Recommended configuration in `~/.config/clipit/clipitrc`:_

    [rc]
    use_copy=true
    use_primary=true
    synchronize=true
    automatic_paste=false
    show_indexes=false
    save_uris=true
    use_rmb_menu=false
    save_history=false
    history_limit=50
    items_menu=20
    statics_show=true
    statics_items=10
    hyperlinks_only=false
    confirm_clear=false
    single_line=true
    reverse_history=false
    item_length=50
    ellipsize=2
    history_key=<Ctrl><Alt>H
    actions_key=<Ctrl><Alt>A
    menu_key=<Ctrl><Alt>P
    search_key=<Ctrl><Alt>F


### tint2 configuration

    NONE NECESSARY

_I haven't gotten around to this yet, and I haven't found a reason or need to either._


### pcmanfm configuration

    NONE NECESSARY

_I haven't gotten around to this yet, and I haven't found a reason or need to either._


### user configuration

For full privileges users should belong to these groups:

- fuse
- scanner
- bluetooth
- netdev
- audio
- video
- adm
- pulse

Many of these groups are assigned by default when a new user is created through the UI.

The `adm` group is necessary for log access; fuse gives the user mounting privileges.  The `pulse` group is intended for specific volume controls.  The `netdev` group is for network device access, and may not be necessary if you aren't using graphical networking tools (which I don't).  The others are all rather self-explanitory.


##### commands

_This can be done via a **single** command line:_

    usermod -aG adm,audio,video,fuse,scanner,netdev,bluetooth,pulse username


## configuring pulse-audio

For whatever reason pulse-audio refuses to play nicely until you have copied the default configuration file from it's global location to your user folder.  The result is a wonky, and often unresponsive or breaking experience.

It is neither mentioned during the package installation, nor is it easy to find anything to explain the phenomina that happen when you don't, hence why this step is here.


##### commands

_Copy and modify the pulse audio default config:_

    mkdir -p ~/.pulse
    cp /etc/pulse/default.pa ~/.pulse/default.pa


## keep the monitor awake

By default the Xorg/xserver is configured to turn off after inactivity.  Unfortunately it decides what "inactivity" means, and that is effectively keyboard and mouse interaction.

When you have installed a graphical environment and are running a web browser, or playing a video (as simple examples) it will decide to shut off the display if you haven't tapped the keyboard or jiggled the mouse in roughly the past hour.

To fix this I've created two scripts, one to force the system to keep awake, and another to ensure it switches on when you have any of a set number of named applications running.

**You can certainly set this permanently instead, or run the script once at boot with modifications to ensure the monitor never sleeps.**


##### commands

_Create a script at `~/.bin/nosleep` containing:_

    #!/bin/bash
    # run these to prevent the monitor from going to sleep
    xset s 0 0
    xset s noexpose
    xset s noblank
    xset s off
    xset -dpms

_Create another script, `~/.bin/nosleep-daemon` containing:_

    #!/bin/bash
    # run nosleep on a 5 minute interval while any applications below are running
    nosleep_apps=("vlc" "flash" "chrom")
    which nosleep &> /dev/null || exit 1
    while [ true ]
    do
        for app in ${nosleep_apps[*]}
        do
            if [ $(ps aux | grep -v "grep" | grep -c "${app}") -gt 0 ]
            then
                nosleep
            fi
        done
        sleep 300
    done

_Make sure both are executable, then tell openbox to run the daemon when it starts:_

    echo "which nosleep-daemon &> /dev/null && (nosleep-daemon) &" >> ~/.config/openbox/autostart

_As an alternative, you can set the `nosleep` script as a crontab event instead (this may be more reliable, but it will run even if you haven't loaded the gui environment)._


## [youtube downloader](https://github.com/rg3/youtube-dl)

This is a really cool command line utility that you can use to download (the highest quality) youtube videos without any GUI utilities.  It includes asynchronous processing and even spits out the percent status.


##### commands

_Run these commands to download and install the `youtube-dl` command:_

    git clone https://github.com/rg3/youtube-dl
    cd youtube-dl
    sudo python setup.py install
    cd ..
    rm -rf youtube-dl


## google chrome dev channel

I prefer the dev channel of google chrome.  The easy way to install it is to go to your current web browser, search "Google Chrome Dev Channel" and then download the `.deb` and install it with `sudo dpkg -i`.

It should ask to be set as the default browser at first launch.


##### commands

_Register google's apt key:_

    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -

_Create a file at `/etc/apt/sources.list.d/google` with these lines:_

    # Google Chrome repo http://www.google.com/linuxrepositories/
    deb http://dl.google.com/linux/chrome/deb/ stable main
    deb http://dl.google.com/linux/talkplugin/deb/ stable main

_Run these commands to update aptitude:_

    sudo aptitude clean
    sudo aptitude update

_Install these packages:_

    sudo aptitude install -ryq google-chrome-stable google-chrome-unstable google-talkplugin

_Set as default browser:_

    update-alternatives --set x-www-browser /usr/bin/google-chrome-stable

_Remove the duplicate sources to prevent errors on future `aptitude update` commands:_

    rm /etc/apt/sources.list.d/google.list
    rm /etc/apt/sources.list.d/google-chrome-unstable.list


### [sublime text](https://github.com/cdelorme/system-setup/tree/master/shared_config/sublime_text.md)

Since installing and configuring sublime text is nearly identical between platforms I've moved its instructions to a more centralized location.  Click the header link to read it!


## still investigating

I have a lot of software that I have not yet finished researching or have not successfully setup and want to add it to my list someday.


### multiple keyboard layout configuration

This depends on `xorg` currently, but I have a lot of details to work out still.  I'm also working on how to use the `fbxkb` package to toggle layouts.


### pipelight

For linux this is the alternative to silverlight.  You can run a browser in linux while it connects silverlight plugin through a wine bottle.

**I have not yet tested this.**


### [viewnoir](https://github.com/xsisqox/Viewnior)

The viewnior program is a superb lightweight image viewer with quick previews, outmatching most competator image-viewer software.  Unfortunately this software requires newer packages than are available to debian, and attempts to build it have been unsuccessful.  I would like to try previous versions, or in the worst case scenario plan to install it when Debian Jessie is released as the new stable.


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
