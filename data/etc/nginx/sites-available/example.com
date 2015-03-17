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

# define alpha api source(s)
upstream alpha-api {
    least_conn;
    server 127.0.0.1:8080;
    keep_alive 300;
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

    # serve alpha api
    location /api/alpha {
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $remote_addr;
        proxy_set_header Host $host;
        proxy_pass http://alpha-api;
    }
}
