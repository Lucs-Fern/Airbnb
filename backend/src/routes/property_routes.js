
const express = require('express');
const multer = require('multer');

const {
  requireHost
} = require('../middlewares/auth_middleware');

const {
  createProperty,
  getProperties,
  getMyProperties,
  updateProperty,
  deleteProperty
} = require('../controllers/property_controller');

const router = express.Router();

// ==========================================
// CONFIGURACIÓN DE FOTOGRAFÍAS
// ==========================================

// Recibir una fotografía de máximo 5 MB.
const upload = multer({
  storage: multer.memoryStorage(),

  limits: {
    fileSize: 5 * 1024 * 1024,
    files: 1,
    fields: 12
  },

  fileFilter: (req, file, callback) => {
    const allowedTypes = [
      'image/jpeg',
      'image/png',
      'image/webp'
    ];

    if (!allowedTypes.includes(file.mimetype)) {
      return callback(
        new Error(
          'Solo se permiten imágenes JPG, PNG o WebP.'
        )
      );
    }

    callback(null, true);
  }
});

// ==========================================
// MIDDLEWARE PARA CARGAR FOTOGRAFÍAS
// ==========================================

// Reutilizamos esta función al crear
// y al editar una publicación.
function uploadPhoto(req, res, next) {
  upload.single('photo')(req, res, error => {
    if (error) {
      let message = error.message;

      if (
        error instanceof multer.MulterError &&
        error.code === 'LIMIT_FILE_SIZE'
      ) {
        message =
          'La fotografía no puede superar los 5 MB.';
      }

      return res.status(400).json({
        success: false,
        message
      });
    }

    next();
  });
}

// ==========================================
// CONSULTAR ALOJAMIENTOS PÚBLICOS
// ==========================================

// Cualquier usuario puede ver los
// alojamientos que están disponibles.
router.get(
  '/',
  getProperties
);

// ==========================================
// MIS PUBLICACIONES
// ==========================================

// Solo un anfitrión autenticado puede
// consultar sus propias publicaciones.
router.get(
  '/mine',
  requireHost,
  getMyProperties
);

// ==========================================
// CREAR ALOJAMIENTO
// ==========================================

// Requiere iniciar sesión como anfitrión.
// La fotografía es obligatoria al crear.
router.post(
  '/',
  requireHost,
  uploadPhoto,
  createProperty
);

// ==========================================
// NUEVO: EDITAR ALOJAMIENTO
// ==========================================

// Requiere iniciar sesión como anfitrión.
//
// El controlador updateProperty comprueba
// que el alojamiento le pertenezca.
//
// Si se envía una fotografía nueva,
// se procesa y reemplaza la anterior.
//
// Si no se envía ninguna fotografía,
// se conserva la fotografía existente.
router.put(
  '/:id',
  requireHost,
  uploadPhoto,
  updateProperty
);

// ==========================================
// ELIMINAR ALOJAMIENTO
// ==========================================

// El controlador comprueba que la
// publicación pertenezca al anfitrión
// y que no tenga reservas asociadas.
router.delete(
  '/:id',
  requireHost,
  deleteProperty
);

// ==========================================
// EXPORTAR RUTAS
// ==========================================

module.exports = router;
