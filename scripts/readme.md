
# scripts

The setup script at top level will look here to find the primary modules and all subsequent files.

The main modules are:

- [template.sh](template.sh)
- [web.sh](web.sh)
- [dev.sh](dev.sh)
- [osx.sh](osx.sh)
- [windows.sh](windows.sh)

The windows script may seem contradictory, but in fact it is for git-bash, which comes with git-scm installation on windows, and can cover a very small portion of configuration.  It is only useful really if you are using windows for development and need things like ssh keys and customized sublime text.
