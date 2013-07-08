#!/bin/sh
# Xen Method Library

# -------------------------------- Setup

# Prepare Paths
if [ -z "$SCRIPT_PATH" ];then
    XEN_SCRIPT=$(readlink -f $0)
else
    XEN_SCRIPT="$SCRIPT_PATH/linux/$DISTRIBUTION/$DISTRIBUTION_VERSION/xen/$XEN_VERSION/setup.sh"
fi
XEN_PATH=$(dirname $XEN_SCRIPT)

# Load configuration
. $XEN_PATH/config


# -------------------------------- Library Methods

xen_script_cleanup()
{
    echo "cleaning and polishing script leavings..."
    sed -i "\!$SCRIPT!d" '/etc/rc.local'
}

xen_passwordless_xl()
{
    if [ -n "$PASSWORDLESS_XL" ] && $PASSWORDLESS_XL;then
        echo "making sudo passwordless..."
        echo "\n# Allow sudo group passwordless xl execution\n%sudo ALL=(ALL:ALL) ALL, !/usr/sbin/xl, NOPASSWD: /usr/sbin/xl" >> /etc/sudoers
        echo "\n# XL Alias\nalias xl='sudo xl'" >> /etc/bash.bashrc
        echo "\n# XL Alias\nalias xl='sudo xl'" >> /etc/skel/.bashrc
        if [ -n "$USERNAME" ];then
            echo "\n# XL Alias\nalias xl='sudo xl'" >> /home/$USERNAME/.bashrc
        fi
    fi
}

xen_insserv_configuration()
{
    echo "adding xen scripts to services and fixing order..."
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
}

xen_save_restore()
{
    if [ -n "$DISABLE_SAVE_RESTORE" ] && $DISABLE_SAVE_RESTORE;then
        echo "disabling save and restore features to reduce disk consumption..."
        sed -i "s/XENDOMAINS_SAVE=\/var\/lib\/xen\/save/XENDOMAINS_SAVE=/" /etc/default/xendomains
        sed -i "s/XENDOMAINS_RESTORE=true/XENDOMAINS_RESTORE=false/" /etc/default/xendomains
    fi
}

xen_patch_grub()
{
    echo "patching grub parameters for xen..."
    mv /etc/grub.d/20_linux_xen /etc/grub.d/09_linux_xen
    if [ ! -z "$PCIBACK" ];then
        sed -r -i "s/(module.*ro.*)/\1$PCIBACK/" /etc/grub.d/09_linux_xen
    fi
    if [ ! -z "$XEN_CONF" ];then
        sed -r -i "s/(multiboot.*)/\1$XEN_CONF/" /etc/grub.d/09_linux_xen
    fi
    update-grub
}

xen_remove_boot_symlinks()
{
    for FILE in /boot/xen*
    do
        if [ -L $FILE ];then
            rm -f $FILE
        fi
    done
    rm -f /boot/xen-syms*
}

xen_cleanup_configuration()
{
    echo "cleaning up after xen install..."
    ldconfig
    xen_remove_boot_symlinks
    xen_patch_grub
    xen_save_restore
    xen_insserv_configuration
    xen_passwordless_xl
}

xen_install()
{
    echo "installing xen..."
    dpkg -i $DEV_DIR/xen/*.deb
}

xen_build()
{
    if [ -d $FILES/xen ] && ls $FILES/xen/$XEN_PACKAGE_SUFFIX >/dev/null 2>&1;then
        echo "loading prebuilt deb package..."
        mkdir -p $DEV_DIR/xen
        cp $FILES/xen/$XEN_PACKAGE_SUFFIX $DEV_DIR/xen/
    else
        echo "preparing build directory..."
        mkdir -p $DEV_DIR/xen
        cd $DEV_DIR/xen

        echo "downloading xen source..."
        git clone git://xenbits.xen.org/xen.git
        cd xen*
        git checkout -b stable-4.3

        echo "configuring xen source..."
        sed -i "s/^PYTHON_PREFIX_ARG.*/PYTHON_PREFIX_ARG ?= --install-layout=deb/" Config.mk
        ./configure --enable-githttp

        echo "building xen..."
        make -j$(nproc) world
        make -j$(nproc) debball

        echo "preparing package for installation..."
        cp dist/*.deb $DEV_DIR/xen/
    fi
}

xen_process()
{
    echo "running xen process..."
    xen_build
    xen_install
    xen_cleanup_configuration
}

xen_reboot_procedure()
{
    echo "preparing for reboot procedure..."
    echo "\n\n# SCRIPT-ADDED PARAMETERS FOR XEN REBOOT\nXEN_REBOOT=true" >> $SCRIPT_PATH/config
    sed -i "s!^exit 0!$SCRIPT 2\nexit 0!" /etc/rc.local
}

add_vfio_kernel_modules()
{
    if [ -n "$ENABLE_VFIO" ] && $ENABLE_VFIO;then
        echo "adding vfio kernel modules..."
        KERNEL_MODULES="$KERNEL_MODULES\nCONFIG_VFIO_IOMMU_TYPE1=y"
        KERNEL_MODULES="$KERNEL_MODULES\nCONFIG_VFIO=y"
        KERNEL_MODULES="$KERNEL_MODULES\nCONFIG_VFIO_PCI=y"
        KERNEL_MODULES="$KERNEL_MODULES\nCONFIG_VFIO_PCI_VGA=y"
    fi
}

add_virtio_kernel_modules()
{
    if [ -n "$ENABLE_VIRTIO" ] && $ENABLE_VIRTIO;then
        echo "adding virtio kernel modules..."
        KERNEL_MODULES="$KERNEL_MODULES\nCONFIG_VIRTIO_MMIO=y"
        KERNEL_MODULES="$KERNEL_MODULES\nCONFIG_VIRTIO_PCI=y"
        KERNEL_MODULES="$KERNEL_MODULES\nCONFIG_VIRTIO_NET=y"
        KERNEL_MODULES="$KERNEL_MODULES\nCONFIG_VIRTIO_BALLOON=y"
        KERNEL_MODULES="$KERNEL_MODULES\nCONFIG_VIRTIO_BLK=y"
    fi
}

add_kernel_modules()
{
    echo "adding xen kernel modules"
    KERNEL_MODULES="$KERNEL_MODULES\nCONFIG_VIRT_CPU_ACCOUNTING_GEN=y"
    KERNEL_MODULES="$KERNEL_MODULES\nCONFIG_NUMA_BALANCING=y"
    KERNEL_MODULES="$KERNEL_MODULES\nCONFIG_PARAVIRT_TIME_ACCOUNTING=y"
    KERNEL_MODULES="$KERNEL_MODULES\nCONFIG_PREEMPT=y"
    KERNEL_MODULES="$KERNEL_MODULES\nCONFIG_MOVABLE_NODE=y"
    KERNEL_MODULES="$KERNEL_MODULES\nCONFIG_CLEANCACHE=y"
    KERNEL_MODULES="$KERNEL_MODULES\nCONFIG_FRONTSWAP=y"
    KERNEL_MODULES="$KERNEL_MODULES\nCONFIG_HZ_1000=y"
    KERNEL_MODULES="$KERNEL_MODULES\nCONFIG_PCI_STUB=y"
    KERNEL_MODULES="$KERNEL_MODULES\nCONFIG_XEN_PCIDEV_FRONTEND=y"
    KERNEL_MODULES="$KERNEL_MODULES\nCONFIG_XEN_PCIDEV_BACKEND=y"
    KERNEL_MODULES="$KERNEL_MODULES\nCONFIG_XEN_BLKDEV_FRONTEND=y"
    KERNEL_MODULES="$KERNEL_MODULES\nCONFIG_XEN_BLKDEV_BACKEND=y"
    KERNEL_MODULES="$KERNEL_MODULES\nCONFIG_XEN_NETDEV_FRONTEND=y"
    KERNEL_MODULES="$KERNEL_MODULES\nCONFIG_XEN_NETDEV_BACKEND=y"
    KERNEL_MODULES="$KERNEL_MODULES\nCONFIG_NETXEN_NIC=y"
    KERNEL_MODULES="$KERNEL_MODULES\nCONFIG_XEN_WDT=y"
    KERNEL_MODULES="$KERNEL_MODULES\nCONFIG_XEN_SELFBALLOONING=y"
    KERNEL_MODULES="$KERNEL_MODULES\nCONFIG_XEN_BALLOON_MEMORY_HOTPLUG=y"
    KERNEL_MODULES="$KERNEL_MODULES\nCONFIG_XENFS=y"
    KERNEL_MODULES="$KERNEL_MODULES\nCONFIG_XEN_GRANT_DEV_ALLOC=y"
    KERNEL_MODULES="$KERNEL_MODULES\nCONFIG_XEN_GNTDEV=y"
    KERNEL_MODULES="$KERNEL_MODULES\nCONFIG_XEN_DEV_EVTCHN=y"
}

prepare_xen_kernel()
{
    echo "preparing xen kernel configuration..."
    add_kernel_modules
    add_vfio_kernel_modules
    add_virtio_kernel_modules
}

setup_xen_firewall()
{
    echo "adding xen firewall rules..."
    FILEWALL_RULES="$FILEWALL_RULES\n\n# Forwarding Rules (for Dual LAN Xen)"
    FILEWALL_RULES="$FILEWALL_RULES\n-A FORWARD -i eth0 -o xenbr1 -j REJECT"
    if [ -n "$DUAL_LAN" ] && $DUAL_LAN;then
        FILEWALL_RULES="$FILEWALL_RULES\n-A FORWARD -i eth0 -o eth1 -j REJECT"
        FILEWALL_RULES="$FILEWALL_RULES\n-A FORWARD -i eth1 -o eth0 -j REJECT"
        FILEWALL_RULES="$FILEWALL_RULES\n-A FORWARD -i eth1 -o xenbr0 -j REJECT"
    fi
}

setup_xen_network()
{
    echo "adding bridges to network interfaces..."
    echo "auto lo xenbr0 xenbr1" >> /etc/network/interfaces
    echo "iface lo inet loopback"
    echo "iface eth0 inet manual"
    echo "\tbridge_ports eth0"
    echo "\tbridge_maxwait 0"
    echo "iface xenbr0 inet manual"
    if [ -n "$DUAL_LAN" ] && $DUAL_LAN;then
        echo "configuring for dual interfaces..."
        echo "iface eth0 inet manual"
        echo "iface xenbr1 inet dhcp"
        echo "\tbridge_ports eth1"
        echo "\tbridge_maxwait 0"
    else
        echo "iface xenbr1 inet dhcp"
        echo "\tbridge_ports xenbr0"
        echo "\tbridge_maxwait 0"
    fi
}

xen_preparation()
{
    echo "preparing system for xen..."
    setup_xen_network
    setup_xen_firewall
}

add_xen_packages()
{
    echo "adding xen packages..."

    # These should already be in our list
    PACKAGES="$PACKAGES build-essential"
    PACKAGES="$PACKAGES libncurses-dev"
    PACKAGES="$PACKAGES mercurial"
    PACKAGES="$PACKAGES git"

    # These are new
    PACKAGES="$PACKAGES bridge-utils"
    PACKAGES="$PACKAGES python-dev"
    PACKAGES="$PACKAGES uuid"
    PACKAGES="$PACKAGES uuid-dev"
    PACKAGES="$PACKAGES libglib2.0-dev"
    PACKAGES="$PACKAGES libyajl-dev"
    PACKAGES="$PACKAGES bcc"
    PACKAGES="$PACKAGES iasl"
    PACKAGES="$PACKAGES libpci-dev"
    PACKAGES="$PACKAGES flex"
    PACKAGES="$PACKAGES bison"
    PACKAGES="$PACKAGES libaio-dev"

    # This is an x64 package for x32 compatibility
    PACKAGES="$PACKAGES gcc-multilib"

    if [ -n "$HEADLESS" ] && ! $HEADLESS;then
        echo "adding xen gui packages..."
        PACKAGES="$PACKAGES libsdl-dev"
        PACKAGES="$PACKAGES gvncviewer"
    fi
}
