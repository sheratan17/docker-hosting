#!/bin/bash
domain=$(docker ps --format "{{.Names}}")

for domain in $domain; do
if [[ "$domain" != *_pma* && "$domain" != *_filebrowser* ]]; then
cpu_usage=$(docker stats --no-stream --format "{{.CPUPerc}}" "$domain" | sed 's/%//')
memory_usage=$(docker stats --no-stream --format "{{.MemUsage}}" "$domain" | awk -F'MiB /' '{print $1}')
timestamp=$(date +"%Y-%m-%d %H:%M:%S")

input_resource_query="USE docker; INSERT INTO resource (domain, cpu_usage, memory_usage, timestamp) VALUES ('$domain', '$cpu_usage', '$memory_usage', '$timestamp')"

mysql --login-path=client -e "$input_resource_query"
fi
done

disk_quotas=$(repquota -a | tail -n+3)

# Loop through each line of disk quotas and insert into the database
while IFS= read -r line; do
  domain=$(echo "$line" | awk '{print $1}')
  disk_usage=$(echo "$line" | awk '{print $3}')
  disk_usage_mb=$((disk_usage / 1024))
  timestamp2=$(date +"%Y-%m-%d %H:%M:%S")

  # Exclude unwanted lines
  if [[ "$domain" != "root" && ! $domain =~ ^(Block|User|-+)$ ]]; then
    query="USE docker; INSERT INTO disk (domain, disk_usage, timestamp) VALUES ('$domain', $disk_usage_mb, '$timestamp2');"
    mysql --login-path=client -e "$query"
  fi
done <<< "$disk_quotas"