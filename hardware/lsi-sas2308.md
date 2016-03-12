
# fixing the LSI SAS2308 RAID controller

My ASRock Z77 Extreme11 came with this chipset onboard to control 8 SATA ports.

They are now releasing consumer motherboards with entire controllers, which does an excellent job at expanding available options to the user.

At the same time, these cards come default configured to be fully managed raid chipsets, which tend to cause problems with mdadm or "software" raid managed by the OS.


## a brief opinionated rant

Many years ago when processors were not as capable, hardware raid was a very good solution to offload the handling of calculations.  That said, in current day hardware raid has several failings.  To transfer a hardware raid configuration you need a compatible card, and often those cards cost a boatload and are only on the market for a fixed period of time.

With the growing rate of new hardware being released, the changes of hard-ware raid being useful for a very long period are only getting lower and lower.  Meanwhile, advances in multi-core and parallel processing have only made software raid a more appealing option.

I use software raid, because I can spinup any copy of linux or unix with mdadm support and access my data, on any set of hardware I wire them into.


## the bug

When using this chipset without any modifications to attach MDADM raid, you will find that your disks drop randomly and the RAID degrades for seemingly no reason.

The exact reason for this is unknown, but it has to do with a managed chipset interpretting transactions and probably assuming the configuration is invalid and therefore dropping the drives.


## solving the bug

Fortunately, the bug can be solved.  It is an easy fix, but poorly documented anywhere on the web.

To resolve the problem we have to flash the IT firmware onto the device from an EFI shell.  This process will turn the "smart" chip into a "dumb" HBA.

We will need:

- An EFI bootable device
- A copy of the IT firmware
- An EFI shell script to install it (or known commands)

I found some downloads and moderately helpful notes on this from these sources:

- [Great Solution And Downloads](http://lime-technology.com/forum/index.php?topic=26598.0)
- [Same Solution Less Details](http://forum.manjaro.org/index.php?topic=5575.0)
- [Drivers](ftp://ftp.supermicro.com/Driver/SAS/LSI/2308/Firmware/IT/)

The solution for me consisted of three steps:

- Grabbing the SAS Address
- Booting into a raw EFI Shell
- Running the update process from that shell

The sas address is _supposedly_ unique to every chip.  To grab it easily you can run this command:

    find /sys/ -name "*sas_address" -exec cat {} \;

That will spit out one code for the host, and then one for each port.  _You can alternatively use `host_sas_address` if you prefer, but for me (and perhaps due to my own errors discovering this the first go-around, the codes were the same for all devices._  You will need the last 9 digits of whatever it spits onto the screen (though some notes mentioned being able to enter whatever you wanted here).

I used the downloaded EFI Shell from the second links guide, and simply replaced the older firmware they had with the latest IT firmware from the first link.  If you have Arch on CD or USB that should also be UEFI bootable, and has an option to launch the EFI shell (though you still need a way to access the firmware, preferably a FAT32 partition).  The first links IT firmware are supposed to turn the controller into a "Stupid HBA", which should prevent it from trying to do any managerial tasks that might break a software raid.  **If you are using the controller to manage the raid, then you probably won't want to do any of this.**

The instructions in the second link were written for the version 14 release, and the latest has a few additional steps.  You can either read and perform them manually from the .nsh file, or you can make things even easier and run the .nsh file from the EFI Shell.  This will strip the existing firmware from the controller, then load the new contents on.  The last step will ask for the 9 digits you took down in the first step, if you do not enter them it will say it failed (I did not test whether the ports worked without entering this information, nor did I test with a random value).

Prior to doing this, my drives would drop with no load in a few hours, and if I tried to mount and copy files they would drop in even less.  Since the firmware update on Saturday, I have been able to transfer over 80GB of data to my raid storage, without a single problem.  I have mounted an unmounted disks over 50 times, and run a complete `check` on the raid array.

I hope this information is helpful to anyone with either this motherboard, or the LSI SAS2308 chipset in general who is trying to use it in linux.
