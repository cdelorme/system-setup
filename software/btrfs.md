
# btrfs

I began using btrfs six months ago, and have been quite pleased with both its performance and feature-set.  Thus far it has shown to be very stable as a primary file system, and reliable for file storage as well.

There are specific features, such as snapshots and time-slices that I would like to eventually take advantage of.

I will describe a basic root partition configuration, optimizations, and maintenance for using btrfs.


## root partition schema

_With btrfs you can use qgroups to assign disk quota's without creating separated partitions._

Here is my latest approach to partitioning:

- 250M efi boot partition
- 2-8G swap file partition
- remainder btrfs


## optimizations

These optimizations should be added to the `/etc/fstab` so they are kept on subsequent reboots of the system:

    noatime,compress=lzo,ssd,space_cache,autodefrag

Here is a breakdown of what each flag offers:

- `noatime`: reduce io by not updating access times
- `compress=lzo`: apply compression to all _new_ files going forward, using lzo is best for performance
- `space_cache`: Allows block group metadata to be stored on-disk, such that caching can be sped up (_requires kernels newer than 2.6.36_).
- `autodefrag`: automatically defragment in the background when new random io occurs, may perform poorly on virtual-machines
- `inode_cache`: caches groups of inodes, improving performance when very large inode values are reached (eg .**only good for very large file systems, such as storage, not ideal for a boot partition**)
- `ssd`: treat the drive as a solid state drive, various optimizations are made (best results with kernel 3.14 or newer).


### about compression

Initially it may sound counter-productive to compress the root partition, but in truth it is exceptionally useful.

For the same reason the kernel is often compressed, the time it takes to read from the disk is always going to be slower than the speed of your CPU, therefore even with the fastest hard disk if the amount of data that needs to be loaded into memory is smaller, then you can gain performance by loading compressed data into memory and decompressing it from there.

In otherwords, compression increases both the performance of your drive, and its longevity due to the reduced amount of actual IO happening on-disk.


## maintenance

While the auto-defragment option works wonderfully, you may want to run this at least once after setting the `/etc/fstab` compression to recompress the root file system (and possibly weekly afterwards just in case):

    btrfs filesystem defragment -r -clzo /

On a weekly basis it is also wise to rebalance the data on disk:

    btrfs balance start /

_This can take some time, so it may not be wise to do daily, or in the middle of anything important._

Finally, you should try to run a scrub daily:

        btrfs scrub start /


### checking the status

To display the file system size and details:

    btrfs filesystem show /

Because btrfs dynamically allocates space and grows in actual size, the `df` command itself may not accurately reflect the actual free space, and so this command is recommended instead:

    btrfs filesystem df /


### repairing

Fortunately it is very easy to repair damaged btrfs systems, **but the disk must not be connected while doing so**:

    btrfs check --repair /dev/sdX

_The device name must be a btrfs partition._

If the repair says there were unrecoverable files you can try to run this operation to find the broken files:

    find / -type f -exec cp {} /dev/null \;


## features

**The latest debian kernel version has known problems with subvolume management and quotas which can lead to kernel panics, so it may be ill-advised to utilize some of the features described here currently.**

- subvolumes
- qgroups and quotas
- snapshots
- data migration
- raid


### subvolumes

A subvolume is treated like a folder, but given a logical volume id inside btrfs and a mount-point inside of its root file system.  Parent btrfs partitions will automatically mount their child partitions, so a subvolume is extremely transparent in both appearance and management.

Subvolumes are required to use other features, such a snapshots, qgroups and quotas, and data migration.  They allow you to organize formless partitions underneath a root btrfs partition.

You can easily find subvolumes and their ids with:

    btrfs subvolume list /

_Most of the other commands expect the subvolume id and not its mount point._

Creating a subvolume is simple:

    btrfs subvolume create /home

_If `/home` exists already then the subvolume creation will fail; therefore creating subvolumes after-the-fact requires a bit of manipulation._

You can delete a subvolume in the same way you create it:

    btrfs subvolume delete /home


### qgroups and quotas

A qgroup is used to define restrictions, such as quotas or "size limits" on a subvolume.

Listing them is as simple as:

    btrfs qgroup show /

To begin using quotas you must enable them:

    btrfs quota enable /

If you had a `/var/log` subvolume, you could restrict it to 2 gigabytes by running:

    btrfs qgroup limit 2g /var/log

To remove a limit, replace the size with `none`:

    btrfs qgroup limit none /var/log

The easiest way to test whether your quota is working is to create a file using `dd` of the size you expect, and attempt to copy it into that space.  The operation should fail if the size exceeds the quota space.  _Due to bugs in debian you may need to remove the quota to make space or delete files again._


### snapshots

A basic snapshot grabs the current state of a subvolume excluding child subvolumes.

For example, to create a root snapshot is as simple as:

    btrfs subvolume snapshot -r / /backup
    sync

This will create a `/backup` subvolume.  If you had a `/home` subvolume behind `/` (the root), its contents will **not** be a part of `/backup`.

**It is very important to run `sync` afterwards to ensure the snapshot is finished before moving onto any other steps that may manipulate the file system.**

When a new btrfs file system is created, it starts with a default root subvolume, which means you can actually switch the subvolume id used for the default-root.  Assuming `/backup` has an id of _261_ we could do this:

    btrfs subvolume set-default 261 /

The next time you boot the system it will load `/backup` where `/` was previously.  _This may have unexpected effects on child subvolumes that belong to `/` and not `/backup`, so there are quirks to this._

Taking this a step further, you can use the `send` and `receive` operations to create incremental snapshots.  This is very useful if you wanted to `diff` the state before running software updates, such that you can quickly restore to that state, but without keeping a complete copy of that state.

_Unfortunately you cannot use `send` to create incremental snapshots without a read-only copy of the current state, which means you do need enough space to take a complete snapshot to create the incremental one._

In our previous example we created a root backup at `/backup`.  Assuming a week later we wanted to install a number of peices of software, but we wanted to be able to restore to the point just before that, we would start by creating a new read-only snapshot, like this:

    btrfs subvolume snapshot -r / /backup.$(date +%Y-%m-%d)
    sync

Next, to create the incremental snapshot, we use `send` against the two states:

    btrfs send -p /backup /backup.$(date +%Y-%m-%d)

Ideally you would pipe this to `btrfs receive` which can be run either locally or remotely, and against a different btrfs file system.  For example:

    btrfs send -p /backup /backup.$(date +%Y-%m-%d) | btrfs receive /backup.partial.$(date +%Y-%m-%d)

**This means that incremental snapshots require at least enough space for the original state, current state, and incremental states in between.**  If you want to keep a complete history, this will consume at least as much as the total size of the subvolume you are making backups of, and at least enough for the original state, and double the current state, to create the backup.

_I am still struggling with the means of restoring from these snapshots._

While you can use `btrfs send` to restore a complete copy of the data against something like `/home`, it won't work very well if you attempt to do it against an active volume, such as root (`/`).  Instead you would have to change `default-root`, reboot, run the restore against the original root, then change default-root back and reboot.

Alternatively you can run `cp -ax --reflink=always` to copy from the backup to the destination, but that won't necessarily delete files because it will merge folder contents recursively.


### migrating data

If you have more than one btrfs file system you can use the `send` and `receive` commands to pass around the data.  You can also create snapshots across systems.  This can be especially useful if you want to store a snapshot someplace else or relocate a snapshot after creating it such as a backup to an external drive.

Another valuable tip is that the `send` and `receive` commands are not limited to eachother, you can effectively export the filesystem with send to a file, and vice versa (something akin to `dd` backups but more specifically for btrfs).

Here is an example of sending from root and receiving at any other path:

    btrfs send -p / /first/disk/path | btrfs receive /second/disk/path

_Because a subvolume is created with the receive command it will infer the parent volume._


## raid10

**I plan to test out ext4 on mdadm raid10 with 8 disks and compare the performance against btrfs.  I will likely choose btrfs because of its compression, improved inode handling, and copy-on-write sanity checking, all of which greatly improve the reliability of a raid.**  It is also much simpler to create the same effect of multiple partitions without the same performance problems as lvm or restrictions as raw ext4 partitions.

Creating a raid 10 configuration with both metadata and data spread across all disks:

    mkfs.btrfs -m raid10 -d raid10 /dev/sdb /dev/sdc /dev/sdd /dev/sde

A shorthand version of the same:

    mkfs.btrfs -m raid10 -d raid10 /dev/sd[fghijk]

You can specify other raid types, as well as different options for where to store the metadata, which says how to read the spread of contents on those disks.  This gives you a lot of flexibility.

Finally, you can mount the entire group by specifying _any_ of the disks in the array:

    mount /dev/sdf /raid10_mountpoint

Alternatively you can use `btrfs dev scan` to find the optimal disk to use to mount the disks.


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
- [superb resource](http://codepoets.co.uk/2014/btrfs-gotchas-balance-scrub-snapshots-quota/)
- [another excellent resource](http://blog.kourim.net/installing-debian-on-btrfs-subvolume)
- [btrfs fun comprehensive step-through features](http://www.funtoo.org/BTRFS_Fun)
