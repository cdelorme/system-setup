
### ssl certificates

SSL allows HTTPS traffic on port 443, and enables content encryption between the server and client.  This is exceptionally beneficial if the site has a login or any administrative features.

There is absolutely no excuse not to have https on your sites today; you can get class 1 certificates for free and class 2 which support wildcard subdomains for as little as $70 every two years and an authentication process.  Configuring nginx for ssl literally takes 5 minutes.  Redirecting to it is 3 lines of configuration as well.


## generating a host key

There are two parts, a signed key, and a host key.  The host can can be re-used, but the signed key is either self-signed or needs to be provided by a service like startssl.

Start by creating a server key:

    openssl genrsa -des3 -out host.key 2048

You will be prompted for a password.  Next we will want to remove the passphrase from this key, so we can load it in nginx without entering a password everytime it restarts:

    openssl rsa -in host.key -out server.key

_You will need to enter the password for this._

We can now use the `host.key` to generate "certificate requests", and `server.key` can be used by nginx as the host key.

Let's create a signed certificate request:

    openssl req -new -key host.key -out example.com.csr

You will be prompted for the password for `host.key`, then a series of identification questions.  This information will likely be required for the request to be considered valid by the third party signee.  **If you need a wildcard certificate you will want to enter `*.example.com` as the common-name.**  Wildcard certificates are "free" through startssl, but you need to pay $60 for full identification and must supply them with two forms of ID.  If you need subdomains, that is the only option.

_This `.csr` file can now be supplied to a company such as startssl for a legitimate signed certificate._


## signed key

After you get the signed key (usually a `.crt` file) you will likely need to append the intermediate certificates to it.

Check the company you went through for documentation, they will likely provide two other files that you need to append to the `.crt` to create a chained certificate.

_While most browsers will accept just the signed `.crt`, certain browsers will not._


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
