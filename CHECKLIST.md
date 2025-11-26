# ✅ Checklist de Configuración - SIPII Flutter

## Antes de Ejecutar por Primera Vez

### 1. ✅ Prerrequisitos Instalados
- [ ] Flutter SDK instalado (verificar con `flutter doctor`)
- [ ] Android Studio (para Android) o Xcode (para iOS/Mac)
- [ ] Emulador/Simulador configurado O dispositivo físico conectado
- [ ] VS Code o Android Studio como IDE

### 2. ✅ Dependencias del Proyecto
- [ ] Ejecutado `flutter pub get` en el directorio del proyecto
- [ ] No hay errores al ejecutar `flutter analyze`

### 3. ✅ Configuración de la API

#### Para Emulador Android:
- [ ] URL configurada en `lib/services/api_service.dart`: `http://10.0.2.2:8000/api`

#### Para Simulador iOS:
- [ ] URL configurada en `lib/services/api_service.dart`: `http://localhost:8000/api`

#### Para Dispositivo Físico:
- [ ] Obtenida tu IP local con `ipconfig` (Windows)
- [ ] URL configurada con tu IP: `http://192.168.X.XXX:8000/api`
- [ ] Dispositivo y PC en la misma red WiFi

### 4. ✅ Servidor Laravel

- [ ] Servidor Laravel iniciado con: `php artisan serve --host=0.0.0.0 --port=8000`
- [ ] Endpoint público accesible en navegador: `http://localhost:8000/api/public/focos-incendios`
- [ ] El endpoint devuelve datos JSON (aunque sea un array vacío)

### 5. ✅ Firewall y Permisos

- [ ] Firewall de Windows permite conexiones al puerto 8000 (o desactivado temporalmente)
- [ ] Puerto 8000 no está siendo usado por otra aplicación

---

## Primera Ejecución

### Paso 1: Verificar Dispositivos
```powershell
flutter devices
```
Debe mostrar al menos un dispositivo disponible.

### Paso 2: Ejecutar la App
```powershell
cd "c:\Users\lenovo\OneDrive\Desktop\Proyectos\SIPII Laravel\Laraprueba-CRUD\sipii_flutter"
flutter run
```

### Paso 3: Probar Funcionalidad
- [ ] La app se abre sin errores
- [ ] Pantalla de login aparece correctamente
- [ ] Hacer clic en "Continuar sin iniciar sesión"
- [ ] Pantalla de mapa carga correctamente
- [ ] Aparecen marcadores en el mapa (si hay datos en la API)
- [ ] Al hacer tap en un marcador se abre un modal con detalles
- [ ] El botón de recarga funciona

---

## Verificación de Datos

### ✅ ¿Hay Focos de Incendio en la Base de Datos?

Verificar en navegador:
```
http://localhost:8000/api/public/focos-incendios
```

Debe devolver algo como:
```json
{
  "data": [
    {
      "id": 1,
      "fecha": "2024-11-26",
      "ubicacion": "Ejemplo",
      "coordenadas": [40.4168, -3.7038],
      "intensidad": 7.5
    }
  ]
}
```

Si devuelve array vacío `{"data": []}` o `[]`:
- [ ] Añadir datos de prueba en Laravel
- [ ] Verificar que los seeders se hayan ejecutado
- [ ] Crear un foco manualmente desde el CRUD de Laravel

### ✅ ¿Hay Biomasas en la Base de Datos?

Verificar endpoint (si existe):
```
http://localhost:8000/api/public/biomasas
```

Si no existe, es normal - la app manejará el error correctamente.

---

## Solución de Problemas Comunes

### ❌ Error: "Target of URI doesn't exist: 'package:flutter/material.dart'"
**Solución:** Ejecutar `flutter pub get`

### ❌ Error: "No se puede conectar a la API"
**Checklist:**
- [ ] Servidor Laravel está corriendo
- [ ] URL en `api_service.dart` es correcta
- [ ] Firewall desactivado o puerto 8000 permitido
- [ ] Dispositivo y PC en misma red (si es físico)

### ❌ Error: "No issues found" pero no aparecen datos
**Checklist:**
- [ ] Hay datos en la base de datos de Laravel
- [ ] El endpoint público devuelve datos JSON
- [ ] Presionar el botón de recarga en la app
- [ ] Revisar logs con `flutter logs`

### ❌ App se cierra inmediatamente
**Checklist:**
- [ ] Verificar logs: `flutter logs`
- [ ] Ejecutar en modo debug: `flutter run`
- [ ] Revisar permisos en AndroidManifest.xml / Info.plist

---

## Testing Manual

### Login Screen
- [ ] Formulario de email acepta emails válidos
- [ ] Formulario de contraseña acepta passwords de 6+ caracteres
- [ ] Validación funciona (mostrar errores con campos vacíos)
- [ ] Botón "Continuar sin iniciar sesión" navega al mapa

### Map Screen
- [ ] Mapa carga correctamente
- [ ] Tiles de OpenStreetMap se muestran
- [ ] Marcadores rojos aparecen si hay focos
- [ ] Marcadores verdes aparecen si hay biomasas
- [ ] Tap en marcador muestra modal
- [ ] Modal muestra información correcta
- [ ] Leyenda muestra contadores correctos
- [ ] Botón de recarga funciona

---

## Datos de Prueba Recomendados

Si no tienes datos en Laravel, crea al menos:

### 1 Foco de Incendio:
```sql
INSERT INTO focos_incendios (fecha, ubicacion, coordenadas, intensidad, created_at, updated_at)
VALUES ('2024-11-26', 'Madrid Centro', '[40.4168, -3.7038]', 7.5, NOW(), NOW());
```

### 1 Tipo de Biomasa:
```sql
INSERT INTO tipo_biomasas (nombre, descripcion, created_at, updated_at)
VALUES ('Arbustos', 'Vegetación arbustiva', NOW(), NOW());
```

---

## ✅ Todo Listo Para Producción

- [ ] App funciona en emulador/simulador
- [ ] App funciona en dispositivo físico
- [ ] Datos se cargan correctamente
- [ ] Marcadores se muestran en el mapa
- [ ] Navegación entre pantallas funciona
- [ ] No hay errores en `flutter analyze`
- [ ] No hay warnings en los logs

---

## 📝 Notas Adicionales

- La autenticación aún no está implementada funcionalmente
- Los marcadores de biomasas son puntos, no polígonos (futura mejora)
- La ubicación del usuario no se usa todavía
- Los datos se cargan al iniciar la pantalla de mapa

---

**¿Todo funciona?** ¡Excelente! 🎉

**¿Aún hay problemas?** Revisa la documentación:
- `INICIO-RAPIDO.md` - Guía de 5 minutos
- `INSTALACION.md` - Instalación completa
- `CONFIGURACION.md` - Configuración detallada
- `ESTRUCTURA.md` - Arquitectura del proyecto

---

**Última actualización:** 26 de Noviembre de 2025
