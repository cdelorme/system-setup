#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# fail if not running as root
[ $(id -u) -ne 0 ] && echo "must be executed with root permissions..." && exit 1

# loop read-input until env var is populated
grab_input() {
	until [ -n "$(eval echo \${$1:-})" ]; do
		read -p "${2:-input}: " ${1}
	done
}

# loop hidden read-input until env var is populated
grab_password() {
	until [ -n "$(eval echo \${$1:-})" ]; do
		read -p "${2:-input}: " -s ${1}
		echo ""
	done
}

# loop read-input until env var is populated with y or n
grab_yn() {
	until [[ "$(eval echo \${$1:-})" = "y" || "$(eval echo \${$1:-})" = "n" ]]; do
		read -p "${2:-input} (y/n)? " ${1}
	done
}

# gather configuration details via user input
grab_yn "workstation" "is this a workstation"
grab_input "username" "enter your username"
grab_password "password" "enter your user password"
grab_input "github_username" "enter your github username"
su $username -c '[ -f ~/.ssh/id_rsa ]' 2>/dev/null || grab_yn "generate_ssh_key" "create an ssh key"
(su $username -c '[ -f ~/.ssh/id_rsa ]' 2>/dev/null || [ "${generate_ssh_key:-n}" = "y" ]) && grab_yn "github_ssh_key" "upload ssh key to github"
[ "${github_ssh_key:-n}" = "y" ] && grab_password "github_password" "enter your github password"

# enable debug mode so we can witness execution
set -x

# remove cdrom entries from apt sources
sed -i '/cdrom/d' /etc/apt/sources.list

# install baseline utilities
apt-get clean
apt-get update
apt-get upgrade -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y
until apt-get install -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y ssh sudo parted lm-sensors lzma unzip screen tmux vim resolvconf ntp curl git mercurial bzr subversion command-not-found; do sleep 1; done

# set vim.basic as the default editor
update-alternatives --set editor /usr/bin/vim.basic

# configure sensors
which sensors-detect &>/dev/null && (yes | sensors-detect) || true

# optimize uefi boot (case sensitive)
if [ ! -d /boot/efi/EFI/BOOT ]; then
	mkdir -p /boot/efi/EFI/BOOT
	echo "FS0:\EFI\debian\grubx64.efi" > /boot/efi/startup.nsh
	cp -f /boot/efi/EFI/debian/grubx64.efi /boot/efi/EFI/BOOT/bootx64.efi
fi

# optimize btrfs
if [ "$(mount -t btrfs | awk '{print $3}' | grep -c '/')" -gt 0 ]; then
	export btrfs_optimizations="noatime,compress=lzo,space_cache,autodefrag"

	# create /home subvolume if it is not already a subvolume
	if [ "$(btrfs subvol list / | awk '{print $9}')" != "home" ]; then
		mv -f /home /home.bak
		btrfs subvol create /home
		find /home.bak -mindepth 1 -maxdepth 1 -exec cp -R {} /home/ \;
		rm -rf /home.bak/
	fi

	# check whether fstab already contains optimizations
	if [ $(grep '\s/\s' /etc/fstab | grep -c "${btrfs_optimizations}") -eq 0 ]; then

		# verify if ssd is being used
		export root_partition="$(mount | awk -v dev='/' '$3==dev {print $1}')"
		export root_disk="${root_partition:5:3}"
		[ $(cat /sys/block/${root_disk}/queue/rotational) -eq 0 ] && export btrfs_optimizations="${btrfs_optimizations},ssd"

		# add optimizations
		sed -i "s;/.*btrfs.*;/\tbtrfs\t${btrfs_optimizations}\t0\t1;" /etc/fstab

		# defragment and rebalance
		set +eu
		btrfs filesystem defragment -rfclzo / &>/dev/null
		mount -n -o "remount,${btrfs_optimizations}" $root_partition /
		btrfs balance start /
		set -eu
	fi
fi

# install data files
if ([ -d linux/debian/data/base ] && [ -d linux/debian/data/desktop ]); then
	cp -fR linux/debian/data/base/* /
	[ "$workstation" = "y" ] && cp -fR linux/debian/data/desktop/* /
else
	([ -d /tmp/system-setup ] && cd /tmp/system-setup && git pull) || git clone https://github.com/cdelorme/system-setup /tmp/system-setup
	cp -fR /tmp/system-setup/linux/debian/data/base/* /
	[ "$workstation" = "y" ] && cp -fR /tmp/system-setup/linux/debian/data/desktop/* /
fi

# install global dot-files
curl -Ls https://raw.githubusercontent.com/cdelorme/dot-files/master/install | bash -s -- -q

# reboot after timeout on kernel panic
[ $(grep -c "panic=10" /etc/default/grub) -eq 0 ] && sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 panic=10"/' /etc/default/grub && update-grub
[ $(grep -c "panic = 10" /etc/sysctl.conf) -eq 0 ] && echo "kernel.panic = 10" >> /etc/sysctl.conf

# add pam tally locking
[ $(grep -c "pam_tally2" /etc/pam.d/common-auth) -eq 0 ] && echo "auth required pam_tally2.so deny=4 even_deny_root onerr=fail unlock_time=600 root_unlock_time=60" >> /etc/pam.d/common-auth
[ $(grep -c "pam_tally2" /etc/pam.d/common-account) -eq 0 ] && echo "account required pam_tally2.so" >> /etc/pam.d/common-account

# fix default permissions (secure by group)
sed -i 's/UMASK\s*022/UMASK\t\t002/' /etc/login.defs
if [ $(grep -c "umask=002" /etc/pam.d/common-session) -eq 0 ]; then
	echo "session optional pam_umask.so umask=002" >> /etc/pam.d/common-session
fi

# secure & optimize ssh
sed -i "s/^#\?PermitRootLogin.*[yn].*/PermitRootLogin no/" /etc/ssh/sshd_config
sed -i "s/^#\?PasswordAuthentication\s*[yn].*/PasswordAuthentication no/" /etc/ssh/sshd_config
sed -i "s/^#\?GSSAPIAuthentication.*/GSSAPIAuthentication no/" /etc/ssh/sshd_config
sed -i "s/^#\?UseDNS.*/UseDNS no/" /etc/ssh/sshd_config
[ $(grep -c 'GSSAPIAuthentication no' /etc/ssh/sshd_config) -eq 0 ] && echo "GSSAPIAuthentication no" >> /etc/ssh/sshd_config
[ $(grep -c 'UseDNS no' /etc/ssh/sshd_config) -eq 0 ] && echo "UseDNS no" >> /etc/ssh/sshd_config

# optimize lvm
[ -f /etc/lvm/lvm.conf ] && sed -i 's/issue_discards = 0/issue_discards = 1/' /etc/lvm/lvm.conf

# eliminate udev network persistence
if [ ! -d /etc/udev/rules.d/70-persistent-net.rules ]; then
	rm -f /etc/udev/rules.d/70-persistent-net.rules
	mkdir -p /etc/udev/rules.d/70-persistent-net.rules
fi

# disable capslock forever in favor of ctrl & reload console configuration
if [ $(grep "XKBOPTIONS" /etc/default/keyboard | grep -c "ctrl:nocaps") -eq 0 ]; then
	sed -i 's/XKBOPTIONS.*/XKBOPTIONS="ctrl:nocaps"/' /etc/default/keyboard
	dpkg-reconfigure -phigh console-setup
fi

# enable jis and load any installed fonts
[ $(grep "# ja_JP.UTF-8" -F /etc/locale.gen) -eq 0 ] || sed -i "s/# ja_JP\.UTF-8 UTF-8/ja_JP.UTF-8 UTF-8/" /etc/locale.gen
locale-gen
fc-cache -fr

# update command not found archive
update-command-not-found

# install dot-files for root
find /etc/skel -mindepth 1 -maxdepth 1 -exec cp -R {} /root/ \;

# reload ssh and iptables
systemctl restart ssh
/etc/network/if-up.d/iptables

# create and configure non-root user
if [ "$username" != "root" ]; then
	id $username &>/dev/null || useradd -m -s /bin/bash -p $(mkpasswd -m md5 "$password") $username
	usermod -aG sudo,users,disk,adm,netdev,plugdev $username

	# add crontab entry for user to run update-keys with github username hourly
	if [ ! -f "/var/spool/cron/crontabs/${username}" ] || [ $(grep -c "update-keys" "/var/spool/cron/crontabs/${username}") -eq 0 ]; then
		echo "@hourly /usr/local/bin/update-keys $github_username" >> /var/spool/cron/crontabs/$username
		chown $username:crontab "/var/spool/cron/crontabs/${username}"
		chmod 600 "/var/spool/cron/crontabs/${username}"
	fi

	# run update-keys as the user now
	su $username -c "which update-keys &>/dev/null && update-keys $github_username"

	# generate ssh key and optionally upload to github
	if [ "${generate_ssh_key:-n}" = "y" ] && su $username -c '[ ! -f ~/.ssh/id_rsa ]' 2>/dev/null; then
		su $username -c "cd && ssh-keygen -q -b 4096 -t rsa -N "$password" -f ~/.ssh/id_rsa"
		su $username -c "cd && chmod 600 ~/.ssh/id_rsa && chmod 600 ~/.ssh/id_rsa.pub"
		if su $username -c '[ -f ~/.ssh/id_rsa.pub ]' 2>/dev/null && [ "${github_ssh_key:-n}" = "y" ]; then
			su $username -c "cd && curl -Li -u '${github_username}:${github_password:-}' -H 'Content-Type: application/json' -H 'Accept: application/json' -X POST -d \"{\\\"title\\\":\\\"$(hostname -s) ($(date '+%Y/%m/%d'))\\\",\\\"key\\\":\\\"$(cat ~/.ssh/id_rsa.pub)\\\"}\" https://api.github.com/user/keys"
			# curl -Li -u "${github_username}:${github_password:-}" -H "Content-Type: application/json" -H "Accept: application/json" -X POST -d "{\"title\":\"$(hostname -s) ($(date '+%Y/%m/%d'))\",\"key\":\"$(cat ~/.ssh/id_rsa.pub)\"}" https://api.github.com/user/keys

			# optimize gitconfig to use loaded ssh key
			su $username -c "cd && git config --global url.git@github.com:.insteadOf https://github.com"
		fi
	fi

	# use github username to acquire name & email from github
	tmpdata=$(curl -Ls "https://api.github.com/users/${github_username}")
	github_name=$(echo "$tmpdata" | grep name | cut -d ':' -f2 | tr -d '",' | sed "s/^ *//")
	github_email=$(echo "$tmpdata" | grep email | cut -d ':' -f2 | tr -d '":,' | sed "s/^ *//")
	su $username -c "cd && git config --global user.name $github_username"
	su $username -c "cd && git config --global user.email $github_email"
fi

# finish with a positive exit code
[ "${workstation:-n}" != "y" ] && exit 0

# register other sources for installation
wget --no-check-certificate -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
echo "# Google Chrome repo http://www.google.com/linuxrepositories/" > /etc/apt/sources.list.d/google-tmp.list
echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-tmp.list
echo "deb [arch=amd64] http://dl.google.com/linux/talkplugin/deb/ stable main" >> /etc/apt/sources.list.d/google-tmp.list
echo "deb [arch=amd64] http://dl.google.com/linux/earth/deb/ stable main" >> /etc/apt/sources.list.d/google-tmp.list
echo "deb [arch=amd64] http://dl.google.com/linux/musicmanager/deb/ stable main" >> /etc/apt/sources.list.d/google-tmp.list
echo "deb http://ftp.debian.org/debian jessie-backports main" > /etc/apt/sources.list.d/backports.list

# enable multiarch
dpkg --add-architecture i386

# install desktop utilities
apt-get clean
apt-get update
until apt-get install -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y linux-headers-amd64 dkms menu build-essential gcc-multilib g++-multilib cmake bison pkg-config libncurses-dev firmware-linux uuid-runtime exfat-fuse exfat-utils libimobiledevice-utils gvfs gvfs-bin ssh sshfs bluez xboxdrv libsdl1.2-dev libsdl2-dev lzop p7zip-full p7zip-rar zip unzip unrar unace rzip unalz zoo arj anacron miscfiles xorg xinit consolekit openbox obconf obmenu pcmanfm tint2 conky-all xarchiver feh hsetroot rxvt-unicode gparted hardinfo gmrun clipit graphicsmagick lame libvorbis-dev vorbis-tools libogg-dev libexif-dev libfaac-dev libx264-dev id3 mplayer kazam guvcview openshot gimp gimp-plugin-registry viewnior evince fonts-droid fonts-freefont-ttf fonts-liberation fonts-takao ttf-mscorefonts-installer ibus-mozc pulseaudio pavucontrol pasystray compton ffmpeg ffmpegthumbnailer chromium google-chrome-stable google-talkplugin mednafen mame joystick libgtk2.0-0:i386 libxt6:i386 libnss3:i386 libcurl3:i386; do sleep 1; done
until apt-get install -yt jessie-backports playonlinux; do sleep 1; done

# cleanup duplicate sources post-installation
rm -f /etc/apt/sources.list.d/google-tmp.list
apt-get clean
apt-get update

# install nvidia driver from backports
if [ $(lspci | grep -i " vga" | grep -ci " nvidia") -gt 0 ]; then
	apt-get install -yt jessie-backports nvidia-driver
	[ $(grep -c "nomodeset" /etc/default/grub) -eq 0 ] && sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 nomodeset"/' /etc/default/grub && update-grub
fi

# install steam
if ! which steam &>/dev/null; then
	[ -f /tmp/steam.deb ] && rm -f /tmp/steam.deb
	curl -Lo /tmp/steam.deb http://repo.steampowered.com/steam/archive/precise/steam_latest.deb
	dpkg -i /tmp/steam.deb || apt-get install -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -fy
fi

# detect & install firmware packages based on known device names
[ $(lspci | grep -ci "realtek") -gt 0 ] && apt-get install -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y firmware-realtek
[ $(lspci | grep -i "wireless" | grep -ci "atheros") -gt 0 ] && apt-get install -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y firmware-atheros
[ $(lspci | grep -i "wireless" | grep -ci "broadcom") -gt 0 ] && apt-get install -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y firmware-brcm80211
[ $(lspci | grep -i "wireless" | grep -ci "intel") -gt 0 ] && apt-get install -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y firmware-iwlwifi

# enable xboxdrv
echo "blacklist xpad" > /etc/modprobe.d/blacklist-xpad.conf
systemctl enable xboxdrv.service
systemctl restart xboxdrv.service

# build and install ppsspp
[ -d /usr/local/src/ppsspp ] || git clone https://github.com/hrydgard/ppsspp.git /usr/local/src/ppsspp
if ! which psp &>/dev/null; then
	pushd /usr/local/src/ppsspp
	git pull
	git checkout v1.3
	git submodule update --init --recursive
	./b.sh
	ln -fs /usr/local/src/ppsspp/build/PPSSPPSDL /usr/local/bin/psp
	popd
fi

# build 32&64 sdl2
if [ ! -d /usr/local/src/SDL2-2.0.5 ]; then
	curl -Lso /tmp/sdl2.tar.gz https://www.libsdl.org/release/SDL2-2.0.5.tar.gz
	tar -C /usr/local/src -xf /tmp/sdl2.tar.gz
	rm /tmp/sdl2.tar.gz
	mkdir -p /usr/local/src/SDL2-2.0.5/{build,build_i386}

	pushd /usr/local/src/SDL2-2.0.5/build
	../configure
	make
	popd

	pushd /usr/local/src/SDL2-2.0.5/build_i386
	CFLAGS=-m32 CXXFLAGS=-m32 LDFLAGS=-m32 ../configure --build=i386-linux
	CFLAGS=-m32 CXXFLAGS=-m32 LDFLAGS=-m32 make
	make install
	popd

	ldconfig
fi

# build koku-xinput-wine as a wine/playonlinux controller plugin
if [ ! -d /usr/local/src/koku-xinput-wine ]; then
	git clone https://github.com/KoKuToru/koku-xinput-wine.git /usr/local/src/koku-xinput-wine
	mkdir -p /usr/local/src/koku-xinput-wine/build
	pushd /usr/local/src/koku-xinput-wine/build
	cmake ..
	make
	chown :input koku-xinput-wine.so
	chmod 0775 koku-xinput-wine.so
	popd
fi

# install 32bit flash projector (64bit is buggy on exit)
curl -Lso /tmp/flash.tar.gz "https://fpdownload.macromedia.com/pub/flashplayer/updaters/11/flashplayer_11_sa.i386.tar.gz"
tar xf /tmp/flash.tar.gz -C /tmp
rm -f /tmp/flash.tar.gz
mv /tmp/flashplayer /usr/local/bin/flashplayer

# install 64bit flash projector
# curl -Lso /tmp/flash.tar.gz "https://fpdownload.macromedia.com/pub/flashplayer/updaters/24/flash_player_sa_linux.x86_64.tar.gz"
# tar xf /tmp/flash.tar.gz -C /tmp
# rm -f /tmp/flash.tar.gz
# mv /tmp/flashplayer /usr/local/bin/flashplayer

# look for packer supplied version file to install vbox guest additions
if [ -f ~/.vbox_version ] && [ $(lsmod | grep vbox) -eq 0 ]; then
	mkdir -p /tmp/vbox
	VER=$(cat ~/.vbox_version 2>/dev/null)
	mount -o loop ~/VBoxGuestAdditions_$VER.iso /tmp/vbox
	sh /tmp/vbox/VBoxLinuxAdditions.run || echo "vbox requires a reboot and returned a bad exit code..."
	umount /tmp/vbox
	echo "# eliminate 3d acceleration for various tools due to borked drivers" >> /etc/skel/.bash_profile
	echo "export LIBGL_ALWAYS_SOFTWARE=1" >> /etc/skel/.bash_profile
	su $username -c 'echo "# eliminate 3d acceleration for various tools due to borked drivers" >> ~/.bash_profile'
	su $username -c 'echo "export LIBGL_ALWAYS_SOFTWARE=1" >> ~/.bash_profile'
	rm -f ~/VBoxGuestAdditions_$VER.iso ~/.vbox_version
fi

# add youtube-dl utility
if which youtube-dl &>/dev/null; then
	curl -Lo /usr/local/bin/youtube-dl https://yt-dl.org/latest/youtube-dl
	chmod a+rx /usr/local/bin/youtube-dl
fi

# install gif duration script
if ! which gifduration &>/dev/null; then
	curl -Lo /usr/local/bin/gifduration https://raw.githubusercontent.com/alimony/gifduration/master/gifduration.py
	chmod a+rx /usr/local/bin/gifduration
fi

# sublime text 3 installation /w package manager
if ! which subl &>/dev/null; then
	curl -Lso /tmp/sublime.tar.bz2 "https://download.sublimetext.com/sublime_text_3_build_3126_x64.tar.bz2"
	tar xf /tmp/sublime.tar.bz2 -C /tmp
	rm /tmp/sublime.tar.bz2
	cp -R /tmp/sublime_text_3 /usr/local/sublime-text
	ln -nsf /usr/local/sublime-text/sublime_text /usr/local/bin/subl
fi

# install urxvt font plugin
[ ! -f /usr/lib/urxvt/perl/font ] && curl -Lo /usr/lib/urxvt/perl/font "https://raw.githubusercontent.com/noah/urxvt-font/master/font"

# update alternative default softwares
update-alternatives --set x-www-browser /usr/bin/google-chrome-stable
update-alternatives --set x-session-manager /usr/bin/openbox-session
update-alternatives --set x-window-manager /usr/bin/openbox
update-alternatives --set x-terminal-emulator /usr/bin/urxvt

# update user groups
if [ "$username" != "root" ]; then
	usermod -aG input,audio,video,bluetooth $username

	# install go & node with user gvm/nvm
	set +eu
	[ "$username" != "root" ] && su $username -c '[ ! -d ~/.gvm ] && cd && (curl -Ls "https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer" | bash) && . ~/.gvm/scripts/gvm && gvm install go1.4.2 && gvm use go1.4.2 && GOROOT_BOOTSTRAP=$GOROOT gvm install go1.7.5 && gvm use go1.7.5 --default && gvm uninstall go1.4.2'
	set -eu
fi
