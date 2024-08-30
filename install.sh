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
sudo apt update -y
sudo apt install php
sudo apt install php libapache2-mod-php php-common php-gmp php-curl php-soap php-bcmath php-intl php-mbstring php-xmlrpc php-mysql php-gd php-xml php-cli php-zip
echo "php version": php -v

# Install Apache
echo_message "Installing Apache..."
sudo apt install apache2
sudo systemctl start apache2
sudo systemctl enable apache2
# fist run that
sudo a2enmod rewrite
#sudo systemctl status apache2

# Install Elasticsearch (you might need to adjust the repository URL)
echo_message "Installing Elasticsearch..."
sudo apt install apt-transport-https
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo sh -c 'echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" > /etc/apt/sources.list.d/elastic-7.x.list'
sudo apt update
sudo apt install elasticsearch
sudo systemctl start elasticsearch
sudo systemctl enable elasticsearch
#sudo systemctl status elasticsearch

# Install MySQL
echo_message "Installing MySQL..."
sudo apt install mysql-server
sudo systemctl start mysql-server
sudo systemctl enable mysql-server
mysql --version
#sudo systemctl status mysql-server

#Add the password to mysql
#ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'admin123';

# Install Composer
echo_message "Installing Composer..."
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === 'dac665fdc30fdd8ec78b38b9800061b4150413ff2e3b6f88543c636f7cd84f6db9189d43a81e5503cda447da73c7e5b6') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
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
nvm install 20
npm install -g yarn
npm install -g bun
npm install -g pnpm

# Install Java (OpenJDK)
sudo apt update && sudo apt -y install default-jdk
java -version

#Install Dbeaver
curl -fsSL https://dbeaver.io/debs/dbeaver.gpg.key | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/dbeaver.gpg
echo "deb https://dbeaver.io/debs/dbeaver-ce /" | sudo tee /etc/apt/sources.list.d/dbeaver.list
sudo apt update && sudo apt install dbeaver-ce
sudo apt policy dbeaver-ce

sudo apt install git
#git config --global credential.helper store
#git config core.fileMode false

# jenkins inatall
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
    https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
    https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
    /etc/apt/sources.list.d/jenkins.list >/dev/null
sudo apt-get update
sudo apt-get install jenkins -y
sudo systemctl start jenkins
#sudo systemctl status jenkins

#minize
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize'

# for ubantu 20  (php issue solve)
sudo add-apt-repository ppa:ondrej/php && sudo apt update -y

echo_message "Installation completed!"

#https://www.omgubuntu.co.uk/2020/06/how-to-enable-wobbly-windows-effect-on-ubuntu-20-04-lts
