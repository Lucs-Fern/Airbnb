
const pool = require('../config/database');

// ==========================================
// ROOMLY - CONTROLADOR DE FAVORITOS
// ==========================================

// Validar identificadores de alojamientos.
function validatePropertyId(value) {
  if (!/^[1-9]\d*$/.test(String(value))) {
    return null;
  }

  const id = Number(value);

  if (!Number.isSafeInteger(id) || id <= 0) {
    return null;
  }

  return id;
}

// ==========================================
// 1. CONSULTAR MIS FAVORITOS
// ==========================================

// GET /api/favorites
//
// Devuelve los alojamientos guardados
// por el usuario autenticado.

async function getFavorites(req, res) {
  try {
    const result = await pool.query(
      `SELECT
         p.*,
         u.full_name AS host_name,
         f.created_at AS favorited_at
       FROM favorites f
       JOIN properties p
         ON p.id = f.property_id
       JOIN users u
         ON u.id = p.host_id
       WHERE f.user_id = $1
       ORDER BY f.created_at DESC, p.id DESC`,
      [req.userId]
    );

    return res.status(200).json({
      success: true,
      favorites: result.rows
    });

  } catch (error) {
    console.error(
      'Error al consultar favoritos:',
      error.message
    );

    return res.status(500).json({
      success: false,
      message: 'No fue posible cargar tus favoritos.'
    });
  }
}

// ==========================================
// 2. AGREGAR A FAVORITOS
// ==========================================

// POST /api/favorites/:propertyId
//
// Guarda un alojamiento en PostgreSQL.
//
// La clave primaria de favorites impide
// que el mismo usuario lo guarde dos veces.

async function addFavorite(req, res) {
  const propertyId = validatePropertyId(
    req.params.propertyId
  );

  if (propertyId === null) {
    return res.status(400).json({
      success: false,
      message: 'Identificador de alojamiento inválido.'
    });
  }

  try {
    // Insertar únicamente si el alojamiento
    // existe y se encuentra disponible.
    const result = await pool.query(
      `INSERT INTO favorites (
         user_id,
         property_id
       )
       SELECT
         $1,
         p.id
       FROM properties p
       WHERE p.id = $2
         AND p.available = TRUE
       ON CONFLICT (user_id, property_id)
       DO NOTHING
       RETURNING property_id`,
      [
        req.userId,
        propertyId
      ]
    );

    // Si se creó el favorito correctamente.
    if (result.rowCount > 0) {
      return res.status(201).json({
        success: true,
        message: 'Alojamiento agregado a favoritos.',
        property_id: propertyId
      });
    }

    // Si no se insertó, comprobar si
    // el alojamiento sigue disponible.
    const property = await pool.query(
      `SELECT id
       FROM properties
       WHERE id = $1
         AND available = TRUE`,
      [propertyId]
    );

    if (property.rowCount === 0) {
      return res.status(404).json({
        success: false,
        message:
          'El alojamiento no existe o no está disponible.'
      });
    }

    // Ya se encontraba guardado.
    return res.status(200).json({
      success: true,
      message: 'Este alojamiento ya está en tus favoritos.',
      property_id: propertyId
    });

  } catch (error) {
    // Puede ocurrir si el alojamiento
    // se elimina durante la operación.
    if (error.code === '23503') {
      return res.status(404).json({
        success: false,
        message: 'El alojamiento ya no está disponible.'
      });
    }

    console.error(
      'Error al agregar favorito:',
      error.message
    );

    return res.status(500).json({
      success: false,
      message:
        'No fue posible agregar el alojamiento a favoritos.'
    });
  }
}

// ==========================================
// 3. ELIMINAR DE FAVORITOS
// ==========================================

// DELETE /api/favorites/:propertyId
//
// Elimina solamente la relación de favoritos.
//
// No elimina el alojamiento de PostgreSQL.

async function removeFavorite(req, res) {
  const propertyId = validatePropertyId(
    req.params.propertyId
  );

  if (propertyId === null) {
    return res.status(400).json({
      success: false,
      message: 'Identificador de alojamiento inválido.'
    });
  }

  try {
    const result = await pool.query(
      `DELETE FROM favorites
       WHERE user_id = $1
         AND property_id = $2
       RETURNING property_id`,
      [
        req.userId,
        propertyId
      ]
    );

    if (result.rowCount === 0) {
      return res.status(200).json({
        success: true,
        message: 'El alojamiento no estaba en tus favoritos.',
        property_id: propertyId
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Alojamiento eliminado de favoritos.',
      property_id: propertyId
    });

  } catch (error) {
    console.error(
      'Error al eliminar favorito:',
      error.message
    );

    return res.status(500).json({
      success: false,
      message:
        'No fue posible eliminar el alojamiento de favoritos.'
    });
  }
}

// ==========================================
// EXPORTAR FUNCIONES
// ==========================================

module.exports = {
  getFavorites,
  addFavorite,
  removeFavorite
};
