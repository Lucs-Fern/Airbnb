const fs = require('node:fs/promises');
const path = require('node:path');
const crypto = require('node:crypto');
const sharp = require('sharp');

const pool = require('../config/database');

const uploadsDirectory = path.join(
  __dirname,
  '../../uploads'
);

// PUBLICAR ALOJAMIENTO
async function createProperty(req, res) {
  let savedFile = null;

  try {
    const {
      title,
      description,
      location,
      type,
      duration,
      house_rules
    } = req.body;

    const price = Number(req.body.price_monthly);
    const capacity = Number(req.body.capacity);

    let amenities;

    try {
      amenities = JSON.parse(req.body.amenities || '[]');
    } catch (_) {
      return res.status(400).json({
        success: false,
        message: 'Los servicios no tienen un formato válido.'
      });
    }

    // Validar los datos de la publicación
    const validText = (value, min, max) =>
      typeof value === 'string' &&
      value.trim().length >= min &&
      value.trim().length <= max;

    if (
      !validText(title, 5, 150) ||
      !validText(description, 20, 5000) ||
      !validText(location, 3, 200) ||
      !validText(duration, 3, 50) ||
      !['Apartamento', 'Habitación'].includes(type) ||
      !Number.isFinite(price) ||
      price <= 0 ||
      !Number.isInteger(capacity) ||
      capacity < 1 ||
      capacity > 30 ||
      !Array.isArray(amenities) ||
      amenities.length > 20 ||
      !amenities.every(
        item => validText(item, 1, 50)
      ) ||
      (house_rules != null &&
        (typeof house_rules !== 'string' ||
          house_rules.length > 2000))
    ) {
      return res.status(400).json({
        success: false,
        message: 'Verifica los datos del alojamiento.'
      });
    }

    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'Debes agregar una fotografía.'
      });
    }

    // Crear carpeta de fotografías
    await fs.mkdir(uploadsDirectory, {
      recursive: true
    });

    // Generar nombre único
    const filename = `${crypto.randomUUID()}.webp`;

    savedFile = path.join(
      uploadsDirectory,
      filename
    );

    // Procesar y optimizar la fotografía
    await sharp(req.file.buffer, {
      limitInputPixels: 20000000
    })
      .rotate()
      .resize({
        width: 1600,
        withoutEnlargement: true
      })
      .webp({ quality: 80 })
      .toFile(savedFile);

    const imagePath = `/uploads/${filename}`;

    // Guardar publicación en PostgreSQL
    const result = await pool.query(
      `INSERT INTO properties (
        host_id,
        title,
        description,
        location,
        price_monthly,
        type,
        capacity,
        duration,
        amenities,
        available,
        image_path,
        house_rules
      )
      VALUES (
        $1, $2, $3, $4, $5, $6,
        $7, $8, $9, TRUE, $10, $11
      )
      RETURNING *`,
      [
        req.userId,
        title.trim(),
        description.trim(),
        location.trim(),
        price,
        type,
        capacity,
        duration.trim(),
        amenities,
        imagePath,
        house_rules || null
      ]
    );

    return res.status(201).json({
      success: true,
      message: 'Alojamiento publicado con éxito.',
      property: result.rows[0]
    });

  } catch (error) {
    // Eliminar la foto si falla la publicación
    if (savedFile) {
      await fs.unlink(savedFile).catch(() => {});
    }

    console.error('Error al publicar:', error.message);

    return res.status(500).json({
      success: false,
      message: 'No fue posible publicar el alojamiento.'
    });
  }
}

// CONSULTAR ALOJAMIENTOS
async function getProperties(req, res) {
  try {
    const result = await pool.query(
      `SELECT
        p.*,
        u.full_name AS host_name
       FROM properties p
       JOIN users u ON u.id = p.host_id
       WHERE p.available = TRUE
       ORDER BY p.created_at DESC
       LIMIT 100`
    );

    return res.json({
      success: true,
      properties: result.rows
    });

  } catch (error) {
    console.error('Error al consultar:', error.message);

    return res.status(500).json({
      success: false,
      message: 'No fue posible cargar los alojamientos.'
    });
  }
}

// NUEVO: mostrar solamente las publicaciones del anfitrión autenticado
async function getMyProperties(req, res) {
  try {
    const result = await pool.query(
      `SELECT * FROM properties
       WHERE host_id = $1
       ORDER BY created_at DESC`,
      [req.userId]
    );

    return res.json({
      success: true,
      properties: result.rows
    });
  } catch (error) {
    console.error('Error al listar publicaciones propias:', error.message);
    return res.status(500).json({
      success: false,
      message: 'No fue posible consultar tus publicaciones.'
    });
  }
}

// NUEVO: eliminar solo un alojamiento del anfitrión autenticado
async function deleteProperty(req, res) {
  const id = Number(req.params.id);

  if (!Number.isSafeInteger(id) || id <= 0) {
    return res.status(400).json({
      success: false,
      message: 'Identificador de alojamiento inválido.'
    });
  }

  try {
    const ownership = await pool.query(
      `SELECT id FROM properties WHERE id = $1 AND host_id = $2`,
      [id, req.userId]
    );

    if (ownership.rowCount === 0) {
      return res.status(404).json({
        success: false,
        message: 'No existe esa publicación entre tus alojamientos.'
      });
    }

    // Evita borrar el historial incluso si la FK usa ON DELETE CASCADE.
    const reservations = await pool.query(
      `SELECT 1 FROM reservations WHERE property_id = $1 LIMIT 1`,
      [id]
    );
    if (reservations.rowCount > 0) {
      return res.status(409).json({
        success: false,
        message: 'Este alojamiento tiene reservas asociadas. No puede eliminarse sin revisar su historial.'
      });
    }

    // Se restringe también por propietario durante el DELETE.
    const result = await pool.query(
      `DELETE FROM properties
       WHERE id = $1 AND host_id = $2
       RETURNING id, image_path`,
      [id, req.userId]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({
        success: false,
        message: 'No existe esa publicación entre tus alojamientos.'
      });
    }

    const imagePath = result.rows[0].image_path;
    // Solo tocar archivos de nuestra propia carpeta y formato generado.
    if (typeof imagePath === 'string' &&
        /^\/uploads\/[a-f0-9-]+\.webp$/i.test(imagePath)) {
      const absolutePath = path.join(
        uploadsDirectory,
        path.basename(imagePath)
      );
      try {
        await fs.unlink(absolutePath);
      } catch (fileError) {
        if (fileError.code !== 'ENOENT') {
          console.error('La foto quedó sin eliminar:', fileError.message);
        }
      }
    }

    return res.json({
      success: true,
      message: 'Alojamiento eliminado correctamente.'
    });
  } catch (error) {
    if (error.code === '23503') {
      return res.status(409).json({
        success: false,
        message: 'Este alojamiento tiene registros relacionados (por ejemplo, reservas). No puede eliminarse sin revisar su historial.'
      });
    }

    console.error('Error al eliminar alojamiento:', error.message);
    return res.status(500).json({
      success: false,
      message: 'No fue posible eliminar el alojamiento.'
    });
  }
}

module.exports = {
  createProperty,
  getProperties,
  getMyProperties,
  deleteProperty
};
