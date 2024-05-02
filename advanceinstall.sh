#!/bin/bash

# Function to display messages
function echo_message {
    echo -e "\033[1;32m$1\033[0m"
}

# Function to prompt for user confirmation
function confirm {
    read -r -p "$1 [Y/n]: " response
    if [[ $response =~ ^([nN]|[nN][oO])$ ]]; then
        return 1
    fi
    return 0
}

# Check if user is running as root
if [[ $EUID -ne 0 ]]; then
    echo_message "This script must be run as root."
    exit 1
fi

# Install the Dependencies of the fresh system
echo_message "Installing system dependencies..."
sudo apt update && sudo apt install -y curl wget

# Install PHP
echo_message "Installing PHP..."
sudo apt update && sudo apt install php
sudo apt install php libapache2-mod-php php-common php-gmp php-curl php-soap php-bcmath php-intl php-mbstring php-xmlrpc php-mysql php-gd php-xml php-cli php-zip
echo "PHP version: $(php -v | head -n 1 | cut -d " " -f 2)"

# Install Apache
echo_message "Installing Apache..."
sudo apt install apache2
sudo systemctl start apache2
sudo systemctl enable apache2
sudo systemctl status apache2

# Install Elasticsearch
echo_message "Installing Elasticsearch..."
sudo apt install -y apt-transport-https
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo sh -c 'echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" > /etc/apt/sources.list.d/elastic-7.x.list'
sudo apt update && sudo apt install -y elasticsearch
sudo systemctl start elasticsearch
sudo systemctl enable elasticsearch
sudo systemctl status elasticsearch

# Install MySQL
echo_message "Installing MySQL..."
sudo apt install -y mysql-server
sudo systemctl start mysql-server
sudo systemctl enable mysql-server
sudo systemctl status mysql-server

# Install Composer
echo_message "Installing Composer..."
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === 'e21205b207c3ff031906575712edab6f13eb0b361f2085f1f1237b7126d785e826a450292b6cfd1d64d92e6563bbde02') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"
sudo mv composer.phar /usr/local/bin/composer

# Install NVM
echo_message "Installing Nvm"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
source ~/.bashrc
echo "Nvm list: $(nvm list-remote)"

# Install Node.js and Yarn
echo_message "Installing Node.js and Yarn"
nvm install node16
npm install -g yarn

echo_message "Installation completed!"

# Prompt user for additional steps
if confirm "Do you want to configure and customize the installed components?"; then
  # Add your customization and configuration steps here
  # Configure Apache Virtual Hosts
    echo_message "Configuring Apache Virtual Hosts..."
    sudo mkdir -p /var/www/html/demo_app
    sudo chown -R $USER:$USER /var/www/html
    echo "<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        ServerName demo_app.local
        ServerAlias demo_app.local
        DocumentRoot /var/www/html/demo_app
        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
        <Directory /var/www/html/demo_app>
            Options Indexes FollowSymLinks
            AllowOverride All
            Require all granted
        </Directory>
    </VirtualHost>" | sudo tee /etc/apache2/sites-available/mywebsite.conf
    sudo a2ensite mywebsite.conf
    sudo systemctl reload apache2

    # Create MySQL User and Database
    echo_message "Creating MySQL User and Database..."
    read -p "Enter MySQL root password: " mysql_root_password
    mysql -u root -p$mysql_root_password -e "CREATE DATABASE mydb;"
    mysql -u root -p$mysql_root_password -e "CREATE USER 'myuser'@'localhost' IDENTIFIED BY 'mypassword';"
    mysql -u root -p$mysql_root_password -e "GRANT ALL PRIVILEGES ON mydb.* TO 'myuser'@'localhost';"
    mysql -u root -p$mysql_root_password -e "FLUSH PRIVILEGES;"
    
    # Example: Configure Apache virtual hosts, MySQL users/databases, etc.
fi
