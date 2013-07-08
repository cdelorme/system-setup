#!/bin/sh
# Xen 4.3 Setup Script!

# -------------------------------- Preparation & Loading

# Grab Important Paths (Script, Script Exec Path, Install Files)
SCRIPT=$(readlink -f $0)
PWD=$(dirname $SCRIPT)
FILES=$(readlink -f $PWD/../../../../../files)

# Load Configuration Flags (should be with the actual scripts location)
. $PWD/xen-config


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

setup_xen()
{

    # Run build & install process
    xen_build_install

    # Configurations
    xen_cleanup
    insserv_xen_configuration
    patch_xen_grub
    xen_interfaces
    passwordless_sudo_xl

    # UNFINISHED
    # patch_xendomains

}

package_updates()
{

    # Handle updates recursively on failure
    if [ ! -z "$PACKAGES" ];then
        aptitude install -y $PACKAGES
        aptitude install -y $PACKAGES

        # This approach fails for unknown reasons, best option is to simply execute twice hoping that the first-attempt having a failed connection resolves itself on the second run.
        # # Check with arbitrary software package in the list (assuming one failure halts the entire process)
        # if command -v bison >/dev/null 2>&1;then
        #     package_updates
        # fi
    fi

}

package_management_process()
{

    echo "Installing all Packages."

    # Clean Package Manager
    aptitude clean
    aptitude update

    # Install Updates
    aptitude upgrade -y
    aptitude safe-upgrade -y

    # Install Packages
    package_updates

    # Add Automatic Updates
    if $AUTOMATIC_UPDATES && [ ! -f /etc/cron.weekly/aptitude ];then
        setup_automatic_updates
    fi

}

gui_packages()
{

    echo "Adding GUI Packages."

    # Append Gnome Packages
    PACKAGES="$PACKAGES gnome-session gnome-terminal gnome-disk-utility gnome-screenshot gnome-screensaver desktop-base gksu gdm3 pulseaudio xorg-dev ia32-libs-gtk binfmt-support libc6-dev libc6-dev-i386 libcurl3 xdg-user-dirs-gtk xdg-utils network-manager libnss3-1d"

    # Append GUI Software
    PACKAGES="$PACKAGES gparted guake eog gnash vlc gtk-recordmydesktop chromium"

    # Append Xen GUI Packages
    PACKAGES="$PACKAGES libsdl-dev gvncviewer"

}

system_packages()
{

    echo "Adding System Packages."

    # Basic System Packages
    PACKAGES="$PACKAGES screen tmux sudo ssh vim parted ntp p7zip-full build-essential libncurses-dev kernel-package fakeroot git mercurial"

    # Xen Packages
    PACKAGES="$PACKAGES bridge-utils build-essential libncurses-dev python-dev uuid uuid-dev libglib2.0-dev libyajl-dev bcc gcc-multilib iasl libpci-dev mercurial flex bison libaio-dev"

}


stage_one_config_and_kernel()
{

    # Prepare System Packages
    system_packages

    # OPTIONAL Prepare GUI Packages
    if ! $HEADLESS;then
        gui_packages
    fi

    # Package Management Process
    package_management_process

    # System Configuration
    system_configuration

    # GUI Configuration
    if ! $HEADLESS;then
        gui_configuration
    fi

    # Install Kernel
    kernel_installation

    # Continue after Reboot (try /etc/rc.local replacement)
    sed -i "s!^exit 0!$SCRIPT 2\nexit 0!" /etc/rc.local

    # Reboot System
    reboot

}

stage_two_xen()
{

    # Remove on-Reboot Process
    sed -i "\!$SCRIPT!d" '/etc/rc.local'

    echo "Testing Script Execution on Reboot"

    # Fresh Kernel so run aptitude cleansing
    # package_management_process

    # Run Xen Install
    # setup_xen

    # Reboot System
    # reboot

}
