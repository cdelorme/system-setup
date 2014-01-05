
#### System File Systems

You'll surely forgive the redundant name once you recognize the benefits of understanding the system file systems.

**Both the `sysfs` and `procfs` draw from the `device tree` data structure.**


##### `procfs`

The `procfs` or "Process File System" was used originally to make process information accessible in a file-system managed way.

In that sense you can use the basic system utilities like `cat` and `echo` to interact with it.

The location of procfs is `/proc`, provided your system mounts it (not all systems do anymore).

The `procfs` has been deprecated in favor of `sysfs`, a newer set of tools that manage similar information in a more modern fashion.  The mixing of device and process information, plus the lack of support for upcoming technologies at the time of its state of deprecation (like hotplugging), have led this to be a less supported structure.

Many systems still have it, whether they intend to keep it long-term is up for debate.


##### `sysfs`

The "System File System", is the new more redundant title where the information from procfs has been moved and restructured.

This file system is substantially more complex, consisting of a myriad of symlinks (quite literally a symlink hell that you can get lost in).

However, all of the information procfs used to supply can be accessed here, and probably has newer code to provide that information (being thus faster and potentially more reliable).

Besides accessing device and system information, you can also interact with many of them by sending commands to them.

For example, raid can be controlled by echoing a status into a file in the sysfs.  Devices can be forced to reset, and you can even connect and disconnect drivers manually.

Granted _doing any of this requires substantial knowledge of the structure, or that you accept the risks involved._


##### References

- [sysfs wiki](http://en.wikipedia.org/wiki/Sysfs)
- [procfs wiki](http://en.wikipedia.org/wiki/Procfs)
- [device tree wiki](http://en.wikipedia.org/wiki/Device_tree)
