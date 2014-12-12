#!/bin/bash

# pre-emptive responses to mdadm package installation
echo "mdadm   mdadm/autostart boolean true" | debconf-set-selections
echo "mdadm   mdadm/autocheck boolean true" | debconf-set-selections
echo "mdadm   mdadm/mail_to   string  root" | debconf-set-selections
echo "mdadm   mdadm/initrdstart   string  all" | debconf-set-selections
echo "mdadm   mdadm/initrdstart_notinconf boolean false" | debconf-set-selections
echo "mdadm   mdadm/start_daemon  boolean true" | debconf-set-selections

# install package
aptitude install -ryq mdadm