#!/bin/bash
domain=$(docker ps --format "{{.Names}}")
disk_quotas=$(repquota -a | tail -n+3)

for domain in $domain; do
cpu_usage=$(docker stats --no-stream --format "{{.CPUPerc}}" "$domain" | sed 's/%//')
memory_usage=$(docker stats --no-stream --format "{{.MemUsage}}" "$domain" | awk -F'/' '{print $1}')
disk_usage=1
timestamp=$(date +"%Y-%m-%d %H:%M:%S")

input_resource_query="USE docker; INSERT INTO resource (domain, cpu_usage, memory_usage, disk_usage, timestamp) VALUES ('$domain', '$cpu_usage', '$memory_usage', 'disk_usage', '$timestamp')"

mysql --login-path=client -e "$input_resource_query"
done