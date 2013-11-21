
# Virtual Box

Sad to say, but my time with Xen may get cut short if they don't start making further progress.

Recently began experimenting with Arch linux, and honestly I feel that it may be where I migrate to.  I'm liking the low-level feel to it so far, despite some issues with my first install (UEFI in Parallels, where _Parallels_ is the keyword here).

In any event, I am planning to try Arch instead of Debian for my next host machine, and if that fails I may be looking at testing VirtualBox instead.


## OS X

VirtualBox now supports OS X guests.

This gives it a very distinct advantage over almost ALL of its competition, especially being a cross platform FREE service.

Xen "supposedly" supports OS X, but there is almost no documentation on this.  Further, KVM is in the same boat as Xen.

Parallels has support, if you're running a licensed server copy of OS X, and I'm tired of dealing with their bullshit.


## VGA Passthrough

VirtualBox now has limited support for IOMMU, and graphics passthrough:

- [Ubuntu Laptop GPU Passthrough](http://askubuntu.com/questions/202926/how-to-use-nvidia-geforce-m310-on-ubuntu-12-10-running-as-guest-in-virtualbox)

If this works even with an additional 10% loss in performance, it would still be a better place than where I am with Xen.


## Fuck it Mentality

If it goes south and I still can't get VGA Passthrough working, that's even more reason to use VBox instead.

I can just run my IPFire and other machines through it, while relegating my gaming to the Arch host which I should be able to install nVidia drivers onto.


## VBox Stupid Networking

VirtualBox has some really dumb networking options.  Instead of something simple and functional like "Shared Networking" in Parallels, you have to use two adapters to get an internal DHCP address AND internet access.

God forbid they fucking connect it without a billion firewall settings, the lack of ping is outrageously bad.

So in any event, to work around this **severe limitation for home users** we have to create a host-only and a nat or bridged network.  The host-only is for us to access our machines, while the nat or bridge allows them to grab internet access.  Using a NAT network allows you to assign a fixed IP for internet access without worry of direct interuptions you may experience with bridged networking, and is my recommended approach.

First, in VBox you have to configure the network, creating both a NAT Network and a Host-Only Network.

The VM will be responsible for identifying the network they belong to, and optionally applying their own addresses.


## SSH and VBox NAT Networks

NAT is connected to your localhost, 127.0.0.1, so you cannot actually access it at all.

That is, without port forwarding.  You can configure port-forwarding to the port and guest machine IP.

If you are using only NAT for your network, you will need to add a port forwarding rule to be able to access it via SSH.

Then you can connect with:

    ssh -p 9005 root@127.0.0.1

_This will create a known_hosts record, so you may consider separate ports for different VMs._
