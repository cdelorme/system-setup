#!/bin/bash

# install transmission
aptitude install -ryq transmission transmission-cli transmission-daemon

# @todo configure transmission
# config_bt_max_down=3000
# config_bt_max_up=80
# config_bt_watch_path="/tmp"
# config_bt_incomplete_path="/tmp"
# config_bt_complete_path="/tmp"
# config_bt_web_accessible=true
# config_bt_web_port=9010

# @todo download transmission monit