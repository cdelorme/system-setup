
# [hipchat](https://www.hipchat.com/)

This is a communication software by atlassian, and is growing in popularity.

It is used by my company and friends so I figured I'd add instructions to installing it.  _These are more specifically for linux, as there are some unlisted dependencies._


## linux config

To install the hipchat software on linux you will need to [add their package repository and key](https://www.hipchat.com/downloads#linux).

To install it on linux you will need between two and three packages not listed by the deb package dependencies.  Some systems will come with these already installed.

- libcanberra-dev
- libcanberra-pulse
- sound-theme-desktop

You may also need to set the configuration settings to application, which is recommended by atlassian developers as they created a much nicer notification interface from their own application than most GUI's have.


##### commands

_Run these to install hipchat plus additional dependencies:_

    echo "deb http://downloads.hipchat.com/linux/apt stable main" > /etc/apt/sources.list.d/atlassian-hipchat.list
    wget -O - https://www.hipchat.com/keys/hipchat-linux.key | apt-key add -
    apt-get update
    apt-get install hipchat
    aptitude install -ryq libcanberra-dev libcanberra-pulse sound-theme-desktop


## references

- [hipchat](https://www.hipchat.com/downloads#linux)
