const express = require('express');
const multer = require('multer');

const { requireHost } = require('../middlewares/auth_middleware');

const {
  createProperty,
  getProperties,
  getMyProperties,
  deleteProperty
} = require('../controllers/property_controller');

const router = express.Router();

// Recibir una foto de máximo 5 MB
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
        new Error('Solo se permiten imágenes JPG, PNG o WebP.')
      );
    }

    callback(null, true);
  }
});

// Lista pública de alojamientos
router.get('/', getProperties);

// NUEVO: publicaciones del anfitrión autenticado
router.get('/mine', requireHost, getMyProperties);

// Crear publicación: requiere anfitrión autenticado
router.post(
  '/',
  requireHost,
  (req, res, next) => {
    upload.single('photo')(req, res, error => {
      if (error) {
        return res.status(400).json({
          success: false,
          message: error.message
        });
      }

      next();
    });
  },
  createProperty
);

// NUEVO: eliminación autorizada por propietario
router.delete('/:id', requireHost, deleteProperty);

module.exports = router;
