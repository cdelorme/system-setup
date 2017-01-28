
# uefi

This is a new and improved bios "operation system", which is both larger and more feature-filled.

In fact, OSX has had this for a while, which is how wireless drivers on their laptops are able to work without the OS itself having been installed.

It often has support for a mouse, and provides a far more visual interface.

Configuration is not always as strait forward, but it is intended for use with a GPT partition table and a FAT32 partition and not the traditional MBR partition table with sequenced bits at the tip of the disk.


## automation

Here is how I would suggest modifying the default uefi configuration:

	# clean up uefi configuration
	if [ -d "/boot/efi" ]; then
		mkdir -p /boot/efi/EFI/boot
		echo "FS0:\EFI\debian\grubx64.efi" > /boot/efi/startup.nsh
		cp -f /boot/efi/EFI/debian/grubx64.efi /boot/efi/EFI/boot/bootx64.efi
		# @link: https://svn.code.sf.net/p/edk2/code/trunk/edk2/ShellBinPkg/UefiShell/X64/Shell.efi
		[ ! -f /boot/efi/shellx64.efi ] && wget --no-check-certificate -qO- "/boot/efi/shellx64.efi" "https://d2xxklvztqk0jd.cloudfront.net/github/Shell.efi" || true
	fi

_Systems like virtualbox have uefi support but treat uefi, like bios configuration, as volatile settings and will not save them on exit.  Thus copying the uefi boot image to the default path from the debian path can eliminate problems on data loss._
