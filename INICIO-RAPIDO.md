# 🚀 Inicio Rápido - SIPII Flutter

## En 5 Minutos

### 1️⃣ Instala las dependencias
```powershell
cd "c:\Users\lenovo\OneDrive\Desktop\Proyectos\SIPII Laravel\Laraprueba-CRUD\sipii_flutter"
flutter pub get
```

### 2️⃣ Configura la URL de tu API

Edita `lib/services/api_service.dart`, línea 9:

**Para emulador Android:**
```dart
static const String baseUrl = 'http://10.0.2.2:8000/api';
```

**Para dispositivo físico (misma red WiFi):**
```dart
static const String baseUrl = 'http://TU-IP-LOCAL:8000/api';
```
Obtén tu IP con: `ipconfig` (Windows)

### 3️⃣ Inicia tu servidor Laravel

```powershell
cd "c:\Users\lenovo\OneDrive\Desktop\Proyectos\SIPII Laravel\Laraprueba-CRUD\Laraprueba-CRUD"
php artisan serve --host=0.0.0.0 --port=8000
```

### 4️⃣ Ejecuta la app

```powershell
flutter run
```

Si tienes múltiples dispositivos:
```powershell
flutter devices              # Ver dispositivos
flutter run -d <device-id>  # Ejecutar en dispositivo específico
```

---

## 📱 Cómo Usar la App

1. **Pantalla de Login**: Haz clic en "Continuar sin iniciar sesión" (el login no está implementado aún)
2. **Pantalla de Mapa**: 
   - 🔴 Marcadores rojos = Focos de incendio
   - 🟢 Marcadores verdes = Biomasas
   - Haz clic en un marcador para ver detalles
   - Botón de recarga en la AppBar para actualizar datos

---

## ✅ Verificación Rápida

**¿Tu API funciona?**
Abre en el navegador:
```
http://localhost:8000/api/public/focos-incendios
```
Deberías ver JSON con datos.

**¿El firewall bloquea la conexión?**
Desactívalo temporalmente para probar.

---

## 🐛 Solución de Problemas

| Problema | Solución |
|----------|----------|
| "No se puede conectar a la API" | Revisa la URL en `api_service.dart` y que el servidor Laravel esté corriendo |
| "Error al cargar datos" | Verifica que los endpoints públicos devuelvan datos en formato JSON |
| Pantalla en blanco | Presiona el botón de recarga en la AppBar |
| App se cierra al abrir | Revisa los logs: `flutter logs` |

---

## 📚 Más Información

- **Instalación completa:** Ver `INSTALACION.md`
- **Configuración detallada:** Ver `CONFIGURACION.md`
- **Documentación Flutter:** https://flutter.dev/docs

---

## 🎯 Próximos Pasos

Una vez que la app funcione:

1. ✅ Verifica que se muestren los focos de incendio en el mapa
2. ✅ Verifica que se muestren las biomasas (si tienes datos)
3. ✅ Prueba hacer clic en los marcadores
4. 🔄 Implementa autenticación real (futura mejora)
5. 🔄 Añade formularios para crear focos/biomasas desde la app

---

**¿Necesitas ayuda?** Revisa los archivos de documentación o contacta al equipo de desarrollo.
