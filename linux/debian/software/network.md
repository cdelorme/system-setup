
# network

The default debian networking behavior is at best difficult to manipulate.

It is laden with two problems for desktop users:

- unpredictably named network interfaces
- a networking service that does not actually operate the interfaces

The latest `udev` will automatically set the name in relation to the name of the device and associated driver, which means you can no longer rely on something simple like `eth0` and instead get names like `enp0s25`.

To restart the network and reset the dhcp lease you would run this:

	systemctl restart ifup@enp0s25

**This is to say nothing of wireless network management which is equally plagued by `NetworkManager` as the only recommended gui, which installs most of Gnome.**  My recommendation is something more lightweight like [`connman`](connman.md), but that has its own bugs.
