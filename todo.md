
# todo

- craft a script to install at `/usr/local/bin/pulseshort` for pulseaudio behaviors
	- apply behaviors: toggle mute, increase by 5%, decrease by 5%
	- iterate **all** sinks in RUNNING state to apply the change
		- `pactl list short sinks | grep RUNNING | awk '{print $1}'`?

- move iptable rules to `nginx.md` and `transmission.md` documentation

- add a `btrfs.md` document
	- document benefits of mirrored raid for data-safety


---

- build a new box with no provisioner steps
	- load that box into vagrant to test everything else manually!
	- launch instance and verify configuration has enabled audio
	- take a snapshot prior to testing further code

- execute my script starting with workstation behaviors:
	- verify i386 does not break
	- verify steam installs from downloaded deb

- verify audio works

- debug xdefaults
	- test urxvt resize hotkeys
	- test clipboard on highlight

- verify that `ffmpeg` replaces `libav-tools` and these others:
	-`libavcodec-extra libavcodec-dev libavfilter-dev libavdevice-dev libavutil-dev`

- identify a superior "dark" openbox theme to use
	- update configuration files

- test i386 flashplayer does not crash like the 64bit did
	- also make sure it doesn't print a bunch of missing module errors when run from terminal

- test that openbox `reboot` and `shutdown` menu options work


---

- check through usage for unavailable functionality and errors that may explain these:
	- old: `nfs-common perl markdown checkinstall convmv bison devscripts python-dev python3-dev python-pip python3-pip bpython bpython3 libmcrypt-dev libperl-dev libconfig-dev libpcre3-dev libsdl2-dev libglfw3-dev libsfml-dev gnome-icon-theme-extras lxappearance alsa-base alsa-utils alsa-tools pulseaudio-module-bluetooth xserver-xorg-video-all x11-xserver-utils x11-utils xinput suckless-tools desktop-base zenity tumbler arandr catfish xsel gksu fbxkb xtightvncviewer flashplugin-nonfree regionset dh-autoreconf intltool libgtk-3-dev gtk-doc-tools gobject-introspection libsdl2-dev libboost1.55-dev scons libusb-1.0-0-dev git-core libgd-tools rfkill`
	- 386 `libharfbuzz-dev:i386 libxcomposite-dev:i386 libpixman-1-dev:i386 libgtk-3-0:i386 libasound2-plugins:i386`

- upgrade conkyrc
	- consider launcher script to parameterize details
		- multi-monitor detection & placement/resolution
		- connected hard disks for multi-disk readout
		- active network device detection
		- temperature availability?
	- add datetime before uptime
	- add temperature reporting

- revisit the `7zw` script and see if we can extend it at all

- figure out how to automate `ibus-mozc`, `ibus-setup`, and `im-config`

- figure out how to setup either `hyperspin` or `hyperloop` as frontends to launch mame & mednafen


---

- test on real hardware /w an nvidia card that the nvidia installation block works
- verify xboxdrv works on real hardware (crashing in vbox)
- verify working pulse audio (no extra steps?)
	- saved settings are stored in `~/.config`, hence the copy of the files is to ensure user-owned modifiable for saves
	- this includes things like the volume controls, and default sinks/sources
- verify working bluetooth (no extra steps or `rfkill` dependencies?)
- verify `koku-xinput-wine` can be used (install steam and a game, try controller)


---

- optimize preseed by identifying which undocumented gpt partition table lines are actually needed
	- disable all lines
	- add `exit 0` to top of script temporarily
	- keep only one line enabled at a time, or until we get past the preseed automation
	- once we reach the os, verify with parted that a valid gpt partition table was used
- test preseed with fixed-size swap for greater predictability in partitions (useful for btrfs raid1)
- test building ppsspp 1.3 and keeping the entire source at `/usr/local/src/`


---

- revisit usb installer preloaded with my preseed & system-setup scripts
	- if we cannot get `biosboot` support go pure uefi
		- investigate partman-efi for creating a compatible installer
	- verify expansion of disk does not break boot behavior
	- identify which file produces the menu so we can select "Casey's Install"
		- if biosboot allowed, investigate menu item per launch mode


---

- investigate creating `debian/stretch.sh`
	- test using a preseed that upgrades to `testing` via:
		- ``apt-get -u -o APT::Force-LoopBreak=1 dist-upgrade``
		- if errors occur try `dpkg --configure -a`, then `apt-get -f install`
		- finally cleanup after via `apt-get autoremove`

- spend some time figuring out arch again
	- try out `i3wm`, a tiling window manager (especially with my new monitor!)

- create and share a new debian jessie installation video for youtube
	- demonstrate manual steps & with preseed (using github address?)
	- preferrably record from mac?

- continue investigating thumbnailers for folders
	- try patching pcmanfm and compiling from source (yay my favorite!?)
	- try out a heavier file browser with folder thumbnail support?

- investigate using `chroot` to compile software without bleeding dependencies
	- slower for automation, but cleaner


---

## desktop

Do we need to build xboxdrv from source?:

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


Is this really how to configure pulse audio?:

	# configure audio
	which alsactl &>/dev/null && alsactl store
	if [ -d /etc/pulse ]; then
		[ ! -e /etc/skel/.pulse ] && cp -R /etc/pulse /etc/skel/.pulse
	fi


## user configuration

Former crontab creation:

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

- [debian jessie preseed](https://www.debian.org/releases/stable/amd64/apbs04.html.en)
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
- [Everything you need to know about conffiles: configuration files managed by dpkg](https://raphaelhertzog.com/2010/09/21/debian-conffile-configuration-file-managed-by-dpkg/)


# functions

I am probably removing this in favor of simply running `apt-get`:

	# function to correctly retry package installation on failure
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
		aptitude install -fryq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" "$@" 2>&1 | tee /tmp/aptitude.log
		if [ $(grep -c "E: Failed" /tmp/aptitude.log) -ne 0 ] || [ $(grep -c "W: Failed" /tmp/aptitude.log) -ne 0 ]
		then
			safe_aptitude_install $@
		fi
	}
