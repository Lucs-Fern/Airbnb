
-- ============================================
-- ROOMLY
-- MIGRACION 001
-- FAVORITOS PERMANENTES
-- ============================================

-- Objetivo:
-- Permitir que cada usuario autenticado
-- guarde sus alojamientos favoritos
-- de manera permanente en PostgreSQL.
--
-- Requisitos:
-- Las tablas public.users y
-- public.properties deben existir.
--
-- Esta migracion se puede ejecutar
-- varias veces sin duplicar la tabla.

BEGIN;

-- ============================================
-- 1. CREAR TABLA DE FAVORITOS
-- ============================================

CREATE TABLE IF NOT EXISTS public.favorites (
    user_id BIGINT NOT NULL,

    property_id BIGINT NOT NULL,

    created_at TIMESTAMPTZ
        NOT NULL
        DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT favorites_pkey
        PRIMARY KEY (user_id, property_id),

    CONSTRAINT favorites_user_id_fkey
        FOREIGN KEY (user_id)
        REFERENCES public.users(id)
        ON DELETE CASCADE,

    CONSTRAINT favorites_property_id_fkey
        FOREIGN KEY (property_id)
        REFERENCES public.properties(id)
        ON DELETE CASCADE
);

-- ============================================
-- 2. INDICE PARA CONSULTAS
-- ============================================

-- La clave primaria ya permite consultar
-- los favoritos por usuario.
--
-- Este indice adicional optimiza las
-- consultas relacionadas con alojamientos.

CREATE INDEX IF NOT EXISTS
    idx_favorites_property
ON public.favorites (property_id);

COMMIT;

-- ============================================
-- 3. VERIFICACION DE LA MIGRACION
-- ============================================

-- Comprobar que la tabla existe.

SELECT
    to_regclass('public.favorites')
        AS favorites_table;

-- Comprobar los favoritos guardados.

SELECT
    f.user_id,
    f.property_id,
    p.title AS property_title,
    f.created_at
FROM public.favorites f
JOIN public.properties p
    ON p.id = f.property_id
ORDER BY f.created_at DESC;
