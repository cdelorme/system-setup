
# todo

- add a `btrfs.md` document
	- document benefits of mirrored raid for data-safety


---

- execute updated system-setup script
	- verify idempotency of first half
	- fix bugs as encountered
- snapshot post-completion
	- verify idempotency of the second half


---

- optimize preseed by identifying which undocumented gpt partition table lines are actually needed
	- temporarily disable provisioners
	- verify partition table used is gpt once booted
- verify partman partition size options (1G vs 1024???) and switch for clarity


- use dd to copy the iso onto a usb
- test a hardware install on a spare physical box by coding the preseed manually
- verify ppsspp compiles without depending on a reboot or mesa/freeglut packages
- try it on a box with an nvidia card to verify the nvidia installation block works
- verify xboxdrv does not choke on real hardware (no libusb errors)
- verify working pulseaudio (with minimal extra effort?)
- verify working bluetooth without `rfkill` as a dependency and restores paired devices on reboot
- install a playonlinux game and connect a controller to test `koku-xinput-wine` works

- revisit the usb and see if we can't expand the disk to add files and modify the install
- identify the menu portion to add "Casey's System Setup" that launches a local preseed file
- test on spare hardware, and document the results


---

- verify that 7zw works correctly still?
	- test it against copies of large numbers of compressed files
	- fix bugs and/or improve stability

- craft a script to install at `/usr/local/bin/pulseshort` for pulseaudio behaviors
	- apply behaviors: toggle mute, increase by 5%, decrease by 5%
	- iterate **all** sinks in RUNNING state to apply the change
		- `pactl list short sinks | grep RUNNING | awk '{print $1}'`?

- craft a conky-launcher that can identify and parameterize useful data so we get:
	- datetime & uptime
	- multiple hard drives
	- multiple monitors
	- one or more valid network addresses
	- CPU overview (summary & per-core)
	- CPU & Disk temperatures (summary & per-core/disk)


---

- figure out how to automate `ibus-mozc`, `ibus-setup`, and `im-config`
- figure out how to setup either `hyperspin` or `hyperloop` as frontends to launch mame & mednafen

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


## ppsspp

We ran into errors attempting to compile ppsspp inside virtualbox, possibly due to the fact that we needed a reboot after installing vbox guest additions.

I may have to turn this into something we run post-boot, like `/usr/local/sbin/install-ppsspp`:

	# build & install ppsspp
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


## xboxdrv

We ran into a problem running xboxdrv in vbox, not entirely sure why but I have to try on hardware and see...

I could also try compiling it from source:

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


## pulseaudio

This was how I used to install, but `alsactl store` may not be necessary:

	# configure audio
	which alsactl &>/dev/null && alsactl store
	if [ -d /etc/pulse ]; then
		[ ! -e /etc/skel/.pulse ] && cp -R /etc/pulse /etc/skel/.pulse
	fi


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
