#!/bin/bash

# install wireless utility packages
aptitude install -ryq avahi-utils avahi-daemon libnss-mdns wireless-tools bluez bluez-utils bluez-tools bluez-firmware bluez-hcidump

# conditionally install wireless audio package
if [ "$install_openbox" = "y" ]
then
    aptitude install -ryq pulseaudio-module-bluetooth
fi