#!/bin/bash

# install msmtp-mta and all related/useful components
aptitude install -ryq msmtp-mta

# download msmtp-mta sample config & modify
[ -f "data/etc/msmtprc" ] && cp "data/etc/msmtprc" "/etc/msmtprc"  || $dl_cmd "/etc/msmtprc" "${remote_source}data/etc/msmtprc"

# set restricted permissions (file will contain plain-text password)
chmod 0600 /etc/msmtprc

# set email & password
sed -i "s/user username/user $msmtp_username/" /etc/msmtprc
sed -i "s/password password/password $msmtp_password/" /etc/msmtprc