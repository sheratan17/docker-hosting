server {
  server_name _domain www._domain;
  location / {
    proxy_pass http://_ipprivate_node:_randomminio;

    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header Host $http_host;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "Upgrade";
    proxy_http_version 1.1;
    chunked_transfer_encoding off;

        client_max_body_size 0;
  }

    listen 443 ssl http2; # managed by Certbot
    ssl_certificate /home/_domain/fullchain.pem; # managed by Certbot
    ssl_certificate_key /home/_domain/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot



    add_header Strict-Transport-Security "max-age=31536000" always; # managed by Certbot

}

server {
  server_name s3._domain www.s3._domain;
  location / {
    proxy_pass http://_ipprivate_node:_randommini;

    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header Host $http_host;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "Upgrade";
    proxy_http_version 1.1;
    chunked_transfer_encoding off;

        client_max_body_size 0;
  }

    listen 443 ssl http2; # managed by Certbot
    ssl_certificate /home/_domain/fullchain.pem; # managed by Certbot
    ssl_certificate_key /home/_domain/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot



    add_header Strict-Transport-Security "max-age=31536000" always; # managed by Certbot

}
server {
    if ($host = www._domain) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


    if ($host = _domain) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


  listen 80;
  server_name _domain www._domain;
  location / {
    proxy_pass http://_ipprivate_node:_randomminio;

    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header Host $http_host;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "Upgrade";
    proxy_http_version 1.1;
    chunked_transfer_encoding off;

        client_max_body_size 0;
  }

}

server {
    if ($host = www.s3._domain) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


    if ($host = s3._domain) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


  listen 80;
  server_name s3._domain www.s3._domain;
  location / {
    proxy_pass http://_ipprivate_node:_randommini;

    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header Host $http_host;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "Upgrade";
    proxy_http_version 1.1;
    chunked_transfer_encoding off;

        client_max_body_size 0;
  }

}
