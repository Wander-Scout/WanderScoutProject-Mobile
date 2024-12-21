#!/bin/bash

# Navigate to the root of your Flutter project
cd $APPCENTER_SOURCE_DIRECTORY

# Create a .env file dynamically
cat <<EOT > .env
BASE_URL=https://wander-scout-project.vercel.app/
EOT

echo ".env file created successfully."
