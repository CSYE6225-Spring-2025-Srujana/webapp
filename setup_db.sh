#!/bin/bash

echo "Setting up MySQL database..."

# Load environment variables
if [ -f /home/ubuntu/webapp/.env ]; then
  export $(grep -v '^#' /home/ubuntu/webapp/.env | xargs)
fi

# Login as root and execute MySQL commands
sudo mysql -e "
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
CREATE USER IF NOT EXISTS '${DB_USER}'@'${DB_HOST}' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
"

echo "Database setup complete."
