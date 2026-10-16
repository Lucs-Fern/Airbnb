# Backend — Node.js + Express

La API REST conectará Flutter con PostgreSQL. El backend está organizado por responsabilidad para separar rutas, validaciones, controladores y lógica de negocio.

## Preparación

```powershell
npm install express cors dotenv pg bcryptjs jsonwebtoken helmet zod
npm install --save-dev nodemon
```

La configuración local se guardará en `.env`, creado a partir de `.env.example`. No incluyas credenciales reales en Git.

## Estructura

- `src/config/`: configuración y conexión a la base de datos.
- `src/controllers/`: recibe solicitudes HTTP y devuelve respuestas.
- `src/middlewares/`: autenticación, autorización y tratamiento de errores.
- `src/models/`: modelos/estructuras de datos.
- `src/repositories/`: consultas a PostgreSQL.
- `src/routes/`: endpoints agrupados por módulo.
- `src/services/`: reglas de negocio.
- `src/validators/`: esquemas y reglas de entrada.
- `src/utils/`: funciones auxiliares.
- `tests/`: pruebas unitarias y de integración.

Todavía no se incluyen endpoints ni lógica funcional; se añadirán cuando se empiece con cada módulo.
