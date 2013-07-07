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
    if $LOG_TO_FILE;then

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

prepare_for_reboot()
{

    echo "Preparing for Reboot execution"

    # Not sure yet how to make this work

}


# -------------------------------- Installation Options

install_xen_server()
{
    echo "Setting up Xen Server"
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
    echo "Setting up Template"

    # Load Template Function Library
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
