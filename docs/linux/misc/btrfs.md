
# btrfs

I've begun to experiment with btrfs as an alternative to ext4 for the primary file system for my personal machines as well as for my file server storage.

With the recent stabilization of the btrfs file system the number of reasons to use btrfs continues to grow.  Data checksums and reliability as well as raw raid10 performance are improving, the option to use builtin compression reduces the space consumed on disk while having the reverse effect of improving read and write speeds by data being smaller (because compression) and increasing lifespan (because less io) meaning a heavy-win all around for the file system.

This document aims to compile a bunch of useful information from various resources around the web.  Unfortunately there are not many good video tutorials, so I may follow-up by creating a few.  I started with a virtual machine to get a feel for out it worked and how to implement it in debian, my preferred distro.

All examples in this document assume the root of the btrfs file system is `/`, but if you are using a separate storage disk with a different mount point, use that mount point in place of `/`.

_As a forenote, I use the debian expert installer, no graphical interface.  It is possible that some of the steps I was unable to perform are available in the gui installer._


## schema

Starting with the disk schema, when installing I used to use lvm, but with btrfs we can create a single root partition.  We still need a 250 megabyte partition for the for uefi support, and for performance reasons the swap drive should be a separate partition.  However, we only need one btrfs file system for the remainder, and it is grub2 compatible reducing boot complexity.

The new layout I'll use is as follows:

- 250M efi boot partition
- 2-8G swap file partition
- remainder btrfs

We will have the ability to take the single btrfs partition and create subvolumes that are treated like folders but act as sub-partitions to btrfs, upon which we can enable quota's and apply limits just like we had used lvm to do previously.

Unfortunately we are not given many options to configure or improve the performance of btrfs at install time, but once the system has finished installing we can play around with optimizing it, creating subvolumes, snapshots, and regularly scheduled maintenance.


## fstab configuration

Key optimizations need to be added after the installation to the `fstab`.  Here is a list of options:

- `noatime`: reduce io by not updating access times
- `compress=lzo`: apply compression to all _new_ files going forward, using lzo is best for performance
- `space_cache`: Allows block group metadata to be stored on-disk, such that caching can be sped up (_requires kernels newer than 2.6.36_).
- `autodefrag`: automatically defragment in the background when new random io occurs, may perform poorly on virtual-machines
- `inode_cache`: caches groups of inodes, improving performance when very large inode values are reached (eg .**only good for very large file systems, such as storage, not ideal for a boot partition**)
- `ssd`: treat the drive as a solid state drive, various optimizations are made (best results with kernel 3.14 or newer).

Your updated fstab record should look like this:

    noatime,compress=lzo,ssd,space_cache,autodefrag

We will need to reboot to remount root and take advantage of these flags, but we also have some commands to run first.

**A word on compression:**

If you are like any logical person you're probably wondering why someone would want to use compression on anything other than a storage drive, and even then question whether compression would harm performance.

In truth, compression is trading the amount of disk IO for cpu cycles.  Because the CPU is so much faster than the hard disk, this is _almost always_ going to be a pro-compression result.  You can find benchmarks have shown significant performance gains.

If that's not enough to convince you, realize that uncompressed data means more disk IO, which means your disks lifespan is actually reduced by choosing to write uncompressed data.

Couple that with the fact that modern CPU's are already outrageously powerful and you should have almost no reason not to take advantage of compression and btrfs.


## optimizations

To compress the contents on disk run this command (which may take several minutes to complete):

    btrfs filesystem defragment -r -clzo /

_If you run this command and reboot prior to adding the appropriate mount flag (`compress=lzo`) your system may not boot._  Because the debian installer does not provide you the opportunity to heavily modify the `/etc/fstab` or the btrfs partition at install time you cannot run compression automatically during the installation and need to run a command to fix it.

Given the system just installed this command may not be required, but it may help with the placement of data across the drive:

    btrfs balance start /

_After this finishes the dynamic size of the btrfs file system should shrink along with the total space consumed._  This can be run on a schedule to improve overall performance as a part of maintenance.

Assuming you made fstab changes you will also want to reboot the system now to take advantage of those changes.  **The first reboot after making these changes may be slow, this is to be expected, subsequent reboots will likely be faster.**


## subvolumes

Let's start by explaining what a subvolume is.  With btrfs, a subvolume is effectively its own separate file system structure.  When created you define a mount point.  Doing so allows the main system to treat subvolumes as regular folders, while in truth the data is separated just like using multiple partitions.  This seamless integration is what really defines btrfs's subvolume system.

_While in my experience subvolumes have mounted automatically, many documents claim that this is not the case._  I will update my documentation if I find any situations where this does not happen for me.

**Unfortunately, we are once-again burned by the debian installer not giving us the flexibility to configure our btrfs partitioning.**  We cannot create subvolumes where existing folders lay.  Therefore to create `/var/log/` and `/home/` subvolumes we have to move or delete the existing folders.  For those two folders this is hardly a concern, but imagine how this might impact things like `/lib/` or `/etc/`.  Anything in runtime paths will be very difficult to relocate without breaking.

**Some commands:**

You can display subvolumes and their ids with:

    btrfs subvolume list /

_If you have no subvolumes, no results will be listed._

Creating a subvolume is incredibly simple:

    btrfs subvolume create /path/of/your/choice

_The only catch is the final folder cannot already exist._  It will fail if it does.

You can delete a subvolume with:

    btrfs subvolume delete /path/to/subvolume

You can swap any subvolume in as the "root" subvolume via:

    btrfs subvolume set-default 261 /

_Upon rebooting the alternative subvolume will be used as the new "root"._  By default the actual root of the system has an id of 0, which you can use with the same command to "reset" the change.


**Fixing `/var/log/` and `/home/`:**

Fortunately the steps to work-around our problem with the folders already existing are simple.  We move the folders first, create the subvolumes, then copy the contents with original reflinks back into the new "folder":

    mv /var/log /var/logt
    btrfs subvolume create /var/log
    cp -a --reflink /var/logt/* /var/log/
    rm -rf /var/logt
    mv /home /homet
    btrfs subvolume create /home
    cp -a --reflink /homet/* /home/
    rm -rf /homet

_While this should work immediately, it may be beneficial to reboot to ensure no log files got disconnected from their services._

_I have not tested the above command on `/home/` with existing users in the `/home/` path.  For obvious reasons they should not be connected while this change is happening, and you may want to verify they can still access afterwards._


## snapshots

With btrfs you can use the snapshot feature to create another subvolume with a mirror of the contents.

A snapshot ignores the contents of layered subvolumes, so if you have `/home/` as a subvolume to root (`/`) and you create a snapshot of root, you will not have a copy of `/home/`.  This approach allows you to easily manage backups without needing additional partitions!

Further, because even the root of a btrfs file system is treated like a subvolume, you can easily swap any other subvolume for the root, allowing you to restore or swap states very quickly.  _For example, one good option after installing the system and configuring it to a desired state, is creating a snapshot of your root, then switching places with that snapshot._  Doing this will allow you to restore your original configured state when rebooted in the event of a serious problem.

To create a snapshot:

    btrfs subvolume snapshot -r / /backup

_This will create a new subvolume and mount it, duplicating the contents of the root file system._  The contents do not stay in-sync after they are copied, so it is _not_ a single-command to process.

**It is very important that after creating a snapshot you run the `sync` command before interacting with it.**  While the files and file system will appear to exist the operation to duplicate them may still be running in the background and can take a while depending on the size of the volume.

Just like a subvolume, you can use the `btrfs subvolume delete` command to remove old snapshots.

There are also more complicated methods of creating snapshots incrementally so as to both backup changes quickly and frequently, without taking up lots of space.  _I will eventually document those once I've had a chance to try them out._


## quotas

**Support for quota features may not be available until kernel 3.14.**

The primary objective of using quotas is to impose size restrictions on subvolumes, much like using partitions of a specific size.  While the restrictions themselves are applied via `qgroups` the quota feature must first be enabled via:

    btrfs quota enable /


### qgroups

By default each subvolume created will have a quota-group.  These can be displayed via:

    btrfs qgroup show /

To apply a limit follow this format:

    btrfs qgroup limit 2g /var/log

To remove a limit you use the same command but replace the size with the word "none":

    btrfs qgroup limit none /var/log

The easiest way to test your quota is to create a file of the appropriate size via `dd` and move it into that space.  If the file exceeds the disk quota it will fail.  _There may be a problem getting rid of that file afterwards._  When data is copied or moved onto the system the limit may not trigger before filling up or exceeding the limit.  When this happens you cannot `rm -f`, `echo "" > `, `cat /dev/null >`, or `cp /dev/null ` to delete the file(s) taking up all the space.  The solution is to increase or remove the limit first, remove the files, then reset the limit.

In most cases this additional step is not a barrier because you should never "normally" run into that problem.  The point of having the restriction is still upheld, which is why this was not a "deal-breaker" for my use-cases.

A quota limit can only be assigned to a subvolume and will not work when pointed at any other paths.

_I have not confirmed whether limits include layered subvolumes, but given that snapshots and other components treat them independently, we can assume it will not restrict them._


## migrating data

If you have more than one btrfs file system you can use the `send` and `receive` commands to pass around the data.  You can also create snapshots across systems.  This can be especially useful if you want to store a snapshot someplace else or relocate a snapshot after creating it such as a backup to an external drive.

Another valuable tip is that the `send` and `receive` commands are not limited to eachother, you can effectively export the filesystem with send to a file, and vice versa (something akin to `dd` backups but more specifically for btrfs).

Here is an example of sending from root and receiving at any other path:

    btrfs send -p / /first/disk/path | btrfs receive /second/disk/path

_Because a subvolume is created with the receive command it will infer the parent volume._


## general maintenance

To display the file system size and details:

    btrfs filesystem show /

_This command is how you verify the maxium file system size, as by default btrfs expands-to-fill, and the `btrfs filesystem df /` command only shows the total as the space filled by the expanding system._  Until your system actually uses all of your disk, that makes `df` an innaccurate source for partition/file-system size.

You can see how much of your btrfs file system is in use with:

    btrfs filesystem df /

_This will not display quota limitations, and until your disk fills up it may not accurately reflect the partition size._  You still have to subtract the usage from the `btrfs filesystem show /` total to get the available disk space.  **The older `df` command will not accurately reflect disk space.**

You can force the file system to defragment, as well as compress, via:

    btrfs filesystem defragment -r -clzo /

_Depending on the amount of data this can take quite a while._

Because of the nature of its dynamic expansion at some point you may need to rebalance the disk, which can be done via:

    btrfs balance start /

_If you do not rebalance regularly you may end up having your disk fill up prematurely, by rebalancing you can reorganize the segmentation of the data.  This process can also be time consuming._

It is highly recommended **not** to use the `discard` flag, same as with the ext4 file system.  Instead you should regularly use the `fstrim` command, on a weekly or monthly schedule.  This reduces the io levels on the disk, and can improve performance and longevity of the disk.


## crontab

These commands will help retain optimal performance and disk space availability:

    #!/bin/bash
    fstrim /
    btrfs filesystem defragment -r -clzo /
    btrfs balance start /
    # insert incremental snapshot logic here
    sync

At your discretion this can be run once a week or once a month for regular disk maintenance.


## raid10

**I plan to test out ext4 on mdadm raid10 with 8 disks and compare the performance against btrfs.  I will likely choose btrfs because of its compression, improved inode handling, and copy-on-write sanity checking, all of which greatly improve the reliability of a raid.**  It is also much simpler to create the same effect of multiple partitions without the same performance problems as lvm or restrictions as raw ext4 partitions.

    TODO~

Creating a raid configuration:

    # Use raid10 for both data and metadata
    mkfs.btrfs -m raid10 -d raid10 /dev/sdb /dev/sdc /dev/sdd /dev/sde
    # mkfs.btrfs -d raid10 -m raid10 /dev/sd[fghijk]
    # mount /dev/sdf /raid10_mountpoint

You can specify any disk in a btrfs raid configuration to mount the entire file system.  While this may be concerning, if the disk that you usually mount fails you can use `btrfs dev scan` to find the information you need to mount dynamically.

_I still have to test and verify the `btrfs dev scan` logic._


# tips and tricks

If you want to mount a subvolume without mounting the entire pool or "root" subvolume, you can do so using its volume id:

    mount -o suvolid=260 /mount/path

**Almost all of the btrfs commands accept "shortest match", so if `btrfs subvolume list /` seems too long, you can also use `btrfs su l /` to get the same output.**


# references

- [guide part 1](http://www.linux.com/learn/tutorials/767332-howto-manage-btrfs-storage-pools-subvolumes-and-snapshots-on-linux-part-1)
- [guide part 2](http://www.linux.com/learn/tutorials/767683-how-to-create-and-manage-btrfs-snapshots-and-rollbacks-on-linux-part-2)
- [raid10](http://superuser.com/questions/364222/btrfs-on-top-of-a-mdadm-raid10-or-btrfs-raid10-on-bare-devices)
- [snapshots](http://www.dedoimedo.com/computers/btrfs-snapshots.html)
- [multiple devices](https://btrfs.wiki.kernel.org/index.php/Using_Btrfs_with_Multiple_Devices)
- [creating btrfs](http://docs.oracle.com/cd/E37670_01/E37355/html/ol_create_btrfs.html)
- [incremental backups](https://btrfs.wiki.kernel.org/index.php/Incremental_Backup)
- [send & receive](http://marc.merlins.org/perso/btrfs/post_2014-03-22_Btrfs-Tips_-Doing-Fast-Incremental-Backups-With-Btrfs-Send-and-Receive.html)
- [btrfs fun](http://www.funtoo.org/BTRFS_Fun)
