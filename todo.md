
# todo

Here is a summary of changes:

- figure out how to setup partitioning in the preseed
	- 2GB fat32 boot partition
	- btrfs for the root partition
		- if possible subvolume at /home before installation?
	- 2GB swap at end of disk

Currently it stops at manual, so we DO need more than simply one section...

Alternative disk config:

	partman-auto/text/atomic_scheme ::

	538 538 1075 free
	    $iflabel{ gpt }
	    $reusemethod{ }
	    method{ efi }
	    format{ } .

	128 512 256 ext2
	    $defaultignore{ }
	    method{ format }
	    format{ }
	    use_filesystem{ }
	    filesystem{ ext2 }
	    mountpoint{ /boot } .

	500 10000 -1 $default_filesystem
	    $lvmok{ }
	    method{ format }
	    format{ }
	    use_filesystem{ }
	    $default_filesystem{ }
	    mountpoint{ / } .

	100% 512 200% linux-swap
	    $lvmok{ }
	    $reusemethod{ }
	    method{ swap }
	    format{ } .

Modified config:

	if [ -d "/sys/firmware/efi/" ]; then
	    debconf-set "partman-auto/expert_recipe" "$(
	        echo -n '600 600 1075 free $iflabel{ gpt } $reusemethod{ } method{ efi } format{ } . '
	        echo -n '128 512 256 ext2 $defaultignore{ } method{ format } format{ } use_filesystem{ } filesystem{ ext2 } mountpoint{ /boot } . '
	        echo -n '9216 2000 -1 $default_filesystem $lvmok{ } method{ format } format{ } use_filesystem{ } $default_filesystem{ } mountpoint{ / } .'
	    )"
	fi



      boot-root ::                                            \
              40 50 100 ext3                                  \
                      $primary{ } $bootable{ }                \
                      method{ format } format{ }              \
                      use_filesystem{ } filesystem{ ext3 }    \
                      mountpoint{ /boot }                     \
              .                                               \
              500 10000 1000000000 ext3                       \
                      method{ format } format{ }              \
                      use_filesystem{ } filesystem{ ext3 }    \
                      mountpoint{ / }                         \
              .                                               \
              64 512 300% linux-swap                          \
                      method{ swap } format{ }                \


Garbage?

	d-i partman-basicfilesystems/choose_label string gpt
	d-i partman-partitioning/choose_label string gpt
	d-i partman-auto/method string regular
	d-i partman-auto/choose_recipe select btrfs


These might be needed?  All or just one or some?

	d-i partman-basicfilesystems/choose_label string gpt
	d-i partman-basicfilesystems/default_label string gpt
	d-i partman-partitioning/choose_label string gpt
	d-i partman-partitioning/default_label string gpt
	d-i partman/choose_label string gpt
	d-i partman/default_label string gpt


Temporarily removed for testing:

	# old mbr disk partitions
	d-i partman/default_filesystem string ext4
	d-i partman-auto/method string lvm
	d-i partman-auto/choose_recipe select atomic
	d-i partman-lvm/confirm boolean true
	d-i partman-lvm/confirm_nooverwrite boolean true
	d-i partman-auto-lvm/guided_size string max

	# old mbr grub
	d-i grub-installer/only_debian boolean true
	d-i grub-installer/bootdev string /dev/sda

	# install additional utilities
	d-i pkgsel/update-policy select none
	d-i pkgsel/upgrade select full-upgrade
	d-i pkgsel/include string ssh ntp curl nfs-common linux-headers-$(uname -r) build-essential perl dkms

	# prevent packaged guest additions since they are always out of date
	d-i preseed/early_command string sed -i \
		'/in-target/idiscover(){/sbin/discover|grep -v VirtualBox;}' \
		/usr/lib/pre-pkgsel.d/20install-hwpackages

	# allow root login for packer
	d-i preseed/late_command string \
		in-target sed -i 's/PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config

- is the preseed 100% automated
- did the partitions get setup correctly
- verify whether ssh server is available as part of `Standard` set
- verify whether virtualbox guest additions package is auto-installed (eg. do we need to add a blocker)


---

- did we have a cdrom mounted from fstab still?
	- can we tell the preseed to remove the mounted disk?
	- `virtualbox-iso: Media change: Please insert the disc labeled 'Debian GNU/Linux 8.7.1 _Jessie_ - Official amd64 CD Binary-1 20170116-11:01' into the drive '/media/cdrom/' and press [Enter].Get: 1 http://http.d`

- did we end up with `avahi-autoipd` and do we need the uninstall line?
	- `dpkg -r avahi-autoipd` might be preferred

- which system depended on these:
	- `libharfbuzz-dev:i386`
	- `libpixman-1-dev:i386`
	- `libxcomposite-dev:i386`


Reference document

- [debian jessie preseed](https://www.debian.org/releases/stable/amd64/apbs04.html.en)


- fix the maximize button behavior in `openbox` configuration
- fill out `openbox.md` with a brief overview and primarily note the hotkeys in my arrangement

- test aptitude vs apt-get behavior for package installation failure
	- invalid package name
	- network failure/disruption
- switch back to inline commands away from the enormous retry block /w tee commands and files created

Go back to using `apt-` programs?:

	apt-get clean
	apt-get update
	apt-get upgrade -yq

- simplify iptables by removing the commented lines
	- add the lines to my documentation relating to transmission & nginx

- revisit vbox block adding file-detection (more limited, but so is the use-case)
	- like nvidia this should be part of the workstation steps

- figure out how to get vagrant to launch uefi .box instance


- add copy command to load desktop data files
- consolidate updated desktop interface packages
	- reduce overall set of packages to only what I regularly use
	- include multimedia
	- include development tools
	- include gaming packages
		- add `mame`
		- try to automate the `steam` package again.
		- autobuild [koku-xinput-wine](https://github.com/KoKuToru/koku-xinput-wine)
- minor updates to openbox
	- remove useless software (catfish)
	- fix hotkeys (set alternative stack)
- upgrade conkyrc perhaps using a launcher
	- add datetime /w uptime after
	- include temperature
	- automation to detect:
		- monitors
		- disks
		- primary/valid-ip network device
- add nvidia detection & installation block
- download any special installers
- download any custom compilations
- verify available openbox default themes
	- automate using a good one

- revisit usb installer preloaded with my configuration
	- it's fine to go pure uefi now
	- can switch to correct debian.net apt address
	- real question, can we simply expand media size without breaking uefi boot settings to add files?
	- it seems `partman-efi` is used to create MBR/UEFI compatible installers, so maybe we can follow that?

- extend inputs if workstation is true with more user inputs
- rebuild user configuration section as part of the workstation section

- push up changes so I can check for broken relative-path links
- review every page of documentation for broken links

- figure out how to automate `ibus-mozc`, `ibus-setup`, and `im-config`
- investigate `scim` for debian japanese input support
- revisit and test the `7zw` script extensively
- figure out hyperspin or hyperloop and create a gui mednafen wrapper

- investigate upgrading to debian-stretch
	- supposedly switch to `testing`
		- ``apt-get -u -o APT::Force-LoopBreak=1 dist-upgrade``
		- if errors occur try `dpkg --configure -a`, then `apt-get -f install`
		- finally cleanup after via `apt-get autoremove`
	- upcoming freeze date, between this or arch

- spend some time figuring out arch again
	- try out `i3wm`, a tiling window manager (especially with my new monitor!)

- continue investigating thumbnailers for folders
	- try patching pcmanfm and compiling from source (yay my favorite!?)
	- try out a heavier file browser with folder thumbnail support?

- investigate using `chroot` to compile software without bleeding dependencies
	- slower for automation, but cleaner

- create a new debian jessie video for youtube
	- setup a system manually
	- show preseed and demonstrate automated setup


## was this needed?

	# fix conflicting packages and install system utilities
	which avahi-autoipd &>/dev/null && aptitude purge -yq avahi-autoipd


## gitcompletion

We need to verify that this is a mac-only requirement

	# install git-completion
	[ ! -f /etc/skel/.git-completion ] && curl -Lso /etc/skel/.git-completion "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash"


## questions

These are username, password, ssh key, and github related questions that will be part of the workstation block:

	if [ "$workstation" = "y" ]; then
		grab_input "username" "enter your username"
		grab_password "password" "enter your user password"
		[ ! -f "/home/$username/.ssh/id_rsa" ] && grab_yn "generate_ssh_key" "create an ssh key"
		grab_input "github_username" "" "enter your github username"
		if [ -n "$github_username" ]; then
			if [ -f "/home/$username/.ssh/id_rsa" ] || [ "${generate_ssh_key:-}" = "y" ]; then
				grab_yes_no "github_ssh_key" "upload ssh key to github"
				[ "$github_ssh_key" = "y" ] && grab_secret_or_fallback "github_password" "" "enter your github password"
			fi
		fi
	fi


## desktop

This is what loads our desktop configuration files:

	if [ -d linux/debian/data/base ]; then
		cp -fR linux/debian/data/desktop/* /
	else
		([ -d /tmp/system-setup ] && cd /tmp/system-setup && git pull ) || git clone https://github.com/cdelorme/system-setup /tmp/system-setup
		cp -fR /tmp/system-setup/linux/debian/data/desktop/* /
	fi


Figure out which of these we want to install onto a desktop:

	# add these as part of the desktop environment?
	safe_aptitude_install graphicsmagick imagemagick libgd-tools libav-tools lame libvorbis-dev libogg-dev libexif-dev libfaac-dev libx264-dev vorbis-tools libavcodec-dev libavfilter-dev libavdevice-dev libavutil-dev id3


We need to verify whether or not i386 is required, as well as exactly what it is required for.  _Basically refreshing my brain on our dependency chain._


Review and simplify openbox/desktop configuration steps:

	# development & workstation packages
	if [ "$is_a_workstation" = "y" ]; then

		# enable multiarch
		dpkg --add-architecture i386
		safe_aptitude_install

		# install workstation packages
		safe_aptitude_install firmware-linux firmware-linux-free firmware-linux-nonfree uuid-runtime fuse exfat-fuse exfat-utils sshfs lzop p7zip-full p7zip-rar zip unzip unrar unace rzip unalz zoo arj anacron miscfiles markdown checkinstall lm-sensors hddtemp cpufrequtils bluez rfkill connman convmv

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

			# install core desktop packages
			safe_aptitude_install openbox obconf obmenu menu dmz-cursor-theme gnome-icon-theme gnome-icon-theme-extras lxappearance alsa-base alsa-utils alsa-tools pulseaudio pavucontrol pasystray xorg xserver-xorg-video-all x11-xserver-utils x11-utils xinit xinput suckless-tools compton desktop-base tint2 conky-all zenity pcmanfm consolekit xarchiver tumbler ffmpegthumbnailer feh hsetroot rxvt-unicode gmrun arandr clipit xsel gksu catfish fbxkb xtightvncviewer gparted mplayer kazam guvcview openshot flashplugin-nonfree gimp gimp-plugin-registry evince viewnior fonts-droid fonts-freefont-ttf fonts-liberation fonts-takao ttf-mscorefonts-installer ibus-mozc regionset libavcodec-extra dh-autoreconf intltool libgtk-3-dev gtk-doc-tools gobject-introspection hardinfo

			# update alternative default softwares
			which google-chrome-stable &>/dev/null && update-alternatives --set x-www-browser /usr/bin/google-chrome-stable
			which openbox-session &>/dev/null && update-alternatives --set x-session-manager /usr/bin/openbox-session
			which openbox &>/dev/null && update-alternatives --set x-window-manager /usr/bin/openbox
			which urxvt &>/dev/null && update-alternatives --set x-terminal-emulator /usr/bin/urxvt

			# configure audio
			which alsactl &>/dev/null && alsactl store
			if [ -d /etc/pulse ]; then
				[ ! -e /etc/skel/.pulse ] && cp -R /etc/pulse /etc/skel/.pulse
			fi

			# @todo: run im-config
			# @todo: run ibus-setup (as user?)

			# add youtube-dl utility
			if which youtube-dl &>/dev/null; then
				curl -Lo /usr/local/bin/youtube-dl https://yt-dl.org/latest/youtube-dl
				chmod a+rx /usr/local/bin/youtube-dl
			fi

			# install gif duration script
			if which gifduration &>/dev/null; then
				curl -Lo /usr/local/bin/gifduration https://raw.githubusercontent.com/alimony/gifduration/master/gifduration.py
				chmod a+rx /usr/local/bin/gifduration
			fi

			# remove auto-mounted items from fstab
			sed -i '/auto/d' /etc/fstab

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
				curl -Lso /tmp/sublime.tar.bz2 "https://download.sublimetext.com/sublime_text_3_build_3126_x64.tar.bz2"
				tar xf /tmp/sublime.tar.bz2 -C /tmp
				rm /tmp/sublime.tar.bz2
				cp -R /tmp/sublime_text_3 /usr/local/sublime-text
				ln -nsf /usr/local/sublime-text/sublime_text /usr/local/bin/subl
				mkdir -p "/etc/skel/.config/sublime-text-3/Installed Packages/"
				curl -Lso "/etc/skel/.config/sublime-text-3/Installed Packages/Package Control.sublime-package" "https://sublime.wbond.net/Package%20Control.sublime-package"
			fi

			# conditionally install gaming software
			if [ "$install_gaming_software" = "y" ]; then
				safe_aptitude_install playonlinux mednafen cmake libsdl2-dev libboost1.55-dev scons libusb-1.0-0-dev git-core

				# build xboxdrv from source without bugs
				git clone https://github.com/captin411/xboxdrv.git /tmp/xboxdrv
				pushd /tmp/xboxdrv
				git checkout feature-send-disconnect-on-error
				make
				make install PREFIX=/usr
				popd

				# enable xboxdrv
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


Here are the steps for nvidia download and build /w grub modifier:

	# conditionally install nvidia driver
	set +eu
	if [ $(lspci | grep -i " vga" | grep -ci " nvidia") -ge 1 ] && ! which nvidia-installer &>/dev/null; then
		safe_aptitude_install linux-headers-amd64 dkms
		curl -Lso "/tmp/nvidia.run" "http://us.download.nvidia.com/XFree86/Linux-x86_64/375.26/NVIDIA-Linux-x86_64-375.26.run"
		/bin/bash /tmp/nvidia.run -a -q -s -n --install-compat32-libs --compat32-libdir=/usr/lib/i386-linux-gnu --dkms -X -Z
		[ $(grep -c "nomodeset" /etc/default/grub) -eq 0 ] && sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 nomodeset"/' /etc/default/grub
	fi
	set -eu

_I'd like to see if we can eliminate the `set +eu` wrappers._


A similar set of lines for virtualbox:

	# if running in packer let's install vbox guest additions
	if [ -f /root/.vbox_version ]; then
		mkdir /tmp/vbox
		VER=$(cat /root/.vbox_version 2>/dev/null)
		mount -o loop /home/vagrant/VBoxGuestAdditions_$VER.iso /tmp/vbox
		sh /tmp/vbox/VBoxLinuxAdditions.run || echo "vbox requires a reboot and returned a bad exit code..."
		umount /tmp/vbox
		rm -f /home/vagrant/VBoxGuestAdditions_$VER.iso
		echo "# eliminate 3d acceleration for various tools due to borked drivers" >> /etc/skel/.bash_profile
		echo "export LIBGL_ALWAYS_SOFTWARE=1" >> /etc/skel/.bash_profile
	fi


## user configuration

We need to tidy this up:

	# create the user & add to basic groups
	id $username &>/dev/null || useradd -m -s /bin/bash -p $(mkpasswd -m md5 "$password") $username
	usermod -aG sudo,users,disk,adm,netdev,plugdev $username
	[ "$workstation" = "y" ] && usermod -aG bluetooth,input,audio,video $username

	# generate ssh key & optionally upload to github
	if [ "$username" != "root" ] && [ "${generate_ssh_key:-}" = "y" ] && [ ! -f /home/$username/.ssh/id_rsa ]; then
		ssh-keygen -q -b 4096 -t rsa -N "$password" -f "/home/$username/.ssh/id_rsa"
		[ -d /home/$username/.ssh ] && chmod 600 /home/$username/.ssh/*
		if [ -f "/home/$username/.ssh/id_rsa.pub" ] && [ "${github_ssh_key:-}" = "y" ]; then
			curl -Li -u "${github_username}:${github_password}" -H "Content-Type: application/json" -H "Accept: application/json" -X POST -d "{\"title\":\"$(hostname -s) ($(date '+%Y/%m/%d'))\",\"key\":\"$(cat /home/${username}/.ssh/id_rsa.pub)\"}" https://api.github.com/user/keys
		fi
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

	# use github username to acquire name & email from github
	if [ -n "$github_username" ]; then
		tmpdata=$(curl -Ls "https://api.github.com/users/${github_username}")
		github_name=$(echo "$tmpdata" | grep name | cut -d ':' -f2 | tr -d '",' | sed "s/^ *//")
		github_email=$(echo "$tmpdata" | grep email | cut -d ':' -f2 | tr -d '":,' | sed "s/^ *//")
		su $username -c "cd && git config --global user.name $github_username"
		su $username -c "cd && git config --global user.email $github_email"
	fi

Installing go as the user via gvm and nodejs via nvm:

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

_We can probably remove nodejs, but I do still want go and may have a better set of commands plus newer versions._


## iptables

These are deprecated lines that I can probably remove and document:

	# configure iptables
	[ "$install_transmission" = "y" ] && sed -i "s/#-A INPUT -p udp -m udp --dport 51413 -j ACCEPT/-A INPUT -p udp -m udp --dport 51413 -j ACCEPT/" /etc/iptables/iptables.rules && sed -i "s/#-A INPUT -s 127.0.0.1 -p tcp -m tcp --dport 9091 -j ACCEPT/-A INPUT -s 127.0.0.1 -p tcp -m tcp --dport 9091 -j ACCEPT/" /etc/iptables/iptables.rules

	# tranmission peer traffic (default port 51413)
	#-A INPUT -p udp -m udp --dport 51413 -j ACCEPT
	# transmission web interface restricted-local-access
	#-A INPUT -s 127.0.0.1 -p tcp -m tcp --dport 9091 -j ACCEPT


	[ "${public_nginx:-}" = "y" ] && sed -i 's/#-A INPUT -p tcp -m multiport --dports 80,443 -m conntrack --ctstate NEW -j ACCEPT/-A INPUT -p tcp -m multiport --dports 80,443 -m conntrack --ctstate NEW -j ACCEPT/' /etc/iptables/iptables.rules


## pulse

For audio I was setting an absurdly high fragment size:

	[ -f /etc/pulse/daemon.conf ] && echo "default-fragments = 128" >> /etc/pulse/daemon.conf

_Was this sane, or necessary?_


## transmission daemon

Should we offload this into extras?:

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

	# update command system, and restart services which may have been configured
	[ "$install_transmission" = "y" ] && systemctl restart transmission-daemon

	# install go utility
	if [ "$install_golang" = "y" ]; then
	 	go get github.com/cdelorme/go-transmission-api/...
	fi

	# add user to group
	usermod -aG debian-transmission $username


Also, any chance we can make this a userspace daemon?  If so that'd solve a lot of bugs, such as ownership for execution, and also the ability to watch the download path without using any extra tools.

If so, we should look at systemd unit files for userspace, and adding a line to openbox to launch it perhaps?


## chroot

Example setup process:

	aptitude install -ryq debootstrap
	mkdir /tmp/deb-chroot
	debootstrap jessie /tmp/deb-chroot
	chroot /tmp/deb-chroot

_Each `chroot` takes a significant amount of time and disk space, which may make it painful to isolate each build, but reuse may lead to new conflicting issues._  We also have to verify whether or not we can even copy the executables out without dependency issues on the host.

Conveniently, you can use `chroot -c` to execute commands from a script within a given space, thus complex commands may be encapsulated into other scripts that can run these builds in a way that is able to be repeated as updates are found (eg. user can run them to update a select software).

Specific executables that might be nice to abstract in this way:

- `compton` (_if not from package_)
- `ppsspp`
- `pcsx2`

_In theory, given static compilation, this would eliminate i386 dependencies from being required for the host system._


# references

- [hyperlaunch](https://gameroomsolutions.com/setup-hyperspin-mame-hyperlaunch-full-guide/)
- [2015 howto setup](https://www.youtube.com/watch?v=PxigHfBUPiA)
- [jis config reference](http://okomestudio.net/biboroku/?p=1834)
- [scim console jis support ubuntu 8.x (old docs but relevant to my interests)](http://ubuntuforums.org/showthread.php?t=975144)
- [resource using xdg for icons?](https://wiki.archlinux.org/index.php/Xdg_user_directories)
- [python script for older ubuntu?](http://www.webupd8.org/2009/11/music-album-covers-and-picture-previews.html)
- [similar project](http://ubuntuforums.org/showthread.php?t=226199&page=3)
- [another project](https://www-user.tu-chemnitz.de/~klada/?site=projects&id=albumcover)
- [KDE implementation, worth investigating?](http://ppenz.blogspot.com/2009/04/directory-thumbnails.html)
- [this plus a patch](https://github.com/gcavallo/pcmanfm-covers)
- [the patch](https://sourceforge.net/p/pcmanfm/bugs/1020/)
- [setting user global hooks](https://coderwall.com/p/jp7d5q/create-a-global-git-commit-hook)
- [golang example](https://golang.org/misc/git/pre-commit)
- [automatically reload](http://superuser.com/questions/181377/auto-reloading-a-file-in-vim-as-soon-as-it-changes-on-disk)
- [more vim awareness](http://vim.wikia.com/wiki/Have_Vim_check_automatically_if_the_file_has_changed_externally)
- [automated installation](https://debian-handbook.info/browse/stable/sect.automated-installation.html)
- [extremely complicated parameterized debian uefi packer kit](https://github.com/tylert/packer-build)
