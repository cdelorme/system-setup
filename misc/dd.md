
# dd

This is a short blurb on using dd for backups.

This tool has come to earn negative nicknames like "data destroyer" as a result of how easy it is to improperly use it and loose data.

However, it is a low level data access utility that is a vital part of everyday linux for me.


I use it to make backups:

    dd if=/dev/sda1 of=/path/to/disk.img conv=sync,noerror bs=1M

Also to restore them:

    dd if=/path/to/disk.img of=/dev/sda1 conv=sync,noerror bs=1M

_The `conv` options are very important.  The `sync` flag says to wait until data is written to disk and not memory before assuming completion.  The `noerror` flag will continue the process even if an error occurs (eg. unable to read or write a block of data due to corruption)._

_Setting the `bs` is optional but can greatly improve speeds when set to match the block size of the partition._


I also usually combine compression which can drop a 120GB partition to a 60GB file:

    dd if=/dev/sda1 conv=sync,noerror bs=1M | gzip -9 > /path/to/disk.img.gz

Syntax to restore from a compressed file:

    gzip -dc /path/to/disk.img.gz | dd of=/dev/sda1 conv=sync,noerror bs=1M

_It is important to label these files with the size, because it can be difficult to find the original size after compression._

_Compression takes up a lot of CPU power and can be a big slowdown for the backup process.  If you need up-time you should make use of file system snapshots and then use dd to copy those.  Another idea is if you have space to make a copy of the disk first, then compress it._


## osx tips

Since `dd` is portable it also exists on osx; a unix distro.

However, the way OSX handles disk assignment is quite different.

First, you may need to unmount disks with:

    diskutil unmount /volumes/NAME/

It names disks as `disk1`, but also has `rdisk1`.  The `rdisk` is the raw disk, and the other has OS filters on it.  For best performance you should use the `rdisk#` when running `dd` on OSX.

Also, OSX does not use capital letters for `bs`.
