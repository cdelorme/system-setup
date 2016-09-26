#!/bin/bash
set -euo pipefail
IFS=$'\n\t'


##
# fail if not running as root
##

[ $(id -u) -ne 0 ] && echo "must be executed with root permissions..." && exit 1


##
# define reusable functions
##

##
# abstract and fix safe package installation
# accepts an array of packages
##
safe_aptitude_install() {
	unset UCF_FORCE_CONFNEW
	local UCF_FORCE_CONFOLD=true
	local DEBIAN_FRONTEND=noninteractive
	aptitude clean
	aptitude update
	aptitude upgrade -yq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" | tee /tmp/aptitude.log
	if [ $(grep -c "E: Failed" /tmp/aptitude.log) -ne 0 ] || [ $(grep -c "W: Failed" /tmp/aptitude.log) -ne 0 ]
	then
		safe_aptitude_install $@
	fi
	aptitude install -f -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
	[ -z "$@" ] && return 0
	aptitude install -fryq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" "$@" 2>&1 | tee /tmp/aptitude.log
	if [ $(grep -c "E: Failed" /tmp/aptitude.log) -ne 0 ] || [ $(grep -c "W: Failed" /tmp/aptitude.log) -ne 0 ]
	then
		safe_aptitude_install $@
	fi
	return 0
}


##
# @description request input and optionally apply a fallback/default value
# @param $1 variable name
# @param $2 default value
# @param $3 description
##
grab_or_fallback()
{
	[ -n "$(eval echo \${$1:-})" ] && return 0
	export ${1}=""
	read -p "${3:-input}: " ${1}
	[ -z "$(eval echo \$$1)" ] && export ${1}="${2:-}"
	return 0
}

##
# @description request secret input (eg. passwords) and optionally apply a fallback/default value
# @param $1 variable name
# @param $2 default value
# @param $3 description
##
grab_secret_or_fallback()
{
	[ -n "$(eval echo \${$1:-})" ] && set -x && return 0
	export ${1}=""
	read -p "${3:-input}: " -s ${1}
	echo "" # move to nextline
	[ -z "$(eval echo \$$1)" ] && export ${1}="${2:-}"
	return 0
}

##
# @description ask for yes/no response via y/n
# @param $1 variable to handle input
# @param $2 description
##
grab_yes_no()
{
	[[ "$(eval echo \${$1:-})" = "y" || "$(eval echo \${$1:-})" = "n" ]] && return 0
	export ${1}=""
	until [[ "$(eval echo \$$1)" = "y" || "$(eval echo \$$1)" = "n" ]]; do
		read -p "${2:-} (yn)? " ${1}
	done
	return 0
}


##
# gather user defined configuration
##

# user & key information
grab_or_fallback "username" "root" "enter your username"
grab_secret_or_fallback "password" "" "enter your user password"
[ ! -f "/home/$username/.ssh/id_rsa" ] && grab_yes_no "generate_ssh_key" "create an ssh key"
[ "${generate_ssh_key:-}" = "y" ] && grab_secret_or_fallback "ssh_key_password" "$password" "alternative password for ssh key (defaults to user password)"

# github configuration
grab_or_fallback "github_username" "" "enter your github username"
if [ -n "$github_username" ]; then
	if [ -f "/home/$username/.ssh/id_rsa" ] || [ "${generate_ssh_key:-}" = "y" ]; then
		grab_yes_no "github_ssh_key" "upload ssh key to github"
		[ "$github_ssh_key" = "y" ] && grab_secret_or_fallback "github_password" "" "enter your github password"
	fi
fi

# various settings
grab_or_fallback "ssh_port" "22" "enter your preferred ssh port (22)"
grab_or_fallback "system_hostname" "$(hostname -s)" "enter a system hostname"
grab_or_fallback "system_domainname" "" "enter a system domain name"

# additional customization packages
grab_yes_no "install_dotfiles" "install dot files"

# ask if it is a laptop
grab_yes_no "is_laptop" "is this a laptop"

# conditional services
grab_yes_no "install_weechat" "install weechat irc client"
grab_yes_no "install_transmission" "install transmission bittorrent server"
grab_yes_no "install_processing_tools" "install graphics, audio, and video processing utilities"

# web service questions
grab_yes_no "is_webserver" "is this a web server"
if [ "$is_webserver" = "y" ]; then
	grab_yes_no "install_nginx" "do you want to install nginx web & proxy server"
	[ "$install_nginx" = "y" ] && grab_yes_no "public_nginx" "do you want to open web ports 80 & 443 publicly"
	grab_yes_no "install_mail_server" "would you like to install the msmtp mail server"
	[ "$install_mail_server" = "y" ] && grab_or_fallback "mail_server_username" "$username" "mail server username"
	[ "$install_mail_server" = "y" ] && grab_secret_or_fallback "mail_server_password" "$password" "mail server password"
fi

# development & workstation questions
grab_yes_no "is_a_workstation" "is this a local workstation"
if [ "$is_a_workstation" = "y" ]; then

	# as if we want development tools
	grab_yes_no "install_development_tools" "do you want to install development tools"
	if [ "$install_development_tools" = "y" ]; then

		# we want processing tools
		install_processing_tools="y"

		# languages for development
		grab_yes_no "install_golang" "do you want to install golang"
		grab_yes_no "install_nodejs" "do you want to install nodejs"
	fi

	# desktop questions
	grab_yes_no "install_openbox" "would you like to install the openbox desktop environment"
	if [ "$install_openbox" = "y" ]; then

		# we want processing tools
		install_processing_tools="y"

		# login manager
		grab_yes_no "install_login_manager" "would you like to install a graphical login manager"

		# flash projector
		grab_yes_no "install_flashprojector" "would you like to install a flash projector"

		# game packages
		grab_yes_no "install_gaming_software" "would you like to install gaming software like steam and playonlinux"
	fi
fi


##
# here be dragons
##

# enable debug mode so we can witness execution
set -x

# clean up uefi configuration
if [ -d "/boot/efi" ]; then
	mkdir -p /boot/efi/EFI/boot
	echo "FS0:\EFI\debian\grubx64.efi" > /boot/efi/startup.nsh
	cp -f /boot/efi/EFI/debian/grubx64.efi /boot/efi/EFI/boot/bootx64.efi
	# @link: https://svn.code.sf.net/p/edk2/code/trunk/edk2/ShellBinPkg/UefiShell/X64/Shell.efi
	[ ! -f /boot/efi/shellx64.efi ] && wget --no-check-certificate -qO- "/boot/efi/shellx64.efi" "https://d2xxklvztqk0jd.cloudfront.net/github/Shell.efi" || true
fi

# offer to optimize btrfs root
export btrfs_optimizations="noatime,compress=lzo,space_cache,autodefrag"
if [ "$(mount -t btrfs | awk '{print $3}' | grep -c '/')" -gt 0 ] && [[ $(cat /etc/fstab | grep ' / ' | grep -c "${btrfs_optimizations}") -eq 0 || "$(btrfs subvol list / | awk '{print $9}')" != "home" ]]; then
	grab_yes_no "optimize_btrfs" "do you want to optimize your btrfs"

	if [ "$optimize_btrfs" = "y" ]; then

		# create /home subvolume if it is not already a subvolume
		if [ "$(btrfs subvol list / | awk '{print $9}')" != "home" ]; then
			mv -f /home /home.bak
			btrfs subvol create /home
			find /home.bak -mindepth 1 -maxdepth 1 -exec cp -R {} /home/ \;
			rm -rf /home.bak/
		fi

		# check whether fstab already contains optimizations
		if [ $(cat /etc/fstab | grep ' / ' | grep -c "${btrfs_optimizations}") -eq 0 ]; then

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
fi

# fix conflicting packages and install system utilities
which avahi-autoipd &>/dev/null && aptitude purge -yq avahi-autoipd
safe_aptitude_install screen tmux vim git mercurial bzr subversion command-not-found unzip ntp resolvconf watchdog ssh sudo parted smartmontools htop pv nload iptraf nethogs libcurl3 lzma

# handle laptop packages & configuration
if [ "$is_laptop" = "y" ]; then
	safe_aptitude_install laptop-mode-tools
	sed -i 's/battery = 0/battery = 1/' /etc/skel/.config/tint2/tint2rc
fi

# detect & install firmware (primarily for networking devices)
[ $(lspci | grep -ci "realtek") -gt 0 ] && safe_aptitude_install firmware-realtek
[ $(lspci | grep -i "wireless" | grep -ci "atheros") -gt 0 ] && safe_aptitude_install firmware-atheros
[ $(lspci | grep -i "wireless" | grep -ci "broadcom") -gt 0 ] && safe_aptitude_install firmware-brcm80211
[ $(lspci | grep -i "wireless" | grep -ci "intel") -gt 0 ] && safe_aptitude_install firmware-iwlwifi

# install local files or clone from git
if [ -d data/ ]; then
	cp -fR data/* /
else
	rm -rf /tmp/system-setup
	git clone https://github.com/cdelorme/system-setup /tmp/system-setup
	cp -fR /tmp/system-setup/data/* /
fi

# install global dot-files
[ "$install_dotfiles" = "y" ] && curl -Ls https://raw.githubusercontent.com/cdelorme/dot-files/master/install | bash -s -- -q

# install some vim plugins & color schemes
mkdir -p /etc/skel/.vim/colors
if [ ! -d /tmp/vim-ctrlp ]; then
	git clone "https://github.com/kien/ctrlp.vim" /tmp/vim-ctrlp
	find /tmp/vim-ctrlp/* -maxdepth 0 -type d -exec cp -R {} /etc/skel/.vim/ \;
fi
if [ ! -d /tmp/vim-json ]; then
	git clone "https://github.com/elzr/vim-json" /tmp/vim-json
	find /tmp/vim-json/* -maxdepth 0 -type d -exec cp -R {} /etc/skel/.vim/ \;
fi
if [ ! -d /tmp/vim-ansiesc ]; then
	git clone "https://github.com/powerman/vim-plugin-AnsiEsc" /tmp/vim-ansiesc
	find /tmp/vim-ansiesc/* -maxdepth 0 -type d -exec cp -R {} /etc/skel/.vim/ \;
fi
if [ ! -d /tmp/vim-go ] && [ "${install_golang:-}" = "y" ]; then
	git clone "https://github.com/fatih/vim-go" /tmp/vim-go
	find /tmp/vim-go/* -maxdepth 0 -type d -exec cp -R {} /etc/skel/.vim/ \;
fi
if [ ! -d /tmp/vim-node ] && [ "${install_nodejs:-}" = "y" ]; then
	git clone "https://github.com/moll/vim-node" /tmp/vim-node
	find /tmp/vim-node/* -maxdepth 0 -type d -exec cp -R {} /etc/skel/.vim/ \;
fi
[ ! -f /etc/skel/.vim/colors/vividchalk.vim ] && curl -Lso /etc/skel/.vim/colors/vividchalk.vim "https://raw.githubusercontent.com/tpope/vim-vividchalk/master/colors/vividchalk.vim"
[ ! -f /etc/skel/.vim/colors/sunburst.vim ] && curl -Lso /etc/skel/.vim/colors/sunburst.vim "https://raw.githubusercontent.com/tangphillip/SunburstVIM/master/colors/sunburst.vim"

# download ~/.git-completion
[ ! -f /etc/skel/.git-completion ] && curl -Lso /etc/skel/.git-completion "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash"

# conditionally install weechat
[ "$install_weechat" = "y" ] && safe_aptitude_install weechat

# conditionally install transmission
if [ "$install_transmission" = "y" ]; then
	safe_aptitude_install transmission-daemon
	systemctl stop transmission-daemon

	# configure transmission directory
	if id debian-transmission &>/dev/null; then
		mkdir -p /media/transmission/{torrents,incomplete,downloads}
		chown -R debian-transmission:debian-transmission /media/transmission
		chmod -R 6775 /media/transmission
	fi
fi

# conditionally install video, audio, and graphics processing utilities
[ "$install_processing_tools" = "y" ] && safe_aptitude_install graphicsmagick imagemagick libgd-tools libav-tools lame libvorbis-dev libogg-dev libexif-dev libfaac-dev libx264-dev vorbis-tools libavcodec-dev libavfilter-dev libavdevice-dev libavutil-dev id3

# conditionally setup web server folder permissions
if [ "$is_webserver" = "y" ]; then

	# add new groups, and to user
	groupadd -f www-data
	groupadd -f gitdev

	# create environment folders & set permissions /w sticky bits
	mkdir -p /srv/{www,git}
	chown -R www-data:www-data /srv
	chown -R www-data:gitdev /srv/git
	chmod -R 6775 /srv
fi

# conditionally install nginx
if [ "${install_nginx:-}" = "y" ]; then

	# install nginx
	safe_aptitude_install nginx-full

	# configure nginx folder layout
	rm -f /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
	mkdir -p /etc/nginx/ssl
fi

# install msmtp mail server
if [ "${install_mail_server:-}" = "y" ]; then

	# install msmtp-mta and all related/useful components
	safe_aptitude_install msmtp-mta

	# ensure permissions on the msmtprc file are strict (will contain password in plain-text)
	chmod 0600 /etc/msmtprc

	# set email & password & username (assumes gmail)
	sed -i "s/from username@gmail.com/from ${mail_server_username}@gmail.com/" /etc/msmtprc
	sed -i "s/user username/user $mail_server_username/" /etc/msmtprc
	sed -i "s/password password/password $mail_server_password/" /etc/msmtprc
fi

# development & workstation packages
if [ "$is_a_workstation" = "y" ]; then

	# enable multiarch
	dpkg --add-architecture i386
	safe_aptitude_install

	# install workstation packages
	safe_aptitude_install firmware-linux firmware-linux-free firmware-linux-nonfree uuid-runtime fuse exfat-fuse exfat-utils sshfs lzop p7zip-full p7zip-rar zip unzip unrar unace rzip unalz zoo arj anacron miscfiles markdown checkinstall lm-sensors hddtemp cpufrequtils bluez rfkill connman convmv

	# check graphics card and adjust compton configuration
	if [ $(lspci | grep -i "vga" | grep -ic " intel") -eq 1 ] || [ $(lspci | grep -i "vga" | grep -ic " nvidia") -eq 1 ]; then
		sed -i 's/#vsync = "opengl-swc";/vsync = "opengl-swc";/' /etc/skel/.compton.conf
		sed -i 's/#glx-no-rebind-pixmap = true;/glx-no-rebind-pixmap = true;/' /etc/skel/.compton.conf
	fi

	# conditionally install development tools
	if [ "${install_development_tools:-}" = "y" ]; then
		safe_aptitude_install build-essential dkms cmake bison pkg-config devscripts python-dev python3-dev python-pip python3-pip bpython bpython3 libncurses-dev libmcrypt-dev libperl-dev libconfig-dev libpcre3-dev libsdl2-dev libglfw3-dev libsfml-dev

		# conditionally install gvm
		if [ "${install_golang:-}" = "y" ] && ! which go &>/dev/null; then
			[ ! -d $HOME/.gvm ] && curl -Lo- https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer | bash
			set +eu
			. ~/.gvm/scripts/gvm
			gvm install go1.4.3
			gvm use go1.4.3
			GOROOT_BOOTSTRAP=$GOROOT gvm install go1.6.2
			gvm use go1.6.2 --default
			set -eu

			# install go for all users
			[ ! -d /etc/skel/.gvm ] && git clone https://github.com/moovweb/gvm /etc/skel/.gvm
			echo -e 'export GVM_ROOT=~/.gvm\n. $GVM_ROOT/scripts/gvm-default' > /etc/skel/.gvm/scripts/gvm
			echo -e '\n# load go version manager\n[[ -s ~/.gvm/scripts/gvm ]] && . ~/.gvm/scripts/gvm' >> /etc/skel/.bash_profile
		fi

		# conditionally install nvm
		if [ "${install_nodejs:-}" = "y" ] && ! which node &>/dev/null; then
			[ ! -d ~/.nvm ] && curl -Ls https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
			set +eu
			export NVM_DIR="$HOME/.nvm" && . "$NVM_DIR/nvm.sh"
			nvm install node
			nvm use node
			nvm alias default node
			set -eu

			# install node for all users
			[ ! -d /etc/skel/.nvm ] && curl -Ls https://raw.githubusercontent.com/creationix/nvm/master/install.sh | NVM_DIR=/etc/skel/.nvm bash
			echo -e '\n# load node version manager\nexport NVM_DIR="$HOME/.nvm"\n[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"' >> /etc/skel/.bashrc
		fi
	fi

	# conditionally install openbox desktop environment
	if [ "${install_openbox:-}" = "y" ]; then

		# add vlc sources
		if [ ! -f /etc/apt/sources.list.d/vlc.list ]; then
			echo "# vlc source for dvdcss2" > /etc/apt/sources.list.d/vlc.list
			echo "deb http://download.videolan.org/pub/debian/stable/ /" >> /etc/apt/sources.list.d/vlc.list
			echo "deb-src http://download.videolan.org/pub/debian/stable/ /" >> /etc/apt/sources.list.d/vlc.list
			wget -qO- http://download.videolan.org/pub/debian/videolan-apt.asc | sudo apt-key add -
		fi

		# install core desktop packages
		safe_aptitude_install openbox obconf obmenu menu dmz-cursor-theme gnome-icon-theme gnome-icon-theme-extras lxappearance alsa-base alsa-utils alsa-tools pulseaudio pavucontrol pasystray xorg xserver-xorg-video-all x11-xserver-utils x11-utils xinit xinput suckless-tools compton desktop-base tint2 conky-all zenity pcmanfm consolekit xarchiver tumbler ffmpegthumbnailer feh hsetroot rxvt-unicode gmrun arandr clipit xsel gksu catfish fbxkb xtightvncviewer gparted vlc mplayer kazam guvcview openshot flashplugin-nonfree gimp gimp-plugin-registry evince viewnior fonts-droid fonts-freefont-ttf fonts-liberation fonts-takao ttf-mscorefonts-installer ibus-mozc regionset libavcodec-extra dh-autoreconf intltool libgtk-3-dev gtk-doc-tools gobject-introspection

		# build connman-ui
		if ! which connman-ui &>/dev/null; then
			rm -rf /tmp/connman-ui
			git clone https://github.com/tbursztyka/connman-ui.git /tmp/connman-ui
			pushd /tmp/connman-ui
			./autogen.sh
			./configure --prefix=/usr
			make
			make install
			popd
		fi

		# build playerctl
		if ! which playerctl &>/dev/null; then
			git clone https://github.com/acrisci/playerctl /tmp/playerctl
			pushd /tmp/playerctl
			./autogen.py --prefix=/usr
			make
			make install
			popd
		fi

		# add youtube-dl utility
		if which youtube-dl &>/dev/null; then
			curl -Lo /usr/local/bin/youtube-dl https://yt-dl.org/latest/youtube-dl
			chmod a+rx /usr/local/bin/youtube-dl
		fi

		# install slim login manager
		[ "$install_login_manager" = "y" ] && safe_aptitude_install slim

		# remove auto-mounted items from fstab
		sed -i '/auto/d' /etc/fstab

		# handle workstation laptop packages
		if [ "$is_laptop" = "y" ] && safe_aptitude_install xbacklight

		# install urxvt plugins
		[ ! -f /usr/lib/urxvt/perl/tabbedex ] && curl -Lso /usr/lib/urxvt/perl/tabbedex "https://raw.githubusercontent.com/shaggytwodope/tabbedex-urxvt/master/tabbedex"
		[ ! -f /usr/lib/urxvt/perl/font ] && curl -Lo /usr/lib/urxvt/perl/font "https://raw.githubusercontent.com/noah/urxvt-font/master/font"
		[ ! -f /usr/lib/urxvt/perl/clipboard ] && curl -Lo /usr/lib/urxvt/perl/clipboard "https://raw.githubusercontent.com/muennich/urxvt-perls/master/clipboard"

		# conditionally install flash projector
		if [ "$install_flashprojector" = "y" ]; then
			safe_aptitude_install libgtk-3-0:i386 libgtk2.0-0:i386 libasound2-plugins:i386 libxt-dev:i386 libnss3 libnss3:i386 libcurl3:i386 libcurl3:i386
			curl -Lso /tmp/flash.tar.gz "https://fpdownload.macromedia.com/pub/flashplayer/updaters/11/flashplayer_11_sa.i386.tar.gz"
			tar xf /tmp/flash.tar.gz -C /tmp
			rm -f /tmp/flash.tar.gz
			mv /tmp/flashplayer /usr/local/bin/flashplayer
		fi

		# google chrome installation
		if ! which google-chrome-stable &>/dev/null; then
			wget --no-check-certificate -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
			echo "# Google Chrome repo http://www.google.com/linuxrepositories/" > /etc/apt/sources.list.d/google-tmp.list
			echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-tmp.list
			echo "deb http://dl.google.com/linux/talkplugin/deb/ stable main" >> /etc/apt/sources.list.d/google-tmp.list
			echo "deb http://dl.google.com/linux/earth/deb/ stable main" >> /etc/apt/sources.list.d/google-tmp.list
			echo "deb http://dl.google.com/linux/musicmanager/deb/ stable main" >> /etc/apt/sources.list.d/google-tmp.list
			safe_aptitude_install chromium google-chrome-stable google-talkplugin
			rm -f /etc/apt/sources.list.d/google-tmp.list /etc/apt/sources.list.d/google-chrome-unstable.list
			safe_aptitude_install
		fi

		# sublime text 3 installation
		if ! which subl &>/dev/null; then
			curl -Lso /tmp/sublime.tar.bz2 "https://download.sublimetext.com/sublime_text_3_build_3114_x64.tar.bz2"
			tar xf /tmp/sublime.tar.bz2 -C /tmp
			rm /tmp/sublime.tar.bz2
			cp -R /tmp/sublime_text_3 /usr/local/sublime-text
			ln -nsf /usr/local/sublime-text/sublime_text /usr/local/bin/subl
			mkdir -p "/etc/skel/.config/sublime-text-3/Installed Packages/"
			curl -Lso "/etc/skel/.config/sublime-text-3/Installed Packages/Package Control.sublime-package" "https://sublime.wbond.net/Package%20Control.sublime-package"
		fi

		# check for and install nvidia drivers
		set +eu
		if [ $(lspci | grep -i " vga" | grep -ci " nvidia") -ge 1 ] && ! which nvidia-installer &>/dev/null; then
			safe_aptitude_install linux-headers-amd64 dkms
			curl -Lso "/tmp/nvidia.run" "http://us.download.nvidia.com/XFree86/Linux-x86_64/352.63/NVIDIA-Linux-x86_64-352.63.run"
			/bin/bash /tmp/nvidia.run -a -q -s -n --install-compat32-libs --compat32-libdir=/lib/i386-linux-gnu --dkms -X -Z
		fi
		set -eu

		# conditionally install gaming software
		if [ "$install_gaming_software" = "y" ]; then
			safe_aptitude_install xboxdrv playonlinux mednafen cmake libsdl2-dev

			# enable xbox drv
			echo "blacklist xpad" > /etc/modprobe.d/blacklist-xpad.conf
			systemctl enable xboxdrv.service
			systemctl restart xboxdrv.service

			# build & install ppsspp
			if ! which psp &>/dev/null; then
				rm -rf /tmp/ppsspp
				git clone https://github.com/hrydgard/ppsspp.git /tmp/ppsspp
				pushd /tmp/ppsspp
				git checkout v1.1.1
				git submodule update --init
				./b.sh
				mkdir /usr/local/ppsspp
				cp -R build/assets /usr/local/ppsspp/
				cp -R build/PPSSPPSDL /usr/local/ppsspp/
				ln -s /usr/local/ppsspp/PPSSPPSDL /usr/local/bin/psp
				popd
			fi

			# install steam dependencies, then download & install steam directly
			if ! which steam &>/dev/null; then
				safe_aptitude_install xterm
				[ -f /tmp/steam.deb ] && rm -f /tmp/steam.deb
				curl -Lo /tmp/steam.deb http://repo.steampowered.com/steam/archive/precise/steam_latest.deb
				dpkg -i /tmp/steam.deb
				safe_aptitude_install
			fi
		fi
	fi
fi

# secure ssh & restart service
sed -i "s/Port\s*[0-9].*/Port ${ssh_port:-22}/" /etc/ssh/sshd_config
sed -i "s/^#\?PermitRootLogin.*[yn].*/PermitRootLogin no/" /etc/ssh/sshd_config
sed -i "s/^#\?PasswordAuthentication\s*[yn].*/PasswordAuthentication no/" /etc/ssh/sshd_config
sed -i "s/^#\?GSSAPIAuthentication.*/GSSAPIAuthentication no/" /etc/ssh/sshd_config
[ $(grep -c 'GSSAPIAuthentication no' /etc/ssh/sshd_config) -eq 0 ] && echo "GSSAPIAuthentication no" >> /etc/ssh/sshd_config
[ $(grep -c 'UseDNS no' /etc/ssh/sshd_config) -eq 0 ] && echo "UseDNS no" >> /etc/ssh/sshd_config

# add pam tally locking
[ $(grep -c "pam_tally2" /etc/pam.d/common-auth) -eq 0 ] && echo "auth required pam_tally2.so deny=4 even_deny_root onerr=fail unlock_time=600 root_unlock_time=60" >> /etc/pam.d/common-auth
[ $(grep -c "pam_tally2" /etc/pam.d/common-account) -eq 0 ] && echo "account required pam_tally2.so" >> /etc/pam.d/common-account

# fix default permissions (secure by group)
sed -i 's/UMASK\s*022/UMASK\t\t002/' /etc/login.defs
if [ $(grep -c "umask=002" /etc/pam.d/common-session) -eq 0 ]; then
	echo "session optional pam_umask.so umask=002" >> /etc/pam.d/common-session
fi

# optimize lvm
[ -f /etc/lvm/lvm.conf ] && sed -i 's/issue_discards = 0/issue_discards = 1/' /etc/lvm/lvm.conf

# eliminate udev network persistence
if [ ! -d /etc/udev/rules.d/70-persistent-net.rules ]; then
	rm -f /etc/udev/rules.d/70-persistent-net.rules
	mkdir -p /etc/udev/rules.d/70-persistent-net.rules
fi

# conditionally update hostname & domain name
if [ -n "$system_hostname" ]; then
	echo "$system_hostname" > /etc/hostname
	hostname -F /etc/hostname
	[ -n "$system_domainname" ] && sed -i "s/127.0.1.1.*/127.0.1.1 ${system_hostname}.${system_domainname} ${system_hostname}/" /etc/hosts
fi

# disable capslock forever in favor of ctrl
if [ $(grep "XKBOPTIONS" /etc/default/keyboard | grep -c "ctrl:nocaps") -eq 0 ]; then
	sed -i 's/XKBOPTIONS.*/XKBOPTIONS="ctrl:nocaps"/' /etc/default/keyboard
	dpkg-reconfigure -phigh console-setup
fi

# configure sensors
which sensors-detect &>/dev/null && sensors-detect --auto || true

# add handler for kernel panics to grub & nomodeset for nvidia
[ $(grep -c "panic = 10" /etc/sysctl.conf) -lt 1 ] && echo "kernel.panic = 10" >> /etc/sysctl.conf
if [ $(grep -c "panic=10" /etc/default/grub) -lt 1 ]; then
	if [ $(lspci | grep -i "vga" | grep -ic " nvidia") -eq 1 ]; then
		sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet nomodeset panic=10"/' /etc/default/grub
	else
		sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet panic=10"/' /etc/default/grub
	fi
	update-grub
fi

# enable watchdog if supported
[ -f /dev/watchdog ] && systemctl enable watchdog && systemctl start watchdog

# conditionally install virtualbox guest additions /w visual enhancements
if [ $(dmesg | grep -c "VirtualBox") -gt 0 ] && id vagrant &>/dev/null; then
	mkdir /tmp/vbox
	VER=$(cat /home/vagrant/.vbox_version)
	mount -o loop /home/vagrant/VBoxGuestAdditions_$VER.iso /tmp/vbox
	sh /tmp/vbox/VBoxLinuxAdditions.run || echo "vbox requires a reboot and exited with bad code..."
	umount /tmp/vbox
	rm -f /home/vagrant/VBoxGuestAdditions_$VER.iso
	echo "# eliminate 3d acceleration for various tools due to borked drivers" >> /etc/skel/.bash_profile
	echo "export LIBGL_ALWAYS_SOFTWARE=1" >> /etc/skel/.bash_profile
fi

# enable custom fonts
[ $(grep "# ja_JP.UTF-8" -F /etc/locale.gen) -eq 0 ] || sed -i "s/# ja_JP\.UTF-8 UTF-8/ja_JP.UTF-8 UTF-8/" /etc/locale.gen
locale-gen
fc-cache -fr

# update alternative default softwares
update-alternatives --set editor /usr/bin/vim.basic
which google-chrome-stable &>/dev/null && update-alternatives --set x-www-browser /usr/bin/google-chrome-stable
which openbox-session &>/dev/null && update-alternatives --set x-session-manager /usr/bin/openbox-session
which openbox &>/dev/null && update-alternatives --set x-window-manager /usr/bin/openbox
which urxvt &>/dev/null && update-alternatives --set x-terminal-emulator /usr/bin/urxvt

# configure iptables
[ "$ssh_port" != "22" ] && sed -i "s/ 22 / $ssh_port /" /etc/iptables/iptables.rules
[ "$install_transmission" = "y" ] && sed -i "s/#-A INPUT -p udp -m udp --dport 51413 -j ACCEPT/-A INPUT -p udp -m udp --dport 51413 -j ACCEPT/" /etc/iptables/iptables.rules && sed -i "s/#-A INPUT -s 127.0.0.1 -p tcp -m tcp --dport 9091 -j ACCEPT/-A INPUT -s 127.0.0.1 -p tcp -m tcp --dport 9091 -j ACCEPT/" /etc/iptables/iptables.rules
[ "${public_nginx:-}" = "y" ] && sed -i 's/#-A INPUT -p tcp -m multiport --dports 80,443 -m conntrack --ctstate NEW -j ACCEPT/-A INPUT -p tcp -m multiport --dports 80,443 -m conntrack --ctstate NEW -j ACCEPT/' /etc/iptables/iptables.rules

# configure audio
which alsactl &>/dev/null && alsactl store
if [ -d /etc/pulse ]; then
	[ -f /etc/pulse/daemon.conf ] && echo "default-fragments = 128" >> /etc/pulse/daemon.conf
	[ ! -e /etc/skel/.pulse ] && cp -R /etc/pulse /etc/skel/.pulse
fi

# @todo: run im-config
# @todo: run ibus-setup (as user?)

# install dot-files for root
find /etc/skel -mindepth 1 -maxdepth 1 -exec cp -R {} /root/ \;

# create the user & add to basic groups
id $username &>/dev/null || useradd -m -s /bin/bash -p $(mkpasswd -m md5 "$password") $username
usermod -aG sudo,users,disk,adm,netdev,plugdev $username
[ "$is_a_workstation" = "y" ] && usermod -aG bluetooth,input,audio,video $username
[ "${install_nginx:-}" = "y" ] && usermod -aG www-data,gitdev $username
[ "$install_transmission" = "y" ] && usermod -aG debian-transmission $username

# generate ssh key
if [ "$username" != "root" ] && [ "${generate_ssh_key:-}" = "y" ] && [ ! -f /home/$username/.ssh/id_rsa ]; then
	ssh-keygen -q -b 4096 -t rsa -N "$ssh_key_password" -f "/home/$username/.ssh/id_rsa"
	[ -d /home/$username/.ssh ] && chmod 600 /home/$username/.ssh/*

	# attempt to upload new ssh key to github account
	if [ -f "/home/$username/.ssh/id_rsa.pub" ] && [ "${github_ssh_key:-}" = "y" ]; then
		curl -Li -u "${github_username}:${github_password}" -H "Content-Type: application/json" -H "Accept: application/json" -X POST -d "{\"title\":\"$(hostname -s) ($(date '+%Y/%m/%d'))\",\"key\":\"$(cat /home/${username}/.ssh/id_rsa.pub)\"}" https://api.github.com/user/keys
	fi
fi

# use github username to acquire name & email from github
if [ -n "$github_username" ]; then
	tmpdata=$(curl -Ls "https://api.github.com/users/${github_username}")
	github_name=$(echo "$tmpdata" | grep name | cut -d ':' -f2 | tr -d '",' | sed "s/^ *//")
	github_email=$(echo "$tmpdata" | grep email | cut -d ':' -f2 | tr -d '":,' | sed "s/^ *//")
	su $username -c "cd && git config --global user.name $github_username"
	su $username -c "cd && git config --global user.email $github_email"
fi

# prepare crontab for non-root user
if [ "$username" != "root" ]; then
	export cronfile="/var/spool/cron/crontabs/${username}"
	[ -f "$cronfile" ] || touch "$cronfile"
	chown $username:crontab $cronfile
	chmod 600 $cronfile

	# update ssh keys using github account
	set +eu
	if [ -n "$github_username" ]; then
		[ $(grep -c "update-keys" "$cronfile") -eq 1 ] || echo "@hourly /usr/local/bin/update-keys $github_username" >> /var/spool/cron/crontabs/$username
		su $username -c "which update-keys &>/dev/null && update-keys $github_username"
	fi
	set -eu
fi

# ensure ownership for users folder
[ -d /home/$username/.ssh ] && chown -R $username:$username /home/$username/.ssh/

# install go & node with user gvm/nvm
set +eu
if [ "$username" != "root" ]; then
	if [ "${install_golang:-}" = "y" ]; then
		yes | su $username -c 'cd && . ~/.gvm/scripts/gvm && gvm install go1.4.2 && gvm use go1.4.2 && GOROOT_BOOTSTRAP=$GOROOT gvm install go1.5 && gvm use go1.5 --default'
	fi
	if [ "${install_nodejs:-}" = "y" ]; then
		yes | su $username -c 'cd && export NVM_DIR="$HOME/.nvm" && . "$NVM_DIR/nvm.sh" && nvm install v4.0.0 && nvm alias default v4.0.0'
	fi
fi
set -eu

# update command system, and restart services which may have been configured
update-command-not-found
systemctl restart ssh
[ "$install_transmission" = "y" ] && systemctl restart transmission-daemon
[ "${install_nginx:-}" = "y" ] && nginx -t && systemctl restart nginx

# load iptables (could disconnect a remote session!)
/etc/network/if-up.d/iptables

# finish with a positive exit code
exit 0
