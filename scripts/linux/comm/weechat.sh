#!/bin/bash

# install package
aptitude install -ryq weechat-ncurses

# @todo download weechat configuration
# @todo insert username and password


# # generate dependent weechat files files
# su $config_system_username -s /bin/bash -c 'weechat-curses &> /dev/null & pid=$!
#     while ! ([ -f ~/.weechat/irc.conf ] && [ -f ~/.weechat/weechat.conf ]); do :; done;
#     kill -9 $pid'

# # set configuration values
# mkdir -p "${user_home_dir}/.weechat"
# sed -i 's/max_buffer_lines_number.*/max_buffer_lines_number = 0/' "${user_home_dir}/.weechat/weechat.conf"
# sed -i 's/freenode\.autoconnect.*/freenode\.autoconnect = on/' "${user_home_dir}/.weechat/irc.conf"
# sed -i "s/freenode\.nicks.*/freenode\.nicks = \"${config_irc_username}, ${config_irc_username}_\"/" "${user_home_dir}/.weechat/irc.conf"
# sed -i "s/freenode\.password.*/freenode\.password = \"${config_irc_password}\"/" "${user_home_dir}/.weechat/irc.conf"