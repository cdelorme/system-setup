
# system setup

This repository serves a dual-purpose as a home for automated configuration and reference documentation.

The documentation will, usually, mirror the automation scripts, and will supplement them where automation cannot complete the process.  Documentation will be modular, while the scripted installation is intended to be simply one script.


## history & purpose

This repository originated for automation, but has flopped back and forth between documentation and which to prioritize.  In previous iterations it also covered the same steps across multiple distributions, and more coverage for special cases, such as [xen](http://www.xen.org).

As a repository the history may be very useful, but the intended purpose today is to keep up to date with my preferred environments and configurations only.


### documentation

As of todays iteration, I only maintain documentation for [osx](osx.md) and [debian linux](debian.md).  Each contains a list of referenced steps in the order you should execute them.  **Steps not covered by the automation will be highlighted as follow-up steps that require manual intervention.**

My configuration is written to scratch my own itch, and may not suit all-needs.  The automation is purely for debian linux, and while written to my own needs it does prepare an optimal "initial state" that should work fine for all-purpose system configuration.

Referenced documentation is broken down by categories, such as:

- [virtualization](virtualization/)
- [software](software/)
- [gaming](gaming/)

Where applicable, documentation on services that exist cross platform will be covered in a single "shared" document.  While the automation is written for debian specifically, it is possible to translate most steps into other distributions.


### [automation](setup)

The automation script is written in bash, and is intended to work on any debian system installed with only "system utilities".  It will use the best available tools during all steps in under 450 lines of bash (800~ including comments and spacing).

The setup script is explicitly for [debian jessie](https://wiki.debian.org/DebianJessie), the current stable release (at time of writing), and provides a myriad of input options to decide what _additional_ software is expected to be installed.

A brief summary of options include user creation, ssh keys creation, upload, and trust, obscuring the ssh port, setting or changing the hostname and domainname, installing a variety of independent communication tools, installing web services such as nginx, mongodb, postgresql, and an smtp mail forwarding server, options for iptable public accessibility of services, workstation services, development services, and graphical desktop environment and services specifically tailored to the openbox window manager.

**For details on services, I highly recommend viewing the source!**


#### usage

To use the automation script, you can use a subshell:

    bash <(wget --no-check-certificate -qO- "https://raw.githubusercontent.com/cdelorme/system-setup/master/setup")

Then answer the questions as it runs.

_Alternatives include downloading or cloning the repository, but those may require additional tools to be installed beyond a post-install state._


#### [data](data/)

The data folder contains **debian linux** configuration files, with the correct permissions to be copied and pasted as an installation process.  These will evolve alongside my automated configuration script.

_Some of the included files are binaries that do not belong to me, but are no-longer available for download on the internet due to missing or aging websites._
