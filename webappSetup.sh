#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
echo "Starting setup process..."

# Update package lists and upgrade installed packages
echo "Updating package lists..."
sudo -E apt update -y
echo "Upgrading system packages..."
sudo -E apt upgrade -y

# Install MySQL
DB_ENGINE="mysql-server" 
if ! dpkg -l | grep -q "$DB_ENGINE"; then
  echo "Installing $DB_ENGINE..."
  sudo apt install -y $DB_ENGINE
else
  echo "$DB_ENGINE is already installed."
fi

# Extract database credentials from .env file
if [ ! -f "/tmp/.env" ]; then
  echo "Error: .env file is missing in /tmp. Please upload it."
  exit 1
fi

echo "Reading database credentials from .env file..."
DB_NAME=$(grep DB_NAME /tmp/.env | cut -d '=' -f2)
DB_USER=$(grep DB_USER /tmp/.env | cut -d '=' -f2)
DB_PASSWORD=$(grep DB_PASSWORD /tmp/.env | cut -d '=' -f2)
DB_PORT=$(grep DB_PORT /tmp/.env | cut -d '=' -f2)

if [ -z "$DB_PORT" ]; then
  DB_PORT=3306
fi

if [ -z "$DB_NAME" ] || [ -z "$DB_USER" ] || [ -z "$DB_PASSWORD" ]; then
  echo "Error: Missing database credentials in .env file."
  exit 1
fi

# Update MySQL configuration for the correct port
MYSQL_CONFIG_FILE="/etc/mysql/mysql.conf.d/mysqld.cnf"

if grep -q "^port" "$MYSQL_CONFIG_FILE"; then
  echo "Updating MySQL port in configuration file..."
  sudo sed -i "s/^port.*/port = $DB_PORT/" "$MYSQL_CONFIG_FILE"
else
  echo "Adding MySQL port to configuration file..."
  echo -e "\n[mysqld]\nport = $DB_PORT" | sudo tee -a "$MYSQL_CONFIG_FILE"
fi

# Restart MySQL to apply port change
echo "Restarting MySQL..."
sudo systemctl restart mysql

# Create MySQL database and user if they don't exist
echo "Setting up MySQL database and user..."
sudo mysql -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"
sudo mysql -e "CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';"
sudo mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

echo "Database setup completed."

# Create Linux group if it does not exist
GROUP_NAME="appgroup"
if ! getent group $GROUP_NAME >/dev/null; then
  echo "Creating group $GROUP_NAME..."
  sudo groupadd $GROUP_NAME
else
  echo "Group $GROUP_NAME already exists."
fi

# Create Linux user if it does not exist
USER_NAME="appuser"
if ! id "$USER_NAME" >/dev/null 2>&1; then
  echo "Creating user $USER_NAME..."
  sudo useradd -m -g $GROUP_NAME $USER_NAME
else
  echo "User $USER_NAME already exists."
fi

# Install unzip utility if not installed
if ! command -v unzip &>/dev/null; then
  echo "Installing unzip..."
  sudo apt install unzip -y
else
  echo "Unzip is already installed."
fi

# Define application directory
APP_DIR="/opt/csye6225"
ZIP_FILE="/tmp/Srujana_Adapa_002837408_02.zip"

# Ensure the application directory exists
if [ ! -d "$APP_DIR" ]; then
  echo "Creating application directory: $APP_DIR"
  sudo mkdir -p "$APP_DIR"
else
  echo "Application directory already exists: $APP_DIR"
fi

# Unzip only the webapp folder into /opt/csye6225
if [ -f "$ZIP_FILE" ]; then
  echo "Unzipping only the webapp folder..."
  sudo unzip -o "$ZIP_FILE" "Srujana_Adapa_002837408_02/webapp/*" -d "$APP_DIR"

  # Move webapp to /opt/csye6225 and clean up
  sudo rm -rf "$APP_DIR/webapp"
  sudo mv "$APP_DIR/Srujana_Adapa_002837408_02/webapp" "$APP_DIR/"
  sudo rm -rf "$APP_DIR/Srujana_Adapa_002837408_02"

else
  echo "Warning: Zip file $ZIP_FILE not found!"
fi

# Update permissions of the folder and artifacts
echo "Setting permissions for application directory..."
sudo chown -R $USER_NAME:$GROUP_NAME "$APP_DIR"
sudo chmod -R 775 "$APP_DIR"

# Install Node.js and npm if not installed
if ! command -v node &>/dev/null; then
  echo "Installing Node.js and npm..."
  sudo apt update
  sudo apt install -y nodejs npm
else
  echo "Node.js and npm are already installed."
fi


APP_WEB_DIR="$APP_DIR/webapp"
PACKAGE_JSON="$APP_WEB_DIR/package.json"

if [ -f "$PACKAGE_JSON" ]; then
  echo "Installing application dependencies from $PACKAGE_JSON..."
  npm install --prefix "$APP_WEB_DIR"

  # Ensure node_modules exists before changing ownership
  if [ -d "$APP_WEB_DIR/node_modules" ]; then
    sudo chown -R $USER_NAME:$GROUP_NAME "$APP_WEB_DIR/node_modules"
  fi
else
  echo "Warning: package.json not found in $APP_WEB_DIR!"
fi

# Move .env file to application directory
ENV_FILE_DEST="$APP_WEB_DIR/.env"
if [ ! -f "$ENV_FILE_DEST" ]; then
  echo "Copying .env file to application directory..."
  sudo cp /tmp/.env "$ENV_FILE_DEST"
else
  echo ".env file already exists in application directory."
fi

sudo chown $USER_NAME:$GROUP_NAME "$ENV_FILE_DEST" # Restrict read/write to owner only
sudo chmod 660 "$ENV_FILE_DEST" 

echo "Setup process completed successfully!"
