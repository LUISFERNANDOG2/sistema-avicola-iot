#!/bin/bash

echo "=== Starting Cloudflare Tunnels (Quick Tunnel Mode) ==="
echo "Note: This will start two tunnels:"
echo "1. HTTP Tunnel for Dashboard & API (Port 80)"
echo "2. TCP Tunnel for MQTT (Port 1883)"
echo ""

# Check if cloudflared is installed
if ! command -v cloudflared &> /dev/null; then
    echo "❌ 'cloudflared' is not installed."
    echo "Please run ./setup-production.sh first to install dependencies."
    exit 1
fi

# Check if ngrok is authenticated
if ! ngrok config check &> /dev/null; then
    echo "❌ Error: Ngrok is not configured!"
    echo "   Please run: ngrok config add-authtoken <YOUR_TOKEN>"
    echo "   (Sign up at https://dashboard.ngrok.com to get one for free)"
    exit 1
fi

echo "🚀 Starting HTTP Tunnel (Cloudflare)..."
cloudflared tunnel --url http://localhost:80 > /tmp/tunnel_http.log 2>&1 &
HTTP_PID=$!

echo "🚀 Starting MQTT Tunnel (Ngrok TCP)..."
# Ngrok tcp 1883
ngrok tcp 1883 --log=stdout > /tmp/tunnel_mqtt.log 2>&1 &
MQTT_PID=$!

# Function to wait for URL in log file
wait_for_url() {
    local logfile=$1
    local type=$2
    local count=0
    local ret=""
    
    echo "⏳ Waiting for $type Tunnel (max 30s)..."
    while [ $count -lt 30 ]; do
        if [ "$type" == "HTTP" ]; then
            ret=$(grep -o 'https://.*\.trycloudflare\.com' "$logfile" | head -n 1)
        else
            # Ngrok URL format: tcp://X.tcp.ngrok.io:12345
            ret=$(grep -o 'tcp://.*\.ngrok\.io:[0-9]*' "$logfile" | head -n 1)
        fi
        
        if [ -n "$ret" ]; then
            return 0
        fi
        sleep 1
        ((count++))
    done
    return 1
}

# Wait for tunnels
wait_for_url "/tmp/tunnel_http.log" "HTTP"
wait_for_url "/tmp/tunnel_mqtt.log" "MQTT (Ngrok)"

echo ""
echo "==================================================="
echo "📊 TUNNEL DETAILS (COPY THESE)"
echo "==================================================="

# Extract URLs from logs
HTTP_URL=$(grep -o 'https://.*\.trycloudflare\.com' /tmp/tunnel_http.log | head -n 1)
MQTT_URL=$(grep -o 'tcp://.*\.ngrok\.io:[0-9]*' /tmp/tunnel_mqtt.log | head -n 1)

if [ -z "$HTTP_URL" ]; then
    echo "❌ HTTP Tunnel failed to start. Debugging info:"
    echo "--- BEGIN LOG (/tmp/tunnel_http.log) ---"
    cat /tmp/tunnel_http.log
    echo "--- END LOG ---"
else
    echo "✅ DASHBOARD/API URL: $HTTP_URL"
    echo "   -> Access via Browser"
fi

echo ""

if [ -z "$MQTT_URL" ]; then
    echo "❌ MQTT Tunnel failed to start (Ngrok). Debugging info:"
    echo "--- BEGIN LOG (/tmp/tunnel_mqtt.log) ---"
    cat /tmp/tunnel_mqtt.log
    echo "--- END LOG ---"
else
    echo "✅ MQTT BROKER URL:   $MQTT_URL"
    echo "   -> Copy this to your ESP32 Firmware!"
    echo "   -> Host: (Remove tcp:// and port) e.g. 0.tcp.ngrok.io"
    echo "   -> Port: The number at the end e.g. 12345"
fi

echo "==================================================="
echo "Press Ctrl+C to stop tunnels..."

# Cleanup on exit
trap "kill $HTTP_PID $MQTT_PID 2>/dev/null; exit" SIGINT SIGTERM

wait
