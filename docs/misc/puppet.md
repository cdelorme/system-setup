
# puppet

[Puppet](http://puppetlabs.com/) is an automated provisioning system that is used to define the "state" of an operating system.

It is a preferred tool among the IT community to automate system configuration.

However, I dislike it.  So far from scripting with it for a month, I have found that its only real benefits are good logging and an attempt to ensure execution.

Through my tests I have found that it fails just like any other method, and its logging is overly verbose because of the amount of configuration that needs to be typed to execute basic operations.

My biggest concerns are that the proposed abstraction it offers between operating systems barely extends past specific API's, such as which package manager to use for installation.

In my honest opinion, a shell script can be written to perform the same task with half as many lines, and I will continue to use that as my de-facto solution for personal projects.

---

The fact that some programmers cannot read bash scripts is a concern for the linux community, as it is the default shell they spend their time in whenever working on a linux or unix system (including OSX).

Further, unlike puppet which requires an entire stack plus extending application API's for abstracted features, shell scripts can be downloaded and executed stand-alone without any extra tools installed besides what comes with the system.
