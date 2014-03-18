
# Xen 4.3 Server Documentation
#### Updated 2013-10-15

This time around I won't chew your ear off with unnecessary dialog, this guides purpose is a quick run-through of setting up Xen 4.3.  Everything contained here-in should be in code-snippet form, allowing you to create a shell script to execute all desired changes at once.


## Changes from Template

The only major change from the template installation is to increase the LVM group size to 60GB and to create a second group spanning the rest of the main drive for DomU's.


## System Configuration

**Remove Exim:**

    aptitude purge exim4
    update-rc.d -f exim4 remove


**Install New Packages**

    aptitude install -y bcc bin86 gawk bridge-utils zlib1g-dev libbz2-dev xz-utils e2fslibs-dev pciutils uuid-dev libcurl3 libcurl4-openssl-dev  python-dev python-twisted bison flex libyajl-dev iasl ocaml ocaml-findlib transfig tgif libvncserver-dev libxml2-dev libx11-dev libsdl-dev libjpeg62-dev gettext texlive-latex-base texlive-latex-recommended texlive-fonts-extra texlive-fonts-recommended

**Untested/Unlisted (possibly 4.4 unstable) Packages:**

    libpng12-dev libjpeg8 libaio-dev libpixman-1-dev


## Building a Custom Kernel

Run these commands to configure kernel build, prepare a workspace, and download the kernel:

    echo "CONCURRENCY_LEVEL=9" >> /etc/kernel-pkg.conf
    cd /home
    mkdir -p src/kernel src/xen
    cd src/kernel
    wget https://www.kernel.org/pub/linux/kernel/v3.x/linux-3.11.5.tar.xz -O kernel.tar.xz
    xf kernel.tar.xz
    cd linux-3.11.5
    cp /boot/config* .config

Add these to the end of the `.config`:

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

Now load the changes:

    yes "" | make oldconfig

_Default values should automatically be selected for anything new, and our flags will override the other settings, allowing the configuration to do the rest of the work (automating the change of other dependent flags)._


**Compiling the Kernel:**

_Remember to run this in screen or tmux if you are connected through SSH._

    fakeroot make-kpkg --initrd --revision=3.11.5.custom kernel_image
    fakeroot make-kpkg --initrd --revision=3.11.5.custom kernel_headers

We should now have a kernel image and headers one directory up.  Let's install them and reboot:

    dpkg -i ../*.deb
    reboot

_Login on reboot and test with `uname -r` if you'd like._


## Building Xen

Run these commands to acquire, configure, and build Xen 4.3:

    cd /home/src/xen
    git clone git://xenbits.xen.org/xen.git
    cd xen
    git checkout -b stable-4.3 origin/stable-4.3
    sed -i "s/^PYTHON_PREFIX_ARG.*/PYTHON_PREFIX_ARG ?= --install-layout=deb/" Config.mk
    CURL=$(which curl-config)
    XML=$(which xml2-config)
    ./configure --enable-githttp
    make
    make debball

This should leave us with a .deb file inside the dist/ folder.  Let's install that:

    dpkg -i dist/*.deb


## Configuring Xen

Run these from a script, or transcribe them into bash:

    ldconfig
    for FILE in /boot/xen*
    do
        if [ -L $FILE ];then
            rm -f $FILE
        fi
    done
    rm -f /boot/xen-syms*
    sed -i "s/XENDOMAINS_SAVE=\/var\/lib\/xen\/save/XENDOMAINS_SAVE=/" /etc/default/xendomains
    sed -i "s/XENDOMAINS_RESTORE=true/XENDOMAINS_RESTORE=false/" /etc/default/xendomains
    mv /etc/grub.d/20_linux_xen /etc/grub.d/09_linux_xen
    sed -r -i "s/(module.*ro.*)/\1 xen-pciback.passthrough=1 xen-pciback.permissive=1 xen-pciback.hide=(00:1d.0)(03:00.0)(03:00.1)(06:00.0)(07:00.0)(0b:00.0)(0e:00.0)(0f:00.0)/" /etc/grub.d/09_linux_xen
    sed -r -i "s/(multiboot.*)/\1 dom0_mem=4096M/" /etc/grub.d/09_linux_xen
    update-grub
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
    wget "http://xenbits.xen.org/gitweb/?p=xen.git;a=blob_plain;f=tools/libxl/bash-completion;hb=HEAD" -O /etc/bash_completion.d/xl
    echo "\n# Allow sudo group passwordless xl execution\n%sudo ALL=(ALL:ALL) ALL, !/usr/local/sbin/xl, NOPASSWD: /usr/local/sbin/xl" >> /etc/sudoers
    echo "\n# XL Alias\nalias xl='sudo xl'" >> /etc/bash.bashrc

That'll resync our libraries with xen, remove symlinks from boot to boot, and the debug xen-syms file (not required if not debugging).

Turning off save and restore to prevent problems with disk space (you can leave those alone if you have disk space to spare).

_Please do modify the grub config changes to meet your needs, these are tailored to my PCI device list._

Next we add our insserv scripts and moving some of them about to avoid errors with watchdog.

We grab the partial bash-completion file for the xl toolstack.

Make the xl command execute without the sudo prefix, and without requiring a password.

Finally, we want to create our dual-LAN network configuration (copy these into `/etc/network/interfaces`):

    auto lo xenbr0 xenbr1
    iface lo inet loopback
    allow-hotplug eth0
    allow-hotplug eth1
    iface eth0 inet manual
    iface eth1 inet manual
    iface xenbr0 inet dhcp
        bridge_ports eth0
        bridge_maxwait 0
    iface eth1 inet manual
    iface xenbr1 inet static
        bridge_ports eth1
        bridge_maxwait 0
        address 10.0.0.2
        gateway 10.0.0.1

_After we have fully established our IPFire system we will change xenbr0 to `manual` from `dhcp`._

    reboot


## Xen DomU Configurations

Create the configurations as needed, here are mine:


**`/etc/xen/ipfire.conf`:**

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


**`/etc/xen/comm/conf`:**

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


**`/etc/xen/nginx.conf`:**

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


**`/etc/xen/windows.conf`:**

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


Create matching logical volumes if it has not already been done.
Add appropriate mac addresses to all systems.

Create symlinks to auto-start key machines via:

    mkdir -p /etc/xen/auto
    cd /etc/xen/auto
    ln -s ../ipfire.conf 01_ipfire
    ln -s ../nginx.conf 02_nginx
    ln -s ../comm.conf 03_comm

Reboot the system and they should load.  Thus concludes this massively abbreviated guide.


## Read

Kernel:

- [Kernel Source](http://kernel.org/)
- [Kernel Git Repo](git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git)
- [Xen Mainline Linux Kernel Configs](http://wiki.xen.org/wiki/Mainline_Linux_Kernel_Configs)
- [Kernel Flag Database for Lookup](http://cateee.net/lkddb/)

Xen:

- [Xenbits Repositories](http://xenbits.xensource.com/)
- [Compiling Xen](http://wiki.xen.org/wiki/Compiling_Xen_From_Source)
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
