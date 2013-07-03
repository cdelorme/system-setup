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

}

xen_interfaces()
{

    # Backup Interfaces
    if [ -f /etc/network/interfaces ];then
        mv /etc/network/interfaces /etc/network/interfaces.bak
    fi

    # Setup network interfaces for Xen
    if $DUAL_LAN;then
        echo "auto lo xenbr0 xenbr1\niface lo inet loopback\niface eth0 inet manual\niface eth1 inet manual\niface xenbr0 inet manual\n\tbridge_ports eth0\n\tbridge_maxwait 0\niface xenbr1 inet dhcp\n\tbridge_ports eth1\n\tbridge_maxwait 0" > /etc/network/interfaces
    else
        echo "auto lo xenbr0 xenbr1\niface lo inet loopback\niface eth0 inet manual\niface xenbr0 inet dhcp\n\tbridge_ports eth0\n\tbridge_maxwait 0\niface xenbr1 inet dhcp\n\tbridge_maxwait 0" > /etc/network/interfaces
    fi

}

patch_xen_grub()
{

    # Update Grub (Iterate PCI devices & add xen conf flags)
    cp /etc/grub.d/20_linux_xen /etc/grub.d/09_linux_xen
    # PCIBACK=" xen-pciback.hide=";for i in "$PCI_BDF";do PCIBACK="$PCIBACK($i)";done;
    # sed -r -i "s/(module.*ro.*)/\1$PCIBACK/" /etc/grub.d/09_linux_xen
    sed -r -i "s/(multiboot.*)/\1$XEN_CONF/" /etc/grub.d/09_linux_xen
    update-grub

}

# patch_xendomains()
# {

#     # I have not yet fixed the xendomains script so this is just a placeholder
#     # Supposedly 4.3 has been fixed, but I need to test it to be sure

# }

insserv_xen_configuration()
{

    # Add Xen Script Defaults on boot
    update-rc.d xencommons defaults
    update-rc.d xendomains defaults
    update-rc.d xen-watchdog defaults

    # Depending on
    # THIS STEP MAY NO-LONGER BE NECESSARY
    # Also check all scripts for proper insserv headers, those may fix all the problems
    # xen-watchdog must be modified to S22 and K02.
    # for DIR in /etc/rc*
    # do
    #     START_FILE=$( ls $DIR | grep S[0-9]*xen-w )
    #     STOP_FILE=$( ls $DIR | grep K[0-9]*xen-w )
    #     if [[ -f $DIR/$START_FILE ]]; then
    #         mv $DIR/START_FILE $DIR/S22xen-watchdog
    #     fi
    #     if [[ -f $DIR/$STOP_FILE ]]; then
    #         mv $DIR/STOP_FILE $DIR/K02xen-watchdog
    #     fi
    # done

}

xen_cleanup()
{

    # Post installation Cleanup (remove symlinks & debug symbols from /boot)
    for FILE in /boot/*
    do
        if [[ $FILE =~ xen* ]] && [ -L $FILE ];then
            rm -f $FILE
        fi
    done
    rm -f /boot/xen-syms*

}

xen_build_install()
{

    # install if .deb exists
    # If kernel debs exist install them
    if [ -d $FILES/xen ] && ls $FILES/xen/*.deb >/dev/null 2>&1;then
        dpkg -i $FILES/xen/*.deb
    else

        # Enter Directory
        cd $DEV_DIR

        # Clone Xen Source
        git clone git://xenbits.xen.org/xen.git

        # Enter Dir & Checkout Tag
        cd xen*

        # Configure & Build a .deb /w automatic core detection for compiling
        ./configure && make -j$(nproc) world && make -j$(nproc) deb

        # Install the .deb
        # dpkg -i dist/*.deb

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

kernel_installation()
{

    # Add Concurrency /w automatic core detection
    echo "\n# Concurrency Level\nCONCURRENCY_LEVEL=$(nproc)" >> /etc/kernel-pkg.conf

    # If kernel debs exist install them
    if [ -d $FILES/kernel ] && ls $FILES/kernel/*.deb >/dev/null 2>&1;then
        dpkg -i $FILES/kernel/*.deb
    else

        # Navigate to work folder
        cd $DEV_DIR

        # Manually download 3.9.8
        wget --no-check-certificate https://www.kernel.org/pub/linux/kernel/v3.x/linux-3.9.8.tar.xz

        # Extract to dev directory & enter
        tar -xf linux*
        rm *.xz
        cd linux*

        # Copy the latest config
        for CONFIG in /boot/config-*;do
            cp $CONFIG .config
        done

        # Set xen flags
        echo "# Xen Manual Configs\nCONFIG_VIRT_CPU_ACCOUNTING_GEN=y\nCONFIG_NUMA_BALANCING=y\nCONFIG_PARAVIRT_TIME_ACCOUNTING=y\nCONFIG_PREEMPT=y\nCONFIG_MOVABLE_NODE=y\nCONFIG_CLEANCACHE=y\nCONFIG_FRONTSWAP=y\nCONFIG_HZ_1000=y\nCONFIG_PCI_STUB=y\nCONFIG_XEN_PCIDEV_FRONTEND=y\nCONFIG_XEN_BLKDEV_FRONTEND=y\nCONFIG_XEN_BLKDEV_BACKEND=y\nCONFIG_XEN_NETDEV_FRONTEND=y\nCONFIG_XEN_NETDEV_BACKEND=y\nCONFIG_XEN_WDT=y\nCONFIG_XEN_SELFBALLOONING=y\nCONFIG_XEN_BALLOON_MEMORY_HOTPLUG=y\nCONFIG_XEN_DEV_EVTCHN=y\nCONFIG_XENFS=y\nCONFIG_XEN_GNTDEV=y\nCONFIG_XEN_GRANT_DEV_ALLOC=y\nCONFIG_XEN_PCIDEV_BACKEND=y" >> .config

        # Automate corrections and missing flags
        yes "" | make oldconfig

        # Build
        make-kpkg clean
        fakeroot make-kpkg --initrd --revision=4.3.xen.custom kernel_image

        # Install
        dpkg -i ../*.deb

        # Move back to current script dir
        cd $PWD

        # Wipe $DEV_DIR
        rm -rf $DEV_DIR/*

    fi

}

gui_configuration()
{

    # Adjustments for gui settings
    update-rc.d gdm3 disable 2
    update-rc.d network-manager disable 2
    update-rc.d network-manager disable 3
    update-rc.d network-manager disable 4
    update-rc.d network-manager disable 5
    update-rc.d bluetooth disable 2
    update-rc.d bluetooth disable 3
    update-rc.d bluetooth disable 4
    update-rc.d bluetooth disable 5

    # Patch Guake Gnome3 notification bug and remove autostart prevention
    sed -i 's/notification.show()/try:\n                notification.show()\n            except Exception:\n                pass/' /usr/bin/guake
    rm /etc/xdg/autostart/guake.desktop
    sed -i '/StartupNotify|X-GNOME-Autostart-enabled/d' /usr/share/applications/guake.desktop

    # Add autostart for guake to user or global if no user
    if [ ! -z "$USERNAME" ];then
        ln -s /usr/share/applications/guake.desktop /home/$USERNAME/.config/autostart/guake.desktop
        chown -R $USERNAME:$USERNAME /home/$USERNAME/.config
    else
        ln -s /usr/share/applications/guake.desktop /etc/xdg/autostart/guake.desktop
    fi

    # Sublime Text 2
    wget --no-check-certificate http://c758482.r82.cf2.rackcdn.com/Sublime%20Text%202.0.1%20x64.tar.bz2
    tar xf Sublime\ Text\ 2.0.1\ x64.tar.bz2
    mv Sublime\ Text\ 2 /usr/share/sublime_text
    ln -s /usr/share/sublime_text/sublime_text /usr/bin/subl
    echo "[Desktop Entry]\nName=Sublime Text 2\nComment=The Best Text Editor in the World!\nTryExec=subl\nExec=subl\nIcon=/usr/share/sublime_text/Icon/256x256/sublime_text.png\nType=Application\nCategories=Office;Sublime Text;" > /usr/share/applications/subl.desktop
    echo "text/plain=subl.desktop\ntext/css=subl.desktop\ntext/htm=subl.desktop\ntext/javascript=subl.desktop\ntext/x-c=subl.desktop\ntext/csv=subl.desktop\ntext/x-java-source=subl.desktop\ntext/java=subl.desktop\n" >> /usr/share/applications/defaults.list
    update-desktop-database
    rm -rf "Sublime Text 2.0.1*"

    # Add User Configuration
    if [ -d $FILES/sublime_text ] && [ ! -z "$USERNAME" ];then
        mkdir -p /home/$USERNAME/.config/sublime-text-2
        cp -R $FILES/sublime_text/* /home/$USERNAME/.config/sublime-text-2/
        chown -R $USERNAME:$USERNAME /home/$USERNAME/.config/
    fi

}

setup_firewall()
{

    # Xen generates vifs dynamically
    # Securing that without a script would be very difficult
    # So we use a blacklist instead of a whitelist to control what we know

    # Define firewall at `/etc/firewall.conf`
    if $DUAL_LAN;then
        echo "*filter\n\n# Prevent use of Loopback on non-loopback dervice (lo0):\n-A INPUT -i lo -j ACCEPT\n-A INPUT ! -i lo -d 127.0.0.0/8 -j REJECT\n\n# Accepts all established inbound connections\n-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT\n\n# Allows all outbound traffic (Can be limited at discretion)\n-A OUTPUT -j ACCEPT\n\n# Allow ping\n-A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT\n\n# Enable SSH Connection (custom port in /etc/ssh/sshd_conf)\n-A INPUT -p tcp -m state --state NEW --dport $SSH_PORT -j ACCEPT\n\n# Forwarding Rules (for Dual LAN Xen)\n-A FORWARD -i eth0 -o eth1 -j REJECT\n-A FORWARD -i eth0 -o xenbr1 -j REJECT\n-A FORWARD -i eth1 -o eth0 -j REJECT\n-A FORWARD -i eth1 -o xenbr0 -j REJECT\n\n# Set other traffic defaults\n-A INPUT -j REJECT\n-A FORWARD -j ACCEPT\n\nCOMMIT" > /etc/firewall.conf
    else
        echo "*filter\n\n# Prevent use of Loopback on non-loopback dervice (lo0):\n-A INPUT -i lo -j ACCEPT\n-A INPUT ! -i lo -d 127.0.0.0/8 -j REJECT\n\n# Accepts all established inbound connections\n-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT\n\n# Allows all outbound traffic (Can be limited at discretion)\n-A OUTPUT -j ACCEPT\n\n# Allow ping\n-A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT\n\n# Enable SSH Connection (custom port in /etc/ssh/sshd_conf)\n-A INPUT -p tcp -m state --state NEW --dport $SSH_PORT -j ACCEPT\n\n# Forwarding Rules (for Dual LAN Xen)\n-A FORWARD -i eth0 -o xenbr1 -j REJECT\n\n# Set other traffic defaults\n-A INPUT -j REJECT\n-A FORWARD -j ACCEPT\n\nCOMMIT" > /etc/firewall.conf
    fi

    # Prepare firewall auto-loading
    echo "#!/bin/sh\niptables -F\niptables-restore < /etc/firewall.conf" > "/etc/network/if-up.d/iptables"
    chmod +x "/etc/network/if-up.d/iptables"

}

user_configuration()
{

    # Create user if not exists
    if ! id -u "$USERNAME" >/dev/null 2>&1;then
        useradd $USERNAME

        # Set Password (without this you will need to access as root to set initial password)
        if [ ! -z "$PASSWORD" ];then
            echo "$PASSWORD" | passwd $USERNAME
        fi

    fi

    # Add to sudo group
    usermod -aG sudo $USERNAME

    # Create important user directories
    mkdir -p /home/$USERNAME/.config/autostart

    # Update Ownership
    chown -R $USERNAME:$USERNAME /home/$USERNAME

}

install_fonts()
{

    # Install my fonts
    mkdir -p /usr/share/fonts/truetype
    if [ -d $FILES/fonts/ ];then
        mv $FILES/fonts/*.ttf /usr/share/fonts/truetype
        fc-cache -rf
    fi

}

ssh_config()
{

    # Set SSH Port
    sed -i "s/Port 22/Port $SSH_PORT/" /etc/ssh/sshd_config
    service ssh restart

}

ssd_trim_config()
{

    # Add discard flag to LVMs and execute it manually every week via crontab
    sed -i 's/issue_discards = 0/issue_discards = 1/' /etc/lvm/lvm.conf
    echo "#!/bin/sh\nfor mount in / /boot /home /var/log /tmp; do\n\tfstrim $mount\ndone" > /etc/cron.weekly/fstab
    chmod +x /etc/cron.weekly/fstab

}

system_configuration()
{

    # (OPTIONAL) Setup trim capabilities
    if $TRIM; then
        ssd_trim_config
    fi

    # Configure SSH
    ssh_config

    # Install Fonts
    install_fonts

    # If USERNAME configure User
    if [ ! -z "$USERNAME" ];then
        user_configuration
    fi

    # Get the firewall setup
    setup_firewall

}

setup_automatic_updates()
{

    # Create file `/etc/cron.weekly/aptitude` with executable flag and contents:
    echo "#!/bin/sh\n# Weekly Software Update Processing\naptitude clean\naptitude update\naptitude upgrade -y\naptitude safe-upgrade -y" > /etc/cron.weekly/aptitude
    chmod +x /etc/cron.weekly/aptitude

}

package_management_process()
{

    # Clean Package Manager
    aptitude clean
    aptitude update

    # Install Updates
    aptitude upgrade -y
    aptitdue safe-upgrade -y

    # Install Packages
    if ! -z $PACKAGES;then
        aptitude install -y $PACKAGES
    fi

    # Add Automatic Updates
    if [ ! -f /etc/cron.weekly/aptitude ];then
        setup_automatic_updates
    fi

}

gui_packages()
{

    # Append Gnome Packages
    PACKAGES="$PACKAGES gnome-session gnome-terminal gnome-disk-utility gnome-screenshot gnome-screensaver desktop-base gksu gdm3 pulseaudio xorg-dev ia32-libs-gtk binfmt-support libc6-dev libc6-dev-i386 libcurl3 xdg-user-dirs-gtk xdg-utils network-manager libnss3-1d"

    # Append GUI Software
    PACKAGES="$PACKAGES gparted guake eog gnash vlc gtk-recordmydesktop chromium"

    # Append Xen GUI Packages
    PACKAGES="$PACKAGES libsdl-dev gvncviewer"

}

system_packages()
{

    # Basic System Packages
    PACKAGES="$PACKAGES screen tmux sudo ssh vim parted ntp p7zip-full build-essential libncurses-dev kernel-package fakeroot git mercurial"

    # Xen Packages
    PACKAGES="$PACKAGES bridge-utils build-essential libncurses-dev python-dev uuid uuid-dev libglib2.0-dev libyajl-dev bcc gcc-multilib iasl libpci-dev mercurial flex bison libaio-dev"

}

stage_one_config_and_kernel()
{

    # Create Dev Directory
    mkdir -p $DEV_DIR

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

    # Create Crontab to continue on reboot
    if crontab -l > /dev/null 2>&1;then
        echo "$(crontab -l)\n@reboot $SCRIPT 2" > /var/spool/cron/crontabs/root
    else
        echo "@reboot $SCRIPT 2" > /var/spool/cron/crontabs/root
    fi

    # Reboot System
    reboot

}

stage_two_xen()
{

    # Fresh Kernel so run aptitude cleansing
    package_management_process
    echo "Testing Reboot Process"

    # Run Xen Install
    # setup_xen

    # Remove crontab record
    # sed -i "/$SCRIPT/d" /var/spool/cron/crontabs/root

    # Reboot System
    # reboot

}


# -------------------------------- Execution

# Log Output
exec 1> xen.log 2> xen.log

# Hide Output (Alternative)
# exec 1> /dev/null 2> /dev/null

# Execute Operation according to supplied state
if [ -z "$1" ] || [ "$1" == 1 ];then
    stage_one_config_and_kernel
elif [ ! -z "$1" ] && [ "$1" -eq 2 ];then
    stage_two_xen
fi
