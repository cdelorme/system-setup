#!/bin/bash

# install dependencies without "recommended" additions
aptitude install -yqR asciidoc

# download source
git clone https://github.com/chjj/compton.git /tmp/compton

# build & install
(cd /tmp/compton && make && make install)

# cleanup
rm -rf /tmp/compton