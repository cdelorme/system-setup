
# wine

One of the best tools for dealing with the limitations of linux when confronted with the desire to run software that is restricted to Windows.

_A very common example is games, but with this tool you can run even most productivity software._


## [compile](../data/desktop/usr/local/bin/install-wine)

While the best option is to compile wine yourself, this often involves far more work than the average user is willing to go through.

To compile a full WOW64 enabled wine installation, you have to compile the source three times, each time with different conflicting dependencies to deal with the 32bit aspect.  _As a result the suggested solution is to use a `chroot`, or a container software (eg. `lxc` or `docker`)._

I borrowed some script information from [this gist](https://gist.github.com/boltronics/9c776d07a97bfe0ac55f48142125910e#file-winebuilder), and [wrote my own alternative](../data/desktop/usr/local/bin/install-wine) with dependency automation.


## alternatives

You can install wine from your package manager, but even as of debian stretch (the current latest stable release) the version is stuck far behind and will lack support for features such as `d3d11` (DirectX11) added in 2.2.

The former best alternative was to install `playonlinux`, however development appears to have ceased and the team has mentioned a new major version release that is in the works but utilizes java.  _I tested this software in its pre-alpha state, and while the interface was much cleaner, the fact that I needed an additional 800mb of java dependencies installed was unappealing._

Another highly recommended piece of software is `lutris`, _however I have seen nothing with regards to wine version management or the interface and it seems to be more of a universal launcher than a wine management tool._


## future

I would love to see some sort of "wine version manager", similar to tools like [`gvm`](https://github.com/moovweb/gvm) and [`nvm`](https://github.com/creationix/nvm) in the future, although without a front-end like `playonlinux` it would still fall short of the average desktop users expectations.  _Given the compilation requirements this is a tall order, but maybe [playonlinux4 wine versions manager source can help](https://github.com/PlayOnLinux/POL-POM-4/blob/master/python/wine_versions.py)._
