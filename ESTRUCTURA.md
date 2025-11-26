# 📂 Estructura del Proyecto SIPII Flutter

```
sipii_flutter/
│
├── 📄 pubspec.yaml                    # Dependencias y configuración del proyecto
├── 📄 analysis_options.yaml           # Reglas de análisis de código
├── 📄 .gitignore                      # Archivos ignorados por Git
├── 📄 .metadata                       # Metadata de Flutter
│
├── 📖 README.md                       # Documentación principal
├── 📖 INSTALACION.md                  # Guía de instalación completa
├── 📖 CONFIGURACION.md                # Guía de configuración de API y entornos
├── 📖 INICIO-RAPIDO.md                # Guía de inicio rápido (5 minutos)
│
├── 📁 lib/                            # Código fuente de la aplicación
│   │
│   ├── 📄 main.dart                   # Punto de entrada de la app
│   │
│   ├── 📁 models/                     # Modelos de datos
│   │   ├── 📄 foco_incendio.dart     # Modelo de Foco de Incendio
│   │   ├── 📄 biomasa.dart           # Modelo de Biomasa
│   │   └── 📄 tipo_biomasa.dart      # Modelo de Tipo de Biomasa
│   │
│   ├── 📁 screens/                    # Pantallas de la aplicación
│   │   ├── 📄 login_screen.dart      # Pantalla de inicio de sesión
│   │   └── 📄 map_screen.dart        # Pantalla principal con mapa
│   │
│   └── 📁 services/                   # Servicios (API, etc.)
│       └── 📄 api_service.dart       # Cliente HTTP para conectar con Laravel API
│
├── 📁 android/                        # Configuración específica de Android
│   ├── 📁 app/
│   │   ├── 📄 build.gradle           # Configuración de build de Android
│   │   └── 📁 src/main/
│   │       ├── 📄 AndroidManifest.xml # Manifest con permisos
│   │       └── 📁 kotlin/
│   │           └── 📄 MainActivity.kt # Activity principal de Android
│   ├── 📄 build.gradle                # Build gradle raíz
│   ├── 📄 settings.gradle             # Settings de Gradle
│   └── 📄 gradle.properties           # Propiedades de Gradle
│
└── 📁 ios/                            # Configuración específica de iOS
    └── 📁 Runner/
        ├── 📄 Info.plist              # Configuración y permisos de iOS
        └── 📄 AppDelegate.swift       # Delegate principal de iOS
```

---

## 📱 Pantallas de la Aplicación

### 1. Pantalla de Login (`login_screen.dart`)
- ✅ Interfaz de inicio de sesión con diseño SIPII
- ✅ Validación de formularios
- ✅ Botón "Continuar sin iniciar sesión"
- ⏳ Autenticación funcional (pendiente de implementación)

**Características:**
- Diseño con gradiente naranja/rojo (colores de fuego)
- Icono de llama
- Campos de email y contraseña con validación
- Navegación directa al mapa

### 2. Pantalla de Mapa (`map_screen.dart`)
- ✅ Mapa interactivo con OpenStreetMap
- ✅ Marcadores de focos de incendio (🔴 rojo)
- ✅ Marcadores de biomasas (🟢 verde)
- ✅ Modal con detalles al hacer clic en marcador
- ✅ Leyenda flotante
- ✅ Botón de recarga de datos
- ✅ Manejo de estados (cargando, error, datos)

**Características:**
- Zoom y pan del mapa
- Auto-centrado en primer foco cargado
- Contador de focos y biomasas en leyenda
- Manejo de errores con reintentar

---

## 🔌 Servicios API

### `ApiService` (`api_service.dart`)

**Endpoints implementados:**

| Método | Endpoint | Descripción | Estado |
|--------|----------|-------------|--------|
| `getFocosIncendio()` | GET `/api/public/focos-incendios` | Obtiene todos los focos | ✅ Funcional |
| `getBiomasas()` | GET `/api/public/biomasas` | Obtiene todas las biomasas | ⚠️ Endpoint pendiente en Laravel |
| `getTiposBiomasa()` | GET `/api/public/tipos-biomasa` | Obtiene tipos de biomasa | ✅ Funcional |
| `login()` | POST `/api/login` | Autenticación de usuario | ⏳ UI lista, lógica pendiente |

**Características:**
- Manejo de errores robusto
- Parsing de JSON flexible (data object o array directo)
- Headers configurables
- URL base configurable

---

## 📦 Modelos de Datos

### `FocoIncendio`
```dart
{
  int id
  DateTime fecha
  String ubicacion
  List<double> coordenadas  // [lat, lng]
  double intensidad
}
```

### `Biomasa`
```dart
{
  int id
  int tipoBiomasaId
  String densidad
  List<List<double>> coordenadas  // Polígono
  double areaM2
  double? perimetroM
  String? descripcion
  DateTime fechaReporte
  String? tipoBiomasaNombre
}
```

### `TipoBiomasa`
```dart
{
  int id
  String nombre
  String? descripcion
}
```

---

## 🎨 Tema de la Aplicación

**Colores principales:**
- 🟠 Naranja (`Colors.orange.shade700`) - AppBar, botones principales
- 🔴 Rojo - Focos de incendio
- 🟢 Verde - Biomasas
- ⚪ Blanco - Textos en AppBar

**Diseño:**
- Material Design 3
- Bordes redondeados (12px)
- Cards con elevación
- Gradientes en pantalla de login

---

## 📝 Dependencias Principales

| Paquete | Versión | Uso |
|---------|---------|-----|
| `flutter_map` | ^6.1.0 | Mapa interactivo |
| `latlong2` | ^0.9.0 | Coordenadas geográficas |
| `http` | ^1.1.0 | Cliente HTTP para API |
| `geolocator` | ^10.1.0 | Servicios de ubicación |
| `permission_handler` | ^11.0.1 | Manejo de permisos |
| `provider` | ^6.1.1 | Gestión de estado |

---

## 🔐 Permisos Configurados

### Android (`AndroidManifest.xml`)
- ✅ `INTERNET` - Conexión a API
- ✅ `ACCESS_FINE_LOCATION` - Ubicación precisa
- ✅ `ACCESS_COARSE_LOCATION` - Ubicación aproximada

### iOS (`Info.plist`)
- ✅ `NSLocationWhenInUseUsageDescription` - Uso de ubicación
- ✅ `NSLocationAlwaysAndWhenInUseUsageDescription` - Ubicación siempre

---

## 🚀 Comandos Útiles

```powershell
# Instalar dependencias
flutter pub get

# Analizar código
flutter analyze

# Formatear código
flutter format lib/

# Limpiar build
flutter clean

# Ver dispositivos disponibles
flutter devices

# Ejecutar en modo debug
flutter run

# Ejecutar en modo release
flutter run --release

# Ver logs
flutter logs

# Construir APK (Android)
flutter build apk

# Construir para iOS
flutter build ios
```

---

## 🔄 Estado del Proyecto

### ✅ Implementado
- [x] Estructura del proyecto
- [x] Modelos de datos
- [x] Servicio API
- [x] Pantalla de login (UI)
- [x] Pantalla de mapa
- [x] Marcadores de focos
- [x] Marcadores de biomasas
- [x] Detalles en modal
- [x] Manejo de errores
- [x] Configuración Android/iOS

### ⏳ Pendiente
- [ ] Autenticación funcional con JWT
- [ ] Polígonos de biomasas en mapa
- [ ] Filtros de visualización
- [ ] Formularios para crear focos/biomasas
- [ ] Modo offline con caché
- [ ] Notificaciones push
- [ ] Tests unitarios
- [ ] Tests de integración

---

## 📚 Recursos

- **Flutter Docs:** https://flutter.dev/docs
- **Flutter Map:** https://pub.dev/packages/flutter_map
- **Dart Packages:** https://pub.dev
- **Material Design:** https://m3.material.io

---

**Versión:** 1.0.0  
**Última actualización:** 26 de Noviembre de 2025  
**Desarrollado para:** SIPII - Sistema de Prevención de Incendios
