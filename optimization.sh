#!/bin/bash

installpackages() {
    echo "Install the Packages?"

    # Install NVM
    echo "Installing Nvm"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
    source ~/.bashrc
    echo "Nvm list: $(nvm list-remote)"

    echo "Installing Node.js and Yarn"
    nvm install node16
    # npm install -g yarn
    nvm use 16
    node -v

    npm install -g uncss
    npm i -g uglify-js
    sudo apt-get install libjpeg-dev libpng-dev libtiff-dev libgif-dev
}

# Function to remove unused CSS and JS files
remove_unused_files() {
    # Remove unused CSS files
    echo "Removing unused CSS files..."
    # Assuming you have UnCSS installed globally
    uncss input.css >output.css

    # Remove unused JS files
    echo "Removing unused JS files..."
    # Assuming you have UglifyJS installed globally
    uglifyjs input.js -o output.js
}

# Function to convert image formats to WebP
convert_to_webp() {
    # Convert JPEG, PNG, and SVG images to WebP format
    echo "Converting images to WebP format..."
    # Assuming you have cwebp installed
    find . \( -name "*.jpg" -o -name "*.png" -o -name "*.svg" \) -exec cwebp -q 80 {} -o {}.webp \;
}

# Function to convert images into <picture> tag in HTML
convert_to_picture_tag() {
    # Convert images to <picture> tag in HTML
    echo "Converting images to <picture> tag in HTML..."
    # Assuming you have sed available
    sed -i 's/<img src="\(.*\).jpg">/<picture><source srcset="\1.webp" type="image/webp"><img src="\1.jpg"></picture>/g' index.html
    sed -i 's/<img src="\(.*\).png">/<picture><source srcset="\1.webp" type="image/webp"><img src="\1.png"></picture>/g' index.html
    sed -i 's/<img src="\(.*\).svg">/<picture><source srcset="\1.webp" type="image/webp"><img src="\1.svg"></picture>/g' index.html
}

# Main function to execute optimization steps
optimize_website_speed() {
    echo "Starting website optimization..."

    #Install the dependiences
    installpackages

    # Step 1: Remove unused CSS and JS files
    remove_unused_files

    # Step 2: Convert images to WebP format
    convert_to_webp

    # Step 3: Convert images to <picture> tag in HTML
    convert_to_picture_tag

    echo "Website optimization completed!"
}

# Execute the main optimization function
optimize_website_speed
