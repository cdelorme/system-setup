
# Vagrant Development Environment

[Vagrant](http://www.vagrantup.com/) is a totally awesome virtual box automation tool that is excellent for creating distributable repositories with web based packages that need environments with specific tools and services configured.

Using Vagrant you can create a very simple file that can be used to install and configure a virtual machine with just one command.  You can chain into puppet or shell scripts (among many others) to configure the box, and it mounts the folder that the vagrant file is in to `/vagrant.` in the machine.

This eliminates any situations like "Doesn't work on my computer", by eliminating inconsistencies in the environment.

It also makes it super easy to distribute a project for editing without piling on a set of instructions to setup your machine (and by supplying puppet or bash scripts they can also carry those to a production environment without vagrant).

Any special use cases I have I may document here.
