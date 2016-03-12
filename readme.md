
# system setup

This repository functions as a home for documentation and automation of system configuration.

Ideally documentation will either mirror or supplement the automated scripts.

Documentation that is modular or independent of a particular configuration will be separated, organized, and referenced.


## platforms

My primary systems are [osx](osx.md) for laptops and [debian](debian-jessie.md) for desktops; _as a result my linux automation and documentation have limited support for laptop and wireless tools._

My configuration was written to scratch my own itch, but has also been in use by various non-technical folks for more than a year now with great success, so I would happily recommend giving it a try to anyone.

If you just got a new mac, try this:

	curl -Lo osx.sh "https://raw.githubusercontent.com/cdelorme/system-setup/master/osx.sh" && bash osx.sh

If you installed a bare-bones debian linux, give this a try:

	wget --no-check-certificate -qO debian-jessie.sh "https://raw.githubusercontent.com/cdelorme/system-setup/master/debian-jessie.sh" && bash debian-jessie.sh

Each script, if safely downloaded, will be run and ask you for input to proceed.  _If you are performing complex automation you can preseed the answers by reviewing the source material._
