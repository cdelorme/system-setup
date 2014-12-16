#!/bin/bash

# download source
git clone https://github.com/rg3/youtube-dl /tmp/youtube-dl

# build & install
(cd /tmp/youtube-dl && python setup.py install)

# first-run updates
youtube-dl -U

# append to system updates
[ -f "/etc/cron.daily/system-updates" ] && echo "which youtube-dl &>/dev/null && youtube-dl -U" >> "/etc/cron.daily/system-updates"