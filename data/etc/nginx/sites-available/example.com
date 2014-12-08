# redirect to https (SECURITY)
server {
    listen 80 default;
    server_name www.example.com example.com;
    return 301 https://www.example.com$request_uri;
}

# redirect to www prefix (SEO)
server {
    listen 443;
    server_name www.example.com example.com example.com;
    return 301 https://www.example.com$request_uri;
}

# HTTPS config
server {
    listen 443 default ssl;

    ssl_certificate ssl/example.com.crt;
    ssl_certificate_key ssl/server.key;

    server_name www.example.com;
    access_log /srv/www/example.com/logs/access.log;
    error_log /srv/www/example.com/logs/error.log;

    root /srv/www/example.com/public;
    index index.html;
    rewrite_log on;

    # generic configuration
    #include scripts.d/*.conf;
}
