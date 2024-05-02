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
sudo apt update
sudo apt-get install ruby-full


gem install bugsnag listen theme-check nokogiri pry-byebug byebug rubocop-shopify rubocop-minitest rubocop-rake iniparse colorize bundler rake minitest mocha minitest-reporters minitest-fail-fast fakefs webmock timecop  rack cucumber --user-install

export GEM_HOME=$HOME/gems
export GEM_PATH=$HOME/gems
source ~/.zshrc

gem install bugsnag listen theme-check nokogiri pry-byebug byebug rubocop-shopify rubocop-minitest rubocop-rake iniparse colorize bundler rake minitest mocha minitest-reporters minitest-fail-fast fakefs webmock timecop  rack cucumber

ls -ld /var/lib/gems/3.0.0/gems/bugsnag-6.26.0
sudo chmod -R u+w /var/lib/gems/3.0.0/gems/bugsnag-6.26.0
ls -l /var/lib/gems/3.0.0/gems/bugsnag-6.26.0
sudo chown -R taha /var/lib/gems/3.0.0/gems/bugsnag-6.26.0

echo_message "Installation completed!"
