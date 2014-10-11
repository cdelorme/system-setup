
# [golang](http://golang.org/)

While I highly recommend [reading their official documentation](http://golang.org/doc/install), the installation process can be summarized quickly, and the same steps (almost universally) applies to Windows, Linux, and OSX.

1. Install golang
2. Create a folder for go to act as the GOPATH, with src, pkg, and bin folders
3. Define a GOPATH variable and point it at that folder
4. Add GOPATH/bin to your PATH variable

With those steps done you will be ready to begin writing code.  Your source should exist in the GOPATH/src, preferably under a domain that is sensible (a github account path is common).  Read more on golangs official documentation for details.


## install

For windows download their installer and run it.

For linux, use your package manager or download the source (ex. `aptitude install golang`).

For osx, use homebrew: `brew install go`.


# folder

On Windows I recommend something simple like `C:\go`.

On linux and osx I recommend `~/.go`, and I recommend symlinking the `~/.go/bin` to a `~/bin` folder.


# gopath & path

In Windows you will need to open system properties, then select advanced on the lefthand menu, followed by the "Environment Variables" button.  From here you can add and modify system and user variables.  You may need to either reboot or logout and log back in for any changes here to take effect.

For linux and mac you can simply set the variable manually `GOPATH=~/.go`, or you can add it as `export GOPATH=~/.go` to a `~/.bashrc` or similar.  Similarly you can append GOPATH to PATH with `export PATH=$PATH:$GOPATH/bin`.  If you have already created a local bin folder for your user you can simply use `ln -s ~/bin $GOPATH/bin` to symlink it and won't need to further modify the PATH variable.
