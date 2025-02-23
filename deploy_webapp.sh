#!/bin/bash

echo "Starting webapp deployment..."

# Navigate to home directory
cd /home/ubuntu

# Unzip the web application
unzip webapp.zip
rm webapp.zip  # Clean up zip file

# Navigate to the webapp folder
cd /home/ubuntu/webapp

# Install dependencies
npm install

# Create the .env file properly
cat <<EOF > /home/ubuntu/webapp/.env
DB_HOST=${DB_HOST}
DB_USER=${DB_USER}
DB_PASSWORD=${DB_PASSWORD}
DB_NAME=${DB_NAME}
DB_PORT=${DB_PORT}
DB_DIALECT=${DB_DIALECT}
EOF

# Secure the .env file
chmod 600 /home/ubuntu/webapp/.env

echo "Environment variables written to .env file."

# Run the database setup script
bash /home/ubuntu/setup_db.sh

# Start the application in the background
# nohup node app.js &

echo "Web app deployment complete!"
