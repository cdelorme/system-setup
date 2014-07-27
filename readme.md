
# System Setup
#### Updated 2014-7-27

The documentation herein is a personal project to help track and reference the best configuration over time.

Ideally the documentation applies to many systems, and many different types of configurations.

Automation will be involved.


## history

This repository has a crazy history.  Originally it was intended to be entirely the automation of systems I had configured.

In spite of tools like chef, ansible, puppet, salt, etc... I have found few utilities are actually simpler than bash scripts, which is what all of those eventually translate to.  While they do provide many added benefits, such as prebuilt facilitation of error handling, and deep abstraction libraries, these tend to run slower and are less flexible that I would have preferred.

Instead of learning yet another language for deployment scripting, I chose to stick with simple bash.  There have been several benefits to this, including refining my own knowledge of bash, and system specific configuration.

Granted, the downsides were complexity and required knowledge.  As a result of these downsides for quite a while the repository turned into almost entirely documentation.

This was great however, as I found documentation to be more useful than scripts in many cases.

As of the most recent release, automation has once again re-emerged; this time bearing all the fruits of my tedious documentation and experiences.


## current state

I love virtualization.  I used it almost exclusively via [xen](http://www.xen.org) for nearly two years.  It provides a means of testing and solving problems short-term without leaving permanent damage.

Learning how to utilize virtual machines in every aspect has greatly enhanced my linux `foo`.

However, it came with its own set of problems, and enables a person to do terrible things they would normally never do otherwise.  I have reinstalled systems thousands of times, often using very similar configurations.

At this point, the documentation helps serve as a reminder to how I got to where I was, and is tweaked as I find issues in the previous state of the systems.

The result is very detailed documentation, and subsequently automated bash scripts to produce said system state.


## instructions

For the setup script included in the root folder, you will want to open and modify the top section.  It contains many configuration settings, and you would be better served by reading them there.

If running on osx then `./setup osx` should begin the osx configuration process.

For a linux platform (_currently only debian is supported_), you would run `./setup name`, where `name` is one of the many standard types of configurations I have documentated (template, comm, gui, web, dev).  Further options may be available in the future (eg. `all` = template+comm+gui, `all-dev` = template+comm+gui + dev packages).

**It is not quite in a completed state yet, many options are missing or incomplete.**  As of current, it can setup a template and comm server, but it's gui is incomplete, and it always includes developer packages by default (which may not be preferred in some cases).


## notes

Despite my love of linux, I use a mac laptop primarily for work and development.  I also have more than 15 years of experience on Windows, and only half that in Mac or Linux.

However, I began using linux with the `debian` distro, and been using it for significantly longer than any other linux distro.  As of current I have used `ubuntu`, `mint`, `fedora`, `centos`, `redhat`, `crunchbang`, `arch`, and `gentoo` distros (at least one month in each, often significantly more).

I have tried to produce documentation to match the other distros, but for the most part I don't use them often enough to do so accurately.  **Therefore the documentation and scripts provided are predominantly debian, and are heavily biased towards that distro.**

**If you are looking for a great platform that is already configured and do not have any particular preferences I highly recommend [crunchbang](http://crunchbang.org/) as an alternative.**

My configuration borrows heavily from the simplistic openbox configuration idea, with a variety of alternative software as a matter of personal preference.

Not for lack of trying, but I have yet to resolve the Windows itch; there are no solutions for gamers to enjoy most games without it.  As a result I still use it, and document it's configuration, but automation on Windows is pretty much non-existent.


#### all documentation is free and all scripts are GPLv3, to be shared
