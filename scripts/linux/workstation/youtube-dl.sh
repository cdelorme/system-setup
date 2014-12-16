#!/bin/bash

# download source
git clone https://github.com/rg3/youtube-dl /tmp/youtube-dl

# build & install
(cd /tmp/youtube-dl && python setup.py install)

# cleanup source files
rm -rf /tmp/youtube-dl

# first-run updates
youtube-dl -U

# append to system updates
[ -f "/etc/cron.daily/system-updates" ] && echo "youtube-dl -U" >> "/etc/cron.daily/system-updates"