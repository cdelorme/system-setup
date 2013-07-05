#!/bin/sh
# Setup Script Core

# Set Script & Path
SCRIPT=$(readlink -f $0)
SCRIPT_PATH=$(dirname $SCRIPT)

# Load Config
. $SCRIPT_PATH/config

# Display instructions to the user
print_instructions()
{
    echo "usage: $0 {xen|comm|web|template}"
    echo "check README.md for details."
}

# Change log file for processing
set_log_file()
{

    # Make logs directory if not exists
    if [ ! -d "$KEEP_LOGS_AT" ];then
        mkdir "$KEEP_LOGS_AT"
    fi

    # Set log location according to supplied argument
    if [ -n "$1" ];then
        exec 1> "$KEEP_LOGS_AT/$1" 2>&1
    fi

}


# Check Argument
if [ -n "$1" ];then
    if [ "$1" = "xen" ];then
        echo "Setting up Xen Server"
    elif [ "$1" = "comm" ];then
        echo "Setting up Communicaton Server"
    elif [ "$1" = "web" ];then
        echo "Setting up Web Server"
    elif [ "$1" = "template" ];then
        echo "Setting up Template"
    else
        echo "invalid argument."
        print_instructions
    fi
else
    print_instructions
fi
