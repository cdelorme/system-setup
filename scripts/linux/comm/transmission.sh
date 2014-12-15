#!/bin/bash

# install transmission
aptitude install -ryq transmission transmission-cli transmission-daemon

# stop transmission daemon (to prevent settings from being overwritten)
service transmission-daemon stop

# download base transmission config
[ -f "data/etc/transmission-daemon/settings.json" ] && cp "data/etc/transmission-daemon/settings.json" "/etc/transmission-daemon/settings.json"  || $dl_cmd "/etc/transmission-daemon/settings.json" "${remote_source}data/etc/transmission-daemon/settings.json"

# attempt to restart transmission daemon
service transmission-daemon start
service transmission-daemon restart

# download transmission monit
[ -f "data/etc/monit/monitrc.d/transmission-daemon" ] && cp "data/etc/monit/monitrc.d/transmission-daemon" "/etc/monit/monitrc.d/transmission-daemon"  || $dl_cmd "/etc/monit/monitrc.d/transmission-daemon" "${remote_source}data/etc/monit/monitrc.d/transmission-daemon"
ln -nsf "../monitrc.d/transmission-daemon" "/etc/monit/conf.d/transmission-daemon"
monit -t && service monit restart