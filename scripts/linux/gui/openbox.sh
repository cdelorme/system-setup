#!/bin/bash

# set dependent variables for stand-alone execution
[ -z "$source_cmd" ] && source_cmd="wget --no-check-certificate -qO-"
[ -z "$dl_cmd" ] && dl_cmd="wget --no-check-certificate -O"
[ -z "$remote_source" ] && remote_source="https://raw.githubusercontent.com/cdelorme/system-setup/master/"

# install gui packages
aptitude install -ryq openbox obconf obmenu menu openbox-themes dmz-cursor-theme gnome-icon-theme gnome-icon-theme-extras lxappearance alsa-base alsa-utils pulseaudio volumeicon-alsa xorg xserver-xorg-video-all x11-xserver-utils xinit xinput suckless-tools x11-utils compton desktop-base xdg-user-dirs shared-mime-info tint2 conky-all chromium zenity zenity-common pcmanfm xarchiver feh hsetroot rxvt-unicode gmrun arandr clipit xsel gksu catfish fbxkb xtightvncviewer gparted vlc gtk-recordmydesktop openshot flashplugin-nonfree gimp gimp-plugin-registry evince fontconfig fontconfig-config fonts-droid fonts-freefont-ttf fonts-liberation fonts-takao ttf-mscorefonts-installer

# make sure compton installs
[ -f "scripts/linux/gui/compton.sh" ] && . "scripts/linux/gui/compton.sh" || . <($source_cmd "${remote_source}scripts/linux/gui/compton.sh")

# include chrome
[ -f "scripts/linux/gui/chrome.sh" ] && . "scripts/linux/gui/chrome.sh" || . <($source_cmd "${remote_source}scripts/linux/gui/chrome.sh")

# install global flash projector /w dependencies
dpkg --add-architecture i386
aptitude install -ryq ia32-lib libgtk-3-0:i386 libgtk2.0-0:i386 libasound2-plugins:i386
$dl_cmd /tmp/flash.tar.gz http://fpdownload.macromedia.com/pub/flashplayer/updaters/11/flashplayer_11_sa.i386.tar.gz
tar xf /tmp/flash.tar.gz -C /tmp
rm /tmp/flash.tar.gz
mv /tmp/flashplayer /usr/sbin/flashplayer

# conditionally set global alternatives
if which google-chrome-stable &> /dev/null
then
    update-alternatives --set x-www-browser /usr/bin/google-chrome-stable
fi
if which openbox-session &> /dev/null
then
    update-alternatives --set x-session-manager /usr/bin/openbox-session
fi
if which openbox &> /dev/null
then
    update-alternatives --set x-window-manager /usr/bin/openbox
fi
if which urxvt &> /dev/null
then
    update-alternatives --set x-terminal-emulator /usr/bin/urxvt
fi

# conditionally remove framerate limit
# if which Xorg &>/dev/null
# then
#     Xorg -configure
#     mv /root/xorg.conf.new /etc/X11/xorg.conf
#     sed -i "s/.*SwapbuffersWait.*/Option \"SwapbuffersWait\" \"false\"/" /etc/X11/xorg.conf
# fi

# install tabbedex for urxvt
curl -o /usr/lib/urxvt/perl/tabbedex "https://raw.githubusercontent.com/shaggytwodope/tabbedex-urxvt/master/tabbedex"

# download/install polkit usb mount permissions
mkdir -p /etc/polkit-1/localauthority/50-local.d/
[ -f "data/etc/polkit-1/localauthority/50-local.d/55-storage.pkla" ] && cp "data/etc/polkit-1/localauthority/50-local.d/55-storage.pkla" "/etc/polkit-1/localauthority/50-local.d/55-storage.pkla"  || $dl_cmd "/etc/polkit-1/localauthority/50-local.d/55-storage.pkla" "${remote_source}data/etc/polkit-1/localauthority/50-local.d/55-storage.pkla"

# install custom fonts globally & rebuild cache
mkdir -p /usr/share/fonts/ttf/jis
$dl_cmd "/usr/share/fonts/ttf/jis/ForMateKonaVe.ttf" "${remote_source}data/home/.fonts/ForMateKonaVe.ttf"
$dl_cmd "/usr/share/fonts/ttf/jis/epkyouka.ttf" "${remote_source}data/home/.fonts/epkyouka.ttf"
fc-cache -fr

# user customizations
if [ -n "$username" ]
then

    # add user to general gui groups
    usermod -aG fuse,scanner,bluetooth,netdev,audio,video,plugdev $username

    # ensure user bin folder exists
    mkdir -p "/home/${username}/.bin"

    # add openbox to xinitrc
    echo "exec openbox-session" > "/home/${username}/.xinitrc"

    # copy the defaults.pa into ~/.pulse, for audio control
    mkdir -p "/home/${username}/.pulse"
    cp "/etc/pulse/default.pa" "/home/${username}/.pulse"

    # download/install .fehbg script
    [ -f "data/home/.fehbg" ] && cp "data/home/.fehbg" "/home/${username}/.fehbg"  || $dl_cmd "/home/${username}/.fehbg" "${remote_source}data/home/.fehbg"

    # download/install ~/.Xdefaults & symlink to ~/.Xresources
    [ -f "data/home/.Xdefaults" ] && cp "data/home/.Xdefaults" "/home/${username}/.Xdefaults"  || $dl_cmd "/home/${username}/.Xdefaults" "${remote_source}data/home/.Xdefaults"
    ln -nsf ".Xdefaults" "/home/${username}/.Xresources"

    # download/install urxvtq guake-like-launcher
    [ -f "data/home/.bin/urxvtq" ] && cp "data/.bin/urxvtq" "/home/${username}/.bin/urxvtq"  || $dl_cmd "/home/${username}/.bin/urxvtq" "${remote_source}data/home/.bin/urxvtq"

    # download/install various openbox config files
    mkdir -p "/home/${username}/.config/openbox"
    [ -f "data/home/.config/openbox/autostart" ] && cp "data/.config/openbox/autostart" "/home/${username}/.config/openbox/autostart"  || $dl_cmd "/home/${username}/.config/openbox/autostart" "${remote_source}data/home/.config/openbox/autostart"
    [ -f "data/home/.config/openbox/menu.xml" ] && cp "data/.config/openbox/menu.xml" "/home/${username}/.config/openbox/autostart"  || $dl_cmd "/home/${username}/.config/openbox/menu.xml" "${remote_source}data/home/.config/openbox/menu.xml"
    [ -f "data/home/.config/openbox/rc.xml" ] && cp "data/.config/openbox/rc.xml" "/home/${username}/.config/openbox/autostart"  || $dl_cmd "/home/${username}/.config/openbox/rc.xml" "${remote_source}data/home/.config/openbox/rc.xml"

    # download/install clipitrc
    mkdir -p "/home/${username}/.config/clipit"
    [ -f "data/home/.config/clipit/clipitrc" ] && cp "data/.config/clipit/clipitrc" "/home/${username}/.config/clipit/clipitrc"  || $dl_cmd "/home/${username}/.config/clipit/clipitrc" "${remote_source}data/home/.config/clipit/clipitrc"

    # @todo download/install tint2 config (not sure if this is necessary, I believe I use the default)
    # [ -f "data/home/.config/tint2/tint2rc" ] && cp "data/.config/tint2/tint2rc" "/home/${username}/.config/tint2/tint2rc"  || $dl_cmd "/home/${username}/.config/tint2/tint2rc" "${remote_source}data/home/.config/tint2/tint2rc"

    # download/install volumeicon config
    mkdir -p "/home/${username}/.config/volumeicon"
    [ -f "data/home/.config/volumeicon/volumeicon" ] && cp "data/.config/volumeicon/volumeicon" "/home/${username}/.config/volumeicon/volumeicon"  || $dl_cmd "/home/${username}/.config/volumeicon/volumeicon" "${remote_source}data/home/.config/volumeicon/volumeicon"

    # download/install conkyrc
    [ -f "data/home/.conkyrc" ] && cp "data/.conkyrc" "/home/${username}/.conkyrc"  || $dl_cmd "/home/${username}/.conkyrc" "${remote_source}data/home/.conkyrc"

    # check for ethernet devices
    if [ $(ifconfig | grep -c "eth1 ") -eq 0 ]
    then
        sed -i "s/eth1/eth0/" "/home/${username}/.conkyrc"
    fi

    # check for multihead to adjust conky
    if [ $(xrandr -d :0 -q | grep -c " connected") -ge 2 ]
    then

        # create two configurations
        mkdir -p "/home/${username}/.conky"
        mv -f "/home/${username}/.conkyrc" "/home/${username}/.conky/rc1"
        cp -f "/home/${username}/.conky/rc1" "/home/${username}/.conky/rc2"

        # adjust settings for dual-screens (assuming 1920 display resolutions)
        sed -i "s/gap_x 0/gap_x 960/" "/home/${username}/.conky/rc1"
        sed -i "s/gap_x 0/gap_x -960/" "/home/${username}/.conky/rc2"

        # patch openbox autostart
        sed -i "s;conky -d -q;conky -d -q -c /home/${username}/.conky/rc1;" "/home/${username}/.config/openbox/autostart"
        echo "which conky &> /dev/null && (sleep 10 && conky -d -q -c /home/${username}/.conky/rc2) &" >> "/home/${username}/.config/openbox/autostart"
    fi

    # @todo configure desktop mimetype defaults
    mkdir -p "/home/${username}/.local/share/applications"
    [ -f "data/home/.local/share/applications/animate.desktop" ] && cp "data/home/.local/share/applications/animate.desktop" "/home/${username}/.local/share/applications/animate.desktop"  || $dl_cmd "/home/${username}/.local/share/applications/animate.desktop" "${remote_source}data/home/.local/share/applications/animate.desktop"
    [ -f "data/home/.local/share/applications/flash.desktop" ] && cp "data/home/.local/share/applications/flash.desktop" "/home/${username}/.local/share/applications/flash.desktop"  || $dl_cmd "/home/${username}/.local/share/applications/flash.desktop" "${remote_source}data/home/.local/share/applications/flash.desktop"
    [ -f "data/home/.local/share/applications/subl.desktop" ] && cp "data/home/.local/share/applications/subl.desktop" "/home/${username}/.local/share/applications/subl.desktop"  || $dl_cmd "/home/${username}/.local/share/applications/subl.desktop" "${remote_source}data/home/.local/share/applications/subl.desktop"
    [ -f "data/home/.local/share/applications/mimeapps.list" ] && cp "data/home/.local/share/applications/mimeapps.list" "/home/${username}/.local/share/applications/mimeapps.list"  || $dl_cmd "/home/${username}/.local/share/applications/mimeapps.list" "${remote_source}data/home/.local/share/applications/mimeapps.list"
    update-desktop-database

    # @todo install nosleep & daemon files
    [ -f "data/home/.bin/nosleep" ] && cp "data/.bin/nosleep" "/home/${username}/.bin/nosleep"  || $dl_cmd "/home/${username}/.bin/nosleep" "${remote_source}data/home/.bin/nosleep"
    [ -f "data/home/.bin/nosleep-daemon" ] && cp "data/.bin/nosleep-daemon" "/home/${username}/.bin/nosleep-daemon"  || $dl_cmd "/home/${username}/.bin/nosleep-daemon" "${remote_source}data/home/.bin/nosleep-daemon"
fi

# include sublime-text-3.sh
[ -f "scripts/linux/gui/sublime-text-3.sh" ] && . "scripts/linux/gui/sublime-text-3.sh" || . <($source_cmd "${remote_source}scripts/linux/gui/sublime-text-3.sh")