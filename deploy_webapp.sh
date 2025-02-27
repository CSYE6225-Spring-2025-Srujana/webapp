#!/bin/bash
set -e  

echo "Starting webapp deployment..."

sudo mkdir -p /opt/csye6225

cd /opt/csye6225

# Check if webapp.zip exists in /tmp before moving
if [ -f "/tmp/webapp.zip" ]; then
  echo "Moving webapp.zip from /tmp to /opt/csye6225"
  sudo mv /tmp/webapp.zip /opt/csye6225/webapp.zip
else
  echo "Error: webapp.zip not found in /tmp"
  exit 1
fi

# Ensure unzip is installed
if ! command -v unzip &> /dev/null; then
  echo "Installing unzip..."
  sudo apt-get update && sudo apt-get install -y unzip
fi

# Unzip the web application
if [ -f "/opt/csye6225/webapp.zip" ]; then
  echo "Extracting webapp.zip..."
  sudo unzip -o /opt/csye6225/webapp.zip -d /opt/csye6225
  sudo rm /opt/csye6225/webapp.zip  # Clean up zip file
else
  echo "Error: webapp.zip not found in /opt/csye6225"
  exit 1
fi

# Navigate to the webapp folder
if [ -d "/opt/csye6225/webapp" ]; then
  echo "Navigating to the webapp folder /opt/csye6225/webapp"
  cd /opt/csye6225/webapp
else
  echo "Error: /opt/csye6225/webapp directory not found"
  exit 1
fi

# Create the .env file properly
echo "Creating .env file..."
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
echo "Setting ownership and permissions..."
sudo chown -R csye6225:csye6225 /opt/csye6225/webapp
sudo chmod -R 750 /opt/csye6225/webapp
sudo chmod 600 /opt/csye6225/webapp/.env

# Verify permissions
echo "Permissions set:"
ls -al /opt/csye6225/webapp
ls -l /opt/csye6225/webapp/.env

# Restart the application service if it exists
if systemctl list-units --full -all | grep -q "webapp.service"; then
  echo "Restarting the application service..."
  sudo systemctl restart webapp.service
else
  echo "Warning: webapp.service not found, skipping restart."
fi

echo "Web app setup complete!"