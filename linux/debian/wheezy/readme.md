
# wheezy
#### Updated 2013-11-20

This is the current stable debian release, and is the one I am using.  Documentation inside here is intended for use in this release and may not work with other versions, or be at all accurate.

Here is the list of documentation I am actively maintaining:

- [Template](template.md)
- [Web](web.md)
- [Communications](comm.md)
- [GUI](gui.md)
- [Xen](xen-4.3.md)


## Template

Because I use debian so much and for so many things, I have found myself installing the same system hundreds of times over with the same services and basic configuration.

To expedite this process, I decided to document all the steps necessary to make it happen.


## Web

This builds off the template to offer a complete web development environment.

The tools I have chosen for development include nginx, php, and node.  While I do know many other languages they are not my primary "go-to" options for web development.


## Comm

While the title is vague, the intention should be obvious.  The instructions here start from where the template documentation leaves off.

This is intended for use as a communications server, serving files through samba, potentially acting as a torrent server (if I ever find the right tool for the job), and a weechat IRC server.

This allows me to SSH in and keep track of my IRC conversations.

My particular iteration using this config has a 6TB RAID 10 storage built from 4x3TB WD Red drives, supplied using IOMMU in a Xen virtual machine.  It performs amazingly well on the local network.


## GUI

The GUI documenation is how to get a bare-bones gnome3 installation up and running.

It is based off my template instructions.

It's intended use is generally for a desktop or development environment where GUI tools or development are a part of the requirement.


## Xen

I began using [Xen](http://www.xen.org) a little over a year ago, after getting fed up with my windows experience.  Windows server fails entirely to fit its own title, with windows updates pretty much taking it down as regularly as their desktop version, it's a wonder that anyone chooses to use that as their platform for anything.

In any event, I spent almost an entire year figuring out how to get VGA Passthrough working with the new IOMMU technology.  In the process I learned more about linux than I had in over three years of using it previously.

This was both an excellent experience, and after nine months a great success.

Xen is an incredibly powerful tool, but equally complex.  I hope my documentation can ease new users into it, despite not necessarily being "best practice" for business applications.

I have two sections for Xen, my current primary is the 4.3 release.  However if you feel obliged to use an older version, I have [fully documented](http://wiki.xen.org/wiki/Comprehensive_Xen_Debian_Wheezy_PCI_Passthrough_Tutorial) my Xen 4.2 configuration, and have a somewhat more [updated copy here]().  Further I released a [full video walkthrough on youtube](http://www.youtube.com/playlist?list=PLC70DC33D993CEB44).

Use of my 4.2 documentation is at your own risk however, as I have not updated it with any patch-sets since the initial 4.3 release came out.

**My 4.2 documentation is much more new-user friendly, as it was written with that intention in mind, so if you find the 4.3 documentation to be lacking then check the 4.2 as it may be clearer.**
