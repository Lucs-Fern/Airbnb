
const express = require('express');

const {
  requireAuth
} = require('../middlewares/auth_middleware');

const {
  getFavorites,
  addFavorite,
  removeFavorite
} = require('../controllers/favorite_controller');

const router = express.Router();

// ==========================================
// ROOMLY - RUTAS DE FAVORITOS
// ==========================================

// Todas las rutas de favoritos requieren
// un usuario autenticado mediante JWT.
//
// Se permiten los tres roles:
// - Huesped
// - Anfitrion
// - Roomie

router.use(requireAuth);

// ==========================================
// CONSULTAR MIS FAVORITOS
// ==========================================

// GET /api/favorites
//
// Devuelve los alojamientos guardados
// por el usuario que inició sesión.

router.get(
  '/',
  getFavorites
);

// ==========================================
// AGREGAR A FAVORITOS
// ==========================================

// POST /api/favorites/:propertyId
//
// Guarda un alojamiento en los favoritos
// del usuario autenticado.
//
// El controlador impedirá duplicados
// y comprobará que exista el alojamiento.

router.post(
  '/:propertyId',
  addFavorite
);

// ==========================================
// ELIMINAR DE FAVORITOS
// ==========================================

// DELETE /api/favorites/:propertyId
//
// Quita un alojamiento de los favoritos
// del usuario autenticado.
//
// No elimina el alojamiento original.

router.delete(
  '/:propertyId',
  removeFavorite
);

// ==========================================
// EXPORTAR RUTAS
// ==========================================

module.exports = router;
