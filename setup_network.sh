#!/bin/bash
# Script para configurar IP Estática en Raspberry Pi
# Soporta tanto NetworkManager (nmcli) como dhcpcd.conf (Legacy/Robust)

INTERFACE="${1:-wlan1}"
STATIC_IP="192.168.0.250"
ROUTER_IP="192.168.0.1"
DNS_IP="8.8.8.8"
SSID_NAME="Monitoring System"

echo "🌐 Configurando IP Estática ($STATIC_IP) en $INTERFACE..."

# --- MÉTODO 1: DHCPCD (El clásico y confiable) ---
# Si existe el archivo de configuración, usaremos este método prioritario
if [ -f /etc/dhcpcd.conf ]; then
    echo "--> Detectado /etc/dhcpcd.conf (Método Clásico)."
    
    # 1. Hacemos backup por si acaso
    sudo cp /etc/dhcpcd.conf /etc/dhcpcd.conf.bak.$(date +%s)
    
    # 2. Limpiamos configuración previa de esa interfaz para evitar duplicados
    # (Borra líneas que empiecen con 'interface wlan1' y las siguientes relacionadas)
    # Nota: Es una limpieza simple. Si está muy modificado manual, mejor revisar.
    
    # 3. Agregamos la nueva configuración al final
    echo "--> Escribiendo configuración en /etc/dhcpcd.conf..."
    cat <<EOT | sudo tee -a /etc/dhcpcd.conf > /dev/null

# Configuración Agregada por Avicola IoT
interface $INTERFACE
static ip_address=$STATIC_IP/24
static routers=$ROUTER_IP
static domain_name_servers=$DNS_IP
EOT

    # 4. Reiniciamos el servicio networking y dhcpcd
    echo "--> Reiniciando servicio dhcpcd..."
    sudo service dhcpcd restart
    
    echo "✅ Configuración aplicada vía dhcpcd."
    echo "   Si no ves cambios, prueba reiniciar: sudo reboot"
    
    # Si usamos dhcpcd, intentamos no pelear con NetworkManager
    exit 0
fi

# --- MÉTODO 2: NetworkManager (nmcli) ---
# Solo llegamos aquí si NO existe dhcpcd.conf
if command -v nmcli &> /dev/null; then
    echo "--> No se encontró dhcpcd.conf. Usando NetworkManager..."
    CON_LABEL="Avicola_Static_IP"

    # Limpiar conexiones duplicadas
    existing_uuids=$(nmcli -t -f UUID,DEVICE connection show | grep $INTERFACE | cut -d: -f1)
    for uuid in $existing_uuids; do
        sudo nmcli connection delete $uuid
    done
    sudo nmcli connection delete "$CON_LABEL" 2>/dev/null || true

    # Crear conexión
    sudo nmcli con add type wifi ifname $INTERFACE con-name "$CON_LABEL" ssid "$SSID_NAME"
    sudo nmcli con mod "$CON_LABEL" ipv4.addresses $STATIC_IP/24
    sudo nmcli con mod "$CON_LABEL" ipv4.gateway $ROUTER_IP
    sudo nmcli con mod "$CON_LABEL" ipv4.dns $DNS_IP
    sudo nmcli con mod "$CON_LABEL" ipv4.method manual
    sudo nmcli con mod "$CON_LABEL" connection.autoconnect yes
    sudo nmcli con up "$CON_LABEL"
    
    echo "✅ Configuración aplicada vía NetworkManager."
else
    echo "❌ Error: No se encontró ni dhcpcd.conf ni NetworkManager."
    exit 1
fi


