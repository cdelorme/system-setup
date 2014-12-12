#!/bin/bash

# install packages
aptitude install -ryq samba samba-tools smbclient

# @todo download samba config

# add user
usermod -aG sambashare $username

# @todo download samba monit