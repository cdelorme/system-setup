
# bare git repositories

**Creating/Cloning a Bare Repo:**

Usually you will be cloning a work repository, this makes things a bit easier:

    git --bare clone <remote> --shared=group

_The use of `--shared=group` will allow others with access to your vm to commit changes, which makes it possible to share a bare repository with a team on a development server, something worth adding._

If you are creating a brand new repository, you can do so (preferably from the `/srv/git` directory we created) via:

    mkdir project_name.git
    cd project_name.git
    git --bare init --shared=group

Then from your local machine you can clone it, or add it as a remote via:

    git remote add dev username@remote_ip:/srv/git/project_name.git

_Personally, I prefer making the `origin` remote my local dev repo, and creating github or bitbucket remotes._

**Adjusted Workflow:**

With the bare repository in place you can now set a remote origin to push to without having to worry.

Ideally you should rename the internet remotes according to their host (eg. github or bitbucket):

    git remote rename origin internet

Then add the bare repository as origin:

    git remote add origin username@remote_ip:/srv/git/project_name.git

You can now test on a local box by pushing changes there first:

    git push origin

Which should automate via a post-receive hook on that server, and once tested you can easily push and pull to the other remote (usually the public or shared repository):

    git pull internet
    git push internet

**Adding a post-receive hook:**

If you want to perform a specific action when new content has been received, you can do so by creating an executable file at the relative path `.git/hooks/post-receive`.

For example, assuming you serve your site from `/srv/www/` using nginx, you can checkout the latest source via:

    #!/bin/bash
    git --git-dir=/srv/git/site.com.git --work-tree=/srv/www/site.com checkout -f

_Obviously this example does not take into account alternative branches, since you'd need folders for each branch configured as well, but it is possible._

Alternatively you can have the server execute unit and integration tests as part of an entire deployment process.
