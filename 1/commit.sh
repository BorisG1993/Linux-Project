#!/bin/bash

# Usage
show_usage() {
    echo "Usage: $0 <developer_description>"
    exit 1
}

# Validation
if [ $# -gt 1 ]; then
    echo "Error: Too many arguments."
    show_usage
fi

# Vars
input_file="bugs.csv"
column_name="branch"
search_value=$(git branch --show-current)
dev_description=""
full_description="Auto commit: $(date):   "

# Check for file existence
if [ ! -f "$input_file" ]; then
    echo "File $input_file not found!"
    exit 1
fi

# Get column index by branch name
column_index=$(head -1 "$input_file" | awk -F, -v column="$column_name" '{
    for (i = 1; i <= NF; i++) {
        if ($i == column) {
            print i;
            exit;
        }
    }
}')

# Locate the row by content in the specific column and add to full description
full_description+=$(awk -F, -v col_idx="$column_index" -v search_val="$search_value" '
NR == 1 { next }
$col_idx == search_val { print }
' "$input_file")

# Add dev's description to full description
if [ ! -z "$1" ]; then
    dev_description="$1"
    full_description+="Dev Description: $dev_description"
fi


# Add to git and push to GitHUb 
git add .
git commit -m "$full_description"
git push -u origin "$search_value"

# Exit status to see if push was OK
if [ $? -eq 0 ]; then
    echo "Git push successful."
else
    echo "Git push failed."
    exit 1
fi