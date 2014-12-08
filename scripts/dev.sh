#!/bin/bash

# load template
[ -f "scripts/template.sh" ] && . "scripts/template.sh" || . <($source_cmd "${remote_source}scripts/template.sh")

# conditionall load web services
[[ "$install_web" = "y" && -f "scripts/web.sh" ]] && . "scripts/web.sh" || . <($source_cmd "${remote_source}scripts/web.sh")

##
# @todo install massive selection of additional packages
##
aptitude install -ryq fontconfig

# breakdown gui & dev packages to part-of & optional
# bluez bluez-tools bluez-utils alsa-base alsa-utils pulseaudio pulseaudio-bluetooth pavucontrol shared-mime-info suckless-tools transmission transmission-cli xdg-user-dirs xorg xserver-xorg-video-all xsel xinit xinput x11-utils x11-xserver-utils arandr gksu gmrun hsetroot desktop-base dmz-cursor-theme lxappearance gnome-icon-theme gnome-icon-theme-extras menu obconf obmenu openbox openbox-themes openshot pcmanfm rxvt-unicode tint2 catfish clipit conky-all volumeicon-alsa zenity zenity-common xtightvncviewer gparted chromium google-chrome-stable google-talkplugin fbxkb fontconfig fontconfig-config fonts-droid fonts-droid fonts-freefont-ttf fonts-liberation fonts-takao ttf-mscorefonts-installer deb-multimedia-keyring libfaac-dev libx264-dev lame ffmpeg vlc flashplugin-nonfree evince feh gtk-recordmydesktop gimp gimp-plugin-registry libconfig-dev libdbus-1-dev libdrm-dev libx11-dev libxcomposite-dev libxdamage-dev libxext-dev libxfixes-dev libXinerama-dev libxrandr-dev libxrender-dev libpcre3-dev libgl1-mesa-dev
# build-essential debconf-utils debhelper git-flow g++ kernel-package libncurses5-dev devscripts bpython openjdk-7-jre python-dev python3-dev



# # youtube-dl installation
# git clone https://github.com/rg3/youtube-dl /tmp/youtube-dl
# (cd /tmp/youtube-dl && python setup.py install)
# rm -rf /tmp/youtube-dl

# conditionally install golang 1.3 manually
# hg clone -u go1.3.1 https://code.google.com/p/go /tmp/go
# (cd /tmp/go/src && GOROOT_FINAL="/usr/lib/go" ./make.bash)
# mv /tmp/go /usr/lib/
# mkdir -p /usr/share/doc/golang-doc /usr/share/go/
# mv /usr/lib/go/src /usr/share/go/
# mv /usr/lib/go/doc /usr/share/doc/golang-doc/html
# mv /usr/lib/go/favicon.ico /usr/share/doc/golang-doc/
# ln -sf /usr/share/go/src /usr/lib/go/src
# ln -sf /usr/share/doc/golang-doc/html /usr/lib/go/doc
# ln -sf /usr/lib/go/favicon.ico /usr/share/doc/golang-doc/favicon.ico
# ln -sf /usr/lib/go/bin/go /usr/local/bin/go
# ln -sf /usr/lib/go/bin/gofmt /usr/local/bin/gofmt

# @todo add golang vim plugin installation for user
# echo '" add go fmt' >> ~/.vimrc
# echo 'autocmd FileType go autocmd BufWritePre <buffer> Fmt' >> ~/.vimrc
# cp -R /usr/lib/go/misc/vim/* ~/.vim/
# @todo OR dynamically install golang vim plugin & don't add fmt to vimrc (avoid problems with saving?)
# which go 2>/dev/null && cp -R "$(go env GOROOT)/misc/vim/" "$DOWNLOADS/.vim"


##
# @todo install a bunch of conditional services
##


# @todo conditionally pre-configure & install mdadm /w debconf selections or automation
# echo "mdadm   mdadm/autostart boolean true" | debconf-set-selections
# echo "mdadm   mdadm/autocheck boolean true" | debconf-set-selections
# echo "mdadm   mdadm/mail_to   string  root" | debconf-set-selections
# echo "mdadm   mdadm/initrdstart   string  all" | debconf-set-selections
# echo "mdadm   mdadm/initrdstart_notinconf boolean false" | debconf-set-selections
# echo "mdadm   mdadm/start_daemon  boolean true" | debconf-set-selections
# aptitude install -ryq mdadm

# @todo conditionally install weechat
# aptitude install -ryq weechat-ncurses

# @todo conditionally install transmission
# aptitude install -ryq transmission-daemon
# config_bt_max_down=3000
# config_bt_max_up=80
# config_bt_watch_path="/tmp"
# config_bt_incomplete_path="/tmp"
# config_bt_complete_path="/tmp"
# config_bt_web_accessible=true
# config_bt_web_port=9010
# @todo download transmission monit

# @todo conditionally install openbox

# @todo conditionally install samba
# aptitude install -ryq samba samba-tools smbclient
# usermod -aG sambashare $username
# @todo download samba monit

##
# @todo configure installed services
##

# install custom fonts globally & rebuild cache
mkdir -p /usr/share/fonts/ttf/jis
$dl_cmd "/usr/share/fonts/ttf/jis/ForMateKonaVe.ttf" "${remote_source}data/home/.fonts/ForMateKonaVe.ttf"
$dl_cmd "/usr/share/fonts/ttf/jis/epkyouka.ttf" "${remote_source}data/home/.fonts/epkyouka.ttf"
fc-cache -fr

# configure sensors for desktop systems
which sensors-detect &>/dev/null && (yes "" | sensors-detect)



##
# OLD SOURCE
##

# openbox options:

# google chrome
# wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
# echo "# Google Chrome repo http://www.google.com/linuxrepositories/" > /etc/apt/sources.list.d/google.list
# echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list
# echo "deb http://dl.google.com/linux/talkplugin/deb/ stable main" >> /etc/apt/sources.list.d/google.list
# echo "deb http://dl.google.com/linux/earth/deb/ stable main" >> /etc/apt/sources.list.d/google.list
# echo "deb http://dl.google.com/linux/musicmanager/deb/ stable main" >> /etc/apt/sources.list.d/google.list
# # cleanup chrome sources
# rm -f /etc/apt/sources.list.d/google.list /etc/apt/sources.list.d/google-chrome-unstable.list

# # attempt compton installation
# git clone https://github.com/chjj/compton.git /tmp/compton
# (cd /tmp/compton && make && make install)
# rm -rf /tmp/compton
# aptitude purge -ryq asciidoc
# aptitude clean

# @todo update default services if they exist
# if which google-chrome-stable &> /dev/null
# then
#     update-alternatives --set x-www-browser /usr/bin/google-chrome-stable
# fi
# if which openbox-session &> /dev/null
# then
#     update-alternatives --set x-session-manager /usr/bin/openbox-session
# fi
# if which openbox &> /dev/null
# then
#     update-alternatives --set x-window-manager /usr/bin/openbox
# fi
# if which urxvt &> /dev/null
# then
#     update-alternatives --set x-terminal-emulator /usr/bin/urxvt
# fi

# @todo add user to groups
# if which openbox &> /dev/null
# then
#     usermod -aG plugdev,video,audio,bluetooth,netdev,fuse,scanner,pulse-access $username
# fi

# @todo remove framerate limit (if xorg is installed)
# (cd /etc/X11 && Xorg --configure)
# sed -i "s/.*SwapbuffersWait.*/Option \"SwapbuffersWait\" \"false\"/" /etc/X11/xorg.conf
