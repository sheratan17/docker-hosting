#!/bin/bash
container_names=$(docker ps --format "{{.Names}}")

for container_name in $container_names; do
cpu_usage=$(docker stats --no-stream --format "{{.CPUPerc}}" "$container_name" | sed 's/%//')
memory_usage=$(docker stats --no-stream --format "{{.MemUsage}}" "$container_name" | awk -F'/' '{print $1}')
timestamp=$(date +"%Y-%m-%d %H:%M:%S")

input_resource_query="USE data_host; INSERT INTO docker_usage (id, domain, cpu_usage, memory_usage, timestamp) VALUES (NULL, '$container_name', '$cpu_usage', '$memory_usage', '$timestamp')"

mysql --login-path=client -e "$input_resource_query"
done