
# vmware efi configuration

For whatever reason when installing debian with the EFI checkbox VMWare has a problem recognizing the EFI bootloader on subsequent boots.

I have not discerned whether this is a flaw in the debian installer, a flaw in VMWare's setup, or perhaps a conflict of configuration steps that creates this issue.

A short-term solution is to run these commands after installation:

    grub-install
    update-grub

In most normal cases, this would be executed during the installation and you'd have been none-the-wiser, plus it'd work properly.  **I believe the problem is that virtualbox provides a stateless EFI BIOS, which upon complete shutdown will forget any of the EFI information set.**

Therefore, the actual solution is to create a file at `/boot/efi/startup.nsh` with the path to the bootloader for the EFI system to pickup:

    FS0:\EFI\debian\grubx64.efi

**However**, if you forgot to do this before rebooting then you'll have to do it from inside the EFI terminal:

    echo "FS0:\EFI\debian\grubx64.efi" > FS0:\startup.nsh

There will be an extra 5 second delay during the countdown to load the efi startup script, but your system should now start correctly.
