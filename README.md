# 🗑️ Swipe Cleaner

Una aplicación Flutter para limpiar y gestionar fotos de tu dispositivo de manera fácil y visual.

## ✨ Características

- 📱 **Selecciona carpetas** - Elige qué carpeta de fotos quieres revisar
- 🖼️ **Grid visual** - Vista previa de todas las fotos en una carpeta
- ✅ **Selección múltiple** - Marca fotos para eliminar de una vez
- 🎨 **Interfaz oscura** - Diseño optimizado para ahorrar batería
- 🚀 **Rendimiento** - Carga rápida de fotos con miniaturas
- 🗑️ **Eliminación segura** - Usa la API nativa del sistema

## 📦 Instalación

### Desde GitHub

```bash
git clone https://github.com/matiasfralasco/swipe_cleaner.git
cd swipe_cleaner
flutter pub get
flutter run
```

### Desde APK

Descarga el APK desde [Releases](https://github.com/matiasfralasco/swipe_cleaner/releases) e instálalo en tu dispositivo.

## 🛠️ Requisitos

- Flutter 3.0+
- Dart 3.0+
- Android 6.0+ (API 21+)
- Permisos de acceso a fotos

## 📱 Uso

1. **Abre la app** - Se solicitarán permisos de acceso a fotos
2. **Selecciona una carpeta** - Elige de la lista de carpetas disponibles
3. **Revisa las fotos** - Ve todas las fotos en grid
4. **Marca fotos** - Toca las fotos que quieres eliminar
5. **Usa "Marcar todo"** - Para seleccionar todas de una vez
6. **Elimina** - Pulsa el botón ELIMINAR

## 📦 Dependencias

```yaml
flutter:
  sdk: flutter

photo_manager: ^2.7.0          # Acceso a galería del dispositivo
flutter_card_swiper: ^10.0.0   # Interfaz de swipe
permission_handler: ^11.4.3    # Manejo de permisos
```

## 🏗️ Estructura del Proyecto

```
lib/
└── main.dart          # Toda la lógica de la app

android/               # Configuración Android
ios/                   # Configuración iOS
macos/                 # Configuración macOS
windows/               # Configuración Windows
linux/                 # Configuración Linux
web/                   # Soporte web
```

## 🚀 Compilar APK

Para generar un APK optimizado:

```bash
# APK único (más grande)
flutter build apk --release

# APKs separados por arquitectura (recomendado)
flutter build apk --split-per-abi --release
```

Los APKs estarán en: `build/app/outputs/flutter-apk/`

## 📝 Licencia

Este proyecto está bajo la licencia [MIT](LICENSE). Ver archivo LICENSE para más detalles.

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Para cambios importantes, abre un issue primero para discutir qué te gustaría cambiar.

## 👨‍💻 Autor

**Matías Fralasco**

- GitHub: [@matiasfralasco](https://github.com/matiasfralasco)

## ⚠️ Disclaimer

Esta app elimina fotos permanentemente. **Asegúrate de hacer backup de fotos importantes antes de usarla.**

## 🐛 Reporte de Bugs

Si encuentras un bug, abre un [Issue](https://github.com/matiasfralasco/swipe_cleaner/issues) en GitHub.

---

Hecho con ❤️ en Flutter
