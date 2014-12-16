#!/bin/bash

# install package
aptitude install -ryq weechat

# prepare weechat directory
mkdir -p "/home/${username}/.weechat"

# generate weechat config with first-run
su $username -s /bin/bash -c 'weechat-curses &>/dev/null & pid=$!; sleep 10; kill -9 $pid'

# configure weechat
sed -i 's/max_buffer_lines_number.*/max_buffer_lines_number = 0/' "/home/${username}/.weechat/weechat.conf"
sed -i 's/freenode\.autoconnect.*/freenode\.autoconnect = on/' "/home/${username}/.weechat/irc.conf"