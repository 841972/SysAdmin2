#!/bin/bash

# Check if the command-line argument is provided
if [ $# -eq 0 ]; then
    echo "Mete un parametro manin"
    exit 1
fi

# Get the number of MB from the command-line argument
num_mb=$1

# Initialize the counter for directories removed
num_directories_removed=0

# Iterate through the directories in the current directory
for dir in $(ls -a); do
    # If it is a hidden directory, delete it
    if [[ $dir == .* ]]; then
        # Remove the hidden directory
        rm -rf "$dir"
        echo "Removed hidden directory: $dir"
        num_directories_removed=$((num_directories_removed + 1))
    else
        # Check if the directory is a directory and not a file
        if [ -d "$dir" ]; then
            # Get the size of the directory in MB
            dir_size=$(du -ms "$dir" | awk '{print $1}')
            # Check if the directory size is greater than the specified number of MB
            if [ $dir_size -gt $num_mb ]; then
                # Remove the directory and its contents
                rm -rf "$dir"
                echo "Removed directory: $dir"
                num_directories_removed=$((num_directories_removed + 1))
            fi
        fi
    fi
done
# Count the number of directories removed
echo "Total directories removed: $num_directories_removed"
