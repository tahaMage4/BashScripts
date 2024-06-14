#!/bin/bash

# Function to display list of changed files and prompt user for file numbers
select_files() {
    # List of changed files
    changed_files=$(git status --short)

    # Display list of changed files
    echo "List of changed files:"
    echo "$changed_files"

    # Prompt user to select files to add
    read -p "Enter the numbers of files you want to add (e.g., '1 2-4 9'): " FILE_NUMBERS

    # Convert space-separated numbers into an array
    FILE_NUMBERS_ARR=($FILE_NUMBERS)

    # Initialize an empty array to store selected files
    selected_files=()

    # Loop through the selected file numbers and add them to the selected_files array
    for NUM_RANGE in "${FILE_NUMBERS_ARR[@]}"
    do
        # Check if the input is a range or single number
        if [[ $NUM_RANGE =~ ^[0-9]+-[0-9]+$ ]]; then
            # Extract the start and end of the range
            START=$(echo "$NUM_RANGE" | cut -d'-' -f1)
            END=$(echo "$NUM_RANGE" | cut -d'-' -f2)
            # Ensure that the end of the range does not exceed the total number of changed files
            if [ "$END" -gt $(git status --short | wc -l) ]; then
                END=$(git status --short | wc -l)
            fi
            # Loop through the range
            for i in $(seq "$START" "$END")
            do
                FILE=$(echo "$changed_files" | sed -n "${i}p" | awk '{print $2}')
                if [ -z "$FILE" ]; then
                    echo "Invalid file number: $i"
                else
                    selected_files+=("$FILE")
                fi
            done
        elif [[ $NUM_RANGE =~ ^[0-9]+$ ]]; then
            FILE=$(echo "$changed_files" | sed -n "${NUM_RANGE}p" | awk '{print $2}')
            if [ -z "$FILE" ]; then
                echo "Invalid file number: $NUM_RANGE"
            else
                selected_files+=("$FILE")
            fi
        else
            echo "Invalid input: $NUM_RANGE"
        fi
    done

    # If no valid files were selected, re-ask for file numbers
    if [ ${#selected_files[@]} -eq 0 ]; then
        echo "No valid files selected. Please try again."
        select_files
    fi
}

# Select files to add
select_files

# Add selected files to the staging area
for FILE in "${selected_files[@]}"
do
    git add "$FILE"
done

# Prompt for commit message
read -p "Enter commit message: " MESSAGE
git commit -m "$MESSAGE"

# Prompt for pull or push
echo "pull or push >"
read -r answer
if [[ $answer == "pull" ]]; then
   git pull
   echo "Done with pulling, would you like to push your files (y/n)?"
   read -r pushing
   if [[ $pushing == "y" ]]; then
      git push
   else
      exit
   fi
elif [[ $answer == "push" ]]; then
   git push
fi
