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

xen_interfaces()
{

    # Backup Interfaces
    if [ -f /etc/network/interfaces ];then
        mv /etc/network/interfaces /etc/network/interfaces.bak
    fi

    # Setup network interfaces for Xen
    if $DUAL_LAN;then
        echo "auto lo xenbr0 xenbr1\niface lo inet loopback\niface eth0 inet manual\niface eth1 inet manual\niface xenbr0 inet dhcp\n\tbridge_ports eth0\n\tbridge_maxwait 0\niface xenbr1 inet manual\n\tbridge_ports eth1\n\tbridge_maxwait 0" > /etc/network/interfaces
    else
        echo "auto lo xenbr0 xenbr1\niface lo inet loopback\niface eth0 inet manual\niface xenbr0 inet dhcp\n\tbridge_ports eth0\n\tbridge_maxwait 0\niface xenbr1 inet manual\n\tbridge_maxwait 0" > /etc/network/interfaces
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






# ---------------- Revised methods (not yet tested but cleaner)

add_vfio_kernel_packages()
{
    echo "adding vfio kernel packages"
    # CONFIG_VFIO_IOMMU_TYPE1=y
    # CONFIG_VFIO=y
    # CONFIG_VFIO_PCI=y
    # CONFIG_VFIO_PCI_VGA=y
}

add_virtio_kernel_packages()
{
    echo "adding virtio kernel packages"
    # CONFIG_VIRTIO_MMIO=y
    # CONFIG_VIRTIO_PCI=y
    # CONFIG_VIRTIO_NET=y
    # CONFIG_VIRTIO_BALLOON=y
    # CONFIG_VIRTIO_BLK=y
}

prepare_reboot_procedure()
{
    echo "preparing for reboot procedure..."
    # Before building & installing xen we will want to execute a method to handle
    # rebooting in debian (using /etc/rc.local)
    # Continue after Reboot (try /etc/rc.local replacement)
    # sed -i "s!^exit 0!$SCRIPT 2\nexit 0!" /etc/rc.local
    # Remove on-Reboot Process
    # sed -i "\!$SCRIPT!d" '/etc/rc.local'
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
