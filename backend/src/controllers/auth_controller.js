
const bcrypt = require('bcryptjs');
const pool = require('../config/database');
const jwt = require('jsonwebtoken');

async function register(req, res) {
  try {
    const {
      full_name,
      email,
      password,
      phone,
      role
    } = req.body || {};

    // 1. Validar nombre
    if (
      typeof full_name !== 'string' ||
      full_name.trim().length < 2 ||
      full_name.trim().length > 120
    ) {
      return res.status(400).json({
        success: false,
        message: 'Ingresa un nombre válido.'
      });
    }

    // 2. Validar correo
    if (
      typeof email !== 'string' ||
      email.length > 255 ||
      !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.trim())
    ) {
      return res.status(400).json({
        success: false,
        message: 'Ingresa un correo válido.'
      });
    }

    // 3. Validar contraseña
    if (
      typeof password !== 'string' ||
      password.length < 8 ||
      Buffer.byteLength(password, 'utf8') > 72
    ) {
      return res.status(400).json({
        success: false,
        message: 'La contraseña debe tener al menos 8 caracteres y no superar 72 bytes.'
      });
    }

    // 4. Validar rol
    const allowedRoles = ['huesped', 'anfitrion', 'roomie'];

    if (!allowedRoles.includes(role)) {
      return res.status(400).json({
        success: false,
        message: 'Selecciona un rol válido.'
      });
    }

    // 5. Validar teléfono opcional
    if (
      phone != null &&
      (
        typeof phone !== 'string' ||
        phone.length > 25
      )
    ) {
      return res.status(400).json({
        success: false,
        message: 'El teléfono no es válido.'
      });
    }

    const normalizedEmail = email.trim().toLowerCase();

    // 6. Proteger contraseña
    const passwordHash = await bcrypt.hash(password, 12);

    // 7. Guardar usuario en PostgreSQL
    const result = await pool.query(
      `INSERT INTO users
       (full_name, email, password_hash, phone, role_id)
       SELECT $1, $2, $3, $4, id
       FROM roles
       WHERE name = $5
       RETURNING id, full_name, email, phone, role_id, created_at`,
      [
        full_name.trim(),
        normalizedEmail,
        passwordHash,
        phone ? phone.trim() || null : null,
        role
      ]
    );

    if (result.rows.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'El rol seleccionado no existe.'
      });
    }

    return res.status(201).json({
      success: true,
      message: 'Usuario registrado con éxito.',
      user: result.rows[0]
    });

  } catch (error) {
    // El correo ya está registrado
    if (error.code === '23505') {
      return res.status(409).json({
        success: false,
        message: 'El correo electrónico ya está registrado.'
      });
    }

    console.error('Error al registrar usuario:', error.message);

    return res.status(500).json({
      success: false,
      message: 'No fue posible registrar el usuario.'
    });
  }
}



async function login(req, res) {
  try {
    const { email, password } = req.body || {};

    if (
      typeof email !== 'string' ||
      typeof password !== 'string' ||
      !email.trim() ||
      !password
    ) {
      return res.status(400).json({
        success: false,
        message: 'Ingresa tu correo y contraseña.'
      });
    }

    const normalizedEmail = email.trim().toLowerCase();

    // Buscar usuario y su rol en PostgreSQL
    const result = await pool.query(
      `SELECT
         u.id,
         u.full_name,
         u.email,
         u.password_hash,
         r.name AS role
       FROM users u
       INNER JOIN roles r ON r.id = u.role_id
       WHERE LOWER(u.email) = $1`,
      [normalizedEmail]
    );

    const user = result.rows[0];

    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Correo o contraseña incorrectos.'
      });
    }

    // Verificar la contraseña protegida
    const validPassword = await bcrypt.compare(
      password,
      user.password_hash
    );

    if (!validPassword) {
      return res.status(401).json({
        success: false,
        message: 'Correo o contraseña incorrectos.'
      });
    }

    // Generar token de sesión
    const token = jwt.sign(
      { role: user.role },
      process.env.JWT_SECRET,
      {
        subject: String(user.id),
        expiresIn: '2h',
        algorithm: 'HS256'
      }
    );

    return res.json({
      success: true,
      message: 'Inicio de sesión exitoso.',
      token,
      user: {
        id: user.id,
        full_name: user.full_name,
        email: user.email,
        role: user.role
      }
    });

  } catch (error) {
    console.error('Error de login:', error.message);

    return res.status(500).json({
      success: false,
      message: 'No fue posible iniciar sesión.'
    });
  }
}

module.exports = { register, login };
