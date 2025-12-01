# SIPII Flutter - Configuración y Uso

## 🚀 Instalación de Dependencias

Después de clonar el proyecto, ejecuta:

```bash
cd sipii_flutter
flutter pub get
```

## ⚙️ Configuración de la API

### 1. Obtener tu IP Local

**Windows:**
```bash
ipconfig
```
Busca "Dirección IPv4" en tu adaptador de red activo (WiFi o Ethernet).

**macOS/Linux:**
```bash
ifconfig
```
Busca la dirección IP en `en0` o `wlan0`.

### 2. Actualizar la URL del API

Edita el archivo `lib/services/api_service.dart`:

```dart
class ApiService {
  // Cambia esta IP por la tuya
  static const String baseUrl = 'http://TU_IP_LOCAL:8000/api';
  
  // Ejemplo:
  // static const String baseUrl = 'http://192.168.1.100:8000/api';
}
```

**IMPORTANTE:** 
- El backend debe estar corriendo en puerto **8000** (API unificada)
- Tu dispositivo móvil debe estar en la **misma red WiFi** que tu computadora
- Si usas emulador de Android, puedes usar `http://10.0.2.2:8000/api`

## 🏃‍♂️ Ejecutar la Aplicación

### Usando Emulador/Simulador:
```bash
flutter run
```

### Usando Dispositivo Físico:
1. Conecta tu dispositivo por USB
2. Habilita "Depuración USB" en opciones de desarrollador
3. Ejecuta:
```bash
flutter devices  # Ver dispositivos conectados
flutter run
```

## 📱 Funcionalidades Implementadas

### ✅ Autenticación (Sanctum)
- **Login:** Email y contraseña
- **Registro:** Formulario completo con validación
- **Logout:** Revocación de token
- **Persistencia:** Token guardado localmente con SharedPreferences

### ✅ Endpoints Públicos (sin autenticación)
- `GET /api/public/focos-incendios` - Ver focos de incendio
- `GET /api/public/biomasas` - Ver biomasas
- `GET /api/public/tipos-biomasa` - Ver tipos de biomasa

### ✅ Endpoints Protegidos (requieren login)
- `POST /api/biomasas` - Crear biomasa
- `PUT /api/biomasas/{id}` - Actualizar biomasa
- `DELETE /api/biomasas/{id}` - Eliminar biomasa

## 🗺️ Estructura de Pantallas

```
/                   → LoginScreen (pantalla inicial)
/register           → RegisterScreen (crear cuenta)
/map                → MapScreen (mapa con focos y biomasas)
```

## 🔐 Flujo de Autenticación

1. **Usuario sin cuenta:**
   - Abre app → LoginScreen
   - Clic en "Regístrate" → RegisterScreen
   - Completa formulario → Token guardado automáticamente
   - Redirección a MapScreen

2. **Usuario con cuenta:**
   - Abre app → LoginScreen
   - Ingresa email/contraseña → Token guardado
   - Redirección a MapScreen

3. **Modo sin autenticación:**
   - Clic en "Continuar sin iniciar sesión"
   - Solo puede ver datos públicos
   - No puede crear/editar/eliminar biomasas

## 📦 Dependencias Principales

```yaml
dependencies:
  flutter_map: ^6.1.0        # Mapas interactivos
  latlong2: ^0.9.0           # Coordenadas geográficas
  http: ^1.1.0               # Requests HTTP
  shared_preferences: ^2.2.2 # Almacenamiento local (tokens)
  geolocator: ^10.1.0        # Geolocalización
  permission_handler: ^11.0.1 # Permisos
  share_plus: ^7.2.1         # Compartir por WhatsApp
  provider: ^6.1.1           # Gestión de estado
```

## 🐛 Solución de Problemas

### Error: "Connection refused"
- ✅ Verifica que el backend esté corriendo en puerto 8000
- ✅ Verifica que la IP en `api_service.dart` sea correcta
- ✅ Asegúrate de estar en la misma red WiFi

### Error: "Unauthenticated"
- ✅ Verifica que el token se esté guardando correctamente
- ✅ Revisa que el header `Authorization: Bearer {token}` se esté enviando
- ✅ Intenta hacer logout y login nuevamente

### No se muestran datos en el mapa
- ✅ Verifica que existan biomasas/focos en la base de datos
- ✅ Revisa los logs de Flutter: `flutter logs`
- ✅ Verifica que los endpoints públicos funcionen: 
  ```bash
  curl http://TU_IP:8000/api/public/biomasas
  ```

## 📝 Próximas Mejoras

- [ ] Pantalla de perfil de usuario
- [ ] Edición de biomasas desde el mapa
- [ ] Notificaciones push para nuevos focos
- [ ] Modo offline con caché local
- [ ] Filtros avanzados en el mapa
- [ ] Exportar datos a PDF/CSV

## 🔄 Actualizar Dependencias

```bash
flutter pub upgrade
```

## 🧪 Testing

```bash
flutter test
```

## 📱 Build para Producción

### Android:
```bash
flutter build apk --release
# APK generado en: build/app/outputs/flutter-apk/app-release.apk
```

### iOS:
```bash
flutter build ios --release
# Requiere macOS y Xcode
```

---

**Versión:** 1.0.0  
**Backend:** Laravel 11 con Sanctum  
**API:** http://localhost:8000/api
