# 🔥 SIPII Flutter - Sistema de Prevención de Incendios

Aplicación móvil Flutter para visualización de focos de incendio y biomasas del proyecto SIPII.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)

---

## 📱 Características

- ✅ **Pantalla de Login** - Interfaz preparada (autenticación pendiente)
- ✅ **Mapa Interactivo** - Visualización con OpenStreetMap
- ✅ **Focos de Incendio** - Marcadores rojos con detalles (ubicación, fecha, intensidad)
- ✅ **Biomasas** - Marcadores verdes con información detallada
- ✅ **Recarga de Datos** - Actualización manual desde la API
- ✅ **Manejo de Errores** - Feedback claro al usuario

---

## 🚀 Inicio Rápido

### 1. Instalar dependencias
```powershell
flutter pub get
```

### 2. Configurar API

Edita `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://TU-IP:8000/api';
```

### 3. Ejecutar

```powershell
flutter run
```

📖 **Más detalles:** Ver [`INICIO-RAPIDO.md`](INICIO-RAPIDO.md)

---

## 📚 Documentación

| Archivo | Descripción |
|---------|-------------|
| [INICIO-RAPIDO.md](INICIO-RAPIDO.md) | Guía rápida para ejecutar en 5 minutos |
| [INSTALACION.md](INSTALACION.md) | Instalación completa paso a paso |
| [CONFIGURACION.md](CONFIGURACION.md) | Configuración de API y entornos |
| [ESTRUCTURA.md](ESTRUCTURA.md) | Estructura del proyecto y arquitectura |

---

## 🗂️ Estructura del Proyecto

```
lib/
├── main.dart              # Punto de entrada
├── models/                # Modelos de datos
│   ├── foco_incendio.dart
│   ├── biomasa.dart
│   └── tipo_biomasa.dart
├── screens/               # Pantallas
│   ├── login_screen.dart
│   └── map_screen.dart
└── services/              # Servicios API
    └── api_service.dart
```

---

## 🔌 Endpoints Utilizados

### Públicos (sin autenticación)
- `GET /api/public/focos-incendios` - Obtener focos de incendio
- `GET /api/public/tipos-biomasa` - Obtener tipos de biomasa

### Protegidos (futura implementación)
- `POST /api/login` - Autenticación
- `POST /api/logout` - Cerrar sesión

---

## 🛠️ Configuración

### Para Emulador Android
```dart
static const String baseUrl = 'http://10.0.2.2:8000/api';
```

### Para Dispositivo Físico
```dart
static const String baseUrl = 'http://192.168.1.XXX:8000/api';
```
Reemplaza `XXX` con tu IP local (obtén con `ipconfig`)

### Iniciar Servidor Laravel
```powershell
php artisan serve --host=0.0.0.0 --port=8000
```

---

## 📦 Dependencias Principales

- **flutter_map** (^6.1.0) - Mapas interactivos
- **latlong2** (^0.9.0) - Coordenadas geográficas
- **http** (^1.1.0) - Cliente HTTP
- **geolocator** (^10.1.0) - Servicios de ubicación
- **provider** (^6.1.1) - Gestión de estado

---

## 🎯 Cómo Usar la App

1. **Login**: Haz clic en "Continuar sin iniciar sesión"
2. **Mapa**: 
   - 🔴 Rojo = Focos de incendio
   - 🟢 Verde = Biomasas
   - Tap en marcador = Ver detalles
   - Botón recarga = Actualizar datos

---

## 🐛 Solución de Problemas

### No se conecta a la API
- ✅ Verifica que Laravel esté corriendo
- ✅ Revisa la URL en `api_service.dart`
- ✅ Desactiva el firewall temporalmente
- ✅ Usa la IP correcta según tu dispositivo

### No aparecen datos en el mapa
- ✅ Verifica que la API devuelva datos JSON
- ✅ Abre `http://localhost:8000/api/public/focos-incendios` en navegador
- ✅ Presiona el botón de recarga en la app

---

## 🔄 Estado del Proyecto

### ✅ Completado
- Estructura del proyecto
- Modelos de datos
- Servicio API
- UI de Login
- Mapa con marcadores
- Detalles de focos/biomasas

### ⏳ Pendiente
- Autenticación funcional
- Polígonos de biomasas
- Filtros de visualización
- Formularios de creación
- Modo offline
- Notificaciones

---

## 📱 Capturas de Pantalla

### Pantalla de Login
- Gradiente naranja/rojo
- Logo de llama
- Formulario con validación
- Opción de continuar sin login

### Pantalla de Mapa
- Mapa interactivo OpenStreetMap
- Marcadores de focos (rojo) y biomasas (verde)
- Leyenda flotante con contadores
- Modal con detalles al hacer tap

---

## 🧪 Comandos Útiles

```powershell
flutter pub get              # Instalar dependencias
flutter analyze              # Analizar código
flutter run                  # Ejecutar app
flutter devices              # Ver dispositivos
flutter logs                 # Ver logs
flutter clean                # Limpiar build
flutter build apk            # Construir APK
```

---

## 👨‍💻 Desarrollo

### Requisitos
- Flutter SDK 3.0+
- Dart 3.0+
- Android Studio / Xcode
- VS Code (recomendado)

### Convenciones de Código
- Usar `const` donde sea posible
- Comillas simples para strings
- Análisis con `flutter analyze`
- Formato con `flutter format lib/`

---

## 📄 Licencia

Este proyecto es parte del Sistema SIPII.

---

## 🆘 Soporte

¿Problemas? Revisa:
1. [INICIO-RAPIDO.md](INICIO-RAPIDO.md) - Guía de inicio
2. [INSTALACION.md](INSTALACION.md) - Instalación completa
3. [CONFIGURACION.md](CONFIGURACION.md) - Configuración API
4. [ESTRUCTURA.md](ESTRUCTURA.md) - Arquitectura del proyecto

---

**Versión:** 1.0.0  
**Fecha:** 26 de Noviembre de 2025  
**Proyecto:** SIPII - Sistema de Prevención de Incendios
