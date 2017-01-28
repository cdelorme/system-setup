
# system setup

This repository functions as a home for documentation and automation of system configuration.

Ideally documentation will either mirror or supplement the automated scripts.

Documentation that is modular or independent of a particular configuration will be separated, organized, and referenced.


## platforms

My primary systems are [osx](osx/readme.md) for laptops and [debian (jessie)](linux/debian/jessie.md) for desktops and servers; _as a result my linux automation and documentation have limited support for laptop and wireless tools._

The automation has been written purely to scratch my own itch.  However, I document almost everything I have configured; **for complex configuration check out my [extensive documentation](linux/) for instructions and code snippets.**

For mac optimizations, try this:

	curl -Lo osx.sh "https://raw.githubusercontent.com/cdelorme/system-setup/master/osx.sh" && bash osx.sh

For debian automation, give this a shot:

	wget --no-check-certificate -qO debian-jessie.sh "https://raw.githubusercontent.com/cdelorme/system-setup/master/debian-jessie.sh" && bash debian-jessie.sh

_This script may ask for input, which can be preseeded with environment variables._
