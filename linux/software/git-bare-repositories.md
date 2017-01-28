
# git bare repositories

In my case I have sometimes wanted to use my own server to store a copy of my projects and act as an intermediary to pushing changes out.  Using a bare repository and post-receive hooks this is not only possible but super useful when you need a locally deployed development copy of your project in a shared environment.


## creating a clone

In my case I start by cloning a remote repository as a bare repository, and set group sharing to alleviate permissions for multiple contributors:

    git clone --bare --shared <remote>


## creating fresh

If you happen to be starting your own project then you can create one instead like this:

    mkdir project_name.git
    cd project_name.git
    git init --bare --shared


## connecting to a bare repository

To connect your local repository to the new remote, you just need to supply your username, the address, and the path like so:

    git remote add dev username@remote_ip:/srv/git/project_name.git

This of course depends on your having access to the remote, which also makes it inherently secure!

It is also a matter of preference, but if you set the remote to `origin`, you can easily chain from there to another public remote (eg. github/bitbucket/gitorous etc) using a post-receive hook.


### renaming remotes

You can easily rename your remotes, such as to keep the current `origin`:

    git remote rename origin github
    git remote rename dev origin


## the power of post-receive hooks

You'll find that your bare repository has a `hooks/` directory, and you can create a `post-receive` shell script which will execute anytime a change has been pushed to that copy.

For example, if you had a `/srv/git/site.com.git` bare repository, then the `/srv/git/site.com.git/hooks/post-receve` file might look like this:

    #!/bin/bash
    git --git-dir=/srv/git/site.com.git --work-tree=/srv/www/site.com checkout -f

Anytime changes are pushed to that repository, a fresh copy of just the source code is placed into `/srv/www/site.com`.  In the event that the code was a compiled project you can begin a build process.  If the file changes require a service to be restarted, that could also be executed from this script.

_There is a bit more work to detecting the branch in the post-receive hook, but as you can imagine that is also quite valuable._
