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

# 2. Instalar Docker y Docker Compose (si no existen)
if ! command -v docker &> /dev/null; then
    echo "🐳 Instalando Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    rm get-docker.sh
    sudo usermod -aG docker $USER
    echo "⚠️ Tienes que cerrar sesión y volver a entrar para usar Docker sin sudo."
else
    echo "✅ Docker ya está instalado."
fi

# Install Docker Compose if not present (kept separate as it's a distinct component)
if ! command -v docker-compose &> /dev/null; then
    echo "Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
else
    echo "✅ Docker Compose ya está instalado."
fi

# 3. Instalar Cloudflared (para HTTP)
if ! command -v cloudflared &> /dev/null; then
    echo "☁️ Instalando Cloudflared..."
    curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
    sudo dpkg -i cloudflared.deb
    rm cloudflared.deb
else
    echo "✅ Cloudflared ya está instalado."
fi

# 4. Instalar Ngrok (para MQTT TCP)
if ! command -v ngrok &> /dev/null; then
    echo "🔗 Instalando Ngrok..."
    curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
    echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list
    sudo apt update && sudo apt install ngrok
else
    echo "✅ Ngrok ya está instalado."
fi

# 5. Crear directorios necesarios y ajustar permisos
echo "📂 Verificando directorios..."
mkdir -p mosquitto/config mosquitto/data mosquitto/log nginx/ssl backups

# Asegurar permisos de scripts
echo "🔧 Ajustando permisos de ejecución..."
chmod +x *.sh

# Verificar Token de Ngrok
echo "🔑 Verificando configuración de Ngrok..."
if ! ngrok config check &> /dev/null; then
    echo "⚠️ No se detectó configuración de Ngrok."
    echo "   Por favor, ejecuta: ngrok config add-authtoken <TU_TOKEN>"
    echo "   (Consíguelo gratis en https://dashboard.ngrok.com)"
fi

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
