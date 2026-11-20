
require('dotenv').config();

const express = require('express');
const cors = require('cors');
const path = require('node:path');

const pool = require('./src/config/database');

// ==========================================
// IMPORTAR RUTAS DE ROOMLY
// ==========================================

const authRoutes = require(
  './src/routes/auth_routes'
);

const propertyRoutes = require(
  './src/routes/property_routes'
);

// NUEVO: rutas de favoritos permanentes.
// Crearemos este archivo en el siguiente paso.
const favoriteRoutes = require(
  './src/routes/favorite_routes'
);

// ==========================================
// CONFIGURAR SERVIDOR
// ==========================================

const app = express();

const PORT = process.env.PORT || 3000;

// Permitir solicitudes desde Flutter Web y móvil.
app.use(cors());

// Interpretar solicitudes JSON.
app.use(express.json());

// ==========================================
// AUTENTICACIÓN
// ==========================================

app.use('/api/auth', authRoutes);

// ==========================================
// FOTOGRAFÍAS DE ALOJAMIENTOS
// ==========================================

app.use(
  '/uploads',
  express.static(
    path.join(__dirname, 'uploads')
  )
);

// ==========================================
// PUBLICACIONES
// ==========================================

app.use('/api/properties', propertyRoutes);

// ==========================================
// NUEVO: FAVORITOS PERMANENTES
// ==========================================

// Permitirá:
// GET    /api/favorites
// POST   /api/favorites/:propertyId
// DELETE /api/favorites/:propertyId
//
// Las operaciones se protegerán con JWT
// dentro del archivo favorite_routes.js.

app.use('/api/favorites', favoriteRoutes);

// ==========================================
// ESTADO DEL SERVIDOR
// ==========================================

app.get('/api/health', (req, res) => {
  res.json({
    success: true,
    message: 'Backend de Roomly funcionando correctamente'
  });
});

// ==========================================
// VERIFICAR POSTGRESQL
// ==========================================

// Ruta de diagnóstico utilizada en desarrollo.
app.get('/api/db-test', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        current_database() AS database,
        (SELECT COUNT(*)::int FROM roles) AS roles_count
    `);

    return res.json({
      success: true,
      message: 'Conexión con PostgreSQL exitosa',
      data: result.rows[0]
    });

  } catch (error) {
    console.error(
      'Error de PostgreSQL:',
      error.message
    );

    return res.status(500).json({
      success: false,
      message: 'No fue posible conectar con PostgreSQL'
    });
  }
});

// ==========================================
// INICIAR ROOMLY
// ==========================================

app.listen(PORT, () => {
  console.log(
    `Roomly ejecutándose en http://localhost:${PORT}`
  );
});
