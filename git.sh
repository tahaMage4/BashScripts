#!/bin/bash

# Function to display list of changed files and prompt user for file numbers
select_files() {
    # List of changed files
    changed_files=$(git status --short)

    # Check if there are any changes to stage
    if [[ -z "$changed_files" ]]; then
        echo "No changes to stage. Exiting."
        exit 0
    fi

    # Display list of changed files with numbering
    echo "List of changed files:"
    echo "$changed_files" | nl -w2 -s': '

    # Prompt user to select files to add
    read -p "Enter the numbers of files you want to add (e.g., '1 2-4 9' or '*' for all files): " FILE_NUMBERS

    # If user selects *, add all files
    if [[ $FILE_NUMBERS == "*" ]]; then
        selected_files=($(echo "$changed_files" | awk '{print $2}'))
        return
    fi

    # Convert space-separated numbers into an array
    FILE_NUMBERS_ARR=($FILE_NUMBERS)

    # Initialize an empty array to store selected files
    selected_files=()

    # Total number of changed files
    total_files=$(echo "$changed_files" | wc -l)

    # Loop through the selected file numbers and add them to the selected_files array
    for NUM_RANGE in "${FILE_NUMBERS_ARR[@]}"
    do
        # Check if the input is a range or single number
        if [[ $NUM_RANGE =~ ^[0-9]+-[0-9]+$ ]]; then
            # Extract the start and end of the range
            START=$(echo "$NUM_RANGE" | cut -d'-' -f1)
            END=$(echo "$NUM_RANGE" | cut -d'-' -f2)
            # Ensure that the end of the range does not exceed the total number of changed files
            if [ "$END" -gt "$total_files" ]; then
                END="$total_files"
            fi
            # Loop through the range
            for i in $(seq "$START" "$END")
            do
                FILE=$(echo "$changed_files" | sed -n "${i}p" | awk '{print $2}')
                if [ -n "$FILE" ]; then
                    selected_files+=("$FILE")
                fi
            done
        elif [[ $NUM_RANGE =~ ^[0-9]+$ ]]; then
            FILE=$(echo "$changed_files" | sed -n "${NUM_RANGE}p" | awk '{print $2}')
            if [ -n "$FILE" ]; then
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



# If files were selected, add them to the staging area
if [ ${#selected_files[@]} -gt 0 ]; then
for FILE in "${selected_files[@]}"; do
    git add "$FILE"
done

# Confirm commit creation
read -p "Do you want to create a commit? (y/n): " commit_confirm
if [[ $commit_confirm == "y" ]]; then
    # Prompt for commit message
    read -p "Enter a commit message: " COMMIT_MSG
    git commit -m "$COMMIT_MSG"
else
    echo "Commit aborted."
    exit 0
fi

else
    echo "No files selected for staging."
fi

# Confirm push
read -p "Do you want to push your changes to the remote repository? (y/n): " push_confirm
if [[ $push_confirm == "y" ]]; then
    # Attempt to push changes
    if git push; then
        echo "Changes pushed successfully."
    else
        echo "Push failed. Please check for any conflicts or network issues."
    fi
else
    echo "Push aborted."
fi
