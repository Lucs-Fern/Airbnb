
const jwt = require('jsonwebtoken');
const pool = require('../config/database');

// ==========================================
// VALIDAR USUARIO AUTENTICADO
// ==========================================

// Esta función comprueba el JWT y consulta
// el usuario real en PostgreSQL.
//
// hostOnly = true:
//   Solo permite anfitriones.
//
// hostOnly = false:
//   Permite cualquier rol autenticado.

async function authenticateUser(req, res, next, hostOnly) {
  const authorization = req.headers.authorization || '';

  // ========================================
  // 1. COMPROBAR TOKEN
  // ========================================

  if (!authorization.startsWith('Bearer ')) {
    return res.status(401).json({
      success: false,
      message: hostOnly
        ? 'Debes iniciar sesión para publicar.'
        : 'Debes iniciar sesión para continuar.'
    });
  }

  const token = authorization.substring(7).trim();

  if (!token) {
    return res.status(401).json({
      success: false,
      message: 'Debes iniciar sesión nuevamente.'
    });
  }

  // ========================================
  // 2. VERIFICAR JWT
  // ========================================

  let decoded;

  try {
    decoded = jwt.verify(
      token,
      process.env.JWT_SECRET,
      { algorithms: ['HS256'] }
    );
  } catch (_) {
    return res.status(401).json({
      success: false,
      message: 'La sesión no es válida o ha expirado.'
    });
  }

  // El token debe contener un ID de usuario válido.
  const userId = decoded &&
    typeof decoded === 'object'
      ? decoded.sub
      : null;

  if (
    (typeof userId !== 'string' &&
      typeof userId !== 'number') ||
    !/^[1-9]\d*$/.test(String(userId))
  ) {
    return res.status(401).json({
      success: false,
      message: 'La sesión no es válida o ha expirado.'
    });
  }

  // ========================================
  // 3. BUSCAR USUARIO EN POSTGRESQL
  // ========================================

  try {
    const result = await pool.query(
      `SELECT
        u.id,
        r.name AS role
       FROM users u
       JOIN roles r ON r.id = u.role_id
       WHERE u.id = $1`,
      [userId]
    );

    const user = result.rows[0];

    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Usuario no encontrado.'
      });
    }

    // ======================================
    // 4. COMPROBAR ROL CUANDO SEA NECESARIO
    // ======================================

    if (hostOnly && user.role !== 'anfitrion') {
      return res.status(403).json({
        success: false,
        message:
          'Solo los anfitriones pueden publicar alojamientos.'
      });
    }

    // ======================================
    // 5. GUARDAR DATOS DEL USUARIO EN REQUEST
    // ======================================

    // Los controladores utilizarán este ID
    // para consultar únicamente los registros
    // correspondientes al usuario autenticado.

    req.userId = user.id;
    req.userRole = user.role;

    next();

  } catch (error) {
    console.error(
      'Error de autorización:',
      error.message
    );

    return res.status(500).json({
      success: false,
      message: 'No fue posible validar el usuario.'
    });
  }
}

// ==========================================
// AUTENTICACIÓN GENERAL
// ==========================================

// Permite:
// - Huéspedes
// - Anfitriones
// - Roomies
//
// Será utilizado en las rutas de favoritos.

function requireAuth(req, res, next) {
  return authenticateUser(req, res, next, false);
}

// ==========================================
// AUTENTICACIÓN DE ANFITRIONES
// ==========================================

// Mantiene la protección de las rutas
// para crear, editar y eliminar publicaciones.

function requireHost(req, res, next) {
  return authenticateUser(req, res, next, true);
}

// ==========================================
// EXPORTAR MIDDLEWARES
// ==========================================

module.exports = {
  requireAuth,
  requireHost
};
