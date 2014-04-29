
# creating a windows install usb

This applies to Windows 8, and to some extent Windows 7 (non-efi).

**For EFI Bootable USB:**

- Make a fat32 partition.
- Mount the Windows iso.
- Copy the files.

**For traditional msdos boot:**

- plugin usb and identify device in `/dev/sd*` (for linux) or `/dev/rdisk*` (for osx)
- run dd command to copy all contents `dd if=/path/to/windows.iso of=/dev/(sda|rdisk)# bs=4m`

Both approaches are very simple to do, but the EFI boot method may not work for Windows 7 installations.
