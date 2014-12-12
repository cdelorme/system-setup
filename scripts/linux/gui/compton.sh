#!/bin/bash

# download source
git clone https://github.com/chjj/compton.git /tmp/compton

# build & install
(cd /tmp/compton && make && make install)

# cleanup
rm -rf /tmp/compton