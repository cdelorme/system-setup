
# gaming

Linux gaming is, unfortunately, not there yet.  A combination of driver support problems, alongside the lack of mainstream development support leads to a significant lack of linux compatible games and "good experiences".

Fortunately, a sizable number of gamers want to game on linux, and there are many services in the works.


## xbox controller support

You can use a controller on your linux platform, and the xbox controllers also work well.

You will need to install these drivers:

- xboxdrv
- joystick
- jstest-gtk

The `jstest-gtk` package is for configuration, and is optional.

The `xboxdrv` package can be run as a daemon, but conflicts with the kernel builtin `xpad` module.  To resolve this you will need to unload `xpad` and then run the `xboxdrv` in daemon mode.  I created an [init script](../../../data/etc/init.d/xboxdrv) for launching it.

A default configuration file should be created at `/etc/default/xboxdrv` containing:

    [xboxdrv]
    silent = true
    next-controller = true
    [xboxdrv-daemon]
    dbus = disabled

Finally, for permissions on the joystick device you will want to add `/etc/udev/rules.d/50-event.rules` with:

    KERNEL="event*", GROUP="games", MODE="660"

Then all you need to do is add users to the `games` group (which should already exist on most linux platforms with a gui installed).


## game on linux

A lot of games exist only on windows.  This is disappointing to any linux user, and fortunately we have groups of people working to fix it.

It's not a perfect solution, but `play-on-linux` is a nice wine-based solution that aims to deliver simplified wine-bottles and a clean wrapper gui to make the installation and execution as easy as possible.  They've done an amazing job of that.

