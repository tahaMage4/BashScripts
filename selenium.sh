#!/bin/bash

# Define the URL of the website to be checked
URL="http://35.163.236.118/"

# Function to perform QA checks
perform_qa_checks() {
  # Send an HTTP GET request to the URL and capture the response
  response=$(curl -s "$URL")

  # Check if the response contains specific content to indicate successful login
  if echo "$response" | grep -q "Welcome, John Doe"; then
    echo "Login functionality appears to be working."
  else
    echo "Login functionality is not working as expected."
  fi

  # Check if the response contains specific content to indicate a registration form
  if echo "$response" | grep -q "Register for an Account"; then
    echo "Registration functionality appears to be working."
  else
    echo "Registration functionality is not working as expected."
  fi

  # You can add more checks for other functionalities here

  # Example: Check if the response contains specific design elements
  if echo "$response" | grep -q "class=\"navbar-brand\">My Website</a>"; then
    echo "Design elements are present and appear to be correct."
  else
    echo "Design elements are missing or not as expected."
  fi
}

# Call the function to perform QA checks
perform_qa_checks
