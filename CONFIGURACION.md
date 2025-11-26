# Configuración de la Aplicación SIPII Flutter

## 📱 Configuración de la URL de la API

La aplicación necesita conectarse a tu servidor Laravel. Debes configurar la URL correcta en el archivo:

**Archivo:** `lib/services/api_service.dart`

### Ejemplos de configuración según tu entorno:

#### 1. Emulador Android
```dart
static const String baseUrl = 'http://10.0.2.2:8000/api';
```
La IP `10.0.2.2` es un alias especial del emulador Android que apunta al `localhost` de tu PC.

#### 2. Simulador iOS
```dart
static const String baseUrl = 'http://localhost:8000/api';
// o también:
static const String baseUrl = 'http://127.0.0.1:8000/api';
```

#### 3. Dispositivo físico en la misma red WiFi
```dart
static const String baseUrl = 'http://192.168.1.100:8000/api';
```
⚠️ Reemplaza `192.168.1.100` con la IP de tu computadora en la red local.

**Para obtener tu IP local:**
```powershell
# Windows
ipconfig
# Busca "Dirección IPv4" en la sección de tu adaptador WiFi/Ethernet
```

#### 4. Servidor en producción
```dart
static const String baseUrl = 'https://tu-dominio.com/api';
```

---

## 🔧 Configuración del Servidor Laravel

Para que la API sea accesible desde dispositivos móviles, debes iniciar el servidor con:

```powershell
php artisan serve --host=0.0.0.0 --port=8000
```

El flag `--host=0.0.0.0` permite conexiones desde cualquier IP de tu red local.

---

## ✅ Verificar la Conexión

1. **Verifica que el servidor Laravel esté corriendo:**
   - Abre en tu navegador: `http://localhost:8000/api/public/focos-incendios`
   - Deberías ver una respuesta JSON

2. **Desde un dispositivo en la misma red:**
   - Abre en el navegador del dispositivo: `http://TU-IP:8000/api/public/focos-incendios`
   - Si ves JSON, la conexión funciona

3. **Si no funciona:**
   - Desactiva temporalmente el firewall de Windows
   - Asegúrate de que ambos dispositivos estén en la misma red WiFi
   - Verifica que el puerto 8000 no esté bloqueado

---

## 🚀 Endpoints Disponibles (Públicos)

La aplicación usa estos endpoints que **NO requieren autenticación:**

- `GET /api/public/focos-incendios` - Obtener todos los focos de incendio
- `GET /api/public/tipos-biomasa` - Obtener tipos de biomasa

### Formato de respuesta esperado:

**Focos de Incendio:**
```json
{
  "data": [
    {
      "id": 1,
      "fecha": "2024-11-26",
      "ubicacion": "Bosque del Norte",
      "coordenadas": [40.4168, -3.7038],
      "intensidad": 7.5
    }
  ]
}
```

**Biomasas:**
```json
{
  "data": [
    {
      "id": 1,
      "tipo_biomasa_id": 1,
      "densidad": "Alta",
      "coordenadas": [[40.4168, -3.7038], [40.4169, -3.7039], [40.4170, -3.7040]],
      "area_m2": 1500.50,
      "perimetro_m": 200.0,
      "descripcion": "Zona de alta vegetación",
      "fecha_reporte": "2024-11-26",
      "tipo_biomasa": {
        "nombre": "Arbustos"
      }
    }
  ]
}
```

---

## 🔐 Estado de Autenticación

**Estado actual:** La pantalla de login está implementada pero **no funciona** todavía.

Puedes:
- Hacer clic en "Continuar sin iniciar sesión" para acceder al mapa
- O ingresar cualquier email/contraseña y hacer clic en "Iniciar Sesión"

Ambas opciones te llevarán al mapa (la autenticación se implementará en futuras versiones).

---

## 📍 Permisos de Ubicación

La app solicita permisos de ubicación, pero por ahora **no los usa**. El mapa se centra en:
- Las coordenadas del primer foco de incendio cargado
- O en el centro de España (40.4168, -3.7038) por defecto

En futuras versiones se implementará:
- Centrar el mapa en tu ubicación actual
- Reportar focos desde tu ubicación

---

## 🗺️ Proveedores de Mapas

La aplicación usa **OpenStreetMap** (gratuito, sin API key necesaria).

Si quieres cambiar a otro proveedor de tiles, edita `lib/screens/map_screen.dart`:

```dart
TileLayer(
  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  // Cambia la URL aquí
)
```

Otras opciones populares:
- **Mapbox:** `https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}`
- **Google Maps:** Requiere configuración adicional y API key
- **Stamen Terrain:** `https://tiles.stadiamaps.com/tiles/stamen_terrain/{z}/{x}/{y}.png`

---

## 🛠️ Variables de Entorno (Futuro)

Para una mejor práctica, se recomienda mover la configuración a un archivo `.env`:

1. Crea un archivo `lib/config/environment.dart`:
```dart
class Environment {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:8000/api',
  );
}
```

2. Úsalo en `api_service.dart`:
```dart
import '../config/environment.dart';

static const String baseUrl = Environment.apiBaseUrl;
```

3. Al ejecutar:
```powershell
flutter run --dart-define=API_URL=http://192.168.1.100:8000/api
```
