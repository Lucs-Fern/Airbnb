
-- ============================================
-- ROOMLY - BASE DE DATOS
-- PostgreSQL
-- ============================================

-- ============================================
-- 1. TABLA DE ROLES
-- ============================================

CREATE TABLE IF NOT EXISTS roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(30) NOT NULL UNIQUE
);

-- Insertar los roles del sistema
INSERT INTO roles (name)
VALUES
    ('huesped'),
    ('anfitrion'),
    ('roomie')
ON CONFLICT (name) DO NOTHING;


-- ============================================
-- 2. TABLA DE USUARIOS
-- ============================================

CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,

    full_name VARCHAR(120) NOT NULL,

    email VARCHAR(255) NOT NULL,

    password_hash TEXT NOT NULL,

    phone VARCHAR(25),

    role_id INTEGER NOT NULL,

    created_at TIMESTAMPTZ
        NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_user_role
        FOREIGN KEY (role_id)
        REFERENCES roles(id)
);

-- Impedir correos duplicados
-- sin importar mayúsculas o minúsculas
CREATE UNIQUE INDEX IF NOT EXISTS idx_users_email
ON users (LOWER(email));


-- ============================================
-- 3. TABLA DE ALOJAMIENTOS
-- ============================================

CREATE TABLE IF NOT EXISTS properties (
    id BIGSERIAL PRIMARY KEY,

    host_id BIGINT NOT NULL,

    title VARCHAR(150) NOT NULL,

    description TEXT NOT NULL,

    location VARCHAR(200) NOT NULL,

    price_monthly NUMERIC(12,2) NOT NULL
        CHECK (price_monthly > 0),

    type VARCHAR(30) NOT NULL,

    capacity INTEGER NOT NULL
        CHECK (capacity > 0),

    duration VARCHAR(50) NOT NULL,

    amenities TEXT[]
        NOT NULL DEFAULT '{}',

    available BOOLEAN
        NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ
        NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_property_host
        FOREIGN KEY (host_id)
        REFERENCES users(id)
);

-- Facilitar la búsqueda de alojamientos
-- publicados por un anfitrión
CREATE INDEX IF NOT EXISTS idx_properties_host
ON properties(host_id);


-- ============================================
-- 4. TABLA DE RESERVAS
-- ============================================

CREATE TABLE IF NOT EXISTS reservations (
    id BIGSERIAL PRIMARY KEY,

    property_id BIGINT NOT NULL,

    guest_id BIGINT NOT NULL,

    start_date DATE NOT NULL,

    end_date DATE NOT NULL,

    guests INTEGER NOT NULL
        CHECK (guests > 0),

    status VARCHAR(20)
        NOT NULL DEFAULT 'pending'
        CHECK (
            status IN (
                'pending',
                'accepted',
                'rejected'
            )
        ),

    created_at TIMESTAMPTZ
        NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_reservation_property
        FOREIGN KEY (property_id)
        REFERENCES properties(id),

    CONSTRAINT fk_reservation_guest
        FOREIGN KEY (guest_id)
        REFERENCES users(id),

    CONSTRAINT valid_reservation_dates
        CHECK (end_date > start_date)
);

-- Consultar las reservas de un alojamiento
CREATE INDEX IF NOT EXISTS idx_reservations_property
ON reservations(property_id);

-- Consultar las reservas de un huésped
CREATE INDEX IF NOT EXISTS idx_reservations_guest
ON reservations(guest_id);


-- ============================================
-- 5. VERIFICAR LAS TABLAS CREADAS
-- ============================================

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;


-- ============================================
-- 6. VERIFICAR LOS ROLES
-- ============================================

SELECT * FROM roles;
