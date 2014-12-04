
# msmtp

I generally despise mail servers; they are never easy to configure and setup and are usually only useful for very specific situations like automated emails.  Fortunately most modern services can utilize other tools and this step is almost entirely unnecessary.

However if you need a mail service, then msmtp is likely your best option.  Here is how to install it:

    aptitude install -ryq msmtp-mta

Now we want to create a file at `/etc/msmtprc`, and add configuration data similar to:

    # Set default values for all following accounts.
    defaults
    tls on
    tls_trust_file /etc/ssl/certs/ca-certificates.crt

    # Default Account
    account gmail
    host smtp.gmail.com
    port 587
    auth on
    user username
    password password
    from username@gmail.com

    # Set a default account
    account default : gmail

Since this file will need to contain a plain-text password you will want to secure it by adjusting permissions:

    chmod 0600 /etc/msmtprc

_You can create multiple accounts and are not limited to just one, this allows you to change sender data accordingly._

By default installing msmtp will add a symlink to `/usr/sbin/sendmail` for the local mail protocol, meaning you should not need to change anything else.  However, you can also symlink `/usr/sbin/msmtp` to `/usr/bin/msmtp` if you want to be able to access it on normal user accounts.


# references

- [msmtp configuration](http://www.serverwatch.com/tutorials/article.php/3923871/Using-msmtp-as-a-Lightweight-SMTP-Client.htm)
