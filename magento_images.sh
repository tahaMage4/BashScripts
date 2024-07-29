#!/bin/bash

# Check if the file containing URLs is provided
if [ -z "$1" ]; then
   echo "Usage: $0 <file_with_urls>"
   exit 1
fi

# Get the file with URLs from the command-line argument
URL_FILE="$1"

# Check if the file exists
if [ ! -f "$URL_FILE" ]; then
   echo "File not found: $URL_FILE"
   exit 1
fi

# Create or clear the result file
RESULT_FILE="result.txt"
>"$RESULT_FILE"

# Loop through each URL in the file
while IFS= read -r URL; do
   # Make an HTTP request and get the status code
   STATUS_CODE=$(curl -o /dev/null -s -w "%{http_code}\n" "$URL")

   # Check if the status code is 200
   if [ "$STATUS_CODE" -eq 200 ]; then
      echo "The product URL $URL is accessible (Status Code: 200)."
   else
      echo "The product URL $URL is not accessible (Status Code: $STATUS_CODE). Logging to $RESULT_FILE."
      echo "$URL (Status Code: $STATUS_CODE)" >>"$RESULT_FILE"
   fi
done <"$URL_FILE"
