# Guía de Instalación y Configuración - SIPII Flutter

## Requisitos Previos

1. **Flutter SDK** instalado (versión 3.0 o superior)
   - Descarga desde: https://flutter.dev/docs/get-started/install
   - Verifica la instalación: `flutter doctor`

2. **Android Studio** (para desarrollo Android) o **Xcode** (para desarrollo iOS en Mac)

3. **VS Code** o **Android Studio** como IDE

## Pasos de Instalación

### 1. Navega al directorio del proyecto

```powershell
cd "c:\Users\lenovo\OneDrive\Desktop\Proyectos\SIPII Laravel\Laraprueba-CRUD\sipii_flutter"
```

### 2. Instala las dependencias de Flutter

```powershell
flutter pub get
```

### 3. Configura la URL de tu API Laravel

Edita el archivo `lib/services/api_service.dart` y cambia la URL base:

```dart
static const String baseUrl = 'http://TU-IP:8000/api';
```

**Importante para emuladores:**
- **Android Emulator**: Usa `http://10.0.2.2:8000/api` (apunta a localhost de tu PC)
- **iOS Simulator**: Usa `http://localhost:8000/api` o `http://127.0.0.1:8000/api`
- **Dispositivo físico**: Usa la IP de tu PC en la red local (ej: `http://192.168.1.100:8000/api`)

### 4. Verifica que Flutter esté correctamente instalado

```powershell
flutter doctor
```

Resuelve cualquier problema que aparezca marcado con ❌.

### 5. Ejecuta la aplicación

#### En un emulador/simulador:

```powershell
# Listar dispositivos disponibles
flutter devices

# Ejecutar la app
flutter run
```

#### En un dispositivo físico:

1. Habilita las opciones de desarrollador en tu dispositivo
2. Conecta el dispositivo por USB
3. Ejecuta: `flutter run`

### 6. Asegúrate de que tu servidor Laravel esté corriendo

En otra terminal, en el directorio del proyecto Laravel:

```powershell
cd "c:\Users\lenovo\OneDrive\Desktop\Proyectos\SIPII Laravel\Laraprueba-CRUD\Laraprueba-CRUD"
php artisan serve --host=0.0.0.0 --port=8000
```

El flag `--host=0.0.0.0` permite que la API sea accesible desde dispositivos en tu red local.

## Estructura del Proyecto

```
sipii_flutter/
├── lib/
│   ├── main.dart                 # Punto de entrada de la app
│   ├── models/                   # Modelos de datos
│   │   ├── foco_incendio.dart
│   │   ├── biomasa.dart
│   │   └── tipo_biomasa.dart
│   ├── screens/                  # Pantallas de la app
│   │   ├── login_screen.dart
│   │   └── map_screen.dart
│   └── services/                 # Servicios (API)
│       └── api_service.dart
├── android/                      # Configuración Android
├── ios/                          # Configuración iOS
└── pubspec.yaml                  # Dependencias del proyecto
```

## Funcionalidades Implementadas

✅ Pantalla de login (UI preparada, sin autenticación funcional aún)
✅ Mapa interactivo con OpenStreetMap
✅ Visualización de focos de incendio (marcadores rojos)
✅ Visualización de biomasas (marcadores verdes)
✅ Detalles al hacer clic en marcadores
✅ Recarga de datos desde la API
✅ Manejo de errores de red

## Solución de Problemas Comunes

### Error: "No se puede conectar a la API"

1. Verifica que el servidor Laravel esté corriendo
2. Revisa la URL en `api_service.dart`
3. Asegúrate de usar la IP correcta según tu dispositivo (ver paso 3)
4. Desactiva el firewall temporalmente para probar

### Error: "Target of URI doesn't exist" en el IDE

Esto es normal antes de ejecutar `flutter pub get`. Ejecuta el comando y los errores desaparecerán.

### Error al compilar para Android

Asegúrate de tener:
- Android SDK instalado
- Licencias aceptadas: `flutter doctor --android-licenses`

## Próximos Pasos (Futuras Mejoras)

- [ ] Implementar autenticación real con JWT
- [ ] Mostrar polígonos para biomasas en lugar de solo marcadores
- [ ] Filtros de visualización (por fecha, intensidad, etc.)
- [ ] Modo offline con caché local
- [ ] Notificaciones push para nuevos focos
- [ ] Formularios para reportar focos desde la app

## Notas Adicionales

- La aplicación usa `flutter_map` con tiles de OpenStreetMap (gratuito, sin API key necesaria)
- Los permisos de ubicación están configurados pero no se usan aún
- El botón "Continuar sin iniciar sesión" permite acceder directamente al mapa
