
# todo

- verify ppsspp build works (can be done inside vm now)
- continue hardware installation checks using `tee` to log results
- verify nvidia installation works & nomodeset is available on reboot
- verify bluetooth works without `rfkill` or `connman` as dependencies
	- verify it works on reboot
	- verify connected devices automatically reconnect on reboot
- install `playonlinux` /w a game to test `koku-xinput-wine` works (valid permissions?)

- investigate a method of checking for and adding backports (otherwise packages like `ffmpeg` will not exist)

- figure out how to automate `ibus-mozc`, `ibus-setup`, and `im-config`
- figure out how to setup either `hyperspin` or `hyperloop` as frontends to launch mame & mednafen

- verify that 7zw works correctly still (test against large folders of compressed files)
	- fix bugs and improve stability/performance

- craft a smarter script for pulseaudio commands (eg. `/usr/local/bin/pulseshort`)
	- provide behaviors like `mute` toggle, increase, and decrease volume
	- iterate **all** sinks in RUNNING state to apply the change
		- `pactl list short sinks | grep RUNNING | awk '{print $1}'`?

- craft a smarter conky launcher
	- add datetime /w uptime
	- detect: hard drives, monitors, valid network address(es), optionally temperatures of cpu/disk
	- generate a template per monitor
	- launch as many conky as there are monitors

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
