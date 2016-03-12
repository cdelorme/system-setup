
# virtual network adapters

Networking with virtual machines is a messy business, and it leads to some unexpected problems.

Two of the problems I have encountered include:

- udev rules and cloning
- virtualbox firewalls


## udev rules and cloning

Linux systems use udev rules to remember the network interface mac address, which when virtualized can (and usually will) change when you clone a system.

This can lead to unpredictable behavior and automation due to adapter naming conventions increasing (eg. `eth0` to `eth1` etc...).

**The easiest solution is to place a folder at `/etc/udev/rules.d/70-persistent-net.rules`, or a symlink to `/dev/null`.**


## virtualbox firewalls

_VirtualBox caters to the more industrial crowd favoring security over usability._

The result is that their default networking functionality is restricted by a firewall, so it can either have internet access or be locally accessible, _but not both from the same adapter._

The solution is generally to configure a host-only network and create a second host-only adapter for your virtual machines.
