#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <code_root_path> <server_name>"
    exit 1
fi

# Assign arguments to variables
CODE_ROOT_PATH=$1
SERVER_NAME=$2
CONFIG_FILE="/etc/apache2/sites-available/${SERVER_NAME//./_}.conf"

# Create the configuration file with the provided content
cat <<EOL > ${CONFIG_FILE}
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    ServerName ${SERVER_NAME}
    DocumentRoot ${CODE_ROOT_PATH}
    ErrorLog ${CODE_ROOT_PATH}/apache.log
    CustomLog ${CODE_ROOT_PATH}/apache_cust.log combined   

    <Directory ${CODE_ROOT_PATH}>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOL

# Output success message
echo "Configuration file created at ${CONFIG_FILE}"

# Enable the new site and reload Apache
a2ensite ${SERVER_NAME//./_}.conf
systemctl reload apache2

# Add ServerName to /etc/hosts if it doesn't already exist
if ! grep -q "${SERVER_NAME}" /etc/hosts; then
    sudo echo "127.0.0.1    ${SERVER_NAME}" >> /etc/hosts
    echo "${SERVER_NAME} added to /etc/hosts"
fi

# Output success message
echo "Site ${SERVER_NAME} enabled and Apache reloaded"
