
# udev device manager

As a device manager its job is to build the `/dev/` directory and fill it with devices.  However, beyond that it is also intended to simplify and enforce consistency.

So, situations like drive names changing due to the cable they connected from becomes a thing of the past, and you can expect the paths to be relatively stable and **predictable**.

On many systems it is also preconfigured to recognize the network adapters and whether you are running in a virtual environment (_and for some reason it will lock those adapters by name in debian and fedora_).
