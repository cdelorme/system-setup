
# virtual network adapters

Networking with virtual machines is a messy business, and it leads to some unexpected problems.

Two of the problems I have encountered include:

- udev and cloning
- virtualbox firewalls


## udev and cloning

Linux systems may remember the network interface mac address, which when virtualized can (and usually will) change when you clone a system.

This means that the system will potentially increment from `eth0` to `eth1`, which can break some network adapter dependent scripts.

A common solution to address this is to delete the file at `/etc/udev/rules.d/70-persistent-net.rules` and creating a directory by the same name, or a symlink to `/dev/null`.


## virtualbox firewalls

This is, in my experience, very specific to virtualbox.  Both VMWare and Parallels provide a network adapter that has its own address, is accessible from the host bridge, and also has internet access.

For "security" reasons virtualbox has a builtin firewall on their bridge, so you cannot ssh into the default NAT adapter, instead you have to create a bridged host-only adapter, or a second adapter for host-only access than the one used for network access.

**It would be excellent is virtualbox would provide a convenient adapter that solves this problem without all these restrictions for people who use it in environments where usability trumps security.**
