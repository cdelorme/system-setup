
# msmtp

I generally despise mail servers; they are never easy to configure and setup and are usually only useful for very specific situations like automated emails.  Fortunately most modern services can utilize other tools and this step is almost entirely unnecessary.

However if you need a mail service, then msmtp is likely your best option.  Here is how to install it:

    aptitude install -ryq msmtp-mta

To configure it, create a file at [`/etc/msmtprc`](../data/etc/msmtprc), and replace the usernames.  To secure it make sure this file has `0600` permissions, since it will store passwords in plain text.

_You can create multiple accounts and are not limited to just one, this allows you to change sender data accordingly._

By default installing msmtp will add a symlink to `/usr/sbin/sendmail` for the local mail protocol, meaning you should not need to change anything else.


# references

- [msmtp configuration](http://www.serverwatch.com/tutorials/article.php/3923871/Using-msmtp-as-a-Lightweight-SMTP-Client.htm)
