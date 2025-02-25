#!/bin/bash
set -e  # Exit immediately if any command fails

echo "Setting up MySQL database..."

# Load environment variables
# if [ -f /home/csye6225/webapp/.env ]; then
#   export $(grep -v '^#' /home/csye6225/webapp/.env | xargs)
# else
#   echo "Error: .env file not found!"
#   exit 1
# fi

# Ensure MySQL is running
if ! systemctl is-active --quiet mysql; then
  echo "Error: MySQL is not running!"
  exit 1
fi

# Login as root and execute MySQL commands
sudo mysql -e "
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
"

echo "Database setup complete."
