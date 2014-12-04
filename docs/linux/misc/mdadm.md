
# mdadm

A software raid solution available on linux.  I will cover installation, and some tips on managing software raid configurations.


## installation

In many cases the package will already be installed, but if not:

    aptitude install -ryq mdadm


## configuration

I chose software raid, `mdadm`, as it provides the greatest flexibility, without relying on hardware.  Hardware raid can alleviate cpu stress, but it adds the hardware dependency, and limits expansion as well as replacement.  It is harder to recover from failure when you need to replace the hardware, and most systems have multi-core processors that are plenty capable of handling software raid.

I have seen numerous guides that depict setting up `RAID0` for gaming rigs, and others about `RAID5` as a good durable solution.  My experience with `RAID5` is that it is not performant, and my thoughts on `RAID0` are that it targets the wrong performance gains for gaming.

To explain, `RAID0` splits data between two drives.  This gives a theoretical gain of 2x read and 2x write speeds.  However, in practice it actually yields a smaller read gain due to coordinating read operations between both disks, including whether or not data is of a size that it spans both disks.  If you are spending hundreds of dollars to build a gaming computer, you can afford the extra hard drives to setup `RAID1` and the improved read speed that goes with it.  Write speeds are not nearly as beneficial for gaming outside of software installation or saving.

My personal preference is `RAID10`.  It costs more in both funds and disks, but it yields a theoretical 4x read and 2x write speed, including fault tolerance that doesn't come at a heavy cost from parity data.  It is also something you can easily extend by adding more drives in pairs.  It has a minimum fault tolerance of one drive failure, and rebuilds faster because it does not have to perform parity calculations.  A large array of RAID10 magnetic drives can outperform high end SSD's as well, if the controller (s) they connect through are good (note, mdadm you can use multiple controllers too).


**Creating a RAID10 MDADM Array:**

Identify the drives in `/dev` (generally sd*).

Start by taking the four drives and giving them partitions (in my case gpt lvm partitions):

    parted /dev/sda
    mklabel gpt
    mkpart lvm 0% 100%

Rinse and repeat for all four.  Then let's turn them into a working array:

    mdadm -v --create /dev/md0 --level=raid10 --raid-devices=4 /dev/sda1 /dev/sdb1 /dev/sdc1 /dev/sdd1

After that it will take a few hours for `/proc/mdstat` to finished setup.  You do not want to touch it before the synchronization is finished.  For me this took eight hours.  _In some cases it will not begin synchronizing.  If it says resync pending, you can force the synchronization via `mdadm --readwrite /dev/md0`._


**Mapping Folders:**

I generally use [samba](samba.md) to share my storage drives across the local network.  Here is an example of mapping folders and preparing a raid partition for this:

    mkdir -p /media/samba/{media,games,software,backups,torrents,documents}

I combine mdadm with LVM, and create a set of logical volumes across my raid partitions with ext4 file systems:

    lvcreate -L #G -n name group
    mkfs -t ext4 /dev/mapper/group-name

_Rinse & repeat for X LV's, replacing # with an actual size._

Finally I add records to `/etc/fstab` to mount them at boot time:

    # Samba Shares
    /dev/mapper/raid-backups    /media/samba/backups    ext4  defaults  0  0
    /dev/mapper/raid-documents  /media/samba/documents  ext4  defaults  0  0
    /dev/mapper/raid-games      /media/samba/games      ext4  defaults  0  0
    /dev/mapper/raid-media      /media/samba/media      ext4  defaults  0  0
    /dev/mapper/raid-software   /media/samba/software   ext4  defaults  0  0
    /dev/mapper/raid-torrent    /media/samba/torrent    ext4  defaults  0  0

_If you want added data reliability you could technically change the 0 to a 1 in the last column to perform a chkdsk at boot time, but this can cut into the boot times and is better left as a cronjob._

When linux boots it should identify raid partitions automatically, but you can customize how it loads them if you'd prefer to do things manually.


## management

We can check the current configuration of mdadm with:

    mdadm --detail --scan

_The above lines can and should also be added to `/etc/mdadm.conf`, at least in arch._

The physical address varies by distro apparently managed by different sets of udev rules.  The newer udev rules that claim "predictable" names I find to be quite annoying, simply because they are the furthest from predictable from my experiences.

To fix a raid, we have to take it down starting with lvm (if applicable).

    vgchange -an raid
    mdadm --stop /dev/md#

_Swapping the `/dev/md#` with whatever the physical address is._

Next we can re-assemble the raid array:

    mdadm --assemble /dev/md0 /dev/sdb1 /dev/sdc1 /dev/sdd1 /dev/sde1 --update=name

_This renames it to `/dev/md0` and also it should update the name according to the hostname though the notation is awkward.  It should also automatically reload the group._

With `systemd` you will want to make sure the mdadm service is run at boot time:

    systemctl start mdadm
    systemctl enable mdadm


## drive checks

Using the sysfs you can force a check or repair of the raid by echoing operations.

**It is important to know that if you reboot a system in the middle of an operation it can cause a failure at next boot, so it's best to tell it to go back to `idle` before rebooting.**

To check for errors:

    echo check > /sys/block/md0/md/sync_action

_If an error is encountered it switches to `repair` and starts over._

To repair errors (best only to run if you know a raid array has errors):

    echo repair > /sys/block/md0/md/sync_action

To go back to idle:

    echo idle > /sys/block/md0/md/sync_action

