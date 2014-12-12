#!/bin/bash

# @todo install base packages
# aptitude install -ryq
# alsa-base alsa-utils pulseaudio pulseaudio-bluetooth pavucontrol
# xorg xserver-xorg-video-all xsel xinit xinput x11-utils x11-xserver-utils
# arandr gksu gmrun hsetroot desktop-base dmz-cursor-theme lxappearance
# gnome-icon-theme gnome-icon-theme-extras menu obconf obmenu openbox
# openbox-themes openshot pcmanfm rxvt-unicode tint2 catfish clipit conky-all
# volumeicon-alsa zenity zenity-common xtightvncviewer gparted fbxkb
# deb-multimedia-keyring flashplugin-nonfree
# vlc evince feh gtk-recordmydesktop gimp gimp-plugin-registry libconfig-dev
# libdbus-1-dev libdrm-dev libx11-dev libxcomposite-dev libxdamage-dev libxext-dev
# libxfixes-dev libXinerama-dev libxrandr-dev libxrender-dev libpcre3-dev libgl1-mesa-dev

# @todo include compton
# @todo include chrome

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
if which Xorg &>/dev/null
then
    (cd /etc/X11 && Xorg --configure)
    sed -i "s/.*SwapbuffersWait.*/Option \"SwapbuffersWait\" \"false\"/" /etc/X11/xorg.conf
fi

# install custom fonts globally & rebuild cache
mkdir -p /usr/share/fonts/ttf/jis
$dl_cmd "/usr/share/fonts/ttf/jis/ForMateKonaVe.ttf" "${remote_source}data/home/.fonts/ForMateKonaVe.ttf"
$dl_cmd "/usr/share/fonts/ttf/jis/epkyouka.ttf" "${remote_source}data/home/.fonts/epkyouka.ttf"
fc-cache -fr

# add user to general gui groups
usermod -aG plugdev,video,audio,bluetooth,netdev,fuse,scanner,pulse-access $username

# add openbox to xinitrc
echo "exec openbox-session" > "/home/${username}/.xinitrc"

# copy the defaults.pa into ~/.pulse, for audio control
mkdir -p "/home/${username}/.pulse"
cp "/etc/pulse/default.pa" "/home/${username}/.pulse"

# @todo download/install .fehbg script
# @todo download/install Xdefaults
# symlink xdefaults to xresources
# ln -nsf .Xdefaults /home/$username/.Xresources
# @todo download/install urxvt launcher
# @todo download/install various openbox config files
#   autostart, menu.xml, rc.xml
# @todo download/install clipitrc
# @todo download/install tint2 config
# @todo download/install volumeicon config
# @todo download/install conkyrc
# @todo configure desktop mimetype defaults

# @todo download/install user-local sublime-text-3
# @todo create subl shell script to search for user-local subl else run global sublime text 3??
