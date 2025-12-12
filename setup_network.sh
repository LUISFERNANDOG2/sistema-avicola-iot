#!/bin/bash
# Script para configurar IP Estática en Raspberry Pi
# Uso: sudo ./setup_network.sh [interfaz]
# Ejemplo: sudo ./setup_network.sh wlan0

INTERFACE="${1:-wlan0}" # Por defecto usa wlan0 si no se especifica
STATIC_IP="192.168.0.100"
ROUTER_IP="192.168.0.1"
DNS_IP="8.8.8.8"

echo "🌐 Configurando IP Estática ($STATIC_IP) en $INTERFACE..."

# Detectar si usamos NetworkManager (Raspberry Pi OS Bookworm y nuevos)
if command -v nmcli &> /dev/null; then
    echo "--> Detectado NetworkManager. Usando nmcli..."
    
    # Buscar la conexión activa para esa interfaz
    CON_NAME=$(nmcli -t -f NAME,DEVICE connection show --active | grep $INTERFACE | cut -d: -f1)
    
    if [ -z "$CON_NAME" ]; then
        echo "⚠️ No se encontró conexión activa en $INTERFACE. Creando una nueva..."
        nmcli con add type wifi ifname $INTERFACE con-name "Static_WiFi" ssid "GranjaAvicola_WiFi"
        CON_NAME="Static_WiFi"
    fi

    echo "--> Modificando conexión: $CON_NAME"
    sudo nmcli con mod "$CON_NAME" ipv4.addresses $STATIC_IP/24
    sudo nmcli con mod "$CON_NAME" ipv4.gateway $ROUTER_IP
    sudo nmcli con mod "$CON_NAME" ipv4.dns $DNS_IP
    sudo nmcli con mod "$CON_NAME" ipv4.method manual
    
    echo "--> Reiniciando interfaz..."
    sudo nmcli con down "$CON_NAME" && sudo nmcli con up "$CON_NAME"

else
    # Método Legacy (dhcpcd.conf) para sistemas viejos (Bullseye y anteriores)
    echo "--> Detectado sistema Legacy. Usando /etc/dhcpcd.conf..."
    
    CONFIG_LINE="interface $INTERFACE"
    
    if grep -q "$CONFIG_LINE" /etc/dhcpcd.conf; then
        echo "⚠️ Ya existe configuración para $INTERFACE en dhcpcd.conf. Por favor edítelo manualmente para evitar conflictos."
    else
        echo "--> Escribiendo configuración en /etc/dhcpcd.conf..."
        sudo tee -a /etc/dhcpcd.conf > /dev/null <<EOT

# Configuración Avicola IoT
interface $INTERFACE
static ip_address=$STATIC_IP/24
static routers=$ROUTER_IP
static domain_name_servers=$DNS_IP
EOT
        echo "--> Reiniciando servicio de red..."
        sudo service dhcpcd restart
    fi
fi

echo "✅ Configuración Terminada."
echo "Prueba con: ping $ROUTER_IP"
