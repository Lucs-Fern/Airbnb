# Aplicación móvil — Flutter

Esta carpeta está preparada para organizar el código de la app. Primero instala Flutter y Android Studio.

Desde esta carpeta, ejecuta `flutter create --platforms=android --project-name roomly_app .` para crear los archivos base oficiales de Flutter. El SDK generará `pubspec.yaml`, `android/`, `lib/main.dart` y la configuración de pruebas.

## Carpetas de `lib/`

- `config/`: navegación y configuración visual.
- `core/`: constantes, validaciones, red y utilidades comunes.
- `controllers/`: controladores por módulo.
- `models/`: modelos usados en el móvil.
- `repositories/`: capa de acceso a datos.
- `services/`: clientes de API, mapas, sesiones y notificaciones.
- `screens/`: pantallas de cada módulo.
- `widgets/`: componentes reutilizables.
