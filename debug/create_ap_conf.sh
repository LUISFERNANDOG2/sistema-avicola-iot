#!/bin/bash

# ============================================================================
# Script para levantar Access Point estable con create_ap en Raspberry Pi 4
# Autor: Luis Fernando González
# ============================================================================

SSID="Modulo_2"
PASS="localwifi_123321"
AP_IFACE="wlan0"     # Interfaz Wi-Fi del AP
INTERNET_IFACE="wlan0" # Si solo quieres AP local, puedes repetir la misma

echo "[+] Actualizando paquetes..."
sudo apt update
sudo apt install -y git util-linux procps hostapd iproute2 iw haveged dnsmasq

echo "[+] Clonando create_ap..."
git clone https://github.com/oblique/create_ap ~/create_ap
cd ~/create_ap
sudo make install

echo "[+] Creando AP '$SSID' sin acceso a internet (solo red local)..."
sudo create_ap --no-virt $AP_IFACE $INTERNET_IFACE $SSID $PASS &

echo "[+] Instalando create_ap como servicio systemd..."
sudo create_ap --install-system-wide

# Configuración automática al inicio
echo "[+] Configurando systemd para levantar AP al iniciar..."
sudo bash -c "cat > /etc/create_ap.conf <<EOF
# Interfaz de AP
INTERFACE=$AP_IFACE

# Interfaz de internet (igual que AP para red local)
INTERNET_IFACE=$INTERNET_IFACE

# SSID y contraseña
SSID=$SSID
PASSPHRASE=$PASS

# Opciones
CHANNEL=6
HIDDEN=0
EOF"

echo "[+] Habilitando y arrancando servicio..."
sudo systemctl enable create_ap
sudo systemctl start create_ap

echo ""
echo "============================================="
echo "✅ AP configurado correctamente"
echo "SSID: $SSID"
echo "Password: $PASS"
echo "IP del AP: 10.10.0.1 aprox (DHCP automático)"
echo "============================================="
echo ""
echo "[+] Reinicia la Raspberry Pi para probar el arranque automático:"
echo "    sudo reboot"
