
# uefi configuration

My experience with parallels desktop and virtualbox has been either non-existent eufi support, or broken implementation that does not retain its state on a fresh boot.  My assumption is the same applies to most virtualization software, although the changes here fix these concerns they may also improve bare-metal systems as well.


## shell

To begin with we can throw a uefi-shell into the file system.  Doing so will allow you to run commands in UEFI without loading the OS, which may be used to (for example) update firmware or modify the system.

The uefi shell this links to is the Tianocore uefi x64 efi v2 shell, and this command will download it into the correct spot from a freshly booted system:

    wget --no-check-certificate -O "/boot/efi/shellx64.efi" "https://svn.code.sf.net/p/edk2/code/trunk/edk2/ShellBinPkg/UefiShell/X64/Shell.efi"


## booting

After installation if you fully shutdown the virtual machine and then attempt to boot it will likely fail.  The reason virtualbox gives is that it does not retain the state or "memory" of the uefi bios on shutdown, and because debian (by default) does not install the efi image into the "expected default" location the system fails to boot.

If you run into this problem, virtualbox will throw you into an uefi shell from which you can create a script at `startup.nsh` to get yourself into the os:

    echo "FS0:\EFI\debian\grubx64.efi" > FS0:\startup.nsh

While this script can solve the problem for virtualbox, it's slow by 5 more seconds of boot-time prior to running that script and not the ideal solution.  The correct solution is to create a copy of your efi image at the expected default location.  **This change should also work well on bare metal uefi systems.**

I recommend running these commands from a freshly installed system, the `startup.nsh` script as a faillback, with the `boot/` efi image copy as the primary solution:

    echo "FS0:\EFI\debian\grubx64.efi" > /boot/efi/startup.nsh
    mkdir -p /boot/efi/EFI/boot
    cp /boot/efi/EFI/debian/grubx64.efi /boot/efi/EFI/boot/bootx64.efi


# references

- [uefi shell notes](https://wiki.archlinux.org/index.php/Unified_Extensible_Firmware_Interface#UEFI_Shell)

