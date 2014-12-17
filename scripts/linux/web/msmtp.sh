#!/bin/bash

# set dependent variables for stand-alone execution
[ -z "$dl_cmd" ] && dl_cmd="wget --no-check-certificate -O"
[ -z "$remote_source" ] && remote_source="https://raw.githubusercontent.com/cdelorme/system-setup/master/"

# install msmtp-mta and all related/useful components
aptitude install -ryq msmtp-mta

# download msmtp-mta sample config & modify
[ -f "data/etc/msmtprc" ] && cp "data/etc/msmtprc" "/etc/msmtprc"  || $dl_cmd "/etc/msmtprc" "${remote_source}data/etc/msmtprc"

# set restricted permissions (file will contain plain-text password)
chmod 0600 /etc/msmtprc

# exit if dependent variables are not set
[ -z "$msmtp_username" ] && echo "no msmtp username..."; exit 1
[ -z "$msmtp_password" ] && echo "no msmtp password..."; exit 1

# set email & password & username as gmail
[ -n "$msmtp_username" ] && sed -i "s/user username/user $msmtp_username/" /etc/msmtprc
[ -n "$msmtp_password" ] && sed -i "s/password password/password $msmtp_password/" /etc/msmtprc
[ -n "$msmtp_username" ] && sed -i "s/from username@gmail.com/from ${msmtp_username}@gmail.com/" /etc/msmtprc