#!/bin/bash

# Define the prefix
prefix="mage4_"

# Function to add prefix
add_prefix() {
    # Find all CSS, JS, HTML, and JSX files in the current directory and its subdirectories
    files=$(find . -type f \( -name "*.css" -o -name "*.js" -o -name "*.html" -o -name "*.jsx" \))

    # Loop through each file
    for file in $files; do
        # Use sed to replace class names with prefixed ones
        sed -i "s/\.\([a-zA-Z0-9_-]*\)/\.$prefix\1/g" "$file"
    done

    echo "Prefix added successfully to class names in CSS, JS, HTML, and JSX files."
}

# Function to remove prefix
remove_prefix() {
    # Find all CSS, JS, HTML, and JSX files in the current directory and its subdirectories
    files=$(find . -type f \( -name "*.css" -o -name "*.js" -o -name "*.html" -o -name "*.jsx" \))

    # Loop through each file
    for file in $files; do
        # Use sed to remove the prefix from class names
        sed -i "s/\.$prefix\([a-zA-Z0-9_-]*\)/\1/g" "$file"
    done

    echo "Prefix removed successfully from class names in CSS, JS, HTML, and JSX files."
}

# Ask the user whether they want to add or remove the prefix
read -p "Do you want to add or remove the prefix? (add/remove): " choice

case $choice in
add)
    add_prefix
    ;;
remove)
    remove_prefix
    ;;
*)
    echo "Invalid choice. Please choose 'add' or 'remove'."
    ;;
esac
