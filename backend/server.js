
require('dotenv').config();

const express = require('express');
const cors = require('cors');

const pool = require('./src/config/database');

const authRoutes = require('./src/routes/auth_routes');

const app = express();
const PORT = process.env.PORT || 3000;


const path = require('node:path');

const propertyRoutes = require(
  './src/routes/property_routes'
);

// Configuración
app.use(cors());
app.use(express.json());
app.use('/api/auth', authRoutes);
// Permitir visualizar fotografías
app.use(
  '/uploads',
  express.static(path.join(__dirname, 'uploads'))
);

// Rutas de publicaciones
app.use('/api/properties', propertyRoutes);

// Comprobar que el servidor funciona
app.get('/api/health', (req, res) => {
  res.json({
    success: true,
    message: 'Backend de Roomly funcionando correctamente'
  });
});

// Comprobar la conexión con PostgreSQL
// Ruta temporal para desarrollo
app.get('/api/db-test', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        current_database() AS database,
        (SELECT COUNT(*)::int FROM roles) AS roles_count
    `);

    res.json({
      success: true,
      message: 'Conexión con PostgreSQL exitosa',
      data: result.rows[0]
    });

  } catch (error) {
    console.error('Error de PostgreSQL:', error.message);

    res.status(500).json({
      success: false,
      message: 'No fue posible conectar con PostgreSQL'
    });
  }
});

// Iniciar servidor
app.listen(PORT, () => {
  console.log(`Roomly ejecutándose en http://localhost:${PORT}`);
});
