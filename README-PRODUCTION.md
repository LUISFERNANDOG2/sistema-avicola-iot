# Sistema Avícola IoT - Production Deployment Guide

## Overview
This guide helps you deploy the Sistema Avícola IoT project on a Windows laptop using WSL2 and Cloudflare Tunnel for global web access.

## Prerequisites
- Windows 10/11 with WSL2 enabled
- Cloudflare account (free tier is sufficient)
- Domain name (optional but recommended)
- High-resource laptop with stable internet connection

## Step 1: Setup WSL2 Environment

### Install WSL2 (if not already installed)
```powershell
# In PowerShell as Administrator
wsl --install
wsl --set-default-version 2
```

### Install Ubuntu in WSL2
```powershell
# From Microsoft Store or PowerShell
wsl --install -d Ubuntu
```

## Step 2: Setup Production Environment

### Clone and Setup Project
```bash
# In WSL2 Ubuntu terminal
cd /home/your-user
git clone <your-repository-url>
cd sistema-avicola-iot

# Make setup script executable
chmod +x setup-production.sh

# Run setup script
./setup-production.sh
```

### Configure Environment Variables
Edit `.env.production` with secure values:
```bash
nano .env.production
```

**Important: Change these values:**
- `POSTGRES_PASSWORD` - Strong database password
- `SECRET_KEY` - 32+ character random string
- `MQTT_PASSWORD` - MQTT authentication password

## Step 3: Start Services

### Start Docker Services
```bash
docker-compose -f docker-compose.prod.yml up -d
```

### Verify Services
```bash
# Check all containers are running
docker-compose -f docker-compose.prod.yml ps

# Check logs
docker-compose -f docker-compose.prod.yml logs -f
```

## Step 4: Configure Cloudflare Tunnel (Dual Track)

Choose the track that matches your current situation:

### 🅰️ TRACK 1: Quick Start (No Domain)
*Use this for immediate testing using free, random addresses.*

1.  **Start the Tunnels**:
    Run the included script to start both HTTP (Dashboard) and TCP (MQTT) tunnels:
    ```bash
    ./start_tunnels.sh
    ```

2.  **Copy the Addresses**:
    The script will output two important addresses.
    *   **Dashboard URL**: `https://random-name.trycloudflare.com` -> Open this in your browser.
    *   **MQTT URL**: `tcp://random-name.trycloudflare.com:12345` -> **IMPORTANT**: See `FIRMWARE_GUIDE.md` to configure your ESP32 with this.

    > **Note**: These addresses CHANGE every time you restart the script.

---

### 🅱️ TRACK 2: Production (With Domain)
*Use this for permanent installation (Recommended).*

1.  **Configure `docker-compose.domain.yml`**:
    *   This file is pre-configured to use a managed Cloudflare Tunnel via Docker.
    *   You need a `TUNNEL_TOKEN` from Cloudflare.

2.  **Get Tunnel Token**:
    *   Go to [Cloudflare Zero Trust Dashboard](https://one.dash.cloudflare.com/).
    *   Navigate to **Networks > Tunnels**.
    *   Create a tunnel (select "Docker" environment) and copy the **Token**.

3.  **Configure Public Hostnames** (In Cloudflare Dashboard):
    *   **Dashboard**: `your-domain.com` -> `http://nginx:80`
    *   **API**: `api.your-domain.com` -> `http://nginx:80`
    *   **MQTT**: `mqtt.your-domain.com` -> `tcp://mqtt:1883`

4.  **Deploy**:
    Update `.env.production` with your token:
    ```bash
    TUNNEL_TOKEN=your_token_here
    ```
    Start the production stack:
    ```bash
    docker-compose -f docker-compose.domain.yml up -d
    ```

## Step 5: Firmware Configuration

**CRITICAL STEP**: Your ESP32 modules need to know where to send data.
Please read **[FIRMWARE_GUIDE.md](FIRMWARE_GUIDE.md)** for detailed instructions on how to configure your devices for either Track 1 or Track 2.

## Security & Maintenance

### Firewall
*   Ensure Windows Firewall allows Docker traffic.
*   No external ports need to be opened on your router (Cloudflare Tunnel handles NAT traversal).

### Backup
```bash
# Database backup
docker exec $(docker-compose -f docker-compose.prod.yml ps -q db) pg_dump -U avicola_user avicola_db > backup_$(date +%F).sql
```

## Troubleshooting

1.  **Mqtt Connection Refused**:
    *   Did you generate the password? Run: `./generate_mqtt_pass.sh`
    *   Did you update the firmware with the correct User/Pass?

2.  **Tunnel not connecting**:
    *   Check `docker-compose logs tunnel` (Track 2).
    *   Check terminal output of `start_tunnels.sh` (Track 1).
