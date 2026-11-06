
const jwt = require('jsonwebtoken');
const pool = require('../config/database');

async function requireHost(req, res, next) {
  const authorization = req.headers.authorization || '';

  if (!authorization.startsWith('Bearer ')) {
    return res.status(401).json({
      success: false,
      message: 'Debes iniciar sesión para publicar.'
    });
  }

  const token = authorization.substring(7);

  let decoded;

  try {
    decoded = jwt.verify(
      token,
      process.env.JWT_SECRET,
      { algorithms: ['HS256'] }
    );
  } catch (error) {
    return res.status(401).json({
      success: false,
      message: 'La sesión no es válida o ha expirado.'
    });
  }

  try {
    const result = await pool.query(
      `SELECT u.id, r.name AS role
       FROM users u
       JOIN roles r ON r.id = u.role_id
       WHERE u.id = $1`,
      [decoded.sub]
    );

    const user = result.rows[0];

    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Usuario no encontrado.'
      });
    }

    if (user.role !== 'anfitrion') {
      return res.status(403).json({
        success: false,
        message: 'Solo los anfitriones pueden publicar alojamientos.'
      });
    }

    req.userId = user.id;

    next();

  } catch (error) {
    console.error('Error de autorización:', error.message);

    return res.status(500).json({
      success: false,
      message: 'No fue posible validar el usuario.'
    });
  }
}

module.exports = { requireHost };
