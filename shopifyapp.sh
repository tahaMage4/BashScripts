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

# Install NVM
echo_message "Installing Nvm"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
source ~/.bashrc
echo "Nvm list: $(nvm list-remote)"

# Install Node.js and Yarn
echo_message "Installing Node.js and Yarn"
nvm install node 20
npm install -g yarn
nvm use 20

#Now Install the default shopify
echo_message "Installing the shopify commands"
npm install -g @shopify/cli

#ruby Install
sudo apt update && sudo apt upgrade

sudo apt install curl gcc g++ make

sudo apt install ruby-full

sudo apt install ruby-dev
# Ruby development environment

sudo apt install git

#Check the Shopify version
echo_message "Check the Shopify version"
shopify version

echo_message "Installation completed!"
