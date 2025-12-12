# 📖 Manual de Operación y Usuario - Sistema Avícola Inteligente

**Versión:** 1.0  
**Última Actualización:** Diciembre 2025  
**Audiencia:** Administradores de Granja, Veterinarios y Operarios.

---

## 📋 Tabla de Contenidos
1.  Introducción y Conceptos Básicos
2.  Acceso al Sistema (Login)
3.  Navegación General
4.  Módulo 1: Dashboard en Tiempo Real
5.  Módulo 2: Centro de Alertas
6.  Módulo 3: Historial y Reportes
7.  Solución de Problemas Frecuentes

---

## 1. Introducción y Conceptos Básicos

Este sistema le permite monitorear el bienestar de sus aves las 24 horas del día. A continuación, explicamos las variables que se miden:

*   **🌡️ Temperatura (°C)**: Control térmico. Valores muy altos causan estrés calórico; muy bajos, hipotermia.
*   **💧 Humedad (%)**: Exceso de humedad favorece bacterias y hongos.
*   **💨 CO2 (Dióxido de Carbono)**: Indica mala ventilación. Valores altos causan letargo.
*   **☠️ NH3 (Amoniaco)**: Gas tóxico producido por las heces. Muy peligroso para los pulmones de las aves incluso en niveles bajos.

---

## 2. Acceso al Sistema

### 2.1 Iniciar Sesión
1.  Abra el navegador e ingrese a la dirección del servidor (ej: `http://localhost:5001`).
2.  Verá la pantalla de bienvenida.
3.  Ingrese su **Nombre de Usuario** y **Contraseña**.
4.  Pulse el botón azul **"Iniciar Sesión"**.

> **[INSERTAR CAPTURA AQUÍ: Pantalla de Login]**
> *Muestre el formulario de entrada limpio.*

### 2.2 Registro de Nuevo Usuario
Si es su primera vez:
1.  En la pantalla de login, haga clic en "¿No tienes cuenta? **Regístrate**".
2.  Llene el formulario con:
    *   **Nombre de Usuario**: Único para entrar (ej: `juan.perez`).
    *   **Nombre Completo**: Su nombre real.
    *   **Contraseña**: Mínimo 6 caracteres.
3.  Pulse **"Registrarse"**. El sistema lo redirigirá al login automáticamente.

---

## 3. Navegación General
El sistema cuenta con una **Barra Lateral (Sidebar)** a la izquierda que le permite moverse entre secciones.

*   **📊 Dashboard**: Vista general en vivo (Inicio).
*   **⚠️ Alertas**: Notificaciones de problemas.
*   **📅 Histórico**: Gráficas de días anteriores.
*   **⚙️ Configuración**: Ajuste de umbrales.
*   **🚪 Cerrar Sesión**: Salir del sistema de forma segura.

---

## 4. Módulo 1: Dashboard en Tiempo Real
Esta es la pantalla principal. Se actualiza automáticamente cada pocos segundos **sin recargar la página**.

### 4.1 Tarjetas de Sensores
Verá 4 tarjetas grandes (Temperatura, Humedad, etc.).
*   **Color Verde**: Todo está bien.
*   **Color Amarillo (Advertencia)**: El valor está un poco alto, preste atención.
*   **Color Rojo (Peligro)**: ¡Acción inmediata requerida! El valor es crítico.

> **[INSERTAR CAPTURA AQUÍ: Dashboard con tarjetas de colores]**
> *Intente que en la foto se vea al menos una tarjeta en color amarillo o rojo para el ejemplo.*

### 4.2 Gráfica de Tendencia
Debajo de las tarjetas, una gráfica lineal muestra cómo ha cambiado la temperatura en la última hora. Úsela para ver si la temperatura está subiendo o bajando rápidamente.

---

## 5. Módulo 2: Centro de Alertas ⚠️ (MUY IMPORTANTE)
Aquí es donde el sistema le "habla" si algo anda mal.

### 5.1 Tipos de Prioridad
*   🔴 **CRÍTICA**: Peligro inminente (ej: Temperatura > 32°C). Actuar YA.
*   🟡 **ALTA**: Advertencia (ej: Temperatura > 28°C). Revisar ventilación.
*   🔵 **INFO**: Mensajes del sistema.

### 5.2 Gestión de Alertas (Paso a Paso)
Cuando vea una alerta en la lista:

1.  **Leer el Mensaje**: Identifique qué módulo (galpón) y qué variable falla.
    *   *Ejemplo: "Temperatura en M1 superó el umbral CRÍTICO: 35.5°C"*
2.  **Marcar como Vista (👁️)**: Si ya está atendiendo el problema, pulse el botón azul. Esto le dice a otros usuarios "Ya lo vi, estoy en ello".
3.  **Marcar como Resuelta (✅)**: Una vez corregido el problema físico (ej: encendió el ventilador), pulse el botón verde. La alerta desaparecerá de la lista de pendientes.

> **[INSERTAR CAPTURA AQUÍ: Lista de Alertas con botones de acción]**
> *Muestre una alerta crítica y los botones de 'Marcar vista' y 'Resolver'.*

### 5.3 Limpieza Total (Eliminar Todas)
Si desea limpiar la pantalla por completo (ej: después de pruebas):
1.  Busque el botón rojo **"🗑️ Eliminar todas"** en la esquina superior derecha.
2.  Confirme la acción en la ventana emergente.
    *   **⚠️ Cuidado**: Esto borra el historial de alertas permanentemente.

---

## 6. Módulo 3: Historial y Reportes
Para análisis post-mortem o reportes semanales.

1.  Vaya a la pestaña **"Histórico"**.
2.  **Filtro de Tiempo**: Arriba a la derecha, seleccione el rango que desea ver:
    *   24 Horas
    *   7 Días
    *   Mes actual
    *   **Personalizado**: Le permite elegir fecha de inicio y fin exactas.
3.  **Exportar**: (Próximamente) Podrá descargar estos datos a Excel.

> **[INSERTAR CAPTURA AQUÍ: Gráfica Histórica mostrando una curva de datos]**

---

## 7. Solución de Problemas (Troubleshooting)

| Problema | Causa Probable | Solución |
| :--- | :--- | :--- |
| **"Sin Conexión"** en Dashboard | El módulo ESP32 está apagado o sin WiFi. | Revise la alimentación eléctrica del módulo y su conexión a la red. |
| **No puedo entrar (Login)** | Contraseña incorrecta o usuario no existe. | Verifique mayúsculas. Si persiste, pida al Admin que reinicie su clave. |
| **Alerta repetitiva** | El valor sigue alto y el tiempo de espera pasó. | El sistema recordará el problema cada 60 segundos hasta que baje el valor. Solucione la causa raíz. |
| **Gráfica vacía** | No hay datos en el rango seleccionado. | Intente seleccionar un rango de fechas más amplio. |

---

> **Soporte Técnico**: Para dudas no cubiertas en este manual, contacte al área de TI al correo: soporte@avicola.com
