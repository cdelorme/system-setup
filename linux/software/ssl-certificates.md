
### ssl certificates

SSL allows HTTPS traffic on port 443, and enables content encryption between the server and client.  This is exceptionally beneficial if the site has a login or any administrative features.

There is absolutely no excuse not to have https on your sites today, as ssl certificates can be requested and renewed for free using [letsencrypt](https://letsencrypt.org/) so long as you can prove site ownership.  _A particularly useful web-driven implementation can be found ad [sslforfree.com](https://www.sslforfree.com/)._

Not only is adding ssl to [nginx](../debian/data/extras/etc/nginx/sites-available/example.com) fast and easy, traffic can be redirected with as few as 3 lines as well.

_If you are hosting multiple sites using nginx on a single server, be sure you are using a version of NGINX with the SNI module otherwise conflicts may occur when using multiple SSL certificates (eg. 2 or more secured sites)._


## generating a host key

You generally want to create a host key for creating or requesting certificates.

Start by creating a host key:

    openssl genrsa -des3 -out encrypted-host.key 2048

You will be prompted for a password.  Next we will want to remove the passphrase from this key, so we can load it in nginx without entering a password every time it restarts:

    openssl rsa -in encrypted-host.key -out host.key

_You will need to enter the password for this._  This file is used by nginx and when creating certificate requests.


## generating a signed certificate request

Next you need to supply a signed certificate request.  _Some services can and will generate this for you, which is useful when requesting an ssl certificate with support for multiple domains (eg. "alternative names")._

We can generate a "Signed Certificate Request" or `.csr` using our host key and this command:

    openssl req -new -key host.key -out example.com.csr

_In this example you will be prompted to enter location, company information, and a single FQDN (important when dealing with wildcard certificates or the standard www subdomain._


### certificate bundles

For additional security, many browsers (especially on mobile devices) will require a complete "certificate chain" before treating a site as secure.

The certificate provider will generally supply an "intermediate certificate" with your request, and their own "CA Certificate" that identifies the certificate authority.

To create a bundle that creates a full validation chain the three files must be added to one file in this order:

- the domain's certificate (eg. `.crt`)
- the intermediate certificate
- the certificate authority's certificate

Supply this `bundle.crt` to the web server and you can check with an [ssl validator](https://www.sslshopper.com/ssl-checker.html).


## self signed certificates

While this can be useful for development, it will not allow others to access your site without security warnings.  _Basically, they must explicitly choose to trust your certificate, and that means you can't use it for much else besides local testing._

However, using the host key and certificate request we can generate a self signed certificate like so:

     openssl x509 -req -days 365 -in example.com.csr -signkey host.key -out example.com.crt

We can now use our self-signed `.crt` file for development.


# references

- [nginx SNI allows multiple ssl certificates per ip](https://www.digitalocean.com/community/tutorials/how-to-set-up-multiple-ssl-certificates-on-one-ip-with-nginx-on-ubuntu-12-04)
- [verify your ssl status](https://www.sslshopper.com/ssl-checker.html)
