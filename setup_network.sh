#!/bin/bash
# Script para configurar IP Estática en Raspberry Pi
# Uso: sudo ./setup_network.sh [interfaz]
# Ejemplo: sudo ./setup_network.sh wlan1

INTERFACE="${1:-wlan1}"
STATIC_IP="192.168.0.250"
ROUTER_IP="192.168.0.1"
DNS_IP="8.8.8.8"
SSID_NAME="Monitoring System"
CON_LABEL="Avicola_Static_IP"  # Nombre interno de la conexión en NM

echo "🌐 Configurando IP Estática ($STATIC_IP) en $INTERFACE..."
echo "   SSID: $SSID_NAME | Conexión: $CON_LABEL"

# Detectar NetworkManager
if command -v nmcli &> /dev/null; then
    echo "--> Detectado NetworkManager."
    
    # 1. Borrar conexiones viejas o conflictivas con el mismo nombre o en la misma interfaz
    # Esto limpia el desastre anterior
    echo "--> Limpiando conexiones anteriores en $INTERFACE..."
    existing_uuids=$(nmcli -t -f UUID,DEVICE connection show | grep $INTERFACE | cut -d: -f1)
    for uuid in $existing_uuids; do
        sudo nmcli connection delete $uuid
    done
    
    # También borrar por nombre si quedó alguna suelta
    sudo nmcli connection delete "$CON_LABEL" 2>/dev/null || true

    # 2. Crear la conexión nueva limpia
    echo "--> Creando nueva conexión '$CON_LABEL'..."
    sudo nmcli con add type wifi ifname $INTERFACE con-name "$CON_LABEL" ssid "$SSID_NAME"
    
    # 3. Configurar IP Estática
    echo "--> Aplicando configuración IP..."
    sudo nmcli con mod "$CON_LABEL" ipv4.addresses $STATIC_IP/24
    sudo nmcli con mod "$CON_LABEL" ipv4.gateway $ROUTER_IP
    sudo nmcli con mod "$CON_LABEL" ipv4.dns $DNS_IP
    sudo nmcli con mod "$CON_LABEL" ipv4.method manual
    sudo nmcli con mod "$CON_LABEL" connection.autoconnect yes
    
    # 4. Activar
    echo "--> Activando conexión..."
    sudo nmcli con up "$CON_LABEL"

else
    # Legacy dhcpcd.conf (si no hay NM)
    echo "--> Sistema Legacy (dhcpcd). Verifique /etc/dhcpcd.conf manualmente."
fi

echo "✅ Configuración Terminada."
echo "Verifique con: ifconfig $INTERFACE"

