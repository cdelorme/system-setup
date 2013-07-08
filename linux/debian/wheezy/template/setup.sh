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

add_jis_locale()
{
    PACKAGES="$PACKAGES fonts-takao"
    echo "ja_JP.UTF-8 UTF-8" >> /etc/locale.gen
    locale-gen
}

ssd_trim_config()
{
    if [ -n "TRIM" ] && $TRIM; then
        echo "Add trim to ssh & weekly crontab for file systems."

        # Add discard flag to LVMs and execute it manually every week via crontab
        sed -i 's/issue_discards = 0/issue_discards = 1/' /etc/lvm/lvm.conf
        echo "#!/bin/sh\nfor mount in / /boot /home /var/log /tmp; do\n\tfstrim $mount\ndone" > /etc/cron.weekly/fstab
        chmod +x /etc/cron.weekly/fstab
    fi
}

install_fonts()
{
    if [ -n "$INSTALL_FONTS" ] && $INSTALL_FONTS;then
        echo "Install custom fonts."

        # Install my fonts
        mkdir -p /usr/share/fonts/truetype
        if [ -d $FILES/fonts/ ];then
            mv $FILES/fonts/*.ttf /usr/share/fonts/truetype
            fc-cache -rf
        fi
    fi
}

ssh_config()
{
    if [ -n "$SSH_PORT" ];then
        echo "Update SSH Port."

        # Set SSH Port
        sed -i "s/Port 22/Port $SSH_PORT/" /etc/ssh/sshd_config
        service ssh restart
    fi
}

setup_automatic_updates()
{
    if [ -n "$AUTOMATIC_UPDATES" ] && $AUTOMATIC_UPDATES;then
    echo "Creating Automatic Updates."

    # Create a file to be executed weekly by crontabs:
    echo "#!/bin/sh" >> /etc/cron.weekly/aptitude
    echo "# Weekly Software Update Processing" >> /etc/cron.weekly/aptitude
    echo "aptitude clean" >> /etc/cron.weekly/aptitude
    echo "aptitude update" >> /etc/cron.weekly/aptitude
    echo "aptitude upgrade -y || aptitude upgrade -y" >> /etc/cron.weekly/aptitude
    echo "aptitude safe-upgrade -y || aptitude safe-upgrade -y" >> /etc/cron.weekly/aptitude

    # Make it executable
    chmod +x /etc/cron.weekly/aptitude
}








setup_firewall()
{

    echo "Setting up firewall."

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

git_config()
{

    echo "Adding Git Helpers."

    # Move awesome helper files
    cp -ra $FILES/git/. /etc/skel
    cp -ra $FILES/git/. /root

    # Load any awesome saved git configs
    echo "\n\t[alias]\n\t\tl = \"!. ~/.githelpers && pretty_git_log\"" >> /root/.gitconfig
    echo "\n# Git Additions\n. ~/.git-completion\n. ~/.git-prompt" >> /root/.profile
    echo "\n\t[alias]\n\t\tl = \"!. ~/.githelpers && pretty_git_log\"" >> /etc/skel/.gitconfig
    echo "\n# Git Additions\n. ~/.git-completion\n. ~/.git-prompt" >> /etc/skel/.profile

}

git_user_config()
{

    echo "Configuring Git."

    # Run global config as root
    if [ ! -z "$GIT_NAME" ];then
        git config --global user.name "$GIT_NAME"
    fi
    if [ ! -z "$GIT_EMAIL" ];then
        git config --global user.email "$GIT_EMAIL"
    fi
    git config --global core.editor "vim"
    git config --global help.autocorrect -1
    git config --global color.ui true

    # Run global config as user
    su -c "git config --global user.name \"$GIT_NAME\"" $USERNAME
    su -c "git config --global user.email \"$GIT_EMAIL\"" $USERNAME
    su -c "git config --global core.editor \"vim\"" $USERNAME
    su -c "git config --global help.autocorrect -1" $USERNAME
    su -c "git config --global color.ui true" $USERNAME

}

user_configuration()
{

    echo "Configure Supplied User: $USERNAME."

    # Create user if not exists
    if ! id -u "$USERNAME" >/dev/null 2>&1 && [ ! -z "$PASSWORD" ]; then
        useradd -m -s /bin/bash -p $(mkpasswd -m md5 $PASSWORD) $USERNAME
    fi

    # Add to sudo group
    usermod -aG sudo $USERNAME

    # Create important user directories
    mkdir -p /home/$USERNAME/.config/autostart

    # Update Ownership
    chown -R $USERNAME:$USERNAME /home/$USERNAME

}










# -------------------------------- Callable Methods

prepare_template_packages()
{
    echo "Run all the package modifiers"
}

prepare_template_environment()
{
    echo "Configure anything environment related"
}

post_template_config()
{
    echo "Handle everything after the install is done"
}
