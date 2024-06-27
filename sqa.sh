#!/bin/bash

# Check if Python3 is installed
if ! command -v python3 &> /dev/null; then
    echo "Python3 is not installed. Installing Python3..."
    sudo apt-get update
    sudo apt-get install python3 -y
fi

# Check if pip is installed
if ! command -v pip3 &> /dev/null; then
    echo "pip3 is not installed. Installing pip3..."
    sudo apt-get install python3-pip -y
fi

# Check if Selenium is installed
if ! python3 -c "import selenium" &> /dev/null; then
    echo "Selenium is not installed. Installing Selenium..."
    pip3 install selenium
fi

# Check if ChromeDriver is installed
if ! command -v chromedriver &> /dev/null; then
    echo "ChromeDriver is not installed. Installing ChromeDriver..."
    CHROMEDRIVER_VERSION=`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE`
    wget -N https://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip
    unzip chromedriver_linux64.zip
    sudo mv -f chromedriver /usr/local/bin/chromedriver
    sudo chmod 755 /usr/local/bin/chromedriver
    rm chromedriver_linux64.zip
fi

# Function to test functionality using curl
function test_functionality() {
    local url=$1
    local response=$(curl -s -o response.html -w "%{http_code}" $url)
    if [ $? -ne 0 ]; then
        echo "Functionality test failed: Network error"
        echo "$url,Functionality,Failed,Network error" >> $output_file
        return 1
    fi

    if [ $response -eq 200 ]; then
        echo "Functionality test passed"
        echo "$url,Functionality,Passed" >> $output_file
    else
        echo "Functionality test failed: HTTP $response"
        echo "$url,Functionality,Failed,HTTP $response" >> $output_file
    fi
}

# Function to test HTML elements
function test_html_elements() {
    local temp_file="response.html"

    # Check for specific elements, e.g., <title> tag
    if grep -q "<title>" $temp_file; then
        echo "HTML element test passed"
        echo "$url,HTML Element,Passed" >> $output_file
    else
        echo "HTML element test failed: <title> tag not found"
        echo "$url,HTML Element,Failed,<title> tag not found" >> $output_file
    fi
}

# Function to test CSS and JS with Selenium
function test_css_js() {
    local url=$1
    python3 test_selenium.py $url $output_file
}

# Prompt user for URL
read -p "Enter the URL to test: " url

# Output CSV file
output_file="test_results.csv"

# Add header to CSV file
echo "URL,Test Type,Result,Details,Screenshot" > $output_file

# Perform tests
test_functionality $url
test_html_elements
test_css_js $url

# Clean up
rm response.html

echo "Tests completed. Results saved to $output_file."
