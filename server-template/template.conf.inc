server {
	listen      80;
	server_name _domain www._domain;
	
	location / {
	proxy_pass http://_ipprivate_node:_random80/;
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
	
	client_max_body_size 100M;
	}
}

server {
        listen      80;
        server_name file._domain www.file._domain;

        location / {
        proxy_pass http://_ipprivate_node:_random81/;
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
		
		client_max_body_size 100M;
        }
}

server {
        listen      80;
        server_name pma._domain www.pma._domain;

        location / {
        proxy_pass http://_ipprivate_node:_random82/;
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
		
		client_max_body_size 100M;
        }
}

