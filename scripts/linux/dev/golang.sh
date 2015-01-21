#!/bin/bash

# install any missing dependencies
aptitude install -ryq gcc libc6-dev libc6-dev-i386 mercurial git subversion bzr

# download source
git clone https://go.googlesource.com/go /tmp/go
(cd /tmp/go && git checkout go1.4.1)

# build source
(cd /tmp/go/src && GOROOT_FINAL="/usr/lib/go" ./make.bash)

# install (many steps)
mv /tmp/go /usr/lib/
mkdir -p /usr/share/doc/golang-doc /usr/share/go/
mv /usr/lib/go/src /usr/share/go/
mv /usr/lib/go/doc /usr/share/doc/golang-doc/html
mv /usr/lib/go/favicon.ico /usr/share/doc/golang-doc/
ln -sf /usr/share/go/src /usr/lib/go/src
ln -sf /usr/share/doc/golang-doc/html /usr/lib/go/doc
ln -sf /usr/lib/go/favicon.ico /usr/share/doc/golang-doc/favicon.ico
ln -sf /usr/lib/go/bin/go /usr/local/bin/go
ln -sf /usr/lib/go/bin/gofmt /usr/local/bin/gofmt

# install golang vim plugins
govim="$(go env GOROOT)/misc/vim/"
cp -R "$govim"* /root/.vim/
cp -R "$govim"* /etc/skel/.vim/
[ -n "$username" ] && cp -R "$govim"* /home/$username/.vim/
