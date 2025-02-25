#!/bin/bash
set -e  # Exit immediately if any command fails

echo "Starting webapp deployment..."

# Ensure the directory exists
sudo mkdir -p /home/csye6225

# Navigate to home directory
cd /home/csye6225


# Move the webapp.zip from GitHub workspace to the home directory
echo "Moving webapp.zip from GitHub workspace to /home/csye6225"
sudo mv $GITHUB_WORKSPACE/webapp.zip /home/csye6225/webapp.zip

# Unzip the web application
sudo unzip -o webapp.zip -d webapp
sudo rm webapp.zip  # Clean up zip file

# Navigate to the webapp folder
cd /home/csye6225/webapp

# Install dependencies
sudo npm install --silent

# Create the .env file properly
cat <<EOF | sudo tee /home/csye6225/webapp/.env > /dev/null
DB_HOST=${DB_HOST}
DB_USER=${DB_USER}
DB_PASSWORD=${DB_PASSWORD}
DB_NAME=${DB_NAME}
DB_PORT=${DB_PORT}
DB_DIALECT=${DB_DIALECT}
DB_FORCE_CHANGES=${DB_FORCE_CHANGES}
EOF

# Set ownership and permissions
sudo chown -R csye6225:csye6225 /home/csye6225/webapp
sudo chmod -R 750 /home/csye6225/webapp
sudo chmod 600 /home/csye6225/webapp/.env

# Restart the application service
sudo systemctl restart webapp.service

echo "Web app setup complete!"
