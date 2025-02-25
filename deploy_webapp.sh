#!/bin/bash
set -e  # Exit immediately if any command fails

echo "Starting webapp deployment..."

# Ensure the directory exists
sudo mkdir -p /opt/csye6225

# Navigate to home directory
cd /opt/csye6225

echo "GITHUB_WORKSPACE: $GITHUB_WORKSPACE"
echo "Current directory: $(pwd)"

if [ -n "${GITHUB_WORKSPACE}" ]; then
    echo "GITHUB_WORKSPACE is set to: ${GITHUB_WORKSPACE}"
    if [ -d "${GITHUB_WORKSPACE}" ]; then
        echo "The directory ${GITHUB_WORKSPACE} exists"
        ls -la "${GITHUB_WORKSPACE}"
    else
        echo "The directory ${GITHUB_WORKSPACE} does not exist"
    fi
else
    echo "GITHUB_WORKSPACE is not set"
fi

# Move the webapp.zip from /tmp to the home directory
echo "Moving webapp.zip from /tmp to /opt/csye6225"
sudo mv /tmp/webapp.zip /opt/csye6225/webapp.zip

# Unzip the web application
if [ -f "/opt/csye6225/webapp.zip" ]; then
  # Unzip the web application
  sudo unzip -o /opt/csye6225/webapp.zip -d /opt/csye6225/webapp
  sudo rm /opt/csye6225/webapp.zip  # Clean up zip file
else
  echo "Error: webapp.zip not found in /opt/csye6225"
  exit 1
fi


# Navigate to the webapp folder
if [ -d "/opt/csye6225/webapp" ]; then
  cd /opt/csye6225/webapp
else
  echo "Error: /opt/csye6225/webapp directory not found"
  exit 1
fi

# Install dependencies
if command -v npm &> /dev/null; then
  sudo npm install --silent
else
  echo "Error: npm is not installed"
  exit 1
fi

# Create the .env file properly
cat <<EOF | sudo tee /opt/csye6225/webapp/.env > /dev/null
DB_HOST=${DB_HOST}
DB_USER=${DB_USER}
DB_PASSWORD=${DB_PASSWORD}
DB_NAME=${DB_NAME}
DB_PORT=${DB_PORT}
DB_DIALECT=${DB_DIALECT}
DB_FORCE_CHANGES=${DB_FORCE_CHANGES}
EOF

# Set ownership and permissions
sudo chown -R csye6225:csye6225 /opt/csye6225/webapp
sudo chmod -R 750 /opt/csye6225/webapp
sudo chmod 600 /opt/csye6225/webapp/.env

# Restart the application service
sudo systemctl restart webapp.service

echo "Web app setup complete!"
