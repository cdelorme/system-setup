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
    if $TRIM; then
        echo "Add trim to ssh & weekly crontab for file systems."

        # Add discard flag to LVMs and execute it manually every week via crontab
        sed -i 's/issue_discards = 0/issue_discards = 1/' /etc/lvm/lvm.conf
        echo "#!/bin/sh\nfor mount in / /boot /home /var/log /tmp; do\n\tfstrim $mount\ndone" > /etc/cron.weekly/fstab
        chmod +x /etc/cron.weekly/fstab
    fi
}

install_fonts()
{
    if [ -n "$INSTALL_FONTS" ];then
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
