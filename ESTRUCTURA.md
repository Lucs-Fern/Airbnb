# Mapa rápido de carpetas

```text
Roomly/
├── app/                         # Aplicación Flutter
│   ├── assets/                  # Imágenes, iconos, fuentes e ilustraciones
│   ├── lib/
│   │   ├── config/              # Rutas y tema visual
│   │   ├── core/                # Red, validaciones, constantes y utilidades
│   │   ├── controllers/         # Lógica de presentación por módulo
│   │   ├── models/              # Modelos de datos del cliente
│   │   ├── repositories/        # Acceso a datos desde Flutter
│   │   ├── services/            # API, sesión, mapas, chat y notificaciones
│   │   ├── screens/             # Pantallas por módulo
│   │   └── widgets/             # Componentes reutilizables
│   └── test/                    # Pruebas Flutter
├── backend/
│   ├── src/
│   │   ├── config/              # Configuración de la API/DB
│   │   ├── controllers/         # Manejadores de endpoints
│   │   ├── middlewares/         # Autenticación, autorización y errores
│   │   ├── models/              # Modelos de servidor
│   │   ├── repositories/        # Consultas a PostgreSQL
│   │   ├── routes/              # Endpoints
│   │   ├── services/             # Reglas de negocio
│   │   ├── validators/           # Validación de solicitudes
│   │   ├── utils/                # Utilidades comunes
│   │   └── constants/            # Constantes del backend
│   ├── tests/                    # Pruebas unitarias y de integración
│   └── storage/uploads/          # Archivos locales temporales (ignorados por Git)
├── database/                     # Migraciones, seeds, esquemas y docs
├── docs/                         # Requerimientos, mockups, arquitectura y pruebas
└── scripts/                      # Automatizaciones de apoyo
```
