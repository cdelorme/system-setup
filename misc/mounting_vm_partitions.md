
#### How to mount Virtual Machine partitions for recovery or backup!

This is useful in many situations; here are some examples:

- Virtual machine dies and you need data off of it
- Virtual machine dies and you want to restore it
- You need access to a backup image but do not have Xen running

The good news is recovery is relatively easy.  First we need to get the offset of the partitions in Bytes with these commands:

    parted /dev/mapper/group-volume
    unit b
    print

The printed data should include the partitions we want to access and their offset value.

_Since linux/unix treats everything as a file, image files should also be a valid source when using parted (hence from backups).  **I assume it will not work if you backup is in a compressed format**._

Now we can mount it using the offset option with the mount command:

    mount -o loop,offset=#### /dev/mapper/group-volume /path/to/mount/dir

**Important: Windows 8 is extremely sensative to being mounted and may cause it to trigger a long winded recovery process on the next boot, for that reason it is recommended to use the `ro` option after `loop` in the mount command if mounting a windows partition.**


## Now for a live example!

Less than an hour ago I removed Xen & a modified Kernel from my system with dpkg.  This is to test some newly available features and patches.  However, I forgot to backup some of the files on my Windows system.

My logical volume is located at `/dev/mapper/victory-uw`, so here are the commands I will run and the output:

    sudo parted /dev/mapper/victory-uw

    GNU Parted 2.3
    Using /dev/mapper/victory-uw
    Welcome to GNU Parted! Type 'help' to view a list of commands.

    (parted) unit b
    (parted) print

    Model: Linux device-mapper (linear) (dm)
    Disk /dev/mapper/victory-uw: 107374182400B
    Sector size (logical/physical): 512B/512B
    Partition Table: msdos

    Number  Start       End            Size           Type     File system  Flags
     1      1048576B    368050175B     367001600B     primary  ntfs         boot
     2      368050176B  107372085247B  107004035072B  primary  ntfs

    (parted) quit

The second partition is the one we want, which has an offset of 368050176 Bytes.

Now we can mount it with these commands:

    sudo mkdir /media/windows
    sudo mount -o loop,ro,offset=368050176 /dev/mapper/victory-uw /media/windows

Now I can copy the contents off of my drive without a problem.

_Note: I had fuse-ntfs packages installed, if you do not have ntfs packages you will not be able to mount the windows partition._
