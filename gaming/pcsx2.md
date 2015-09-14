
# pcsx2

A PS2 emulator!  Fun times, if you happen to be unable to find your decade old copy of games but can find an iso, you may be in luck!


## dependencies

Missing from my current packages:

	aptitude install -ryq gcc-multilib g++-multilib libaio-dev:i386 libbz2-dev:i386 libcggl:i386 libjpeg-dev:i386 libsoundtouch-dev:i386 nvidia-cg-toolkit zlib1g-dev:i386

Other packages that _should_ already exist at this point of `setup` include:

	aptitude install gcc g++ cmake libgles2-mesa-dev


### conflicts

According to the listed requirements on the linux compilation page, these packages conflicted with my configuration:

	aptitude install -ryq libegl1-mesa-dev:i386 libglew-dev:i386 libgtk2.0-dev:i386 libsdl1.2-dev:i386 libwxgtk3.0-dev:i386 portaudio19-dev:i386

_I am still searching for a workaround._

Due to the package conflicts, installation on my system broke or uninstalled these tools:

- avconv and utilities
- pulseaudio
- mplayer
- youtube-dl
- openshot
- mednafen
- recordmydesktop
- ibus
- catfish

_How a modern emulator manages to break a 1990's emulator I will never know._

To undo the damage I had to run this, and reboot, and make sure that core components were still configured such as pulse, and ibus didn't recover:

	aptitude install -ryq catfish gir1.2-atk-1.0 gir1.2-gdkpixbuf-2.0 gir1.2-gtk-3.0 gstreamer1.0-plugins-good gtk-recordmydesktop ibus ibus-mozc libasound2-plugins libav-tools libavahi-client-dev libavahi-common-dev libavdevice-dev libavdevice55 libegl1-mesa-dev libgles2-mesa-dev libglfw3-dev libglib2.0-dev libglu1-mesa-dev libjack-jackd2-0 libjack-jackd2-0:i386 libmlt++3 libmlt6 libpulse-dev libsdl2-dev libsfml-dev libwayland-dev libxi-dev mednafen melt mplayer2 openshot pulseaudio pulseaudio-module-x11 python-mlt recordmydesktop

However, it appears the dependencies pcsx2 needed are compile-time only, which means it may be possible to use a `chroot` to compile.


### future

If we can figure out `chroot` compilation, what flags the `build.sh` expects to create a non-dev version of the emulator, and whether a script can be used to launch the emulator after, all will be good.


## compilation

Start by grabbing the source & checking out the last stable tag:

	git clone https://github.com/PCSX2/pcsx2.git /usr/local/pcsx2
	cd /usr/local/pcsx2
	git checkout v1.3.1
	./build.sh

_Assuming this is as root._

Due to the lack of XDG compatible directories, you have to do this to be able to launch it:

	echo -e '#!/bin/bash\n(cd /usr/local/pcsx2/bin && ./launch_pcsx2_linux.sh' > /usr/local/bin/ps2
	chmod +x /usr/local/bin/ps2
	usermod -aG games username
	chown -R games:games /usr/local/pcsx2

_The rules may change again once we get chroot figured out._


## conclusion

While this emulator works, it's a far cry from what I would call a "good" solution.  It doesn't support symlinking the executable, didn't produce a non-dev version of the software, and it's packages are so tied to 32bit software that compilation itself created problems.

Additionally the emulation on linux is sub-par, the graphics when using hardware acceleration for OpenGL are awful.  _Software rendering works fine fortunately._

If I can manage to figure out the chroot process and add a custom launcher, it may be more usable, but far from respectable compared to dozens of other emulators.


# references

- [pcsx2](https://github.com/PCSX2/pcsx2)
- [how to setup pcsx2 in linux](https://www.youtube.com/watch?v=it6HRyyb8nE)
- [ps2 bios download](http://www.emuparadise.me/biosfiles/bios.html)
