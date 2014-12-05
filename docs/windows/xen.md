
# xen

The xen hypervisor is a "Type 1" hypervisor that is highly performant and used heavily in production environments.  _As an example, it is the primary engine that drives Amazon Web Services EC2 instances._

With the arrival of IOMMU and supporting hardware, we can now pass physical hardware addresses to virtual machines for near-complete control.

**One major exception to this is consumer graphics cards and drivers for them lacking support for FLR or "Function-Level-Reset", where the device can be reset by the virtual operating system without a full powerdown.  This is the primary failing of IOMMU that prevents me from using virtualization exclusively.**


## not a xen guide

This is not a xen guide, this is simply a document about how to treat Windows when installing it inside a xen configuration.  If you want a xen guide, [go here](http://wiki.xen.org/wiki/Comprehensive_Xen_Debian_Wheezy_PCI_Passthrough_Tutorial).


## supporting hardware

First, you will want to pick supporting hardware.

From experience, anything with NF200 chips or pci bridges may create problems passing your devices.  This can be reflected as mere errors using the devices, to entirely crashing or preventing the HVM Windows DomU from booting.

Second, for consumer graphics only AMD graphics cards are supported out-of-the-box.  While professional nvidia and amd graphics cards "should" work, the consumer nVidia cards will likely fail.

_There are solutions to this, but they involve futzing with crazy hardware modifications, or in some cases altering the xen source.  I've never been successful modifying the xen source, but I have hard-modded a GTX 670 to act as a K5000 or similar model, including the ability to install those drivers from Windows._


## major concerns

There are two major concerns with windows running ontop of xen:

- hardware state
- driver corruption

**These primarily effect graphics cards**, but can also effect USB 3.0 devices (varies by motherboard/manufacturer).

Let's discuss hardware state first.  Graphics cards are special, they usually only reset to an unused state when the electrical power is cycled on machine reboot.  Once assigned to a system, they "remember" that they were assigned, and this can create problems "sharing" the resources.

With a hard-modded nVidia card, the professional drivers _should_ properly handle device resetting.  If you have an AMD card, you will likely experience a problem rebooting the DomU without rebooting the entire host machine.

The problem can best be described as performance degradation, where suddenly 3D rendering drops to minimal levels, like 5% or less than the maximum performance of the card.  I will refer to a "fresh" state going forward, which means the Dom0 (host) has been rebooted, and the DomU (guest/windows) has only just been booted up, and nothing else has touched the graphics card in between those events.

Going a step further, this degraded state can cause other issues as well.  For example, any driver installation or configuration changes that occur while running in a degraded mode, can result in corruption of drivers or configuration.

If your drivers become corrupted you will experience either an immediately failure and BSoD when booting, or erratic and slowly increasing rates of failure that cause the system to crash.  Both of these cases are unrecoverably, and you may as well reinstall.


### dealing with device "freshness" and driver corruption

The steps are simple.

- anytime you plan on installing software that depends on the graphics card, make sure you reboot everything, including the host.

- do not allow the system to automatically install drivers, and do not pass hardware to the system if you are not ready to install the drivers manually.

- never install or update drivers while in a non-fresh state.

- **make an image backup of your windows system both prior to installing graphics drivers and any software that depends on graphics drivers, and after.  This gives you a restore point if you mess up the installation, and one for after if somehow an update slips through and corrupts your drivers.**


## installation tips

First, don't pass any pci devices to the virtual machine when you boot it for the first time.  Doing so may trigger automated driver installation, which can result in driver corruption.

You will want to disable hardware installation & automatic updates.  Further updates, especially driver updates, can create corruption if your system is not in a "fresh" state.  This can result in an unrecoverable system.

I recommend splitting your installation into two parts:

- pre-drivers
- post-drivers

The pre-drivers is any software you want that doesn't depend on hardware or graphics is installed and configured.  This lets you create an image after this is done, reducing the time and steps needed to be ready to move onto the next phase, with a clean-image.

The driver installation is the first step to the post-drivers phase.  You install the GPLPV windows-xen drivers, and the graphics card driver, plus any motherboard drivers for devices you may have passed like USB 3.0 controllers.  **The system should be in a "fresh" state when doing any of these.**

Finally, you can install and configure any software that depends on those additional hardware drivers, such as video games.

_As before, the system should be in a "fresh" state during each install, and anytime it asks you to reboot you should reboot the Dom0/host as well._

After the second phase, if you can boot and no problems appear to be happening a second image should be made allowing you to restore to a known-working state with all software and drivers setup.


# references

- [Signed GPLPV](http://wiki.univention.de/index.php?title=Installing-signed-GPLPV-drivers)
