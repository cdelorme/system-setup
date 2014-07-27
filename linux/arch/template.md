
# arch template documentation
#### Updated 2014-7-26

I spent six months learning how to work with arch, and this document contains a small amount of knowledge I can share.  I highly recommend viewing their own documentation, while somewhat outdated it is a far cry better than what I have written here.


## Installation

The arch installation certainly earns its title "linux hard mode", but the actual process is an enjoyable one.  You'll really know what goes on under the hood after installing arch.  They also provide [stellar documentation](https://wiki.archlinux.org/index.php/Installation_Guide).

After booting in you'll be logged into a shell, where you have root privileges and the ability to perform commands almost like it was a full linux environment.  This is the install system, you are given a running copy of "most" of the arch system to do your installation from, and the tools to perform most of the steps.

I had to build a very solid understanding of [partitioning with parted](../../misc/parted.md) before I could get past the "first boss".  Like my other installations I use two 256MB partitions and the rest is LVM, with partitions for `/var/log` and `/tmp`, then of course swap, root, and home.

_Arch is small, even with all my software installed I am using only 1.2GB on root.  I'll know more about the general/recommended sizes after I have installed a desktop environemnt._

The first thing on their list is to set your keyboard (it should be `us` by default, the maps are in `/usr/share/kdb/kemaps/`):

    loadkeys us

If it would make things easier you can set a console font as well with `setfont`.  I especially like the `greek-polytonic` font for its spacing.

Next comes the partitioning.  As stated, you will need to be familiar with parted to get it up and running (or fdisk if you're doing traditional mbr partition tables).  Here are the commands I ran:

    parted /dev/sda
    (parted) mklabel gpt
    (parted) mkpart primary fat32 1MiB 257MiB
    (parted) mkpart primary ext4 257MiB 513MiB
    (parted) mkpart primary fat32 1MiB 256MiB
    (parted) set 1 boot on
    (parted) set 3 lvm on

Next I had to create the volume group and logical volumes:

    vgcreate arch /dev/sda3
    lvcreate -L 2GiB -n swap
    lvcreate -L 8GiB -n root
    lvcreate -L 512MiB -n tmp
    lvcreate -L 512MiB -n log
    lvcreate -l 2134 -n home

_For the last partition, home, I used a lowercase `-l` and the number of PE available, which may not have been 2134 (I don't recall, but I got the figure rom `vgdisplay`).  This way I am using 100% of the LVM disk size._

Next we need to format all of our partitions:

    mkfs.msdos -F 32 /dev/sda1
    mkfs.ext4 /dev/sda2
    mkfs.ext4 /dev/arch/root
    mkfs.ext4 /dev/arch/home
    mkfs.ext4 /dev/arch/tmp
    mkfs.ext4 /dev/arch/log

Now we'll want to mount root at `/mnt/` and proceed to establish our mount points at that location for the install and fstab generator later:

    mount /dev/arch/root /mnt
    cd /mnt
    mkdir boot
    mount /dev/sda2 /mnt/boot
    mkdir /mnt/boot/efi
    mount /dev/sda1 /mnt/boot/efi
    mkdir -p var/log
    mount /dev/arch/log /mnt/var/log
    mkdir /tmp
    mount /dev/arch/tmp /mnt/tmp
    mkdir home
    mount /dev/arch/home /mnt/home

_I found that if I tried to use UUID's I had problems (even if only for the `/dev/sda*` partitions),so it is probably best to let it use labels._

Next we can activate our swap partition as well:

    mkswap /dev/arch/swap
    swapon /dev/arch/swap

By default the system should use DHCP, but you can modify the networking information if you desire.  **I did not do this, and have no documentation for it, as my experiences attempting to configure the network prior to booting into the installed system were very erratic**.

Next, you'll want to install the base system using:

    pacstrap /mnt base

_As I understand it, there are other package groups you can install using the pacstrap command, I only did base._

This process can take a few minutes, but afterwords you will want to create an fstab via:

    genfstab -p /mnt >> /mnt/etc/fstab

Now we can chroot into our actual system and begin configuring it:

    arch-chroot /mnt

We'll symlink our timezone:

    ln -s /usr/share/zoneinfo/US/Eastern /etc/timezone

Next we want to find our locale in `/etc/locale.gen` and uncomment it.  Then we can generate our locale:

    locale-gen

I add a file `/etc/locale.conf` with:

    LANG=en_US.UTF8

Next we can tell our system what keymap and console font to use by creating `/etc/vconsole.conf` with:

    KEYMAP=us-qwerty
    FONT=greek-polytonic

_You are welcome to use any font you like, many prefer Terminus2._

Since we have our system on LVM, we want to go ahead and add that to our `/etc/mkinitcpio.conf` file (it has documentation where `HOOKS` are set).  I also chose to set the compression type to lzop, and add the argument of `-9` for maximum compression.  _AFAIK this requires the lzop package, so I ran `pacman -S lzop` to install it._

**MISSING: Don't forget step with lvm2 hook!**

We can then generate an initramfs image with:

    mkinitcpio -p linux

_**Note:** Always double check that you can extract the contents from the image created, as they have a habit of occassionally corrupting._

This may be a good point during the install to run `passwd` to set our root password.

**MISSING INSTRUCTIONS FOR MOUNTING EFIVARS..**

The last step is installing our bootloader.  Since we installed EFI we need slightly different tools, and to run some specific commands:

    pacman -S grub dosfstools efibootmgr
    grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=grub --recheck --debug

_This will generate a file at `/boot/efi/EFI/grub/grubx64.efi`, and it should communicate this file to the UEFI bios.  However, as a fallback you can always make a copy to `/boot/efi/EFI/boot/bootx64.efi`, which is a standard placement that many systems will check even if the UEFI bios were to be reset.  This can help if your UEFI bios dies, battery runs out, or you have to swap out a motherboard.  It is also the best solution for the volatile NVRAM emulation provided by VirtualBox's EFI option._

**MISSING: Don't forget to `grub-mkconfig > /boot/grub/grub.cfg`, because the default config may or may not work right.**

Finally, we are ready to remount and reboot the system:

    exit
    umount -R /mnt
    reboot

If all went as planned you should be greeted by a terminal.  Congratulate yourself with a beer and a pat on the back, you just beat the first stage of "hard mode linux".


## Configuration

Misc Notes:

Be sure to apply static network names in udev rules.d.
Can test dhcp with `dhcpd name`, for expediting installation of packages.

You can set a static IP, but I recommend waiting until you have installed and rebooted the system.  First, you cannot stop services with systemctl inside chroot, second it's a lot of extra work to tell the network adapter what name it should take on.

The steps are:

- Disable dhcpd service
- Create a profile (copy & edit one from /etc/netctl/examples)
- take down the device
- Optionally rename the device
- Load the profile with netctl

Commands to accomplish all this:

    systemctl stop dhcpd.service
    ip link set dev enl0s3 down
    ip link set dev enl0s3 name eth0
    cp /etc/netctl/examples/ethernet-static /etc/netctl/profile
    netctl enable profile

_To keep the device name the same you will need to create a rule inside `/etc/udev/rules.d/10-network.rules` (create the file if it does not exist).  This requires the adapter mac address, and would look like this: `SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="aa:bb:cc:dd:ee:ff", NAME="eth0"`._

The contents of the profile should be changed to match your network.

_VirtualBox NAT allows internet but does not allow `ping`, so if you test use `curl` or something._


Once the install is finished you can enable dhcpd on the wan network via:

    systemctl start dhcpcd@wan
    systemctl enable dhcpcd@wan

Otherwise you will not have internet when the system is restarted.


## Post Install Configurations

Following my former [Debian Template](../debian/wheezy/template/documentation.md), I decided to run through the various packages and install matching software.

**Arch Packages**

    pacman -S pkgfile sudo openssl openssh tmux screen vim parted bash-completion ntp git mercurial unzip p7zip keychain fuse-exfat exfat-utils monit pastebinit wget curl markdown base-devel ncurses lzop fakeroot ttf-droid ttf-dejavu fontconfig

_Arch uses systemd by default, the newer init system, which changes a lot of things for the more complex IMO._

Enhanced my defrag cronjob to be even more dynamic and less error-prone:

    #!/bin/sh
    LOG=/dev/null
    for DEVICE in `awk '/ext4/{ print $2 }' /proc/mounts`;
    do
        e4defrag $DEVICE &> $LOG
    done

The same for my trim commands (ext4 only):

    #!/bin/sh
    LOG=/dev/null
    for DEVICE in `awk '/ext4/{ print $2 }' /proc/mounts`;
    do
        fstrim $DEVICE &> $LOG
    done

If I am not worried about breaking software I can add my auto-update daily cronjob:

    #!/bin/sh
    LOG=/dev/null
    pacman -Syu --noconfirm

There are two other intelligent options:

- Actually place the output into a log file
- Add `-w` to the flags to only download the update, allowing later installation

Arch does not have cronjobs running by default, and comes with cronie.  We have to enable the service:

    systemctl enable cronie
    systemctl start cronie

_This should automatically run `/etc/anacrontab`, which is preconfigured to run the daily and weekly tasks (among others).  Although it is highly recommended to create a crontab file instead._

Setting umask in `/etc/pam.d/login` and `/etc/login.def` as usual, as well as `/etc/profile` since there are a lot of places it gets modified in arch (values per listed file):

    session optional pam_umask.so umask=0022
    UMASK=002
    umask 002

Arch does not automatically add the hostname to the hosts file, so we must add it manually (to `/etc/hosts`):

    127.0.1.1 hostname.domain.dev hostname

In Arch, the iptables rules are stored `/etc/iptables/iptables.rules` by default, so let's create/modify them with:

    *filter

    # accept established connections
    -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

    # accept local traffic
    -A INPUT -i lo -j ACCEPT
    -A OUTPUT -o lo -j ACCEPT

    # accept ping
    -A INPUT -p icmp -m icmp --icmp-type 8 -m conntrack --ctstate NEW -j ACCEPT

    # accept ssh with rate limiting
    -N LOGDROP
    -A LOGDROP -j LOG --log-prefix "iptables deny: " --log-level 7
    -A LOGDROP -j DROP
    -A INPUT -p tcp -m tcp --dport ssh -m conntrack --ctstate NEW -m recent --set --name SSH --rsource
    -A INPUT -p tcp -m tcp --dport ssh -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 4 --name SSH --rttl --rsource -j LOGDROP
    -A INPUT -p tcp -m tcp --dport ssh -j ACCEPT

    # drop invalid
    -A INPUT -m conntrack --ctstate INVALID -j DROP

    # reject all others (linux compliant blacklist)
    -A INPUT -p udp -j REJECT --reject-with icmp-port-unreachable
    -A INPUT -p tcp -j REJECT --reject-with tcp-rst
    -A INPUT -j REJECT --reject-with icmp-proto-unreachable

    # drop forwards
    -A FORWARD -j DROP

    COMMIT

_Obviously you would replace `ssh` with the port you set it to in `/etc/ssh/sshd_config`, but that is optional, as the text will evaluate to the default port `22`._

Then we need to tell the system to load iptables now and for every reboot:

    systemctl enable iptables
    systemctl start iptables

If you make changes you can quickly reload them with: `systemctl reload iptables`

**Important to note that `StrictModes` for sshd will force the users home directory (`~/`), and ssh directory (`~/.ssh`) to have 700 permissions, and the files within 600 permissions.  With changes to the default umask using pam.d, login.dev, and/or `/etc/profile` you may have to adjust these permissions on new users to make ssh work for them.**

Monit Configuration must be done from scratch.  By default we are given an empty placeholder config at `/etc/monitrc`, which is the default config location.  The solution is to modify the systemd file located at `/usr/lib/systemd/system/monit.service`, by adding `-c /etc/monit/monitrc` to load the specific configuration file.

_Alternatively you can `ln -s /etc/monit/monitrc /etc/monitrc`._

We'll want to create some folders to handle the new structure:

    mkdir -p /etc/monit/conf.d
    mkdir -p /etc/monit/monitrc.d
    mv /etc/monitrc /etc/monit/monitrc
    mkdir -p /var/lib/monit/events

The idea is to place the monit configurations inside `/etc/monit/monitrc.d` and symlink them to `/etc/monit/conf.d`.  Then configuring the placement of monits dot files into `/var/lib/monit` accordingly, and loading the contents of `/etc/monit/conf.d/*`.

Finally you'll need to enable and start the service:

    systemctl enable monit
    systemctl start monit

Yet another service we must configure from scratch is SSH.  Configuration options to look at include the `Port`, whether to `PermitRootLogin` (no usually), and preferably to turn off `PasswordAuthentication`.  Optionally, we may enable X11 Forwarding via the option `X11Forwarding`.  Other than that the rest of the options can be left as defaults, unless you'd rather augment it further.  Finally, we have to tell the system to load it at boot time:

    systemctl enable sshd
    systemctl start sshd

Don't forget to add your public key to `~/.ssh/authorized_keys`, and to generate a new key with:

    ssh-keygen -t rsa -b 4096 -C <email>

Next, for development purposes, let's setup keychain with a passwordless ssh key.  A passwordless ssh key is still sending an encrypted pass phrase over the network, however if someone were to break into your system they would have full access to anything that key is tied to.  Without `keychain` you will have to re-authenticate the ssh key on every access.  With keychain and a password you will have to authenticate on reboots.  _You can create a text file with the passphrase and load that into your keychain program, but this would be no more secure than a passwordless key if someone gains access to your machine._

You can add these lines to your `~/.bashrc` to load the keychain:

    # Autoload SSH Access
    keychain ~/.ssh/id_rsa
    . ~/.keychain/$HOSTNAME-sh

_Arch has a bug where you cannot reboot or shutdown from ssh without the ssh session hanging.  I spent 4 hours trying to fix it to no avail._

**I highly recommend installing my [dot-files](https://github.com/cdelorme/dot-files) repository, or at least visiting it for steps to enhance your cli experience.**

For sudo auto-completion to work we need to add this to `/etc/bash.bashrc`:

    # Carry aliases to sudo env
    alias sudo='sudo '

_Without the above modification, for some reason it won't auto-complete anything with sudo._


## Arch Graphical Interface

- [install documentation](https://wiki.archlinux.org/index.php/Installation_Guide)
- [fastest mirror](https://wiki.archlinux.org/index.php/mirrors#List_by_speed)
