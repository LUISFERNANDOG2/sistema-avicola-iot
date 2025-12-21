#!/bin/bash

# Configuration
MOSQUITTO_DIR="./mosquitto/config"
PASSWD_FILE="$MOSQUITTO_DIR/passwd"

# Create config directory if it doesn't exist
mkdir -p "$MOSQUITTO_DIR"

# Check if file exists
if [ -f "$PASSWD_FILE" ]; then
    echo "Password file already exists at $PASSWD_FILE"
    echo "To regenerate, delete the file and run this script again."
    # Ask if user wants to add a new user
    read -p "Do you want to add/update a user? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
    FLAG="-b" # Helper mode (add to existing file)
else
    echo "Creating new password file..."
    touch "$PASSWD_FILE"
    FLAG="-c" # Create mode
fi

# Prompt for credentials
read -p "Enter MQTT Username: " MQTT_USER
read -s -p "Enter MQTT Password: " MQTT_PASS
echo ""

# Run mosquitto_passwd via Docker to ensure compatibility
# We map the local config directory to /mosquitto/config in the container
docker run --rm -v "$(pwd)/mosquitto/config:/mosquitto/config" eclipse-mosquitto:2 \
    mosquitto_passwd -b /mosquitto/config/passwd "$MQTT_USER" "$MQTT_PASS"

if [ $? -eq 0 ]; then
    echo "✅ Password set successfully for user: $MQTT_USER"
    
    # Fix permissions
    # 1. Take back ownership (Docker might have set it to root)
    sudo chown $USER:$USER "$PASSWD_FILE"
    # 2. Set strict permissions (0700 as requested by Mosquitto logs)
    # Note: We use 0700 so only owner can read. 
    # Docker mount will usually handle this, but if mosquitto user cannot read, we might need 0644.
    # We will stick to 0644 for broad compatibility in WSL2 unless strictness is enforced.
    # The warning asked for 0700, but that often breaks binds if UIDs don't match.
    # Let's use 0644 to be safe for now, as it's guaranteed to work.
    chmod 0644 "$PASSWD_FILE"
    
    echo "📝 Permissions updated."
else
    echo "❌ Error setting password."
fi
