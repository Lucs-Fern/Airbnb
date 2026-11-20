
const fs = require('node:fs/promises');
const path = require('node:path');
const crypto = require('node:crypto');
const sharp = require('sharp');

const pool = require('../config/database');

const uploadsDirectory = path.join(
  __dirname,
  '../../uploads'
);

// ==========================================
// PUBLICAR ALOJAMIENTO
// ==========================================

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

    const priceUnit =
      duration === 'Corto plazo' ? 'night' : 'month';

    let amenities;

    try {
      amenities = JSON.parse(req.body.amenities || '[]');
    } catch (_) {
      return res.status(400).json({
        success: false,
        message: 'Los servicios no tienen un formato válido.'
      });
    }

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

    await fs.mkdir(uploadsDirectory, {
      recursive: true
    });

    const filename = `${crypto.randomUUID()}.webp`;

    savedFile = path.join(
      uploadsDirectory,
      filename
    );

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

    const result = await pool.query(
      `INSERT INTO properties (
        host_id,
        title,
        description,
        location,
        price_monthly,
        price_unit,
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
        $7, $8, $9, $10, TRUE, $11, $12
      )
      RETURNING *`,
      [
        req.userId,
        title.trim(),
        description.trim(),
        location.trim(),
        price,
        priceUnit,
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
    if (savedFile) {
      await fs.unlink(savedFile).catch(() => {});
    }

    console.error(
      'Error al publicar:',
      error.message
    );

    return res.status(500).json({
      success: false,
      message: 'No fue posible publicar el alojamiento.'
    });
  }
}

// ==========================================
// CONSULTAR ALOJAMIENTOS
// ==========================================

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
    console.error(
      'Error al consultar:',
      error.message
    );

    return res.status(500).json({
      success: false,
      message: 'No fue posible cargar los alojamientos.'
    });
  }
}

// ==========================================
// MIS PUBLICACIONES
// ==========================================

async function getMyProperties(req, res) {
  try {
    const result = await pool.query(
      `SELECT *
       FROM properties
       WHERE host_id = $1
       ORDER BY created_at DESC`,
      [req.userId]
    );

    return res.json({
      success: true,
      properties: result.rows
    });

  } catch (error) {
    console.error(
      'Error al listar publicaciones propias:',
      error.message
    );

    return res.status(500).json({
      success: false,
      message: 'No fue posible consultar tus publicaciones.'
    });
  }
}

// ==========================================
// NUEVO: EDITAR ALOJAMIENTO
// ==========================================

async function updateProperty(req, res) {
  const id = Number(req.params.id);
  let savedFile = null;

  // Comprobar que el identificador sea válido.
  if (!Number.isSafeInteger(id) || id <= 0) {
    return res.status(400).json({
      success: false,
      message: 'Identificador de alojamiento inválido.'
    });
  }

  try {
    // ========================================
    // 1. COMPROBAR QUE SEA EL PROPIETARIO
    // ========================================

    const ownership = await pool.query(
      `SELECT id, image_path
       FROM properties
       WHERE id = $1 AND host_id = $2`,
      [id, req.userId]
    );

    if (ownership.rowCount === 0) {
      return res.status(404).json({
        success: false,
        message:
          'No existe esa publicación entre tus alojamientos.'
      });
    }

    // Recordamos la fotografía actual.
    const oldImagePath = ownership.rows[0].image_path;

    // ========================================
    // 2. RECIBIR LOS DATOS ACTUALIZADOS
    // ========================================

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

    // El precio depende del tipo de duración.
    const priceUnit =
      duration === 'Corto plazo' ? 'night' : 'month';

    let amenities;

    try {
      amenities = JSON.parse(
        req.body.amenities || '[]'
      );
    } catch (_) {
      return res.status(400).json({
        success: false,
        message:
          'Los servicios no tienen un formato válido.'
      });
    }

    // ========================================
    // 3. VALIDAR LOS CAMPOS
    // ========================================

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
        message:
          'Verifica los datos del alojamiento.'
      });
    }

    // ========================================
    // 4. PROCESAR FOTO NUEVA SI EXISTE
    // ========================================

    // Si no se selecciona una foto nueva,
    // la foto anterior permanece sin cambios.
    let newImagePath = null;

    if (req.file) {
      await fs.mkdir(uploadsDirectory, {
        recursive: true
      });

      const filename =
        `${crypto.randomUUID()}.webp`;

      savedFile = path.join(
        uploadsDirectory,
        filename
      );

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

      newImagePath = `/uploads/${filename}`;
    }

    // ========================================
    // 5. ACTUALIZAR EN POSTGRESQL
    // ========================================

    const result = await pool.query(
      `UPDATE properties
       SET
         title = $1,
         description = $2,
         location = $3,
         price_monthly = $4,
         price_unit = $5,
         type = $6,
         capacity = $7,
         duration = $8,
         amenities = $9,
         house_rules = $10,
         image_path = COALESCE($11::text, image_path)
       WHERE id = $12 AND host_id = $13
       RETURNING *`,
      [
        title.trim(),
        description.trim(),
        location.trim(),
        price,
        priceUnit,
        type,
        capacity,
        duration.trim(),
        amenities,
        house_rules?.trim() || null,
        newImagePath,
        id,
        req.userId
      ]
    );

    // Revalidar la propiedad en el UPDATE.
    if (result.rowCount === 0) {
      if (savedFile) {
        await fs.unlink(savedFile).catch(() => {});
        savedFile = null;
      }

      return res.status(404).json({
        success: false,
        message:
          'No existe esa publicación entre tus alojamientos.'
      });
    }

    // ========================================
    // 6. LIMPIAR FOTOGRAFÍA ANTERIOR
    // ========================================

    // Solo eliminamos la fotografía anterior
    // después de confirmar el UPDATE.
    if (
      newImagePath &&
      typeof oldImagePath === 'string' &&
      /^\/uploads\/[a-f0-9-]+\.webp$/i.test(oldImagePath)
    ) {
      const oldAbsolutePath = path.join(
        uploadsDirectory,
        path.basename(oldImagePath)
      );

      try {
        await fs.unlink(oldAbsolutePath);
      } catch (fileError) {
        if (fileError.code !== 'ENOENT') {
          console.error(
            'No se pudo eliminar la foto anterior:',
            fileError.message
          );
        }
      }
    }

    // ========================================
    // 7. RESPONDER A FLUTTER
    // ========================================

    return res.json({
      success: true,
      message: 'Alojamiento actualizado correctamente.',
      property: result.rows[0]
    });

  } catch (error) {
    // Si falla el UPDATE o el procesamiento,
    // eliminamos la foto nueva que se haya creado.
    if (savedFile) {
      await fs.unlink(savedFile).catch(() => {});
    }

    console.error(
      'Error al actualizar alojamiento:',
      error.message
    );

    return res.status(500).json({
      success: false,
      message:
        'No fue posible actualizar el alojamiento.'
    });
  }
}

// ==========================================
// ELIMINAR ALOJAMIENTO
// ==========================================

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
      `SELECT id
       FROM properties
       WHERE id = $1 AND host_id = $2`,
      [id, req.userId]
    );

    if (ownership.rowCount === 0) {
      return res.status(404).json({
        success: false,
        message:
          'No existe esa publicación entre tus alojamientos.'
      });
    }

    // Evitar borrar publicaciones con reservas asociadas.
    const reservations = await pool.query(
      `SELECT 1
       FROM reservations
       WHERE property_id = $1
       LIMIT 1`,
      [id]
    );

    if (reservations.rowCount > 0) {
      return res.status(409).json({
        success: false,
        message:
          'Este alojamiento tiene reservas asociadas. '
          + 'No puede eliminarse sin revisar su historial.'
      });
    }

    const result = await pool.query(
      `DELETE FROM properties
       WHERE id = $1 AND host_id = $2
       RETURNING id, image_path`,
      [id, req.userId]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({
        success: false,
        message:
          'No existe esa publicación entre tus alojamientos.'
      });
    }

    const imagePath = result.rows[0].image_path;

    // Solo eliminar fotografías generadas por Roomly.
    if (
      typeof imagePath === 'string' &&
      /^\/uploads\/[a-f0-9-]+\.webp$/i.test(imagePath)
    ) {
      const absolutePath = path.join(
        uploadsDirectory,
        path.basename(imagePath)
      );

      try {
        await fs.unlink(absolutePath);
      } catch (fileError) {
        if (fileError.code !== 'ENOENT') {
          console.error(
            'La foto quedó sin eliminar:',
            fileError.message
          );
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
        message:
          'Este alojamiento tiene registros relacionados '
          + '(por ejemplo, reservas). '
          + 'No puede eliminarse sin revisar su historial.'
      });
    }

    console.error(
      'Error al eliminar alojamiento:',
      error.message
    );

    return res.status(500).json({
      success: false,
      message:
        'No fue posible eliminar el alojamiento.'
    });
  }
}

// ==========================================
// EXPORTAR FUNCIONES
// ==========================================

module.exports = {
  createProperty,
  getProperties,
  getMyProperties,
  updateProperty,
  deleteProperty
};
