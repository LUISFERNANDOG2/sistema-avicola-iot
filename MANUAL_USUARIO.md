# 📖 Manual de Usuario - Controlador Avícola

Este manual guía a los operarios y administradores en el uso del Dashboard Avícola para monitorear sus granjas.

## 1. Acceso al Sistema
1.  Abra su navegador web (Chrome, Edge, Firefox).
2.  Ingrese la dirección del servidor (ej: `http://192.168.1.100:5001`).
3.  **Login**: Ingrese sus credenciales. Si es la primera vez, contacte al administrador o regístrese si el sistema lo permite.

## 2. Pantalla Principal (Dashboard)
Al ingresar, verá el panel de control general:
*   **Tarjetas de Estado**: Muestra la última lectura de Temperatura, Humedad, CO2 y Amoniaco.
    *   🟢 **Verde**: Valores normales.
    *   🟡 **Amarillo**: Precaución.
    *   🔴 **Rojo**: Peligro (requiere acción inmediata).
*   **Gráfica en Vivo**: Muestra la tendencia de la última hora.

## 3. Gestión de Alertas 🚨

### ¿Qué son las alertas?
El sistema le avisará automáticamente si algo anda mal (ej: la temperatura sube de 30°C).

### ¿Cómo verlas?
Vaya a la pestaña **"Alertas"** en el menú lateral. Aquí verá una lista de todos los incidentes.

### Acciones Disponibles:
1.  **Marcar como Vista**: Si ya está enterado del problema pero lo está solucionando, presione el botón "✓" azul.
2.  **Marcar como Resuelta**: Cuando el problema físico (ej: ventilador apagado) se haya arreglado, presione el botón verde. La alerta pasará al historial de resueltas.
3.  **Eliminar Todas**: Si desea limpiar la pantalla por completo (ej: después de pruebas o mantenimiento), pulse el botón rojo **"🗑️ Eliminar todas"** en la parte superior derecha.
    *   *Nota: Esta acción borrará permanentemente el historial de alertas.*

## 4. Análisis Histórico 📊
Para ver qué pasó durante la noche o el fin de semana:
1.  Vaya a la pestaña **"Histórico"**.
2.  Despliegue el selector de rango (arriba a la derecha).
3.  Seleccione: "Últimas 24 horas", "Últimos 7 días" o "Rango Personalizado".
4.  Las gráficas se actualizarán para mostrarle la evolución de las variables.

## 5. Preguntas Frecuentes (FAQ)

**P: ¿Por qué no me llegan alertas nuevas?**
R: El sistema tiene una protección para no llenarle de mensajes. Solo enviará una alerta nueva **cada minuto** si el problema persiste.

**P: ¿Cómo cambio los límites de temperatura?**
R: Esta función está reservada para usuarios con rol de "Administrador" en la sección de Configuración/Umbrales (si está habilitada).

**P: La pantalla dice "Sin conexión"**
R: Verifique que el módulo sensor en la granja tenga luz verde y conectividad WiFi.
