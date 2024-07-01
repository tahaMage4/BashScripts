#!/bin/bash

# Function to enable a PHP version for CLI
enable_php_cli() {
    sudo update-alternatives --set php /usr/bin/php"$1"
}

# Function to enable a PHP version for Apache
enable_php_apache() {
    sudo a2dismod php"$2"
    sudo a2enmod php"$1"
    sudo service apache2 restart
}

# Check if the required number of arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <old_php_version> <new_php_version>"
    exit 1
fi

# Validate if the provided PHP versions are installed
if [ ! -x "$(command -v "php$1")" ] || [ ! -x "$(command -v "php$2")" ]; then
    echo "Error: PHP versions $1 or $2 not found."
    exit 1
fi

# Disable the old PHP version and enable the new one for CLI
enable_php_cli "$2"

# Disable the old PHP version and enable the new one for Apache
enable_php_apache "$2" "$1"

echo "PHP version switched from $1 to $2 for CLI and Apache."
