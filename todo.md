
# todo

- craft a smarter script for pulseaudio commands (eg. `/usr/local/bin/pulseshort`)
	- provide behaviors like `mute` toggle, increase, and decrease volume
	- iterate **all** sinks in RUNNING state to apply the change
		- `pactl list short sinks | grep RUNNING | awk '{print $1}'`?

- craft a smarter conky launcher
	- add datetime /w uptime
	- detect: hard drives, monitors, valid network address(es), optionally temperatures of cpu/disk
	- generate a template per monitor
	- launch as many conky as there are monitors

- figure out how to setup either `hyperspin` or `hyperloop` as frontends to launch mame & mednafen
- test ssh key generation & upload logic without `/home/$username` assumed path (can be done from VM)
- investigate a method of checking for and adding backports (otherwise packages like `ffmpeg` will not exist)
- figure out how to automate `ibus-mozc`, `ibus-setup`, and `im-config`


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
