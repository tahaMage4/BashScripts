#!/bin/bash

git add .
read -p "Enter commit message: " MESSAGE
git commit -m "$MESSAGE"

echo "Pull or Push >"
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
