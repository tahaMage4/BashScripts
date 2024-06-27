#!/bin/bash

# Function to test functionality using curl
function test_functionality() {
   local url=$1
   local response=$(curl -s -o response.html -w "%{http_code}" $url)
   if [ $? -ne 0 ]; then
      echo "Functionality test failed: Network error"
      echo "$url,Functionality,Failed,Network error" >>$output_file
      return 1
   fi

   if [ $response -eq 200 ]; then
      echo "Functionality test passed"
      echo "$url,Functionality,Passed" >>$output_file
   else
      echo "Functionality test failed: HTTP $response"
      echo "$url,Functionality,Failed,HTTP $response" >>$output_file
   fi
}

# Function to test HTML elements
function test_html_elements() {
   local temp_file="response.html"

   # Check for specific elements, e.g., <title> tag
   if grep -q "<title>" $temp_file; then
      echo "HTML element test passed"
      echo "$url,HTML Element,Passed" >>$output_file
   else
      echo "HTML element test failed: <title> tag not found"
      echo "$url,HTML Element,Failed,<title> tag not found" >>$output_file
   fi
}

# Function to test CSS files
function test_css() {
   local temp_file="response.html"

   # Extract and test all CSS files linked in the HTML
   grep -oP '(?<=<link rel="stylesheet" href=")[^"]+' $temp_file | while read -r css_file; do
      if [[ $css_file =~ ^https?:// ]]; then
         curl -s -o css_response.css $css_file
         if [ $? -ne 0 ]; then
            echo "CSS test failed: Unable to download $css_file"
            echo "$url,CSS,Failed,Unable to download $css_file" >>$output_file
            continue
         fi

         # Basic check if the CSS file is not empty
         if [ -s css_response.css ]; then
            echo "CSS test passed for $css_file"
            echo "$url,CSS,Passed,$css_file" >>$output_file
         else
            echo "CSS test failed: $css_file is empty"
            echo "$url,CSS,Failed,$css_file is empty" >>$output_file
         fi
         rm css_response.css
      fi
   done
}

# Function to test JavaScript files
function test_js() {
   local temp_file="response.html"

   # Extract and test all JavaScript files linked in the HTML
   grep -oP '(?<=<script src=")[^"]+' $temp_file | while read -r js_file; do
      if [[ $js_file =~ ^https?:// ]]; then
         curl -s -o js_response.js $js_file
         if [ $? -ne 0 ]; then
            echo "JavaScript test failed: Unable to download $js_file"
            echo "$url,JavaScript,Failed,Unable to download $js_file" >>$output_file
            continue
         fi

         # Basic check if the JS file is not empty
         if [ -s js_response.js ]; then
            echo "JavaScript test passed for $js_file"
            echo "$url,JavaScript,Passed,$js_file" >>$output_file
         else
            echo "JavaScript test failed: $js_file is empty"
            echo "$url,JavaScript,Failed,$js_file is empty" >>$output_file
         fi
         rm js_response.js
      fi
   done
}

# Prompt user for URL
read -p "Enter the URL to test: " url

# Output CSV file
output_file="test_results.csv"

# Add header to CSV file
echo "URL,Test Type,Result,Details" >$output_file

# Perform tests
test_functionality $url
test_html_elements
test_css
test_js

# Clean up
rm response.html

echo "Tests completed. Results saved to $output_file."
