# #!/bin/bash


# # Function for error handling
# handle_error() {
#     echo "Error: $1"
#     log "Error: $1"
#     exit 1
# }

# # Check if the script is run as root
# if [ "$EUID" -ne 0 ]; then
#     #echo "Please run this script as root."
#     #exit 1
#     handle_error "Please run this script as root."
# fi

#  # Install the Dependencies of the fresh system
# echo_message "Installing system dependencies..."
# apt update && apt install -y curl wget  || handle_error "Failed to install system dependencies."


# # Function to install packages using apt (Ubuntu/Debian)
# install_apache() {
#     echo_message "Installing Apache..."
#     apt update
#     apt install -y apache2
#     systemctl start apache2
#     systemctl enable apache2
#     systemctl status apache2
# }

# install_nginx() {
#     apt update
#     apt install -y nginx
#     systemctl status nginx
# }

# install_mysql() {

# # Install MySQL
# echo_message "Installing MySQL..."
# apt install -y mysql-server
# systemctl start mysql-server
# systemctl enable mysql-server
# systemctl status mysql-server
# }

# install_php() {
#     # Install PHP
# echo_message "Installing PHP..."
# apt update && apt install php
# apt install php libapache2-mod-php php-common php-gmp php-curl php-soap php-bcmath php-intl php-mbstring php-xmlrpc php-mysql php-gd php-xml php-cli php-zip
# echo "PHP version: $(php -v | head -n 1 | cut -d " " -f 2)"
# }

# install_Composer() {

# echo_message "Installing Composer..."
# php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
# php -r "if (hash_file('sha384', 'composer-setup.php') === 'e21205b207c3ff031906575712edab6f13eb0b361f2085f1f1237b7126d785e826a450292b6cfd1d64d92e6563bbde02') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
# php composer-setup.php
# php -r "unlink('composer-setup.php');"
# mv composer.phar /usr/local/bin/composer
# }

# # Function to install Node.js and NVM
# install_nvm() {
#     curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
#     source ~/.bashrc
#     echo "Nvm list: $(nvm list-remote)"
#     nvm install node16
# }


# install_node_yarn() {

# echo_message "Installing Node.js and Yarn"
# apt install nodejs || handle_error "Failed to install Node."
# echo "Node Version: $(node -v)"
# apt install npm || handle_error "Failed to install Npm."
# echo "Npm  Version: $(npm -v)"
# npm install -g yarn || handle_error "Failed to install Yarn."
# echo "Yarn Version: $(yarn -v)"

# }




# # Function to install Go
# install_go() {
#     wget https://golang.org/dl/go1.17.2.linux-amd64.tar.gz
#     tar -C /usr/local -xzf go1.17.2.linux-amd64.tar.gz
#     echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
# }

# # Function to install Elasticsearch
# install_elasticsearch() {
#     wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
#     echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | tee /etc/apt/sources.list.d/elastic-7.x.list
#     apt update
#     apt install -y elasticsearch
#     systemctl enable elasticsearch
#     systemctl start elasticsearch
#     systemctl status elasticsearch
# }

# # Function to configure services
# configure_services() {
#     if [ -f /etc/apache2/apache2.conf ]; then
#         # Apache2 configuration (example: enable mod_rewrite)
#         a2enmod rewrite
#         systemctl restart apache2
#     fi

#     if [ -f /etc/nginx/nginx.conf ]; then
#         # Nginx configuration (example: add Nginx server block)
#         echo "server {
#             listen 80;
#             server_name example.com;
#             root /var/www/html;
#         }" > /etc/nginx/sites-available/example.com
#         ln -s /etc/nginx/sites-available/example.com /etc/nginx/sites-enabled/
#         systemctl restart nginx
#     fi

#     if [ -f /etc/mysql/my.cnf ]; then
#         # MySQL configuration (example: secure installation)
#         mysql_secure_installation
#     fi
# }

# # Main script

# echo "Which packages would you like to install?"
# echo "1. Apache2"
# echo "2. Nginx"
# echo "3. MySQL"
# echo "4. PHP"
# echo "5. Composer"
# echo "6. NVM (Node.js)"
# echo "7. Go"
# echo "8. Elasticsearch"
# echo "9. Install Node & Yarn"
# echo "Enter the package numbers separated by spaces (e.g., '1 3 5 6'):"
# read packages

# if [[ $packages == *"1"* ]]; then
#     install_apache
# fi

# if [[ $packages == *"2"* ]]; then
#     install_nginx
# fi

# if [[ $packages == *"3"* ]]; then
#     install_mysql
# fi

# if [[ $packages == *"4"* ]]; then
#     install_php
# fi

# if [[ $packages == *"5"* ]]; then
#     install_Composer
# fi

# if [[ $packages == *"6"* ]]; then
#     install_nvm
# fi

# if [[ $packages == *"7"* ]]; then
#     install_go
# fi

# if [[ $packages == *"8"* ]]; then
#     install_elasticsearch
# fi

# if [[ $packages == *"9"* ]]; then
#     install_node_yarn
# fi

# #configure_services

# echo "Installation and configuration completed."

# # You may need to customize and further configure these services based on your specific needs.



#!/bin/bash

# Function for logging
log_file="/var/log/installation.log"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$log_file"
}

# Function for user input validation
validate_input() {
    if [[ $1 =~ ^[0-9]+$ ]] && [ "$1" -ge $2 ] && [ "$1" -le $3 ]; then
        return 0
    else
        echo "Invalid input. Please enter a valid option between $2 and $3."
        return 1
    fi
}

# Function for error handling
handle_error() {
    echo "Error: $1"
    log "Error: $1"
    exit 1
}

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
    handle_error "Please run this script as root."
fi

# Install system dependencies
echo "Installing system dependencies..."
log "Installing system dependencies..."
apt update && apt install -y curl wget || handle_error "Failed to install system dependencies."

# Function to install packages using apt (Ubuntu/Debian)
install_apache() {
    echo "Installing Apache..."
    log "Installing Apache..."
    apt update
    apt install -y apache2 || handle_error "Failed to install Apache."
    systemctl start apache2
    systemctl enable apache2
    systemctl status apache2 || handle_error "Apache service is not running."
}

install_nginx() {
    echo "Installing Nginx..."
    log "Installing Nginx..."
    apt update
    apt install -y nginx || handle_error "Failed to install Nginx."
    systemctl status nginx || handle_error "Nginx service is not running."
}

install_mysql() {
    echo "Installing MySQL..."
    log "Installing MySQL..."
    apt install -y mysql-server || handle_error "Failed to install MySQL."
    systemctl start mysql || handle_error "Failed to start MySQL service."
    systemctl enable mysql || handle_error "Failed to enable MySQL service."
    systemctl status mysql || handle_error "MySQL service is not running."
}

install_php() {
    echo "Installing PHP..."
    log "Installing PHP..."
    apt update && apt install -y php php-common php-gmp php-curl php-soap php-bcmath php-intl php-mbstring php-xmlrpc php-mysql php-gd php-xml php-cli php-zip || handle_error "Failed to install PHP."
    php_version=$(php -v | head -n 1 | cut -d " " -f 2)
    echo "PHP version: $php_version"
    log "PHP version: $php_version"
}

install_composer() {
    echo "Installing Composer..."
    log "Installing Composer..."
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" || handle_error "Failed to download Composer setup script."
    php -r "if (hash_file('sha384', 'composer-setup.php') === 'e21205b207c3ff031906575712edab6f13eb0b361f2085f1f1237b7126d785e826a450292b6cfd1d64d92e6563bbde02') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); exit(1); } echo PHP_EOL;" || handle_error "Composer setup script verification failed."
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer || handle_error "Failed to install Composer."
    rm composer-setup.php || handle_error "Failed to remove Composer setup script."
    composer_version=$(composer --version)
    echo "Composer version: $composer_version"
    log "Composer version: $composer_version"
}


# Function to install Node.js and NVM
install_nvm() {
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
    source ~/.bashrc
    echo "Nvm list: $(nvm list-remote)"
    nvm install node16
}


install_node_yarn() {

echo_message "Installing Node.js and Yarn"
apt install nodejs || handle_error "Failed to install Node."
echo "Node Version: $(node -v)"
apt install npm || handle_error "Failed to install Npm."
echo "Npm  Version: $(npm -v)"
npm install -g yarn || handle_error "Failed to install Yarn."
echo "Yarn Version: $(yarn -v)"

}




# Function to install Go
install_go() {
    wget https://golang.org/dl/go1.17.2.linux-amd64.tar.gz
    tar -C /usr/local -xzf go1.17.2.linux-amd64.tar.gz
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
}

# Function to install Elasticsearch
install_elasticsearch() {
    wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
    echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | tee /etc/apt/sources.list.d/elastic-7.x.list
    apt update
    apt install -y elasticsearch
    systemctl enable elasticsearch
    systemctl start elasticsearch
    systemctl status elasticsearch
}


# ... Add other installation functions (Node.js, Go, Elasticsearch) here

# Main script

echo "Which packages would you like to install?"
log "Prompting user for package selection..."
echo "1. Apache2"
echo "2. Nginx"
echo "3. MySQL"
echo "4. PHP"
echo "5. Composer"
echo "6. NVM (Node.js)"
echo "7. Go"
echo "8. Elasticsearch"
echo "9. Install Node.js and Yarn"
echo "Enter the package numbers separated by spaces (e.g., '1 3 5 6'):"
read -r package_selection

for package in $package_selection; do
    # validate_input "$package" 1 9 || handle_error "Invalid package option."
    case "$package" in
    1)
        install_apache
        ;;
    2)
        install_nginx
        ;;
    3)
        install_mysql
        ;;
    4)
        install_php
        ;;
    5)
        install_composer
        ;;
    6)

        install_nvm
        ;;
    7)
        install_go
        ;;
    8)
        install_elasticsearch
        ;;
    9)
        install_node_yarn
        ;;
    *)
        echo "Invalid package option: $package"
        log "Invalid package option: $package"
        ;;
    esac
done

echo "Installation and configuration completed."
log "Installation and configuration completed."

# You may need to customize and further configure these services based on your specific needs.

