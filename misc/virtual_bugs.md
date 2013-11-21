
# Virtual Bugs

Virtual Machines have their own set of issues, and I will cover those that I have encountered here (and solutions where applicable).

First, since I describe my documentation as templates you can probably guess that I use template machines and clone them.

There are two major concerns with templates:

- snapshots and drive space
- Network Adapters and udev in virtual machines


Snapshots in a virtual environment consume a significant amount of space.  While they are easily the most convenient tools, you may be better served created multiple independent templates.  Systems like Parallels Desktop cannot compress the drives once you have created a snapshot either.


The second problem is the network adapters.  The mac addresses will change when you clone a machine (as they should), and udev may try to automatically identify your devices and map them to names like `eth0` and `eth1`.

While this can be helpful in scenarios where the order in which the adapters are provided may affect the system, more often than not this is not a problem.  To override these settings you can create a new config file in `/lib/udev/rules.d/`, simply by creating a higher number script.

Alternatively you can delete the rules file and replace it with a symlink to `/dev/null`.  However, that is a slightly more "hacky" solution.
