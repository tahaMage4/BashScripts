#!/bin/bash

# Function to display messages
function echo_message {
    echo -e "\033[1;32m$1\033[0m"
}

#Install the Dependiences of the fresh system
sudo apt install curl 
sudo apt install wget

# Install PHP
echo_message "Installing PHP..."
sudo apt update
sudo apt install php
sudo apt install php libapache2-mod-php php-common php-gmp php-curl php-soap php-bcmath php-intl php-mbstring php-xmlrpc php-mysql php-gd php-xml php-cli php-zip
echo "php version": php -v

# Install Apache
echo_message "Installing Apache..."
sudo apt install apache2
sudo systemctl start apache2
sudo systemctl status apache2

# Install Elasticsearch (you might need to adjust the repository URL)
echo_message "Installing Elasticsearch..."
sudo apt install apt-transport-https
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo sh -c 'echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" > /etc/apt/sources.list.d/elastic-7.x.list'
sudo apt update
sudo apt install elasticsearch
sudo systemctl start elasticsearch
sudo systemctl enable elasticsearch
sudo systemctl status elasticsearch

# Install MySQL
echo_message "Installing MySQL..."
sudo apt install mysql-server
sudo systemctl start mysql-server
sudo systemctl status mysql-server

# Install Composer
echo_message "Installing Composer..."
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === 'e21205b207c3ff031906575712edab6f13eb0b361f2085f1f1237b7126d785e826a450292b6cfd1d64d92e6563bbde02') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"
sudo mv composer.phar /usr/local/bin/composer

#Install NVM
echo_message "Installing Nvm" 
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
source ~/.bashrc
echo "Nvm list": nvm list-remote

# Install Node.js and Yarn
echo_message "Installing Node.js and Yarn"
nvm install node16
npm install -g yarn

echo_message "Installation completed!"
