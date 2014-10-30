
# dev environment documentation

This document consists of configuration steps that will extend gui and comm system configuration.

It will install additional development packages, and configure them as well as modify some system configuration defaults.


## install packages




## xorg framerate limiting

By default, xorg will restrict framerates to 60fps.  This limit is generally useful as it can prevent choppy video and tearing problems in video or poorly built video code.

However, if you are running performance tests, for example trying to test code speed via fps, then it becomes a hindrance on any modern machine.

For development, you should disable this feature by creating, and then modifying the xorg config file.


##### commands

_Create the config file:_

    cd /etc/X11
    Xorg --configure

_Modify the line that restricts higher FPS:_

    sed -i "s/.*SwapbuffersWait.*/Option \"SwapbuffersWait\" \"false\"/" /etc/X11/xorg.conf


## golang

For stability reasons debian opts to not update packages after release.  As a result we don't get a newer version of tools like golang.  This is helpful if there are dependencies on the older version tied into the platform, but in this case that's unlikely.

To install the latest version, you will need to download the package, extract it, and then move the files to the appropriate places.

**Building golang depends on `gcc`, `libc6-dev`, `libc6-dev-i386`, and `mercurial` packages.**

Additional steps include adding its vim package to your plugins, and setting your system to auto-run `go fmt` on write.


##### commands

_Run these to download the golang repository and build then install the latest **release** version:_

    hg clone -u release https://code.google.com/p/go /tmp/go
    (cd /tmp/go/src && GOROOT_FINAL="/usr/lib/go" ./make.bash)
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

_Augmenting vim:_

    echo '" add go fmt' >> ~/.vimrc
    echo 'autocmd FileType go autocmd BufWritePre <buffer> Fmt' >> ~/.vimrc
    cp -R /usr/lib/go/misc/vim/* ~/.vim/

