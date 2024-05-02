#!/bin/bash

# Set the API endpoint URL and parameters
API_URL="https://www.adkdata.com/json?feed=stories"

API_URL_STORIES="https://www.adkdata.com/json?feed=stories"
PARAMS="param1=&domain&param2=id"

API_URL_EVENT="https://www.adkdata.com/json?feed=events"




# Set the time interval between requests in seconds
INTERVAL=60

# Create an infinite loop to continuously get and process data from the API
while true; do
  # Make the API request and save the response to a variable
  data=$(curl -s "$API_URL_STORIES")
  data_stories=$(curl -s "$API_URL_STORIES?$PARAMS")
  data_event=$(curl -s "$API_URL_EVENT")

  # Process the data
  processed_data=$(echo "$data")
  processed_data_stories=$(echo "$data_stories")
  processed_data_event=$(echo "$data_event")

  # Save the processed data to a file or database
  echo "$processed_data" >> stories.json
  echo "$processed_data_stories" >> stories/id.json
  echo "$processed_data_event" >> events.json

  # Wait for the specified time interval before making the next request
  sleep $INTERVAL
done
