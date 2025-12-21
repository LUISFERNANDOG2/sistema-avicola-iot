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
