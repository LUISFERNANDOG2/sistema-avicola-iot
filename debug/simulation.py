import paho.mqtt.client as mqtt
import time
import random

# Valores iniciales realistas
temperature = 28.0
humidity = 55.0
ammonia = 20.0
co2 = 900.0

# Cliente MQTT (se inicializa en start())
client = None

# Función para generar variaciones suaves
def smooth_variation(value, min_val, max_val, max_step):
    # Variación suave entre -max_step y +max_step
    step = random.uniform(-max_step, max_step)
    value += step

    # Limitar dentro del rango
    if value < min_val: value = min_val
    if value > max_val: value = max_val

    return round(value, 2)

def start():
    global temperature, humidity, ammonia, co2, client
    
    print("🎮 Iniciando Simulación de Lecturas MQTT...")
    print("🔌 Conectando a broker MQTT en localhost:1883...")
    
    try:
        # Crear y conectar cliente MQTT
        client = mqtt.Client()
        client.connect("localhost", 1883, 60)
        print("✅ Conectado al broker MQTT correctamente")
        
        # Iniciar loop en background para mantener la conexión
        client.loop_start()
        
    except ConnectionRefusedError:
        print("❌ ERROR: No se pudo conectar al broker MQTT")
        print("   💡 El broker MQTT no está ejecutándose en localhost:1883")
        print("   💡 Para instalar Mosquitto en Windows:")
        print("      - Descarga desde: https://mosquitto.org/download/")
        print("      - O usa Docker: docker run -it -p 1883:1883 eclipse-mosquitto")
        print("   ⚠️  La simulación no se ejecutará sin un broker MQTT")
        return
    except Exception as e:
        print(f"❌ ERROR conectando al broker MQTT: {e}")
        print("   ⚠️  La simulación no se ejecutará sin un broker MQTT")
        return

    print("📡 Publicando datos de sensores simulados...")
    print("   (Presiona Ctrl+C para detener)\n")

    try:
        while True:
            # Cambios suaves por parámetro
            temperature = smooth_variation(temperature, 26, 32, 0.15)  # ±0.15 °C
            humidity    = smooth_variation(humidity, 45, 70, 0.5)     # ±0.5 %
            ammonia     = smooth_variation(ammonia, 10, 40, 0.2)      # ±0.2 ppm
            co2         = smooth_variation(co2, 600, 2000, 5)         # ±5 ppm

            # Publicar
            if client:
                client.publish("avicola/temp", temperature)
                client.publish("avicola/humedad", humidity)
                client.publish("avicola/amoniaco", ammonia)
                client.publish("avicola/co2", co2)

            print(f"📊 T={temperature}°C H={humidity}% NH3={ammonia}ppm CO2={co2}ppm")

            time.sleep(2)
    except KeyboardInterrupt:
        print("\n🛑 Deteniendo simulación...")
        if client:
            client.loop_stop()
            client.disconnect()
        print("✅ Simulación detenida correctamente")

if __name__ == '__main__':
    start()
