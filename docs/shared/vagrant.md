
# vagrant development environment

[Vagrant](http://www.vagrantup.com/) is a totally awesome virtual box automation tool that is excellent for creating distributable repositories with web based packages that need environments with specific tools and services configured.

Using Vagrant you can create a very simple file that can be used to install and configure a virtual machine with just one command.  You can chain into puppet or shell scripts (among many others) to configure the box.  It also mounts the folder that the vagrant file is in as `/vagrant.` in the virtual machine, granting you access to whatever the repository contents are.


## key benefits

Here is a list of key benefits that I can attest to personally:

- Eliminates situations like "Doesn't work on my computer", by enforcing consistent environments
- Allows quick project setup for a distributed system (via repository systems for example)
