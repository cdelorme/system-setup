
#### mdadm

This is just some quick tips on managing mdadm software raid configurations.

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

##### Drive Checks

Using the sysfs you can force a check or repair of the raid by echoing operations.

**It is important to know that if you reboot a system in the middle of an operation it can cause a failure at next boot, so it's best to tell it to go back to `idle` before rebooting.**

To check for errors:

    echo check > /sys/block/md0/md/sync_action

_If an error is encountered it switches to `repair` and starts over._

To repair errors (best only to run if you know a raid array has errors):

    echo repair > /sys/block/md0/md/sync_action

To go back to idle:

    echo idle > /sys/block/md0/md/sync_action
