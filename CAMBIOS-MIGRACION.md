# 📱 SIPII Flutter - Migración a API Unificada

## ✅ Cambios Realizados

### 1. Actualización del ApiService

**Archivo:** `lib/services/api_service.dart`

#### Antes (API Obsoleta - Puerto 8001):
```dart
static const String baseUrl = 'http://192.168.0.27:8001/api';
```

#### Después (API Unificada - Puerto 8000):
```dart
static const String baseUrl = 'http://192.168.0.27:8000/api';
```

#### Nuevas Funcionalidades Agregadas:

1. **Gestión de Tokens con SharedPreferences:**
   - `saveToken(String token)` - Guardar token
   - `getToken()` - Obtener token actual
   - `clearToken()` - Eliminar token
   - `isAuthenticated()` - Verificar autenticación
   - `authHeaders` - Headers con Authorization Bearer

2. **Autenticación Completa:**
   - `register()` - Registro con validación completa
   - `login()` - Login con email/password
   - `logout()` - Cierre de sesión con revocación de token

3. **CRUD de Biomasas Protegido:**
   - `createBiomasa()` - Crear nueva biomasa (requiere auth)
   - `updateBiomasa()` - Actualizar biomasa (requiere auth)
   - `deleteBiomasa()` - Eliminar biomasa (requiere auth)

4. **Endpoints Públicos (Sin Cambios):**
   - `getFocosIncendio()` - GET /api/public/focos-incendios
   - `getBiomasas()` - GET /api/public/biomasas
   - `getTiposBiomasa()` - GET /api/public/tipos-biomasa

---

### 2. LoginScreen Mejorado

**Archivo:** `lib/screens/login_screen.dart`

#### Cambios:
- ✅ Integración real con `ApiService.login()`
- ✅ Manejo de errores con SnackBar
- ✅ Validación de credenciales
- ✅ Guardado automático de token
- ✅ Link a pantalla de registro
- ✅ Opción de continuar sin login

#### Código Agregado:
```dart
final result = await ApiService.login(
  _emailController.text.trim(),
  _passwordController.text,
);

if (result['success'] == true) {
  // Token guardado automáticamente
  Navigator.pushReplacementNamed(context, '/map');
}
```

---

### 3. RegisterScreen (NUEVO)

**Archivo:** `lib/screens/register_screen.dart`

#### Funcionalidades:
- ✅ Formulario completo de registro
- ✅ Validación de campos (nombre, email, teléfono, cédula, contraseñas)
- ✅ Confirmación de contraseña
- ✅ Integración con `ApiService.register()`
- ✅ Guardado automático de token
- ✅ Manejo de errores de validación del backend
- ✅ Navegación automática al mapa tras registro exitoso

#### Campos del Formulario:
1. Nombre Completo (min 3 caracteres)
2. Email (validación de formato)
3. Teléfono (min 8 dígitos)
4. Cédula de Identidad (min 6 dígitos)
5. Contraseña (min 6 caracteres)
6. Confirmar Contraseña (debe coincidir)

---

### 4. Dependencias Actualizadas

**Archivo:** `pubspec.yaml`

#### Agregado:
```yaml
dependencies:
  shared_preferences: ^2.2.2  # Almacenamiento local de tokens
```

#### Instalación:
```bash
flutter pub get
```

---

### 5. Rutas Actualizadas

**Archivo:** `lib/main.dart`

#### Rutas Agregadas:
```dart
routes: {
  '/': (context) => const LoginScreen(),
  '/register': (context) => const RegisterScreen(),  // NUEVO
  '/map': (context) => const MapScreen(),
}
```

---

### 6. Documentación Actualizada

**Archivos Creados/Actualizados:**

1. **`sipii_flutter/README-CONFIG.md`** (NUEVO)
   - Instrucciones completas de configuración
   - Cómo obtener IP local
   - Cómo ejecutar la app
   - Solución de problemas comunes

2. **`LEEME-ESTRUCTURA.md`** (ACTUALIZADO)
   - Sección de Flutter actualizada
   - Instrucciones de autenticación
   - Lista de endpoints implementados

---

## 🔐 Flujo de Autenticación Implementado

### 1. Registro de Usuario:
```
Usuario abre app
  ↓
LoginScreen
  ↓
Clic "Regístrate"
  ↓
RegisterScreen
  ↓
Completa formulario
  ↓
POST /api/register
  ↓
Backend valida y crea usuario
  ↓
Response con token
  ↓
App guarda token en SharedPreferences
  ↓
Navega a MapScreen
```

### 2. Login de Usuario:
```
Usuario abre app
  ↓
LoginScreen
  ↓
Ingresa email/password
  ↓
POST /api/login
  ↓
Backend valida credenciales
  ↓
Response con token
  ↓
App guarda token
  ↓
Navega a MapScreen
```

### 3. Peticiones Protegidas:
```
Usuario crea biomasa
  ↓
MapScreen
  ↓
POST /api/biomasas
  ↓
Headers incluyen: Authorization: Bearer {token}
  ↓
Backend valida token con Sanctum
  ↓
Si válido: Crea biomasa
  ↓
Si inválido: Error 401
```

### 4. Logout:
```
Usuario cierra sesión
  ↓
POST /api/logout (con token)
  ↓
Backend revoca token
  ↓
App elimina token de SharedPreferences
  ↓
Navega a LoginScreen
```

---

## 📊 Comparación Antes vs Después

| Aspecto | Antes (API Obsoleta) | Después (API Unificada) |
|---------|---------------------|-------------------------|
| Puerto API | 8001 | 8000 |
| Autenticación | No implementada | Sanctum completo |
| Registro | No disponible | Formulario completo |
| Login | Simulado | Real con backend |
| Tokens | No guardados | SharedPreferences |
| CRUD Biomasas | Solo GET público | POST/PUT/DELETE protegidos |
| Manejo de errores | Básico | Completo con mensajes |
| Persistencia de sesión | No | Sí (token guardado) |
| Headers | Solo públicos | Con Authorization |

---

## 🧪 Testing de Endpoints

### Endpoints Públicos (Sin Token):
```bash
# Focos de incendio
curl http://TU_IP:8000/api/public/focos-incendios

# Biomasas
curl http://TU_IP:8000/api/public/biomasas

# Tipos de biomasa
curl http://TU_IP:8000/api/public/tipos-biomasa
```

### Registro:
```bash
curl -X POST http://TU_IP:8000/api/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "password": "password123",
    "password_confirmation": "password123",
    "telefono": "12345678",
    "cedula_identidad": "1234567"
  }'
```

### Login:
```bash
curl -X POST http://TU_IP:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

### Crear Biomasa (Con Token):
```bash
curl -X POST http://TU_IP:8000/api/biomasas \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TU_TOKEN_AQUI" \
  -d '{
    "tipo_biomasa_id": 1,
    "densidad": "Media",
    "coordenadas": [[-17.8, -63.1], [-17.9, -63.2]],
    "area_m2": 5000000,
    "descripcion": "Biomasa de prueba"
  }'
```

---

## ⚠️ Checklist de Configuración

Antes de usar la app, verifica:

- [ ] Backend corriendo en puerto 8000
- [ ] IP local obtenida (`ipconfig`)
- [ ] `api_service.dart` actualizado con tu IP
- [ ] Dependencias instaladas (`flutter pub get`)
- [ ] Dispositivo/emulador en la misma red WiFi
- [ ] Base de datos con datos de prueba

---

## 🚀 Próximos Pasos

### Funcionalidades Pendientes:

1. **Pantalla de Perfil:**
   - Ver datos del usuario
   - Editar información personal
   - Cambiar contraseña

2. **Creación de Biomasas desde Mapa:**
   - Dibujar polígonos en el mapa
   - Seleccionar tipo de biomasa
   - Guardar directamente

3. **Focos de Incendio:**
   - CRUD completo desde la app
   - Notificaciones de nuevos focos
   - Filtros por fecha/intensidad

4. **Predicciones:**
   - Ver predicciones en el mapa
   - Crear nuevas predicciones
   - Compartir predicciones

5. **Modo Offline:**
   - Caché de datos con SQLite
   - Sincronización al recuperar conexión
   - Indicador de estado de conexión

---

## 📝 Notas Importantes

1. **Token Expiration:**
   - Los tokens de Sanctum no expiran por defecto
   - Considera implementar refresh tokens si es necesario

2. **Seguridad:**
   - Nunca guardes contraseñas en SharedPreferences
   - Solo guarda tokens
   - Limpia tokens al hacer logout

3. **Testing:**
   - Prueba tanto con usuario autenticado como sin autenticar
   - Verifica manejo de errores de red
   - Prueba en diferentes dispositivos/emuladores

4. **IP Local:**
   - La IP puede cambiar si te reconectas al WiFi
   - Para desarrollo, considera usar IP estática
   - Para producción, usa un dominio real

---

**Fecha de Actualización:** 1 de Diciembre, 2025  
**Versión App:** 1.0.0  
**Backend:** Laravel 11 + Sanctum  
**Flutter:** 3.0+
