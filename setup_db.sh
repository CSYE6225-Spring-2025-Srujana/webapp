#!/bin/bash
set -e  # Exit immediately if any command fails

echo "Setting up MySQL database..."

DB_ENGINE="mysql-server"
if ! dpkg -l | grep -q "$DB_ENGINE"; then
  echo "Installing $DB_ENGINE..."
  sudo apt install -y $DB_ENGINE || { echo "Failed to install $DB_ENGINE"; exit 1; }
else
  echo "$DB_ENGINE is already installed."
fi

if ! systemctl is-active --quiet mysql; then
  echo "MySQL is not running. Attempting to start..."
  sudo systemctl start mysql || { echo "Failed to start MySQL"; exit 1; }
fi

echo "MySQL is running."


# Login as root and execute MySQL commands
sudo mysql -e "
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
"

echo "Database setup complete."
