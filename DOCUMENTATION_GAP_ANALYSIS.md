# Análisis de Brechas en Documentación y Configuración

## Resumen Ejecutivo
Durante la revisión del proyecto "Sistema Avícola IoT" con el objetivo de preparar un entorno de producción en WSL2 usando Cloudflare Tunnels, se identificaron y solucionaron varias inconsistencias críticas entre el código, la configuración de despliegue y la documentación existente.

## 1. Brechas Identificadas

### 1.1 Seguridad MQTT (Crítico)
*   **Problema**: El archivo `docker-compose.prod.yml` original contenía un comando inline complejo que intentaba configurar Mosquitto, pero no existía ningún mecanismo automatizado para generar el archivo de contraseñas (`passwd`). Además, la configuración de `allow_anonymous` era ambigua.
*   **Solución**:
    *   Se creó `generate_mqtt_pass.sh` para crear usuarios de forma interactiva.
    *   Se simplificó `docker-compose.prod.yml` para usar archivos de configuración montados.
    *   Se endureció `mosquitto.conf` (`allow_anonymous false`).

### 1.2 Accesibilidad Externa (Cloudflare Tunnels)
*   **Problema**: La documentación solo mencionaba "Despliegue Local". No existía guía para exponer el sistema a internet sin abrir puertos en el router (CGNAT/Starlink/etc).
*   **Estado**: Implementado soporte dual.
    *   **Modo Rápido**: Script `start_tunnels.sh` para pruebas inmediatas (Dashboard HTTP + MQTT TCP).
    *   **Modo Dominio**: Archivo `docker-compose.domain.yml` preparado para el futuro.

### 1.3 Firmware IoT vs Infraestructura
*   **Problema**: El firmware del ESP32 estaba configurado con IPs locales (`192.168.x.x`). Al mover el servidor a un túnel de Cloudflare, la forma de conectar cambia drásticamente (URL dinámica + Puerto aleatorio).
*   **Solución**: Se creó `FIRMWARE_GUIDE.md` explicando cómo adaptar el código C++ del ESP32 para soportar autenticación y direcciones de túnel.

## 2. Archivos Nuevos/Modificados
| Archivo | Estado | Propósito |
| :--- | :--- | :--- |
| `docker-compose.prod.yml` | 🛠️ Modificado | Fix volúmenes y comando MQTT |
| `mosquitto/mosquitto.conf` | 🛠️ Modificado | Seguridad habilitada |
| `docker-compose.domain.yml` | ✨ Nuevo | Plantilla para futuro dominio |
| `start_tunnels.sh` | ✨ Nuevo | Lanza túneles HTTP y TCP visualizando URLs |
| `generate_mqtt_pass.sh` | ✨ Nuevo | Generador de credenciales MQTT |
| `FIRMWARE_GUIDE.md` | ✨ Nuevo | Guía de conexión para ESP32 |

## 3. Recomendaciones Finales
1.  **Transición a Dominio**: El uso de "Quick Tunnels" para MQTT en producción es desaconsejado debido al cambio constante de puertos tras cada reinicio, lo que obliga a reflashear los dispositivos. Se recomienda adquirir un dominio lo antes posible.
2.  **Persistencia**: Asegúrese de que la carpeta `./mosquitto/data` tenga persistencia para no perder mensajes en cola si el contenedor se reinicia.
