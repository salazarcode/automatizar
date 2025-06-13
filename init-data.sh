#!/bin/bash
set -e

# Script de inicialización para PostgreSQL
# Crea un usuario no-root para n8n

echo "=== Inicializando base de datos PostgreSQL para n8n ==="

# Crear usuario no-root si no existe
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    DO \$\$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '$POSTGRES_NON_ROOT_USER') THEN
            CREATE USER $POSTGRES_NON_ROOT_USER WITH PASSWORD '$POSTGRES_NON_ROOT_PASSWORD';
        END IF;
    END
    \$\$;
    
    -- Otorgar permisos necesarios
    GRANT ALL PRIVILEGES ON DATABASE $POSTGRES_DB TO $POSTGRES_NON_ROOT_USER;
    
    -- Otorgar permisos para crear tablas
    GRANT ALL ON SCHEMA public TO $POSTGRES_NON_ROOT_USER;
    
    -- Permitir crear esquemas
    GRANT CREATE ON DATABASE $POSTGRES_DB TO $POSTGRES_NON_ROOT_USER;
    
    -- Configurar permisos por defecto
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO $POSTGRES_NON_ROOT_USER;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO $POSTGRES_NON_ROOT_USER;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO $POSTGRES_NON_ROOT_USER;
    
    -- Crear extensiones útiles
    CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
    CREATE EXTENSION IF NOT EXISTS "pgcrypto";
    
EOSQL

echo "=== Base de datos inicializada correctamente ==="
echo "Usuario creado: $POSTGRES_NON_ROOT_USER"
echo "Base de datos: $POSTGRES_DB"