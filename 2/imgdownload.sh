#!/bin/bash

current_datetime=$(date "+%Y-%m-%d %H:%M:%S")
log_file="log_${current_datetime}.txt"

echo "User: $USER" >> "$log_file"
echo "Date: $current_datetime" >> "$log_file"
echo "Branch: $(git branch --show-current)" >> "$log_file"

# Usage
show_usage() {
    echo "Usage: $0 <img folder name> <user id (one or more)>" >> "$log_file"
    exit 1
}

# Validation
if [ $# -lt 2 ]; then
    echo "Error: Too few arguments." >> "$log_file"
    show_usage
fi

# Error handler
handle_error() {
    echo "Error occurred: $1" >> $log_file
}

users_url="https://reqres.in/api/users/"
img_folder_path=$1
mkdir -p "$img_folder_path"
shift


for user_id in "$@"; do

  user_url="${users_url}${user_id}"
  users_content=$(curl -s "$user_url")

  # check if json data for user id is {} (empty)
  if [[ "$(echo "$users_content" | jq 'length')" -eq 0 ]]; then
    echo "User id: $user_id couldn't be found" >> "$log_file"
    exit 1
  fi

  user_avatar_url=$(echo "$users_content" | jq -r '.data.avatar')
  user_first_name=$(echo "$users_content" | jq -r '.data.first_name')
  user_last_name=$(echo "$users_content" | jq -r '.data.last_name')
  wget -O "${img_folder_path}/${user_id}_${user_first_name}_${user_last_name}.jpg" "$user_avatar_url"
  echo "Image with user id: ${user_id} added to ${img_folder_path}" >> "$log_file"

done
