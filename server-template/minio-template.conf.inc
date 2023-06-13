server {
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
  listen 9090;
  server_name _domain www._domain;
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