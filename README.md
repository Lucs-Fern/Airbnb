# Roomly — Aplicación móvil de alojamientos y roomies

Roomly es un proyecto académico de Computación Móvil. La aplicación permitirá explorar y publicar alojamientos de corto, mediano y largo plazo, solicitar reservas y buscar posibles roomies a partir de preferencias de convivencia.

## Tecnologías previstas

- **Aplicación Android:** Flutter + Dart.
- **Backend/API REST:** Node.js + Express.
- **Base de datos:** PostgreSQL.
- **Mapas:** OpenStreetMap, respetando sus políticas de uso.
- **Herramientas:** Visual Studio Code, Android Studio, Git/GitHub, Figma y Postman.

## Estructura del repositorio

```text
Roomly/
├── app/          # Aplicación móvil Flutter
├── backend/      # API REST Node.js + Express
├── database/     # Migraciones, semillas y documentación de datos
├── docs/         # Requerimientos y mockups
├── scripts/      # Scripts de apoyo al desarrollo
├── .gitignore
├── .editorconfig
└── README.md
```

## Antes de empezar

Instala Flutter, Android Studio con Android SDK, Git, Node.js LTS y PostgreSQL. Abre **la carpeta raíz `Roomly`** en Visual Studio Code, no únicamente `app` o `backend`.

### 1. Completar el esqueleto nativo de Flutter

La carpeta `app` contiene la estructura de organización de Dart, pero todavía no es un proyecto Flutter generado por el SDK. Cuando Flutter esté instalado, abre una terminal de VS Code y ejecuta:

```powershell
cd app
flutter create --platforms=android --project-name roomly_app .
flutter doctor
flutter pub get
```

Este paso generará `pubspec.yaml`, el proyecto Android y los archivos base que administra Flutter. Después se comenzarán a desarrollar las pantallas dentro de `app/lib/`.

### 2. Preparar el backend

Desde la raíz del repositorio:

```powershell
cd backend
npm install express cors dotenv pg bcryptjs jsonwebtoken helmet zod
npm install --save-dev nodemon
```

El backend se organizará dentro de `backend/src/`. El archivo `backend/.env.example` es una plantilla: cuando se configure la base de datos, copia su contenido a `.env` y reemplaza los valores de ejemplo. **No subas `.env` a GitHub.**

### 3. Subir la estructura a GitHub

En una terminal de VS Code, desde la raíz `Roomly`:

```powershell
git init
git branch -M main
git add .
git commit -m "chore: crear estructura inicial de Roomly"
git remote add origin https://github.com/USUARIO/roomly.git
git push -u origin main
```

Reemplaza la URL por la de tu repositorio. Si ya conectaste `origin`, no repitas el comando `git remote add origin`.

## Organización del código

- `app/lib/controllers/`: controladores de estado y acciones de la interfaz.
- `app/lib/models/`: modelos de datos que consume la aplicación.
- `app/lib/repositories/`: acceso a datos desde la app.
- `app/lib/services/`: comunicación HTTP, mapas, sesión y servicios de dispositivo.
- `app/lib/screens/`: pantallas por módulo.
- `app/lib/widgets/`: componentes visuales reutilizables.
- `backend/src/controllers/`: controladores de la API.
- `backend/src/models/`: modelos y representación de datos del servidor.
- `backend/src/routes/`: definición de rutas HTTP.
- `backend/src/middlewares/`: autenticación, autorización y manejo de solicitudes.
- `backend/src/services/`: lógica de negocio.
- `backend/src/repositories/`: consultas y persistencia en PostgreSQL.
- `database/migrations/`: cambios versionados del esquema de base de datos.

## Estado actual

Este paquete contiene **estructura, configuración inicial, documentación y mockups**. Todavía no implementa la lógica funcional de registro, inicio de sesión, alojamientos, reservas, roomies, compatibilidad ni chat. Esas funciones se desarrollarán y probarán por etapas.
