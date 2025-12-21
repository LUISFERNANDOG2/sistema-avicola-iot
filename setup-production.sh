#!/bin/bash

# Setup script for production deployment on Windows WSL2
echo "=== Sistema Avícola IoT - Production Setup ==="

# Check if running in WSL2
if ! grep -q microsoft /proc/version; then
    echo "This script is designed to run in WSL2"
    exit 1
fi

# Update system
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Docker if not present
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
fi

# Install Docker Compose if not present
if ! command -v docker-compose &> /dev/null; then
    echo "Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Create necessary directories
echo "Creating directories..."
mkdir -p nginx/ssl backups mosquitto/config mosquitto/data mosquitto/log

# Generate MQTT Password (if missing)
if [ ! -f ./mosquitto/config/passwd ]; then
    echo "⚠️ MQTT Password file not found!"
    echo "Please run: ./generate_mqtt_pass.sh"
    # We don't force it here to avoid interactive prompt blocking automation, 
    # but we warn the user.
fi

# Generate self-signed SSL certificate (Cloudflare will override this)
echo "Generating SSL certificate..."
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout nginx/ssl/key.pem \
    -out nginx/ssl/cert.pem \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

# Set proper permissions
echo "Setting permissions..."
chmod 600 nginx/ssl/key.pem
chmod 644 nginx/ssl/cert.pem

# Create systemd service for auto-start
echo "Creating systemd service..."
sudo tee /etc/systemd/system/avicola-iot.service > /dev/null <<EOF
[Unit]
Description=Sistema Avícola IoT
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$(pwd)
ExecStart=/usr/local/bin/docker-compose -f docker-compose.prod.yml up -d
ExecStop=/usr/local/bin/docker-compose -f docker-compose.prod.yml down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF

# Enable systemd service
sudo systemctl enable avicola-iot.service

# Install Cloudflare Tunnel (cloudflared)
echo "Installing Cloudflare Tunnel..."
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb
rm cloudflared-linux-amd64.deb

echo "=== Setup Complete ==="
echo ""
echo "Next steps:"
echo "1. Edit .env.production with your secure passwords"
echo "2. Run: docker-compose -f docker-compose.prod.yml up -d"
echo "3. Setup Cloudflare Tunnel:"
echo "   - Login to Cloudflare dashboard"
echo "   - Create a tunnel"
echo "   - Run: cloudflared tunnel login"
echo "   - Configure tunnel to point to localhost:80"
echo ""
echo "System will auto-start on reboot."
