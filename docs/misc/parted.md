
# parted

The `parted` utility is used to handle drive partitioning, and is an important tool to know for system configuration.

This document will cover partition alignment, and also my preferred partitioning schema.


## general best practice

An ubuntu article states that advanced format disks (eg. modern hardware) using a space of 2048 (multiple of 8) for sector sizes with an initial offset of 1 MiB is best practice.


### about `/sys/block/`

You can check disk information in `/sys/block/` and get actual details for performing manual calculations (again for advanced disks the outcome is pretty standard).

These are the four files to check:

- `/sys/block/sdb/queue/optimal_io_size`
- `/sys/block/sdb/queue/minimum_io_size`
- `/sys/block/sdb/alignment_offset`
- `/sys/block/sdb/queue/physical_block_size`

If the optimal IO size is 0, then you fallback to the 1MiB standard, otherwise you want to perform special calculations:

- Initial Disk Start is: (Optimal IO Size + Alignment Offset) / Physical Block Size
- Subsequent values can be listed with `s` (for sectors) and are multiplied by the physical block size, retaining an optimal relationship

_Remember that the initial 1MiB offset must be subtracted from the `End` value to get an accurate size.  For example if I use a start of `1MiB` and an end of `256MiB` I actually end up with a `255MiB` partition size._

**What about all subsequent partitions?**

Simply set the start point to the last end point.

To save yourself time calculating the prior disks size, simply check the end value after setting `unit MiB`.


### partition alignment test-case

My current test case is Parallels Desktop, where the hardware is virtualized, so it's not a great example of real situations, but a very common one I believe for modern computing.

I found that both my Alignment Offset and Optimal IO Size were 0, so I used the 1MiB offset standard and went with the multiples of 8 for the final values.  My physical and Minimum IO sizes were 4096 (4KiB I believe).

I thus created my partitions using:

- `mkpart primary fat32 1MiB 257MiB`
- `mkpart primary ext4 257MiB 513MiB`
- `mkpart primary ext2 513MiB 100%`

The first two partitions are a UEFI partition for the bootloader, and an Ext4 `/boot` partition.  The initial 1MiB starting point leaves me with negative 1 MiB in my final sizes, hence the odd numbers for subsequent start and end points.  _This isn't a big deal really, but I like even partition sizes._

I followed these commands up with the finishing touches:

- `set 1 boot on`
- `set 3 lvm on`


## preferred partitioning schema

I use this same schema in all installations.

**Partitions:**

- efi (512M)
- /boot (512M, noatime)
- lvm (remainder)
    - swap (4G)
    - /tmp (2G, relatime)
    - /var/log (2G, noexec)
    - /root (20G, noatime)
    - /home (remainder, noatime)

I've heard from far too many folks about how their logs went out of control and filled up the disk.  While you can take specific steps to make sure that does not happen, the most effective strategy that won't ever leave you in a bind with a filled root partition is to create a separate partition for logs.

I've also found that creating one for `tmp/` can also be beneficial, although a ramdisk (ex. tmpfs) may be similarly useful if you are not concerned about persisting temporary data.

The efi and boot partitions are required in order to get your system to boot without any major issues.  A 512MB partition _should_ be enough to hold many linux kernel images, as well as an efi bootloader and possibly an entire efi shell.

_The efi partition must be fat32, and therefore has no separately applied filesystem options._


**Partition Sizes:**

An entire headless (no gui) linux installation can exist on a 2GB disk.  With a graphical environment the root partition would take up roughly 6GB~, and while you could make due with 10GB of space for a full desktop environment you may run into problems depending on what packages you install from there.  An optimal root partition size with plenty of room for additional software and to build large source packages is 20GB, _although I will often go with 40GB._


# references

- [HP Article](http://h10025.www1.hp.com/ewfrf/wc/document?cc=uk&lc=en&dlc=en&docname=c03479326)
- [Independent Tutorial](http://rainbow.chard.org/2013/01/30/how-to-align-partitions-for-best-performance-using-parted/)
- [Ubuntu Summary](http://askubuntu.com/questions/201164/proper-alignment-of-partitions-on-an-advanced-format-hdd-using-parted)
- [Awesome Picture Description](http://superuser.com/questions/291978/western-digital-green-drive-from-512-byte-sectors-jumpered-to-4k-byte-sectors/291992#291992)
