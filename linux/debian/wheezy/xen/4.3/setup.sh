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


# -------------------------------- Define Functions

passwordless_sudo_xl()
{
    # Add passwordless xl for sudo group
    echo "\n# Allow sudo group passwordless xl execution\n%sudo ALL=(ALL:ALL) ALL, !/usr/sbin/xl, NOPASSWD: /usr/sbin/xl" >> /etc/sudoers
    echo "\n# XL Alias\nalias xl='sudo xl'" >> /etc/bash.bashrc
    echo "\n# XL Alias\nalias xl='sudo xl'" >> /etc/skel/.bashrc
    if [ ! -z "$USERNAME" ];then
        echo "\n# XL Alias\nalias xl='sudo xl'" >> /home/$USERNAME/.bashrc
    fi
}

patch_xen_grub()
{

    # Update Grub (Iterate PCI devices & add xen conf flags)
    cp /etc/grub.d/20_linux_xen /etc/grub.d/09_linux_xen
    if [ ! -z "$PCIBACK" ];then
        sed -r -i "s/(module.*ro.*)/\1$PCIBACK/" /etc/grub.d/09_linux_xen
    fi
    if [ ! -z "$XEN_CONF" ];then
        sed -r -i "s/(multiboot.*)/\1$XEN_CONF/" /etc/grub.d/09_linux_xen
    fi
    update-grub

}

insserv_xen_configuration()
{

    # Add Xen Script Defaults on boot
    update-rc.d xencommons defaults
    update-rc.d xendomains defaults
    update-rc.d xen-watchdog defaults

    # xen-watchdog must be modified to S22 and K02.
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

    # Remove XENDOMAINS_SAVE set its path to nothing
    sed -i "s/XENDOMAINS_SAVE=\/var\/lib\/xen\/save/XENDOMAINS_SAVE=/" /etc/default/xendomains

    # Set XENDOMAINS_RESTORE to false
    sed -i "s/XENDOMAINS_RESTORE=true/XENDOMAINS_RESTORE=false/" /etc/default/xendomains

}

xen_cleanup()
{

    # Post installation Cleanup (remove symlinks & debug symbols from /boot)
    for FILE in /boot/xen*
    do
        if [ -L $FILE ];then
            rm -f $FILE
        fi
    done
    rm -f /boot/xen-syms*

}

xen_build_install()
{

    # install if .deb exists
    if [ -d $FILES/xen ] && ls $FILES/xen/*.deb >/dev/null 2>&1;then
        dpkg -i $FILES/xen/*.deb
    else

        # Enter Directory
        cd $DEV_DIR

        # Clone Xen Source
        git clone git://xenbits.xen.org/xen.git

        # Enter Dir & Checkout Tag
        cd xen*
        git checkout -b stable-4.3

        # Exchange Config.mk Python args
        sed -i "s/^PYTHON_PREFIX_ARG.*/PYTHON_PREFIX_ARG ?= --install-layout=deb/" Config.mk

        # Configure & Build a .deb /w automatic core detection for compiling
        ./configure --enable-githttp
        make -j$(nproc) world
        make -j$(nproc) debball

        # Install the .deb produced by make debball inside ./dist/
        dpkg -i dist/*.deb

        # Load Configuration Cache
        ldconfig

    fi

}






# ----------------

xen_configuration()
{
    echo "configuring xen components..."
}

xen_reboot_procedure()
{
    echo "preparing for reboot procedure..."
    # Before building & installing xen we will want to execute a method to handle
    # rebooting in debian (using /etc/rc.local)
    # Continue after Reboot (try /etc/rc.local replacement)
    # sed -i "s!^exit 0!$SCRIPT 2\nexit 0!" /etc/rc.local
    # Remove on-Reboot Process
    # sed -i "\!$SCRIPT!d" '/etc/rc.local'
}



# ---------------- Revised methods (not yet tested but cleaner)

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
