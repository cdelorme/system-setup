#!/bin/sh
# Setup Script Core

# -------------------------------- Setup

# Set Script & Path
SCRIPT=$(readlink -f $0)
SCRIPT_PATH=$(dirname $SCRIPT)

# Load Config
. $SCRIPT_PATH/config

# Apply Argument for State/Operation
if [ -n "$STATE" ];then
    STATE="$1"
fi


# -------------------------------- Global Methods

# Display instructions to the user
print_instructions()
{
    echo "usage: $0 {xen|comm|web|template}"
    echo "check README.md for details."
}

# Change log file for processing
set_log_file()
{

    # If we are logging to a file then listen to the command
    if [ -n "$LOG_TO_FILE" ] && $LOG_TO_FILE;then

        # Make logs directory if not exists
        if [ ! -d "$KEEP_LOGS_AT" ];then
            mkdir "$KEEP_LOGS_AT"
        fi

        # Set log location according to supplied argument
        if [ -n "$1" ];then
            exec 1> "$KEEP_LOGS_AT/$1" 2>&1
        fi
    fi
}

setup_firewall()
{
    if [ -n "$SETUP_FIREWALL" ] && $SETUP_FIREWALL;then
        echo "Setting up firewall."
#         # Xen generates vifs dynamically
#         # Securing that without a script would be very difficult
#         # So we use a blacklist instead of a whitelist to control what we know

#         # Define firewall at `/etc/firewall.conf`
#         if $DUAL_LAN;then
#             echo "*filter\n\n# Prevent use of Loopback on non-loopback dervice (lo0):\n-A INPUT -i lo -j ACCEPT\n-A INPUT ! -i lo -d 127.0.0.0/8 -j REJECT\n\n# Accepts all established inbound connections\n-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT\n\n# Allows all outbound traffic (Can be limited at discretion)\n-A OUTPUT -j ACCEPT\n\n# Allow ping\n-A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT\n\n# Enable SSH Connection (custom port in /etc/ssh/sshd_conf)\n-A INPUT -p tcp -m state --state NEW --dport $SSH_PORT -j ACCEPT\n\n# Forwarding Rules (for Dual LAN Xen)\n-A FORWARD -i eth0 -o eth1 -j REJECT\n-A FORWARD -i eth0 -o xenbr1 -j REJECT\n-A FORWARD -i eth1 -o eth0 -j REJECT\n-A FORWARD -i eth1 -o xenbr0 -j REJECT\n\n# Set other traffic defaults\n-A INPUT -j REJECT\n-A FORWARD -j ACCEPT\n\nCOMMIT" > /etc/firewall.conf
#         else
#             echo "*filter\n\n# Prevent use of Loopback on non-loopback dervice (lo0):\n-A INPUT -i lo -j ACCEPT\n-A INPUT ! -i lo -d 127.0.0.0/8 -j REJECT\n\n# Accepts all established inbound connections\n-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT\n\n# Allows all outbound traffic (Can be limited at discretion)\n-A OUTPUT -j ACCEPT\n\n# Allow ping\n-A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT\n\n# Enable SSH Connection (custom port in /etc/ssh/sshd_conf)\n-A INPUT -p tcp -m state --state NEW --dport $SSH_PORT -j ACCEPT\n\n# Forwarding Rules (for Dual LAN Xen)\n-A FORWARD -i eth0 -o xenbr1 -j REJECT\n\n# Set other traffic defaults\n-A INPUT -j REJECT\n-A FORWARD -j ACCEPT\n\nCOMMIT" > /etc/firewall.conf
#         fi

#         # Prepare firewall auto-loading
#         echo "#!/bin/sh\niptables -F\niptables-restore < /etc/firewall.conf" > "/etc/network/if-up.d/iptables"
#         chmod +x "/etc/network/if-up.d/iptables"
    fi
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

    echo "package installation completed."
}

install_kernel()
{
    echo "Install Kernel"
}

build_kernel()
{
    echo "Build Kernel"
}

# kernel_installation()
# {

#     # Add Concurrency /w automatic core detection
#     echo "\n# Concurrency Level\nCONCURRENCY_LEVEL=$(nproc)" >> /etc/kernel-pkg.conf

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


# -------------------------------- Installation Options

install_xen_server()
{
    # Set Logging
    set_log_file "xen"
    echo "Setting up Xen Server"
    if [ -z "$XEN_REBOOT" ];then
        echo "Handling xen setup pre-reboot"

        # Load Related Libraries
        . $SCRIPT_PATH/linux/$DISTRIBUTION/$DISTRIBUTION_VERSION/template/setup.sh
        . $SCRIPT_PATH/linux/$DISTRIBUTION/$DISTRIBUTION_VERSION/xen/$XEN_VERSION/setup.sh

        # Execute template setup operations

    else
        echo "Handling xen setup post-reboot"

        # Load Related Libraries
        . $SCRIPT_PATH/linux/$DISTRIBUTION/$DISTRIBUTION_VERSION/xen/$XEN_VERSION/setup.sh

        # Call remaining operations

    fi
}

install_comm_server()
{
    echo "Setting up Communicaton Server"
}

install_web_server()
{
    echo "Setting up Web Server"
}

install_template()
{
    # Set Logging
    set_log_file "template"

    # Load Related Libraries
    . $SCRIPT_PATH/linux/$DISTRIBUTION/$DISTRIBUTION_VERSION/template/setup.sh

    # Execute template setup operations

}


# -------------------------------- Execution

# Check Argument
case "$STATE" in
    template)
        install_template
        ;;
    comm)
        install_comm_server
        ;;
    web)
        install_web_server
        ;;
    xen)
        install_xen_server
        ;;
    *)
        print_instructions
        exit 3;
        ;;
esac
