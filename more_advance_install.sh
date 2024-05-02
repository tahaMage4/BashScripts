#!/bin/bash

# Function to install Apache2
install_apache() {
    sudo apt update
    sudo apt install apache2 -y
    sudo systemctl start apache2
    sudo systemctl enable apache2
}

# Function to install ElasticSearch
install_elasticsearch() {
    wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
    sudo apt-get install apt-transport-https
    echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
    sudo apt update
    sudo apt install elasticsearch -y
    sudo systemctl start elasticsearch
    sudo systemctl enable elasticsearch
}

# Function to install PHP
install_php() {
    sudo apt update
    sudo apt install php libapache2-mod-php php-mysql -y
}

# Function to install Node.js via NVM
install_node() {
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
    source ~/.bashrc
    nvm install node
}

# Function to install Nginx
install_nginx() {
    sudo apt update
    sudo apt install nginx -y
    sudo systemctl start nginx
    sudo systemctl enable nginx
}

# Function to install Docker
install_docker() {
    sudo apt update
    sudo apt install docker.io -y
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker $USER
}

# Function to install Jenkins
install_jenkins() {
    wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
    sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
    sudo apt update
    sudo apt install jenkins -y
    sudo systemctl start jenkins
    sudo systemctl enable jenkins
}

# Function to install SonarQube
install_sonarqube() {
    sudo apt update
    sudo apt install openjdk-11-jdk -y
    sudo systemctl start sonarqube
    sudo systemctl enable sonarqube
}

# Ask user for additional installations
read -p "Do you want to install additional components? (yes/no): " additional
if [ "$additional" = "yes" ]; then
    # Add additional installations here
    echo "Additional components will be installed."
else
    echo "No additional components will be installed."
fi

# Perform installations
install_apache
install_elasticsearch
install_php
install_node
install_nginx
install_docker
install_jenkins
install_sonarqube

echo "Installation completed."

