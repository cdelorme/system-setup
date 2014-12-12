#!/bin/bash

# add trusted gpg key
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -

# add sources
echo "# Google Chrome repo http://www.google.com/linuxrepositories/" > /etc/apt/sources.list.d/google.list
echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list
echo "deb http://dl.google.com/linux/talkplugin/deb/ stable main" >> /etc/apt/sources.list.d/google.list
echo "deb http://dl.google.com/linux/earth/deb/ stable main" >> /etc/apt/sources.list.d/google.list
echo "deb http://dl.google.com/linux/musicmanager/deb/ stable main" >> /etc/apt/sources.list.d/google.list
aptitde clean
aptitude update

# run installation
aptitude install chromium google-chrome-stable google-talkplugin

# cleanup chrome sources
rm -f /etc/apt/sources.list.d/google.list /etc/apt/sources.list.d/google-chrome-unstable.list