
# system setup

This repository was created as a personal reference to track optimal configurations over time.

It changes both with my own knowledge on how to improve my environment, as well as with any major changes and new releases of operating systems and utilities.

The documentation is to be extended into automated scripts where applicable.


## history

This repository has a crazy history, so following the changes may be very difficult.  Initially it was created to store automated scripts, but then expanded to cover a wider range of system configuration, and include documentation.

At some point the automated scripts were difficult to keep up with so the contents shifted purely to documentation.

The documentation included a wide variety of experiments and setups, and is in the process of shifting back over to a mixture of automation and more concise documentation.

Most of my linux experience stems from extensive [virtualization](docs/virtualization/readme.md), where I have run many tests and applied my documentation thousands of times over.


## usage

The documentation is for your viewing pleasure, the setup script is a WIP but can be downloaded and executed stand-alone.

To execute the supplied setup script, simply supply a matching environment as an argument.  For example:

    ./setup dev

_My setup code was written for debian, and should work on most systems based on debian._  Operations for OSX will be added eventually.


## notes

Despite my love of linux, I use a mac laptop primarily for work and development.  I also have more than 15 years of experience on Windows, and only half that in Mac or Linux.

However, I began using linux with the `debian` distro, and been using it for significantly longer than any other linux distro.  I have used `ubuntu`, `mint`, `fedora`, `centos`, `redhat`, `crunchbang`, `arch`, and `gentoo` distros (I have spent at least one month in each).  Attempting to upkeep documentation for all of those platforms is too difficult, so I write my scripts biased for debian.

**If you are looking for a great platform that is already configured and do not have any particular preferences I highly recommend [crunchbang](http://crunchbang.org/) as an alternative.**  My configuration borrows heavily from the simplicity of crunchbang, with a variety of alternative software as a matter of personal preference.

Not for lack of trying, but I have yet to resolve the Windows itch; there are no solutions for gamers to enjoy most games without it.  As a result I still use it, and document it's configuration, but automation on Windows is pretty much non-existent.
