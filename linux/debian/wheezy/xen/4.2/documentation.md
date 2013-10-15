
# Xen 4.2 Server Documentation
#### Updated 10-15-2013

A (slightly dated) copy of this guide can be found on the [xen wiki](http://wiki.xen.org/wiki/Comprehensive_Xen_Debian_Wheezy_PCI_Passthrough_Tutorial).

I also highly recommend the [videos](http://www.youtube.com/playlist?list=PLC70DC33D993CEB44) if you want a quick runthrough without a ton of reading.

**Because installing Xen requires a pretty sizable change in setup, the installation stages will be re-iterated here, and the template should be followed post-installation and pre-xen installation.**


## [Introduction](http://www.youtube.com/watch?v=mnTj6_kDIeg)

The following guide is comprised of my personal documentation and excessive filtering for human consumption. It details the series of steps I took to successfully install and compile a custom Linux Kernel, Xen 4.2 unstable, and run three virtual machines to perform unique tasks all on a single physical computer.

To achieve the desired functionality, I used IOMMU for PCI Passthrough with a multimedia operating system, granting complete access to a graphics card for GPU Acceleration.

I am a college student, not a trained professional, and I am sharing this documentation for educational purposes. Blind use of this document for a production environment in a business setting would be ill-advised.


---

To quickly summarize my experiences, I decided to try Xen and began researching in early January 2012.

I purchased equipment in March 2012, and began what I thought would take "at most two weeks".

By late April I finally had a (_mostly_) functional system.

I have been fine tuning the system and my process since then to produce this guide for others.

The purpose of this guide is to turn a 6 month project into a series of steps that can be reproduced inside the time frame of 1-2 days.


### Objectives Overview

I wanted a single physical computer, that could handle three computers worth of separated activities at all times, including these four specifics:

* Router/Firewall (PFSense)
* DNS & Web Development (Debian Squeeze)
* Application Development (Debian Wheezy)
* Multimedia & Gaming (Windows 7)

I investigated alternative software, including VMWare's ESXi and Citrix's XenServer.

I had come from a VMWare platform having used both VMware Server 2 and VMWare Workstation 8 for the same key objectives previously but with a Windows Host, subject to Windows Updates which let to my investigation.

ESXi was easy to install, but missing numerous drivers for hardware components. I quickly ruled it out as I wanted a home-use system, and there was no convenient or well-documented method to installing or even launching a virtual machine from their on-server interface.

Citrix's XenServer was easily my favorite of the options, it's design made for a great user experience. Everything was easy to find and do. However it came with a minimum price tag of $1000, and if I wanted PCI passthrough for graphics cards $2500. This was beyond my reach as a college student.

I chose Xen since it had support for my hardware, was a free open-source project, and had a great community with lots of activity.


---

**Things you Will Need:**

- Compatible Hardware
- ATI Graphics Card
- Motherboard with UEFI & VT-d & Onboard Graphics
- Latest Ubuntu Live DVD
- Debian Wheezy Beta1 (Or Newer) Installer

nVidia Cards can be made to work, with extensive patching, in Windows XP and supposedly Windows 8 Preview, for more information visit [David Techer's blog](http://www.davidgis.fr/blog/).

If you plan to pass your graphics card to a virtual machine, you will need either a second graphics card, onboard graphics, or a second computer to manage your Dom0 system and install virtual machines over VNC.

UEFI compatible boot DVD will save you an undocumented step for setting up a UEFI boot loader.


---

Xen is picky, different hardware may yield different results, both at compile time and runtime. If you want to save yourself some hassle, here is my hardware list and some suggestions to avoid:

- Motherboard:
    - ASRock Z77 Extreme9
- CPU:
    - Intel Core i7 3770
- RAM:
    - 32GB 1333Mhz Corsair XMS (4x8GB)
- Boot Disk:
    - 240GB OCZ Vertex 3
- GPU:
    - ATI Radeon HD 6870
- LAN:
    - Dual Onboard LAN
    - MiniPCI Onboard Wireless

Hardware and Configurations to Avoid:

- NF200 Chipsets are **not** IOMMU compatible
- nVidia Graphics Cards
- RAID5 yields horrible performance

NF200 is a PCI Switch for motherboards sporting SLI and CrossFire, avoid it if you want be able to use those PCI slots for passthrough.


## [UEFI Configuration](http://www.youtube.com/watch?v=mnTj6_kDIeg)

These instructions are for an Intel CPU and ASRock UEFI Motherboard, and may vary depending on your manufacturer as well as your choice of CPU. If you are unfamiliar with motherboard configuration, you may want to watch the video for a visual walk through.

Before starting reset your CMOS so you have a clean slate to work from.


**List of key settings:**

- Turn Legacy USB 3.0 off
- Turn on VT-x and VT-d
- Set drives to ACHI Mode
- Change default video to Onboard


**Justification:**

Consider yourself warned, if you leave Legacy USB on and leave a backup USB drive connected, your system will fail to boot. To my surprise that is because it is trying to boot from that USB drive (_even if that drive is USB 2.0_), which threw me off so I recommend disabling that feature.

Most motherboards will have Intel Virtualization enabled by default (VT-x), but that is _not_ the same as IOMMU, be sure to look for VT-d or check the manual for details. For my system VT-x was in the CPU configuration area, and VT-d was in the Northbridge configuration area.

ACHI is a superior choice for performance with modern hard drives, and while RAID is an alternative that uses ACHI as its underlying type, it increases boot time by checking RAID configurations, and most onboard RAID is software RAID that is built for Windows and rarely helpful for Linux.

ASRock boards will use a PCI GPU by default if it is plugged into a PCI slot, regardless of if any video cables are connected, and if you plan to pass that device to a virtual machine, you do not want to use it for video.


## [Wheezy Installation](http://www.youtube.com/watch?v=mnTj6_kDIeg&t=4m20s)

Select `Advanced Options` from the menu, and then `Advanced Install`.

To expedite this process we can select defaults for most options (such as for networking).

Once we reach Hard Drive Partitioning options, select `Manual` at the bottom.

Select the disk(s) we will be using by title not partition space and hit enter, we can now select `gpt` from the partition tables instead of `msdos`.

We will then create three partitions:

- 256MB EFI Boot Partition
- 256MB Ext4 Partition mounted to /boot
- 60GB LVM Partition
- "Remainder" to LVM Partition

_The first partition we use for xen, by creating the second partition we are keeping our VM LV's out of the "kitchen"._

Select `Configure the Logical Volume Manager` and create a volume group named `xen` with the 60GB LVM partition.

Create three Logical Volumes:

- 8GB or More for Linux
- 20GB or More for Home
- 2GB or More for Swap
- 500MB for /var/log
- 500MB for /tmp

Complete LVM Configuration, and then back to our partition settings we can now select formats and mount points:

- 8GB LV Ext4 for root (/)
- 20GB LV Ext4 for /home
- 2GB LV swap
- 500MB LV ext4 for /var/log
- 500MB LV ext4 for /tmp

Optionally you can add `noatime` flags to all the Ext4 partitioned disks.

Complete the Partition steps by selecting done and create the partitions.

Continue through the options with defaults, until we get to the main Packages.

**De-select "Debian Desktop Environment" and continue**

Don't create a new user just yet, we want root only for the time being.

Debian Wheezy will now recognize EFI partitions during installation and the boot loader should install without any additional steps.


## [Wheezy Configuration](http://www.youtube.com/watch?v=d3pFN2C10x0)

**Follow the instructions from the template file first, then return here.**

If using a SSD (as I am) you will most definetally want to modify the discards flag in LVM configuration as well as create the fstab cronjob to run trim manually every week.

If you intend to install and manage systems from the Dom0 environment, and are not using it as a headless only server, then you will want to install the GUI components from the template as well.  In particular you will want the `xorg` packages for SDL window access to virtual machines.

I don't care for having a mail system that notifies me about things on this system, so I remove exim4:

    aptitude purge exim4
    update-rc.d -f exim4 remove


**Install these new packages:**

    aptitude install -y bcc bin86 gawk bridge-utils libcurl3 libcurl4-openssl-dev transfig tgif zlib1g-dev python-dev python-twisted libvncserver-dev pciutils-dev libbz2-dev e2fslibs-dev uuid-dev bison flex libyajl-dev xz-utils libxml2-dev iasl libx11-dev libsdl-dev libjpeg62-dev ocaml ocaml-findlib gettext texlive-latex-base texlive-latex-recommended texlive-fonts-extra texlive-fonts-recommended


## [Compiling a Custom Linux Kernel](http://www.youtube.com/watch?v=xjcDL9X-2M8)

We will want to compile a custom kernel.  The latest stable is "usually" the best, but sometimes the latest will be buggy or incompatible.  If you aren't looking to take risks, stick with whatever someone has documented as functional.

If you have a premade .deb that'd be far easier, otherwise let's create a workspace we can use for building.  Ideally this should be inside `/home` since we can expand it, and may need to (building a kernel may take upwards of 7GB, and Xen upwards of 2GB).

    cd /home
    mkdir -p src/kernel src/xen

Compiling a kernel is somewhat optional, but it potentially enhance performance by building components into the system instead of as modules.  PCI passthrough becomes a much easier feature to implement with a custom kernel as well.

We can modify our "CONCURRENCY_LEVEL" inside `/etc/kernel-pkg.conf` to improve compiling speed, generally n+1 where n is the number of cores works.

    echo "CONCURRENCY_LEVEL=9" >> /etc/kernel-pkg.conf

Next let's grab us the latest stable kernel (3.11.5 at time of writing):

    wget https://www.kernel.org/pub/linux/kernel/v3.x/linux-3.11.5.tar.xz -O kernel.tar.xz
    xf kernel.tar.xz
    cd linux-3.11.5

To ensure compatibility with our Dom0, we will want to copy the existing configuration from `/boot` for our current kernel:

    cp /boot/config* .config

_The asterisk will cause an error if more than one config exists in /boot, ideally you would autocomplete the name of the newest known-working config file._

When we run `make menuconfig` it will load in the .config inside the current directory and update any outdated components.

When in `menuconfig` you can use vim hotkeys to search for the following flags (some may not be accessible through the menuconfig, but changed as a result of the other flags):

    CONFIG_KERNEL_LZO=y
    CONFIG_VIRT_CPU_ACCOUNTING=y
    CONFIG_VIRT_CPU_ACCOUNTING_GEN=y
    CONFIG_TREE_PREEMPT_RCU=y
    CONFIG_PREEMPT_RCU=y
    CONFIG_CONTEXT_TRACKING=y
    CONFIG_CONTEXT_TRACKING_FORCE=y
    CONFIG_IKCONFIG=y
    CONFIG_IKCONFIG_PROC=y
    CONFIG_ARCH_USES_NUMA_PROT_NONE=y
    CONFIG_NUMA_BALANCING_DEFAULT_ENABLED=y
    CONFIG_NUMA_BALANCING=y
    CONFIG_UNINLINE_SPIN_UNLOCK=y
    CONFIG_HYPERVISOR_GUEST=y
    CONFIG_PARAVIRT=y
    CONFIG_PARAVIRT_SPINLOCKS=y
    CONFIG_XEN=y
    CONFIG_XEN_DOM0=y
    CONFIG_XEN_PRIVILEGED_GUEST=y
    CONFIG_XEN_PVHVM=y
    CONFIG_XEN_MAX_DOMAIN_MEMORY=500
    CONFIG_XEN_SAVE_RESTORE=y
    CONFIG_KVM_GUEST=y
    CONFIG_PARAVIRT_TIME_ACCOUNTING=y
    CONFIG_PARAVIRT_CLOCK=y
    CONFIG_MCORE2=y
    CONFIG_X86_INTEL_USERCOPY=y
    CONFIG_X86_USE_PPRO_CHECKSUM=y
    CONFIG_X86_P6_NOP=y
    CONFIG_PREEMPT=y
    CONFIG_PREEMPT_COUNT=y
    CONFIG_MOVABLE_NODE=y
    CONFIG_CLEANCACHE=y
    CONFIG_FRONTSWAP=y
    CONFIG_HZ_1000=y
    CONFIG_HZ=1000
    CONFIG_ACPI_PROCFS=y
    CONFIG_PCI_XEN=y
    CONFIG_PCI_STUB=y
    CONFIG_XEN_PCIDEV_FRONTEND=y
    CONFIG_SYS_HYPERVISOR=y
    CONFIG_XEN_BLKDEV_FRONTEND=y
    CONFIG_XEN_BLKDEV_BACKEND=y
    CONFIG_VMWARE_BALLOON=m
    CONFIG_HYPERV_STORAGE=m
    CONFIG_NETXEN_NIC=y
    CONFIG_XEN_NETDEV_FRONTEND=y
    CONFIG_XEN_NETDEV_BACKEND=y
    CONFIG_HYPERV_NET=m
    CONFIG_INPUT_XEN_KBDDEV_FRONTEND=y
    CONFIG_HVC_IRQ=y
    CONFIG_HVC_XEN=y
    CONFIG_HVC_XEN_FRONTEND=y
    CONFIG_XEN_WDT=m
    CONFIG_FB_SYS_FILLRECT=y
    CONFIG_FB_SYS_COPYAREA=y
    CONFIG_FB_SYS_IMAGEBLIT=y
    CONFIG_FB_SYS_FOPS=y
    CONFIG_XEN_FBDEV_FRONTEND=y
    CONFIG_HYPERV=m
    CONFIG_HYPERV_UTILS=m
    CONFIG_XEN_BALLOON=y
    CONFIG_XEN_SELFBALLOONING=y
    CONFIG_XEN_BALLOON_MEMORY_HOTPLUG=y
    CONFIG_XEN_SCRUB_PAGES=y
    CONFIG_XEN_DEV_EVTCHN=y
    CONFIG_XEN_BACKEND=y
    CONFIG_XENFS=y
    CONFIG_XEN_COMPAT_XENFS=y
    CONFIG_XEN_SYS_HYPERVISOR=y
    CONFIG_XEN_XENBUS_FRONTEND=y
    CONFIG_XEN_GNTDEV=y
    CONFIG_XEN_GRANT_DEV_ALLOC=y
    CONFIG_SWIOTLB_XEN=y
    CONFIG_XEN_TMEM=y
    CONFIG_XEN_PCIDEV_BACKEND=y
    CONFIG_XEN_PRIVCMD=y
    CONFIG_XEN_ACPI_PROCESSOR=m
    CONFIG_XEN_HAVE_PVMMU=y
    CONFIG_DEBUG_PREEMPT=y
    CONFIG_RCU_CPU_STALL_VERBOSE=y


**An easier alternative:**

If you want to skip the `menuconfig` process (which can be a pain), you can instead copy the flags to the bottom of the `.config` file.  Then you can automate the menuconfig with:

    yes "" | make oldconfig

Which will override those values and fill in the defaults for everything else unanswered.


**Compiling:**

**If you are building over SSH be sure to run screen or tmux first, so if you get disconnected the process is not killed.**

We want to build a .deb for the kernel, and we may want to also create a headers file.  To do so, run these lines:

    fakeroot make-kpkg --initrd --revision=3.11.5.custom kernel_image
    fakeroot make-kpkg --initrd --revision=3.11.5.custom kernel_headers

This will create two .deb files above this directory, which can can install with `dpkg -i`.

They should automatically update grub, and if you reboot the system you can test that they are working (login and run `uname -r` to confirm).


## [Compiling and Installing Xen](http://www.youtube.com/watch?v=pxK2mVDmeVY)

Start by downloading the latest git repo:

    git clone git://xenbits.xen.org/xen.git

You haev the _choice_ of using the latest unstable version, _or_ switching to the 4.2 branch (or 4.3 which is now stable as well).  If you are aiming for VGA Passthrough with a custom kernel I very much doubt that xen-unstable is a concern.  Usually if xen-unstable will not work, it won't compile, it's rarely a matter of it being "unstable" at run-time.

To switch branches to xen-4.2 stable run:

    cd xen
    git checkout -b stable-4.2 origin/stable-4.2

_Specifying the origin branch is the key to ensuring you pull matching data.  Obviously your git configuration should be setup properly as well (see my template documentation for git configuration)._

Don't forget that if you are building over SSH you will want to open `screen` or `tmux` to avoid a canceled build on disconnection.

Let's fix the python reference library by running this:

    sed -i "s/^PYTHON_PREFIX_ARG.*/PYTHON_PREFIX_ARG ?= --install-layout=deb/" Config.mk

Next we'll add XML/Curl support, create these two variables in the shell you are building in:

    CURL=$(which curl-config)
    XML=$(which xml2-config)

Steps to build a .deb package for xen:

    ./configure --enable-githttp
    make
    make debball

This will create a dist folder with a .deb inside, which you can install with `dpkg -i`, just like the kernel.

**The benefit of .deb files is that you now have a portable prebuilt copy.  If you backup this file, you can easily restore your system without a long build process by just installing the packages, including your premade .deb files.**

Don't reboot just yet, we still have to cleanup the /boot directory, and make sure our toolstack loads at boot time before the installation is finished.


## [Xen Configuration](http://www.youtube.com/watch?v=ea3IY2CHBaM)

According to the instructions we should run `ldconfig` first, to resolve library links for our freshly installed xen.

Next we'll clean up our boot files.  If you run `ls -l /boot` you will see a series of symlinks to the same xen file.  We want to delete the symlinks as well as the symbols file unless you are going to debug xen (used for debugging):

    for FILE in /boot/xen*
    do
        if [ -L $FILE ];then
            rm -f $FILE
        fi
    done
    rm -f /boot/xen-syms*

Unless you have all the space necessary to hold hibernated VM's you will want to disable saving by modifying the defaults:

    sed -i "s/XENDOMAINS_SAVE=\/var\/lib\/xen\/save/XENDOMAINS_SAVE=/" /etc/default/xendomains
    sed -i "s/XENDOMAINS_RESTORE=true/XENDOMAINS_RESTORE=false/" /etc/default/xendomains

Our next job is to patch up grub.  If you have PCI devices you want to pass, identify their BDF (Bus/Device/Function) codes now (from lspci), and we can run the following to load xen with proper configuration:

    mv /etc/grub.d/20_linux_xen /etc/grub.d/09_linux_xen
    sed -r -i "s/(module.*ro.*)/\1 xen-pciback.passthrough=1 xen-pciback.permissive=1 xen-pciback.hide=(00:1d.0)(03:00.0)(03:00.1)(06:00.0)(07:00.0)(0b:00.0)(0e:00.0)(0f:00.0)/" /etc/grub.d/09_linux_xen
    sed -r -i "s/(multiboot.*)/\1 dom0_mem=4096M/" /etc/grub.d/09_linux_xen
    update-grub

_You are welcome to change the PCI devices and Xen memory settings to your liking.  Be sure to run `update-grub` after making changes or nothing will happen._

We want to tell our toolstack and services to load, and make sure they are loading in the correct order by running:

    update-rc.d xencommons defaults
    update-rc.d xendomains defaults
    update-rc.d xen-watchdog defaults
    for DIR in /etc/rc*
    do
        START_FILE=$( ls $DIR | grep S[0-9]*xen-w )
        STOP_FILE=$( ls $DIR | grep K[0-9]*xen-w )
        if [ -f "$DIR/$START_FILE" ]; then
            mv "$DIR/$START_FILE" $DIR/S22xen-watchdog
        fi
        if [ -f "$DIR/$STOP_FILE" ]; then
            mv "$DIR/$STOP_FILE" $DIR/K02xen-watchdog
        fi
    done

_The defaults for xen-watchdog used to be invalid and caused errors on shutdown, the above loop should resolve that though._

Let's grab a copy of the bash-completion file for the xl toolstack via:

    wget "http://xenbits.xen.org/gitweb/?p=xen.git;a=blob_plain;f=tools/libxl/bash-completion;hb=HEAD" -O /etc/bash_completion.d/xl

_This will allow us to see the first available set of options with bash auto-completion, but is by no means a full-featured completion script._

If you are not overly concerned with the security on the machine, you might consider making the xl command executable by sudo users without the sudo prefix or a password.  To do so you can modify the sudoers file and your users bashrc:

    echo "\n# Allow sudo group passwordless xl execution\n%sudo ALL=(ALL:ALL) ALL, !/usr/sbin/xl, NOPASSWD: /usr/sbin/xl" >> /etc/sudoers
    echo "\n# XL Alias\nalias xl='sudo xl'" >> /etc/bash.bashrc
    echo "\n# XL Alias\nalias xl='sudo xl'" >> /etc/skel/.bashrc
    echo "\n# XL Alias\nalias xl='sudo xl'" >> ~/.bashrc

Our last task is updating `/etc/network/interfaces` so we have at least one network bridge to work with using the bridge-utils.  Replace the current file with these lines:

    auto lo xenbr0
    iface lo inet loopback
    allow-hotplug eth0
    iface eth0 inet manual
    iface xenbr0 inet dhcp
        bridge_ports eth0
        bridge_maxwait 0

You should be ready to reboot the system.  If all goes as planned, you'll see a different option in grub when it boots, and once loaded and you have logged in you should be able to run `xl dmesg` and get status output from the xl toolstack.

If that worked then Xen is running and the xl toolstack is active.  Our next task is creating some virtual machines to run alongside Dom0 (the original OS).


## Xen DomU Configurations

Configurations will vary, but I use my system to fuel four primary sub-systems:

- IPFire Router/Proxy/Cache/WAP
- Web Development Server
- Communications Server
- Windows Multimedia/Gaming

I will now share my configurations and describe their settings.


**IPFire Config:**

    name="ipfire"
    builder="hvm"
    vcpus=2
    memory=4096
    disk=[
        '/dev/mapper/xen-sipfire,,hda,w'
    ]
    vif=[
        'bridge=xenbr0',
        'bridge=xenbr1'
    ]
    pci=[
        '07:00.0'
    ]
    boot='c'
    vnc=1
    vnclisten="0.0.0.0:15"
    usb=1
    usbdevice="tablet"
    localtime=1
    tsc_mode='native'
    xen_platform_pci=1
    pci_power_mgmt=1

Everything stems from this configuration.  Mac addresses omitted, but generally they exist to keep things tight.  I pass two network devices, one for internal and one for external.  The external should be set to a bridge, and the bridge set to `manual`.  This allows the Dom0 to ignore the incoming connection and have it link strait to IPFire.  Then we give everything an address from the second bridge, and for wiring I connect a switch to the internal connector.

I pass this system my onboard mini wireless adapter, and have additional cables to increase the signal strength of the WAP.  I configure this system to handle all internal traffic, both for my virtual machines as well as any other personal devices on the local network.


**Comm Server Config:**

    name="comm"
    builder="hvm"
    vcpus=2
    memory=4096
    disk=[
        '/dev/mapper/xen-comm,,hda,w'
    ]
    vif=[
        'bridge=xenbr1'
    ]
    pci=[
        '06:00.0',
        '0b:00.0'
    ]
    boot='c'
    vnc=1
    vnclisten="0.0.0.0:11"
    usb=1
    usbdevice="tablet"
    localtime=1
    tsc_mode='native'
    xen_platform_pci=1
    pci_power_mgmt=1

This machine receives the BDF for my secondary SATA PCI devices, which gives it access to four disks to use in Software (mdadm) RAID10.

I connect it to xenbr1, the second bridged network for internal network access.  I have omitted the mac address, but generally I assign a fixed address to my machines for static assignment.


**Web Server Config:**

    name="nginx"
    builder="hvm"
    vcpus=1
    memory=4096
    disk=[
        '/dev/mapper/xen-nginx,,hda,w'
    ]
    vif=[
        'bridge=xenbr1'
    ]
    boot='c'
    vnc=1
    vnclisten="0.0.0.0:12"
    usb=1
    usbdevice="tablet"
    localtime=1
    tsc_mode='native'
    xen_platform_pci=1

Pretty much the same as the comm server, minus some PCI details.  A mac address for static assignment, and generally this system will involve a lot of tweaking to get working as intended.  However having an internal development server can greatly speed up testing.


**Windows Config:**

    name="windows"
    builder="hvm"
    device_model_version="qemu-xen-traditional"
    vcpus=4
    memory=8192
    disk=[
        '/dev/mapper/victory-uw,,hda,w'
    ]
    vif=[
        'bridge=xenbr1'
    ]
    pci=[
        '00:1d.0',
        '03:00.0',
        '03:00.1',
        '0e:00.0',
        '0f:00.0'
    ]
    boot='c'
    pae=1
    nx=1
    #sdl=1
    vnc=1
    vnclisten="0.0.0.0:10"
    usb=1
    usbdevice="tablet"
    localtime=1
    viridian=1
    xen_platform_pci=1
    pci_power_mgmt=1

This machine receives the most devices, and specs.  I use it for multimedia, home theatre, and gaming.  VGA Passthrough works shockingly well, despite some reset bugs.  With some of the latest news some people are having luck with modifying nVidia cards, so I'll be trying that soon for myself.

**Randomly Windows 8 is scary smart.  It will recognize virtual hardware with a flag in the task manager interface and system properties, even before you install GPLPV drivers or anything of that nature.**


**Autostart VM's:**

To have your DomU's load when the Dom0 starts, simply symlink your configuration files to `/etc/xen/auto`, which is also defined in the `/etc/defaults/` xen config file.

For the most part there is nothing else special I can cover here that can't be found in many other guides.


## Managerial Activities

There are a few tricks I can share with regards to managing Xen virtual machines.

However, having an understanding of the fundamentals is also helpful.

Here are the key areas:

- Drive Partitioning
- LVM
- Using mount With LVM Virtual Partitions
- dd


### Drive Partitioning

This is a fundamental, you are welcome to skip ahead if you want the how and not the why.

I find a lot of emails floating around the xen-users email list due to misunderstandings in how Xen recognizes and managed partitions.

It is important to understand how Xen Virtual Machines treat partitions.

It sees them as entire hard drives, and will create a brand new partition table and partitions inside of it.

The result is sub-partitioning, and this causes an offset between the start of the actual partition and the start of the sub-partition containing all of the data on the virtual machine.


**In more detail**

Computers typically segment hard drives into three components.

- Partition Tables
- Partitions
- File Systems

A partition table tells the disk where the beginning and end of a partition exists and usually the file system.

The Partitions are simple blocks of storage.

The File System tells the operating system how to access the partition.

A normal installation of Windows for example, will look like:

- Drive Block 0
    - Partition Table:
        - Starts at Block 256 File System NTFS
- Drive Block 256
    - Partition
        - Data


**LVM**

Linux has LVM handle all the tough parts of managing the positions of data blocks, and makes everything else easier for the user.

Hence it is called the Logical Volume Manager, because it manages logical volumes.

What this means is when we create a LVM Partition, we are actually using an LVM "File System", which looks like this:

- Drive Block 0
    - Partition Table:
        - Starts at Block 256 File System LVM
- Drive Block 256
    - Partition
        - Data

We can then create partitions using LVM which automatically handles the location of the data inside the LVM Partition.

For example, we can create two LVM Partitions for a Windows and Linux Virtual Machine, which would look like this:

- Drive Block 0
    - Partition Table:
        - Starts at Block 256 File System LVM
- Drive Block 256
    - Partition
        - Data
            - LV Windows
            - LV Linux

Only an operating system that recognizes LVM can see "LV Windows" or "LV Linux" though, so if you plug that drive into a basic Windows machine, it won't be able to do anything with the data.


**Finally we have Xen**

With Xen we give one of those partitions to our virtual machine, but as stated it sees that as a hard drive.

If we use the previous drive configuration and just add a Windows Virtual Machine to `LV Windows` our configuration looks like this:

- Drive Block 0
    - Partition Table:
        - Starts at Block 256 File System LVM
- Drive Block 256
    - Partition
        - Data
            - LV Windows
                - LV Block 0
                    - Partition Table
                        - Partition at Block 256 File System NTFS
                - LV Block 256
                    - Partition
                        - Data
            - LV Linux

At this point, we cannot simple access the data on our Xen partition because it has been sub-partitioned.

If you try simply using `mount` it will fail, because it requires the offset to the start of the NTFS sub-partition!


### Using mount With LVM Virtual Partitions

To get the offset of the partition, we will use a tool like `fsdisk` or `parted`:

    sudo parted /dev/mapper/xen-windows unit B print

Using `unit B` we indicate bytes which will be used by the mount command, and we get this:

    Number  Start       End            Size           Type     File system  Flags
     1      1048576B    105906175B     104857600B     primary  ntfs         boot
     2      105906176B  171796594687B  171690688512B  primary  ntfs

Important to note that Windows 7 creates a 100MB Boot Partition, so the first item with the boot flag is actually the boot partition, we want the `Start` value of the second, which is `105906176B`.

We can now mount the partition using:

    sudo mount -o offset=105906176 /dev/mapper/xen-windows /path/to/mount/dir

That is how we can access the data inside our sub-partitions.

Obviously it is ill-advised to access the data while the operating system is running, mounted disks will NOT inform the running platform of changes, so data can get overwritten and cause all kinds of problems.


### dd

The utility `dd` is probably one of my favorites among the tools that come with most linux/unix systems.

It can be used to create an exact copy of data, and is not subject to a number of limitations with higher level software.

It is not the fastest utility, but supplemented with tools like gzip you can compress a complete backup into a size similar to that you might see with professional software.

Here is a backup Example that compressed an 80GB Windows LV with 70GB of Data into a 43GB GZipped Image File:

    sudo dd if=/dev/mapper/xen-windows of=/path/to/backup/windows.img bs=1M
    sudo gzip -9 windows.img

Alternative one-liner (Takes a lot longer since it has to compress "on the fly"):

    sudo dd if=/dev/mapper/xen-windows bs=1M | sudo gzip -9 > /path/to/backup/windows.img.gz

I can also use this command to restore my system from that compressed image:

    sudo gzip -d /path/to/backup/windows.img.gz
    sudo dd if=/path/to/backup/windows.img of=/dev/mapper/xen-windows bs=1M

Once again, one-liner alternative:

    sudo gzip -dc /path/to/backup/windows.img.gz | sudo dd of=/dev/mapper/xen-windows bs=1M

There are plenty of other uses I have found for the `dd` command, but backups and restoration make Linux amazingly easy to restore after terrible failure, and believe me in writing this guide I encountered that plenty of times.


---

This concludes my documentation.  If you like research material I've created a fat stack of links to all the documentation I found helpful when creating my own comprehensive guide.


## Awesome References

Kernel:

- [Kernel Source](http://kernel.org/)
- [Kernel Git Repo](git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git)
- [Xen Mainline Linux Kernel Configs](http://wiki.xen.org/wiki/Mainline_Linux_Kernel_Configs)
- [Kernel Flag Database for Lookup](http://cateee.net/lkddb/)

Xen:

- [Xenbits Repositories](http://xenbits.xensource.com/)
- [Compiling Xen](http://wiki.xen.org/wiki/Compiling_Xen_From_Source)
- [Xen 4.2 Man Pages](http://wiki.xen.org/wiki/Xen_4.2_Man_Pages)
- [Xen 4.3 Man Pages](http://wiki.xenproject.org/wiki/Xen_4.3_Man_Pages)
- [Xen 4.3 Docs](http://xenbits.xen.org/docs/4.3-testing/)
- [Xen Unstable Docs](http://xenbits.xen.org/docs/unstable/)
- [ParaOps for PV Kernels](http://wiki.xen.org/wiki/XenParavirtOps)
- [Kernel Matrix?](http://wiki.xen.org/wiki/Xen_Kernel_Feature_Matrix)
- [VGA Passthrough Wiki](http://wiki.xen.org/wiki/XenVGAPassthrough)

Xen Resources:

- [David Techer's blog](http://www.davidgis.fr/blog/)

Other:

- [mdadm RAID10 Guide](http://kromey.us/2009/08/raid-10-with-mdadm-65.html)
- [RAID10 Guide](http://www.linuxplanet.com/linuxplanet/tutorials/6518/1)
- [RAID10 Guide](http://techblog.tgharold.com/2006/08/creating-4-disk-raid10-using-mdadm.shtml)
- [Setup Weechat](http://thepracticalsysadmin.com/introduction-to-weechat/)

Other Untested:

- [Windows Time Sync](http://www.pretentiousname.com/timesync/index.html)
- [Time-Drift Debugging](http://www.brookstevens.org/2010/06/xen-time-drift-and-ntp.html)
- [MS Windows devcon](http://support.microsoft.com/kb/311272)
- [MS Windows devcon](http://code.msdn.microsoft.com/windowshardware/DevCon-Sample-4e95d71c)
- [Using Devcon](http://social.technet.microsoft.com/Forums/en/w7itprogeneral/thread/e680f48f-30f0-44bb-8289-3eb09e89a226)
- [Devon Debug](http://stackoverflow.com/questions/13694292/windows-8-devcon-remove-issue)
- [Logitech K810 Pairing](http://devasive.blogspot.com/2012/11/ubuntu-1204-persistent-bluetooth-pairing.html)
