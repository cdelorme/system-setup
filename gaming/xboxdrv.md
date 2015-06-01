
# xboxdrv

This is the user-space driver for xbox controllers.  Better explained, it's like modern xinput support for linux.

The default `xpad` kernel-space driver is supported in most games, but it lacks controller compatibility.

Therefore, if you have modern controllers, I recommend using the `xboxdrv`.


## installation

The driver is a simple package, all you have to do is this:

	aptitude install xboxdrv

_Unfortunately, this literally only installs the command to run it, it does not automatically turn it on, nor does it configure it to work properly out-of-the-box._


## controller configuration

We'll start with configuring the controller.  This is not complicated, but there are a dozen "gotcha's" that had me spinning my wheels for hours trying to figure out exactly why things were half-functional.

By default, the `xboxdrv` provides a very modern controller layout.  If you turn it on and connect a wireless controller, then run `jstest-gtk` you'll see a very detailed map:

![detailed xboxdrv map](#)

The problem is may games do not support that mapping.  Oddly enough, [Bastion](#) supports the modern controller layout but [Transistor](#), a newer game made by the same company, expects the older mappings.

To get the older mappings, you need to add the `mimic-xpad` or `mimic-xpad-wireless` flags (_thus far I have not noticed a difference between the two for wireless controllers_).

Here is how `jstest-gtk` sees the xpad controller layout:

![limited xpad map](#)

However, the biggest problem causer is that the `xboxdrv` daemon mode is not compatible with the mimic xpad setting.  It won't crash, but it won't work in games that expect `xpad` mappings.  **I searched for hours and found absolutely nothing to explain why.**  The closest I came was two pages of dbus permission configuration, which made absolutely no sense to me (I am not a dbus person).

Fortunately, to save you the work, I have created a [compatible four-controller configuration](../data/etc/default/xboxdrv), which can be used when loading `xboxdrv`.


## automatically launching xboxdrv

**The xboxdrv cannot be run as a non-root user, because it needs low-level USB access.**

To automatically launch xboxdrv, you'll want to add a [systemd unit file](../data/etc/systemd/system/xboxdrv.service) to `/etc/systemd/system`, then run:

	systemctl enable xboxdrv.service
	systemctl start xboxdrv.service

This will launch it at next boot, and start it right away.  It expects the aforementioned configuration file to be present, and does not use `xboxdrv`'s daemon mode.
