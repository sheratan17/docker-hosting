server {
	server_name _domain  www._domain ;
	
	location / {
	proxy_pass http://10.89.1.2:_random80/;
	proxy_http_version                 1.1;
	proxy_cache_bypass                 $http_upgrade;

	# Proxy headers
	proxy_set_header Upgrade           $http_upgrade;
	proxy_set_header Connection        "upgrade";
	proxy_set_header Host              $host;
	proxy_set_header X-Real-IP         $remote_addr;
	proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
	proxy_set_header X-Forwarded-Proto $scheme;
	proxy_set_header X-Forwarded-Host  $host;
	proxy_set_header X-Forwarded-Port  $server_port;

	# Proxy timeouts
	proxy_connect_timeout              60s;
	proxy_send_timeout                 60s;
	proxy_read_timeout                 60s;
	}

    listen 443 ssl http2; # managed by Certbot
    ssl_certificate /home/_domain/_domain.crt; 
    ssl_certificate_key /home/_domain/_domain.key; 
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot



    add_header Strict-Transport-Security "max-age=31536000" always; # managed by Certbot


    #ssl_trusted_certificate /etc/letsencrypt/live/_domain -0001/chain.pem; # managed by Certbot
    #ssl_stapling on; # managed by Certbot
    #ssl_stapling_verify on; # managed by Certbot



}

server {
        server_name file._domain  www.file._domain ;

        location / {
        proxy_pass http://10.89.1.2:_random81/;
        proxy_http_version                 1.1;
        proxy_cache_bypass                 $http_upgrade;

        # Proxy headers
        proxy_set_header Upgrade           $http_upgrade;
        proxy_set_header Connection        "upgrade";
        proxy_set_header Host              $host;
        proxy_set_header X-Real-IP         $remote_addr;
        proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host  $host;
        proxy_set_header X-Forwarded-Port  $server_port;

        # Proxy timeouts
        proxy_connect_timeout              60s;
        proxy_send_timeout                 60s;
        proxy_read_timeout                 60s;
        }

    listen 443 ssl http2; # managed by Certbot
    ssl_certificate /home/_domain/_domain.crt;
    ssl_certificate_key /home/_domain/_domain.key;
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;



    add_header Strict-Transport-Security "max-age=31536000" always; # managed by Certbot


    #ssl_trusted_certificate /etc/letsencrypt/live/_domain -0001/chain.pem; # managed by Certbot
    #ssl_stapling on; # managed by Certbot
    #ssl_stapling_verify on; # managed by Certbot



}

server {
        server_name pma._domain  www.pma._domain ;

        location / {
        proxy_pass http://10.89.1.2:_random82/;
        proxy_http_version                 1.1;
        proxy_cache_bypass                 $http_upgrade;

        # Proxy headers
        proxy_set_header Upgrade           $http_upgrade;
        proxy_set_header Connection        "upgrade";
        proxy_set_header Host              $host;
        proxy_set_header X-Real-IP         $remote_addr;
        proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host  $host;
        proxy_set_header X-Forwarded-Port  $server_port;

        # Proxy timeouts
        proxy_connect_timeout              60s;
        proxy_send_timeout                 60s;
        proxy_read_timeout                 60s;
        }

    listen 443 ssl http2; # managed by Certbot
    ssl_certificate /home/_domain/_domain.crt;
    ssl_certificate_key /home/_domain/_domain.key;
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;


    add_header Strict-Transport-Security "max-age=31536000" always; # managed by Certbot


    #ssl_trusted_certificate /etc/letsencrypt/live/_domain -0001/chain.pem; # managed by Certbot
    #ssl_stapling on; # managed by Certbot
    #ssl_stapling_verify on; # managed by Certbot

}

server {
    if ($host = www._domain ) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


    if ($host = _domain ) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


	listen      80;
	server_name _domain  www._domain ;
	
	location / {
	proxy_pass http://10.89.1.2:_random80/;
	proxy_http_version                 1.1;
	proxy_cache_bypass                 $http_upgrade;

	# Proxy headers
	proxy_set_header Upgrade           $http_upgrade;
	proxy_set_header Connection        "upgrade";
	proxy_set_header Host              $host;
	proxy_set_header X-Real-IP         $remote_addr;
	proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
	proxy_set_header X-Forwarded-Proto $scheme;
	proxy_set_header X-Forwarded-Host  $host;
	proxy_set_header X-Forwarded-Port  $server_port;

	# Proxy timeouts
	proxy_connect_timeout              60s;
	proxy_send_timeout                 60s;
	proxy_read_timeout                 60s;
	}







}

server {
    if ($host = www.file._domain ) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


    if ($host = file._domain ) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


        listen      80;
        server_name file._domain  www.file._domain ;

        location / {
        proxy_pass http://10.89.1.2:_random81/;
        proxy_http_version                 1.1;
        proxy_cache_bypass                 $http_upgrade;

        # Proxy headers
        proxy_set_header Upgrade           $http_upgrade;
        proxy_set_header Connection        "upgrade";
        proxy_set_header Host              $host;
        proxy_set_header X-Real-IP         $remote_addr;
        proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host  $host;
        proxy_set_header X-Forwarded-Port  $server_port;

        # Proxy timeouts
        proxy_connect_timeout              60s;
        proxy_send_timeout                 60s;
        proxy_read_timeout                 60s;
        }







}

server {
    if ($host = pma._domain ) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


        listen      80;
        server_name pma._domain  www.pma._domain ;

        location / {
        proxy_pass http://10.89.1.2:_random82/;
        proxy_http_version                 1.1;
        proxy_cache_bypass                 $http_upgrade;

        # Proxy headers
        proxy_set_header Upgrade           $http_upgrade;
        proxy_set_header Connection        "upgrade";
        proxy_set_header Host              $host;
        proxy_set_header X-Real-IP         $remote_addr;
        proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host  $host;
        proxy_set_header X-Forwarded-Port  $server_port;

        # Proxy timeouts
        proxy_connect_timeout              60s;
        proxy_send_timeout                 60s;
        proxy_read_timeout                 60s;
        }




}
