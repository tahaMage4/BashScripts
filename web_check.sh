#!/bin/bash

# Prompt the user for the URL
read -p "Enter the URL of the web service: " URL

# Function to check the web service
check_web_service() {
  # Send an HTTP GET request to the URL and capture the HTTP status code
  http_status=$(curl -s -o /dev/null -w "%{http_code}" "$URL")

  # Check if curl encountered an error
  if [ $? -ne 0 ]; then
    echo "Error: Failed to access the URL. Check your internet connection or the URL validity."
  else
    # Check the HTTP status code
    if [ "$http_status" -eq 200 ]; then
      echo "Web service is up and running. HTTP Status: $http_status"
    else
      echo "Web service is not functioning correctly. HTTP Status: $http_status"
    fi
  fi
}

# Call the function to check the web service
check_web_service
