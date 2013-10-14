
# System Setup

I use virtualization extensively, and one problem I encounter regularly is rebuilding.  To counteract this I have created (somewhat disorganized) comprehensive documentation.

The goal of this repository is to make this documentation globally and publically accessible.

In addition to begin enhancing it by adding fully scripted processes for automated handling in the future.

This will also be used to store non-text files of small size that may be used, including for the automated processes.


### Warning

**The documentation and scripts herein are "made-to-order", which means before using them be sure you read and understand what they are doing, and adjust the configurations to you liking.**

For obvious reasons the scripts and documentation will omit configuration specifics in relation to usernames, service port numbers, and anything else that may be a security concern.

Consult the README files of each section before using.


## Organizational Structure

This repositories contents are structured by the operating system, (optionally) distribution, version, and configuration type and (optional) version.  All files and folders will be lowercased for simplicity, with the exception of the README files.

Operating Systems include "linux", "windows", and "osx".

Distributions are aimed at the "linux" operating systems, such as "debian" and "fedora".

Versions are numeric or named, for example "wheezy", "4.2", "19", "10.8", and "8".

Configuration Type is specific to the intended purpose, for example "template" would be basic setup, "xen" would prepare a xen server.  Some are dependent, for example "xen" requires a "template" system to work off of.

The configuration version is at the moment specific to xen, where releases include 4.2 and 4.3, and the instructions may differ between them as well as to the distribution (hence not directly under linux).

---

Each bottom level folder will contain a README describing the systems intended functions, and any details that may be important for scripted execution.

A documentation file will also exist that explains the manual steps in verbose detail.

Finally, depending on support of the operating system (_OS X and Windows cannot be scripted_) it may contain one or more scripts and configuration files.


### Development

This system is still under development, so any of the scripts, readme files, documentation files, or configuration files are subject to change and by no means functional currently.

Two key objectives at the moment:

1. Top level automation
2. Custom Debian installer


