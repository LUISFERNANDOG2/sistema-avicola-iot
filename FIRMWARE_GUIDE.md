# 📟 Guía de Firmware ESP32 - Conexión MQTT y Cloudflare

Esta guía explica cómo configurar el firmware de tus módulos ESP32 (IoT) para conectarse al servidor MQTT, cubriendo dos escenarios:
1.  **Escenario A: Túnel Rápido (Cloudflare Quick Tunnel)** - Sin dominio propio (Actual).
2.  **Escenario B: Dominio Propio** - Producción final con dominio comprado.

---

## 📋 Requisitos Previos

1.  Haber generado el archivo de contraseñas MQTT en el servidor (`./generate_mqtt_pass.sh`).
2.  Conocer el **Usuario** y **Contraseña** MQTT que creaste.

---

## 🛠️ Configuración Común (Para ambos escenarios)

Abre tu archivo `.ino` (ej: `firmware_modulo_iot_json.ino`) y busca la sección de configuración MQTT.

### 1. Agregar Credenciales
Busca la función `client.setServer(...)` en el `setup()` o la conexión en `reconnect()`. Debes modificar la función `connect` para incluir usuario y contraseña.

**Código Original (`reconnect`):**
```cpp
if (client.connect("ESP32Client")) {
```

**Código Modificado:**
```cpp
// Reemplaza "usuario_mqtt" y "password_seguro" con tus credenciales reales
if (client.connect("ESP32Client", "usuario_mqtt", "password_seguro")) {
```

> [!IMPORTANT]
> Si no haces esto, el broker rechazará la conexión porque ahora hemos activado `allow_anonymous false` por seguridad.

---

## 🅰️ Escenario A: Túnel Rápido (Sin Dominio)

En este escenario, Cloudflare te asigna una URL y un PUERTO aleatorio cada vez que inicias el túnel.

### Paso 1: Obtener la Dirección y Puerto
Ejecuta en tu servidor/WSL el script de inicio:
```bash
./start_tunnels.sh
```

Verás una salida como esta:
```text
✅ MQTT BROKER URL:   tcp://random-name-123.trycloudflare.com:54321
```

### Paso 2: Configurar el Firmware
Copia la URL (sin `tcp://`) y el puerto en tu código.

```cpp
// Configuración Cloudflare - Escenario A (Dinámico)
const char* mqtt_server = "random-name-123.trycloudflare.com";
const int mqtt_port = 54321; // <--- ¡OJO! Este puerto cambia siempre
```

En la función `setup()`, asegúrate de usar la variable del puerto:
```cpp
client.setServer(mqtt_server, mqtt_port);
```

> [!WARNING]
> **Desventaja**: Cada vez que reinicies el script `start_tunnels.sh`, la URL y el puerto CAMBIARÁN. Tendrás que actualizar el firmware y volver a subirlo a los ESP32.

---

## 🅱️ Escenario B: Dominio Propio (Recomendado)

En este escenario, configuras un subdominio fijo (ej: `mqtt.midominio.com`) que siempre apunta a tu servidor.

### Paso 1: Configurar DNS y Tunnel
1.  Compra tu dominio (ej: `midominio.com`).
2.  Configura el túnel en el Dashboard de Cloudflare (Zero Trust > Networks > Tunnels).
3.  Agrega un "Public Hostname" para MQTT:
    *   **Subdomain**: `mqtt`
    *   **Domain**: `midominio.com`
    *   **Service**: `tcp://localhost:1883`

### Paso 2: Configurar el Firmware
Ahora la configuración es fija y nunca cambia.

```cpp
// Configuración Cloudflare - Escenario B (Fijo)
const char* mqtt_server = "mqtt.midominio.com";
const int mqtt_port = 1883; // Generalmente Cloudflare proxy usa puertos estándar o mapeados
```
*Nota: Dependiendo de tu configuración de Cloudflare (Spectrum o WARP), el puerto podría variar, pero la dirección será fija.*

---

## 🐛 Solución de Problemas

1.  **Error rc=-2 (Conexión fallida)**:
    *   Verifica que el túnel esté corriendo.
    *   Verifica que copiaste el puerto correcto (si usas Escenario A).
2.  **Error rc=-5 (No autorizado)**:
    *   Verifica usuario y contraseña en `client.connect()`.
3.  **Desconexiones frecuentes**:
    *   Asegura que el `KeepAlive` en la librería `PubSubClient` sea suficiente (ej: 60s).
