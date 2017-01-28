
# snapshots

Most virtualization software allows you to create snapshots, and often clones are based on snapshot states.

These are an **excellent** way to reset to a state prior to corruption, viruses, and other issues, as they are a snapshot of disk state above the OS itself, which makes them much safer.


## disk space

Keep in mind that snapshots will dramatically increase the size consumed by your virtual machine, and often times is unable to be used in conjunction with compression features.
