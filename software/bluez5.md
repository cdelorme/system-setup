
# bluez5

**These instructions do not (yet) work, as the bluetoothd daemon depends on dbus and expects to be handled by systemd, which debian does not use by default.**

Since debian is unwilling to get some modern wifi tools installed, we have to grab the source and build it manually.

Let's start by installing dependent packages:

    aptitude install -ryq libglib2.0-dev libdbus-1-dev libudev-dev libical-dev libreadline-dev systemd

Next let's grab the source:

    wget "http://www.kernel.org/pub/linux/bluetooth/bluez-5.16.tar.xz" -O bluez.tar.xz
    tar xf bluez.tar.xz
    cd bluez*

Now comes the fun part, configuring to install.  We have to set the `PKG_CONFIG_PATH` or it won't find a lot of the files:

    PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig/

Then our configuration command needs a number of arguments:

    ./configure --prefix=/usr --mandir=/usr/share/man --sysconfdir=/etc --localstatedir=/var --without-systemd

Now the build process begins, which we can do in one-line, which will halt if the first step fails:

    make && make install

Now if you run `which bluetoothctl` you will find it has installed!  Be joyful and move onto the next step!


**Bugs!**

The bluez5 package has tight coupling with systemd and the dbus tool, which has thus far made it impossible to function on debian.

I cannot tie it to sysvinit, I don't know how and nobody has any suggested methods to launch the bluetoothd daemon with dbus tie-ins from a shell script.

I installed systemd and rebuilt with systemd, and my system would no longer reboot.

I've drawn a few conclusions about this:

- I can try to find a way to get systemd to play nice with sysvinit so booting continues and bluetoothd can work
- I can try to reverse engineer dbus calls from command line to launch bluetoothd from sysvinit shell
- I can look at building my own bluetooth engine because bluez keeps piling on dependencies

