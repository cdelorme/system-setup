
# system setup

This repository serves dual-purpose as reference documentation storage and automation scripts.

The documentation, and subsequently automation scripts, will be updated as I continue to refine any environment I work in regularly, including but not limited to new software releases and distros.


## history

This repository has a pretty crazy history; as the commits will indicate it flip-flopped between being for scripts to being for documentation and back again.

To maintain automated scripts as well as documenting the steps that led to their creation is time consuming.

I also began experimenting heavily with virtualization, and so I have a large number of documents that were specifically for special test cases.


## [documentation](docs/)

Currently I try to maintain three main configurations of linux, as well as one Windows and one OSX.

I use linux as a server environment, and as a development workstation.  I try to upkeep a set of template instructions that sets the basis for any system I use to go either way, then steps to produce a development or server environment are separated.

Due to the lack of automation tools, there are no Windows scripts.  I may at some point add one to run in git-scm's git-bash on windows, but it will be super lightweight.

While not complete, I do intend to add osx support to the automation scripts in the future, to the extent that it is feasible.

Despite my love of linux, I use an osx laptop primarily for work and development.  At the time of writing this I have had only half as many years experience using osx or linux over windows.

My first real deep dive into linux occurred on the `debian` distro, and it has been preference since.  This is due to a combination of familiarity and experienced instability in other comparable distros.  For a short while I did attempt to upkeep documentation for various other distros, but I have since ceased to do so.

**If you are looking for a great platform that is already configured and do not have any particular preferences I highly recommend [crunchbang](http://crunchbang.org/) as an alternative.**


## [automation](scripts/)

All of my scripts are written in `bash`, and use standard cross-platform tools where able.

I originally had all of my automation code in a single `setup` file, but this became difficult to read and maintain.

I am now using modular scripts for ease of maintenance and individual function reference.  This is both more readable, and more maintainable.

I still offer a `setup` script with interactive prompt for configuration, which will execute a series of modular scripts.

You can run my setup script remotely via:

    bash <(curl -s "https://raw.githubusercontent.com/cdelorme/system-setup/master/setup")

It will ask you for the configuration options as necessary to execute, downloading remote resources as needed.

You can also clone or download the repository and run it locally.  However, it is assumed that you will have a network connection since many steps involve downloading software via the distro package manager...


## [data](data/)

I created a data folder to store any number of configuration files, and special binaries.  Some of the binaries do not belong to me, but are no-longer available for download anywhere on the internet.

The files are organized in a linux-friendly way, such that they can be copied and pasted directly onto a system for installation.
