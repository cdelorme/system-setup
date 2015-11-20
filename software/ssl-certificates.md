
### ssl certificates

SSL allows HTTPS traffic on port 443, and enables content encryption between the server and client.  This is exceptionally beneficial if the site has a login or any administrative features.

There is absolutely no excuse not to have https on your sites today; you can get class 1 certificates for free and class 2 which support wildcard subdomains for as little as $70 every two years and an authentication process.  Configuring nginx for ssl literally takes 5 minutes.  Redirecting to it is 3 lines of configuration as well.

If you are hosting multiple sites using nginx on a single server, be sure you are using a version of NGINX with the SNI module otherwise conflicts may occur when using multiple SSL certificates (eg. 2 or more secured sites).


## generating a host key

There are two parts, a signed key, and a host key.  The host can can be re-used, but the signed key is either self-signed or needs to be provided by a service like startssl.

Start by creating a server key:

    openssl genrsa -des3 -out host.key 2048

You will be prompted for a password.  Next we will want to remove the passphrase from this key, so we can load it in nginx without entering a password everytime it restarts:

    openssl rsa -in host.key -out server.key

_You will need to enter the password for this._

We can now use the `host.key` to generate "certificate requests", and `server.key` can be used by nginx as the host key.


## generating a signed certificate request

We can generate a "Signed Certificate Request" or `.csr` using our host key and this command:

    openssl req -new -key host.key -out example.com.csr

You will be prompted to enter location and company information, and **most importantly** you will be asked for the FQDN!

**If you have wildcard support be sure to enter `*.domain.com`, otherwise, you should pick a valid or common subdomain, such as `www.domain.com`.  Omitting the prefix may lead to only `domain.com` being valid.**

_This `.csr` file can now be supplied to a company such as startssl for a legitimate signed certificate._


### wildcard certificates

It is possible to get free single-level wildcard certificates.  Through StartSSL you will need to file "Personal Identify Validation" (or a corporate identity validation), which requires photocopied id's be submitted and a charge of $60 _to be manually processed by a human being_.

**Afterwards, you get the ability to issue wildcard certificates for up to 2 years.**


## using a signed certificate request

Most certificate providers will ask you for a `.csr`, _or offer to generate one on your behalf._

For example, if you are using StartSSL you will be allowed to skip and paste the contents of your own `.csr` into a form.  It will ask for the subdomain and domain it applies to, then confirm the valid domains supported by that certificate.

**This is important, because if you forgot to add `www.` to the signed certificate request you may only see the raw domain supported by the certificate they will generate.**

After confirming, you will be given a certificate file or `.crt` for your domain.

You will also be given two more files; an "intermediate certificate" and "ca certificate" ("certificate authority"'s certificate).  **You will need all three to create a certificate chain.**


### certificate chains

While the `.crt` file alone may be valid, but some browsers require a complete "certificate chain" (aka bundle file) for security.

The certificate chain is the combination of the three files from the last step in the following order:

- new new domain's `.crt`
- the intermediate certificate
- the certificate authority's certificate

Now you supply the bundle `.crt` file to your web server.

If you wish to verify that the chain is valid, you can use an [ssl validator](https://www.sslshopper.com/ssl-checker.html).


## self signed certificates

This is an alternative, useful for testing but even then it can be a hassle.  An unsigned key will result in your web browser complaining every attempt to load it, and if you do not add the certificate to your local system as trusted it'll prevent you from making much use of it

However, in the event that you do need one temporarily, here is how to create it!

Using the passwordless server key, and the certificate request from the previous steps, we can generate a self-signed certificate.

Taking the host key we generated previously, we will feed it to a request for generating a self-signed certificate:

     openssl x509 -req -days 365 -in example.com.csr -signkey server.key -out example.com.crt

We can now use our self-signed `.crt` file for development.


# references

- [ssl certificates can be acquired for free](https://www.startssl.com/)
- [nginx SNI allows multiple ssl certificates per ip](https://www.digitalocean.com/community/tutorials/how-to-set-up-multiple-ssl-certificates-on-one-ip-with-nginx-on-ubuntu-12-04)
- [startssl intermediate chain](https://www.startssl.com/?app=42)
- [verify your ssl status](https://www.sslshopper.com/ssl-checker.html)
