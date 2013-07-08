#!/bin/sh
# Template Method Library

# -------------------------------- Setup

# Prepare Paths
if [ -z "$SCRIPT_PATH" ];then
    TEMPLATE_SCRIPT=$(readlink -f $0)
else
    TEMPLATE_SCRIPT="$SCRIPT_PATH/linux/$DISTRIBUTION/$DISTRIBUTION_VERSION/template/setup.sh"
fi
TEMPLATE_PATH=$(dirname $TEMPLATE_SCRIPT)

# Load configuration
. $TEMPLATE_PATH/config


# -------------------------------- Library Methods

kernel_install()
{
    echo "installing kernel..."
}

kernel_build()
{
    echo "building kernel..."
}

kernel_preparations()
{
    echo "configuring services for building a kernel..."
    echo "\n# Concurrency Level\nCONCURRENCY_LEVEL=$(nproc)" >> /etc/kernel-pkg.conf
}

kernel_process()
{
    echo "beginning build and install kernel process..."
    kernel_preparations
    kernel_build
    kernel_install
}

# kernel_installation()
# {

#     # If kernel debs exist install them
#     if [ -d $FILES/kernel ] && ls $FILES/kernel/*.deb >/dev/null 2>&1;then
#         dpkg -i $FILES/kernel/*.deb
#     else

#         # Make Directory for development
#         mkdir -p $DEV_DIR/kernel

#         # Navigate to work folder
#         cd $DEV_DIR/kernel

#         # Manually download 3.9.8
#         wget --no-check-certificate https://www.kernel.org/pub/linux/kernel/v3.x/linux-3.9.8.tar.xz

#         # Extract to dev directory & enter
#         tar -xf linux*
#         cd linux*

#         # Copy the latest config
#         for CONFIG in /boot/config-*;do
#             cp $CONFIG .config
#         done

#         # Set xen flags
#         echo "# Xen Manual Configs\nCONFIG_VIRT_CPU_ACCOUNTING_GEN=y\nCONFIG_NUMA_BALANCING=y\nCONFIG_PARAVIRT_TIME_ACCOUNTING=y\nCONFIG_PREEMPT=y\nCONFIG_MOVABLE_NODE=y\nCONFIG_CLEANCACHE=y\nCONFIG_FRONTSWAP=y\nCONFIG_HZ_1000=y\nCONFIG_PCI_STUB=y\nCONFIG_XEN_PCIDEV_FRONTEND=y\nCONFIG_XEN_BLKDEV_FRONTEND=y\nCONFIG_XEN_BLKDEV_BACKEND=y\nCONFIG_XEN_NETDEV_FRONTEND=y\nCONFIG_XEN_NETDEV_BACKEND=y\nCONFIG_XEN_WDT=y\nCONFIG_XEN_SELFBALLOONING=y\nCONFIG_XEN_BALLOON_MEMORY_HOTPLUG=y\nCONFIG_XEN_DEV_EVTCHN=y\nCONFIG_XENFS=y\nCONFIG_XEN_GNTDEV=y\nCONFIG_XEN_GRANT_DEV_ALLOC=y\nCONFIG_XEN_PCIDEV_BACKEND=y" >> .config

#         # Automate corrections and missing flags
#         yes "" | make oldconfig

#         # Build
#         make-kpkg clean
#         fakeroot make-kpkg --initrd --revision=4.3.xen.custom kernel_image

#         # Install
#         dpkg -i ../*.deb

#         # Move back to current script dir
#         cd $PWD

#     fi

# }

setup_template_firewall()
{
    if [ -n "$SETUP_FIREWALL" ] && $SETUP_FIREWALL;then
        echo "setting up firewall..."

        # Xen generates vifs dynamically
        # Securing that without a script would be very difficult
        # So we use a blacklist instead of a whitelist to control what we know

        if [ -f "/etc/firewall.conf" ];then
            rm /etc/firewall.conf
        fi

        # Define all rules
        echo "*filter" >> /etc/firewall.conf
        echo "" >> /etc/firewall.conf
        echo "# Prevent use of Loopback on non-loopback dervice (lo0):" >> /etc/firewall.conf
        echo "-A INPUT -i lo -j ACCEPT" >> /etc/firewall.conf
        echo "-A INPUT ! -i lo -d 127.0.0.0/8 -j REJECT" >> /etc/firewall.conf
        echo "" >> /etc/firewall.conf
        echo "# Accepts all established inbound connections" >> /etc/firewall.conf
        echo "-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT" >> /etc/firewall.conf
        echo "" >> /etc/firewall.conf
        echo "# Allows all outbound traffic (Can be limited at discretion)" >> /etc/firewall.conf
        echo "-A OUTPUT -j ACCEPT" >> /etc/firewall.conf
        echo "" >> /etc/firewall.conf
        echo "# Allow ping" >> /etc/firewall.conf
        echo "-A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT" >> /etc/firewall.conf
        echo "" >> /etc/firewall.conf
        echo "# Enable SSH Connection (custom port in /etc/ssh/sshd_conf)" >> /etc/firewall.conf
        echo "-A INPUT -p tcp -m state --state NEW --dport $SSH_PORT -j ACCEPT" >> /etc/firewall.conf
        echo "$FILEWALL_RULES" >> /etc/firewall.conf
        echo "# Set other traffic defaults" >> /etc/firewall.conf
        echo "-A INPUT -j REJECT" >> /etc/firewall.conf
        echo "-A FORWARD -j ACCEPT" >> /etc/firewall.conf
        echo "" >> /etc/firewall.conf
        echo "COMMIT" >> /etc/firewall.conf

        # Auto-load Firewall at boot time
        echo "#!/bin/sh" >> "/etc/network/if-up.d/iptables"
        echo "iptables -F" >> "/etc/network/if-up.d/iptables"
        echo "iptables-restore < /etc/firewall.conf" >> "/etc/network/if-up.d/iptables"
        # echo "#!/bin/sh\niptables -F\niptables-restore < /etc/firewall.conf" > "/etc/network/if-up.d/iptables"
        chmod +x "/etc/network/if-up.d/iptables"
    fi
}

gui_cleanup()
{
    if [ -n "$LATE_START_GUI" ] && $LATE_START_GUI;then
        echo "resolving boot-time services..."
        update-rc.d gdm3 disable 2
        update-rc.d network-manager disable 2
        update-rc.d network-manager disable 3
        update-rc.d network-manager disable 4
        update-rc.d network-manager disable 5
        update-rc.d bluetooth disable 2
        update-rc.d bluetooth disable 3
        update-rc.d bluetooth disable 4
        update-rc.d bluetooth disable 5
    fi
}

pam_gdm_root()
{
    if [ -n "$ALLOW_ROOT_LOGIN" ] && $ALLOW_ROOT_LOGIN;then
        echo "enabling root login to gdm3..."
        sed -i "s/user != root//" /etc/pam.d/gdm3
    fi
}

guake_config()
{
    echo "patching guake notification..."
    sed -i 's/notification.show()/try:\n                notification.show()\n            except Exception:\n                pass/' /usr/bin/guake
    rm /etc/xdg/autostart/guake.desktop
    sed -i '/StartupNotify|X-GNOME-Autostart-enabled/d' /usr/share/applications/guake.desktop

    echo "setting guake automation at boot time..."
    mkdir -p /root/.config/autostart
    ln -s /usr/share/applications/guake.desktop /root/.config/autostart/guake.desktop
    if [ -n "$USERNAME" ];then
        mkdir -p /home/$USERNAME/.config/autostart
        ln -s /usr/share/applications/guake.desktop /home/$USERNAME/.config/autostart/guake.destop
        chown -R $USERNAME:$USERNAME /home/$USERNAME/.config/autostart
    fi
}

sublime_text_config()
{
    echo "downloading, installing and configuring sublime text 2..."
    wget -O $DEV_DIR/sublime.tar.bz2 "http://c758482.r82.cf2.rackcdn.com/Sublime%20Text%202.0.1%20x64.tar.bz2"
    tar xf $DEV_DIR/sublime.tar.bz2
    rm $DEV_DIR/sublime.tar.bz2
    mv Sublime* /usr/share/sublime_text
    ln -s /usr/share/sublime_text/sublime_text /usr/bin/subl
    echo "[Desktop Entry]\nName=Sublime Text 2\nComment=The Best Text Editor in the World!\nTryExec=subl\nExec=subl\nIcon=/usr/share/sublime_text/Icon/256x256/sublime_text.png\nType=Application\nCategories=Office;Sublime Text;" > /usr/share/applications/subl.desktop
    echo "text/plain=subl.desktop\ntext/css=subl.desktop\ntext/htm=subl.desktop\ntext/javascript=subl.desktop\ntext/x-c=subl.desktop\ntext/csv=subl.desktop\ntext/x-java-source=subl.desktop\ntext/java=subl.desktop\n" >> /usr/share/applications/defaults.list
    update-desktop-database

    if [ -d "$FILES/sublime_text" ] && [ -n "$USERNAME" ];then
        echo "loading sublime configuration files..."
        mkdir -p /home/$USERNAME/.config/sublime-text-2
        cp -R $FILES/sublime_text/* /home/$USERNAME/.config/sublime-text-2/
        chown -R $USERNAME:$USERNAME /home/$USERNAME/.config/
    fi
}

gui_configuration()
{
    echo "running gui configuration..."
    sublime_text_config
    guake_config
    pam_gdm_root
    gui_cleanup
}

user_git_configuration()
{
    if [ -n "$CONFIGURE_GIT" ] && $CONFIGURE_GIT;then
        echo "configuring git..."
        if [ ! -z "$GIT_NAME" ];then
            git config --global user.name "$GIT_NAME"
        fi
        if [ ! -z "$GIT_EMAIL" ];then
            git config --global user.email "$GIT_EMAIL"
        fi
        git config --global core.editor "vim"
        git config --global help.autocorrect -1
        git config --global color.ui true
        su -c "git config --global user.name \"$GIT_NAME\"" $USERNAME
        su -c "git config --global user.email \"$GIT_EMAIL\"" $USERNAME
        su -c "git config --global core.editor \"vim\"" $USERNAME
        su -c "git config --global help.autocorrect -1" $USERNAME
        su -c "git config --global color.ui true" $USERNAME
    fi
}

create_user()
{
    if [ -n "$PASSWORD" ];then
        useradd -m -s /bin/bash -p $(mkpasswd -m md5 $PASSWORD) $USERNAME
    else
        echo "you will have to add a password to the $USERNAME from root with passwd..."
        useradd -m -s /bin/bash $USERNAME
    fi
}

user_configuration()
{
    if [ -n "$USERNAME" ]; then
        echo "configuring supplied user: $USERNAME..."

        if ! id -u "$USERNAME" >/dev/null 2>&1;then
            echo "creating user: $USERNAME..."
            create_user
        fi

        if [ -n "$HAS_SUDO_PRIVS" ] && $HAS_SUDO_PRIVS;then
            echo "adding user to sudo group..."
            usermod -aG sudo $USERNAME
        fi
        user_git_configuration
    fi
}

load_git_config()
{
    if [ -n "$CONFIGURE_GIT" ] && $CONFIGURE_GIT;then
        echo "adding and installing git helpers..."
        cp -ra $FILES/git/. /etc/skel
        cp -ra $FILES/git/. /root
        echo "\n\t[alias]\n\t\tl = \"!. ~/.githelpers && pretty_git_log\"" >> /root/.gitconfig
        echo "\n# Git Additions\n. ~/.git-completion\n. ~/.git-prompt" >> /root/.profile
        echo "\n\t[alias]\n\t\tl = \"!. ~/.githelpers && pretty_git_log\"" >> /etc/skel/.gitconfig
        echo "\n# Git Additions\n. ~/.git-completion\n. ~/.git-prompt" >> /etc/skel/.profile
    fi
}

install_fonts()
{
    if [ -n "$INSTALL_FONTS" ] && $INSTALL_FONTS;then
        echo "installing custom fonts..."
        mkdir -p /usr/share/fonts/truetype
        if [ -d $FILES/fonts/ ];then
            mv $FILES/fonts/*.ttf /usr/share/fonts/truetype
            fc-cache -rf
        fi
    fi
}

add_jis_locale()
{
    PACKAGES="$PACKAGES fonts-takao"
    echo "ja_JP.UTF-8 UTF-8" >> /etc/locale.gen
    locale-gen
}

ssh_config()
{
    if [ -n "$SSH_PORT" ];then
        echo "updating ssh port..."
        sed -i "s/Port 22/Port $SSH_PORT/" /etc/ssh/sshd_config
        service ssh restart
    fi
}

ssd_trim_config()
{
    if [ -n "TRIM" ] && $TRIM; then
        echo "adding trim to ssh & weekly crontab for file systems..."
        sed -i 's/issue_discards = 0/issue_discards = 1/' /etc/lvm/lvm.conf
        echo "#!/bin/sh\nfor mount in / /boot /home /var/log /tmp; do\n\tfstrim $mount\ndone" > /etc/cron.weekly/fstab
        chmod +x /etc/cron.weekly/fstab
    fi
}

setup_automatic_updates()
{
    if [ -n "$AUTOMATIC_UPDATES" ] && $AUTOMATIC_UPDATES;then
    echo "creating automatic updates and adding to executable crontabs..."
    echo "#!/bin/sh" >> /etc/cron.weekly/aptitude
    echo "# Weekly Software Update Processing" >> /etc/cron.weekly/aptitude
    echo "aptitude clean" >> /etc/cron.weekly/aptitude
    echo "aptitude update" >> /etc/cron.weekly/aptitude
    echo "aptitude upgrade -y || aptitude upgrade -y" >> /etc/cron.weekly/aptitude
    echo "aptitude safe-upgrade -y || aptitude safe-upgrade -y" >> /etc/cron.weekly/aptitude
    chmod +x /etc/cron.weekly/aptitude
}

template_configuration()
{
    echo "configuring to match template..."
    setup_automatic_updates
    ssd_trim_config
    ssh_config
    add_jis_locale
    install_fonts
    load_git_config
    user_configuration
    gui_configuration
}

install_packages()
{
    echo "cleaning up aptitude..."

    # Command duplicates exist to handle scenarios where first-attempts fail
    # The problem steps from aptitude failing to return error codes

    aptitude clean
    aptitude update
    aptitude update

    echo "running through system upgrades..."

    aptitude safe-upgrade -y
    aptitude safe-upgrade -y
    aptitude upgrade -y
    aptitude upgrade -y

    echo "executing package installation..."

    aptitude install -y $PACKAGES
    aptitude install -y $PACKAGES

    echo "package installation completed..."
}

add_template_packages()
{
    echo "adding basic software packages..."
    PACKAGES="$PACKAGES screen"
    PACKAGES="$PACKAGES tmux"
    PACKAGES="$PACKAGES ssh"
    PACKAGES="$PACKAGES sudo"
    PACKAGES="$PACKAGES vim"
    PACKAGES="$PACKAGES parted"
    PACKAGES="$PACKAGES ntp"
    PACKAGES="$PACKAGES git"
    PACKAGES="$PACKAGES mercurial"

    if [ -n "$OPTIONAL_SOFTWARE" ] && $OPTIONAL_SOFTWARE;then
        echo "adding optional software..."
        PACKAGES="$PACKAGES p7zip-full"
        PACKAGES="$PACKAGES exfat-fuse"
        PACKAGES="$PACKAGES exfat-utils"
    fi

    if [ -n "$RUNNING_IN_XEN" ] && $RUNNING_IN_XEN || [ "$STATE" = "xen" ];then
        echo "adding kernel packages..."
        PACKAGES="$PACKAGES build-essential"
        PACKAGES="$PACKAGES libncurses-dev"
        PACKAGES="$PACKAGES kernel-package"
        PACKAGES="$PACKAGES fakeroot"
    fi

    if [ -n "$HEADLESS" ] && ! $HEADLESS;then
        echo "adding minimalist gui packages..."
        PACKAGES="$PACKAGES gnome-session"
        PACKAGES="$PACKAGES gnome-terminal"
        PACKAGES="$PACKAGES gnome-disk-utility"
        PACKAGES="$PACKAGES gnome-screenshot"
        PACKAGES="$PACKAGES gnome-screensaver"
        PACKAGES="$PACKAGES desktop-base"
        PACKAGES="$PACKAGES gksu"
        PACKAGES="$PACKAGES gdm3"
        PACKAGES="$PACKAGES pulseaudio"
        PACKAGES="$PACKAGES xorg-dev"
        PACKAGES="$PACKAGES ia32-libs-gtk"
        PACKAGES="$PACKAGES binfmt-support"
        PACKAGES="$PACKAGES libc6-dev"
        PACKAGES="$PACKAGES libc6-dev-i386"
        PACKAGES="$PACKAGES libcurl3"
        PACKAGES="$PACKAGES xdg-user-dirs-gtk"
        PACKAGES="$PACKAGES xdg-utils"
        PACKAGES="$PACKAGES network-manager"
        PACKAGES="$PACKAGES libnss3-1d"

        if [ -n "$OPTIONAL_SOFTWARE" ] && $OPTIONAL_SOFTWARE;then
            echo "adding optional gui software..."
            PACKAGES="$PACKAGES gparted"
            PACKAGES="$PACKAGES guake"
            PACKAGES="$PACKAGES eog"
            PACKAGES="$PACKAGES gnash"
            PACKAGES="$PACKAGES vlc"
            PACKAGES="$PACKAGES gtk-recordmydesktop"
            PACKAGES="$PACKAGES chromium"
        fi
    fi
}
