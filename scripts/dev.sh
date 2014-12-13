#!/bin/bash

# load template
[ -f "scripts/template.sh" ] && . "scripts/template.sh" || . <($source_cmd "${remote_source}scripts/template.sh")

# conditionall load web services
[[ "$install_web" = "y" && -f "scripts/web.sh" ]] && . "scripts/web.sh" || . <($source_cmd "${remote_source}scripts/web.sh")

# @todo conditionally disable services at boot-time

# install basic dev packages
aptitude install -ryq firmware-linux firmware-linux-free firmware-linux-nonfree usbutils uuid-runtime gvfs-fuse exfat-fuse exfat-utils fuse-utils sshfs fusesmb e2fsprogs parted os-prober lzop p7zip-full p7zip-rar zip unrar unace rzip unalz zoo arj pastebinit anacron miscfiles markdown asciidoc lm-sensors cpufrequtils lame ffmpeg libfaac-dev libx264-dev imagemagick graphicsmagick libogg-dev libvorbis-dev vorbis-tools build-essential openjdk-7-jre pkg-config devscripts bpython python-dev python-pip python3-dev python3-pip libncurses5-dev libmcrypt-dev libperl-dev libconfig-dev libpcre3-dev

# configure sensors
which sensors-detect &>/dev/null && (yes "" | sensors-detect)

# include youtube-dl
[ -f "scripts/linux/workstation/youtube-dl.sh" ] && . "scripts/linux/workstation/youtube-dl.sh" || . <($source_cmd "${remote_source}scripts/linux/workstation/youtube-dl.sh")

# install golang
[ -f "scripts/linux/dev/golang.sh" ] && . "scripts/linux/dev/golang.sh" || . <($source_cmd "${remote_source}scripts/linux/dev/golang.sh")

# conditionally install & configure wireless
if [ "$install_wireless" = "y" ]
then
    [ -f "scripts/linux/workstation/wireless.sh" ] && . "scripts/linux/workstation/wireless.sh" || . <($source_cmd "${remote_source}scripts/linux/workstation/wireless.sh")
fi

# conditionally install mdadm
if [ "$install_mdadm" = "y" ]
then
    [ -f "scripts/linux/comm/mdadm.sh" ] && . "scripts/linux/comm/mdadm.sh" || . <($source_cmd "${remote_source}scripts/linux/comm/mdadm.sh")
fi

# conditionally install & configure samba
if [ "$install_samba" = "y" ]
then
    [ -f "scripts/linux/comm/samba.sh" ] && . "scripts/linux/comm/samba.sh" || . <($source_cmd "${remote_source}scripts/linux/comm/samba.sh")
fi

# conditionally install weechat
if [ "$install_weechat" = "y" ]
then
    [ -f "scripts/linux/comm/weechat.sh" ] && . "scripts/linux/comm/weechat.sh" || . <($source_cmd "${remote_source}scripts/linux/comm/weechat.sh")
fi

# conditionally install transmission
if [ "$install_transmission" = "y" ]
then
    [ -f "scripts/linux/comm/transmission.sh" ] && . "scripts/linux/comm/transmission.sh" || . <($source_cmd "${remote_source}scripts/linux/comm/transmission.sh")
fi

# conditionally install openbox
if [ "$install_openbox" = "y" ]
then
    [ -f "scripts/linux/gui/openbox.sh" ] && . "scripts/linux/gui/openbox.sh" || . <($source_cmd "${remote_source}scripts/linux/gui/openbox.sh")
fi

# reset user folder ownership
chown -R $username:$username /home/$username