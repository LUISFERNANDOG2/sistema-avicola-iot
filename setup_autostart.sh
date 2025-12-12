# Avícola IoT - Script de Autoinicio
# Este script asegura que Docker inicie con el sistema
# Uso: sudo ./setup_autostart.sh

echo "🛠️ Configurando autoinicio de Docker..."

# 1. Habilitar el servicio Docker en systemd
sudo systemctl enable docker.service
sudo systemctl enable containerd.service

echo "✅ Servicios de Docker habilitados."

# 2. Reiniciar contenedores actuales con la nueva política
echo "🔄 Aplicando política 'restart: always'..."
docker-compose -f docker-compose.raspberry.yml up -d

echo "🎉 ¡Listo! El sistema iniciará automáticamente si se va la luz."
