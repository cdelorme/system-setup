#!/bin/bash

# install dependencies without "recommended" additions
aptitude install -Ryq asciidoc

# dependencies:
aptitude install -ryq build-essential libxdamage-dev libxcomposite-dev libx11-dev libxfixes-dev libxext-dev libxrender-dev libxrandr-dev libxinerama-dev pkg-config x11-utils libpcre3-dev libconfig-dev libdrm-dev libdbus-1-dev libgl1-mesa-dev x11proto-core-dev libxml2-utils xsltproc

# download source
git clone https://github.com/chjj/compton.git /tmp/compton

# build & install
(cd /tmp/compton && make && make install)