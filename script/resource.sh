#!/bin/bash
# Get a list of user directories in /home
users=$(ls /home)

# Iterate over each user and retrieve their current and maximum disk quota usage
quota_info=""
for user in $users; do
  # Check if the user exists
  if id -u "$user" >/dev/null 2>&1; then
    # Get the quota information for the user
    quota_output=$(quota -u "$user")
    # Extract the used quota and maximum quota values
    used_quota=$(echo "$quota_output" | awk 'NR==3{print $2}')
    max_quota=$(echo "$quota_output" | awk 'NR==3{print $4}')
    # Append the quota info to the result
    quota_info+="$user:$used_quota:$max_quota,"
  fi
done

# Remove the trailing comma from the quota info
quota_info=${quota_info%,}

# Print the quota information
echo "$quota_info"