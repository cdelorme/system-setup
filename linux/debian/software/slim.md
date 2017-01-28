
# slim

While I prefer to be greeted by a black console login screen, many would much rather have a GUI to login with, or better yet automated login as their selected user.

If that's you, then install the `slim` package, enable it with `systemctl enable slim.service`, and add `default_user` with your username plus `auto_login yes` to `/etc/slim.conf` and you are good to go.
