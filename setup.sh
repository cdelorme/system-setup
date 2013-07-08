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
            exec 1> "$KEEP_LOGS_AT/$1.log" 2> "$KEEP_LOGS_AT/$1.log"
        fi
    fi
}


# -------------------------------- Installation Options

install_xen_server()
{
    set_log_file "xen"
    echo "Setting up Xen Server"
    if [ -z "$XEN_REBOOT" ];then
        echo "Handling xen setup pre-reboot"

        # Load Related Libraries
        . $SCRIPT_PATH/linux/$DISTRIBUTION/$DISTRIBUTION_VERSION/template/setup.sh
        . $SCRIPT_PATH/linux/$DISTRIBUTION/$DISTRIBUTION_VERSION/xen/$XEN_VERSION/setup.sh

        # Add & Install Packages
        set_log_file "xen.packages"
        add_template_packages
        add_xen_packages
        install_packages

        # Run system-specific configuration
        set_log_file "xen.config"
        template_configuraton
        xen_preparation
        setup_template_firewall

        # Build Kernel
        set_log_file "xen.kernel"


        # Setup Reboot Preparations
        set_log_file "xen.reboot"

        # Reboot
        echo "Rebooting"
        reboot
    else
        echo "Handling xen setup post-reboot"

        # Load Related Libraries
        . $SCRIPT_PATH/linux/$DISTRIBUTION/$DISTRIBUTION_VERSION/xen/$XEN_VERSION/setup.sh

        # Call remaining operations

    fi
}

install_comm_server()
{
    set_log_file "comm"
    echo "Setting up Communicaton Server"
}

install_web_server()
{
    set_log_file "web"
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
