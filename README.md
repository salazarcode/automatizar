# Guía de Instalación N8N con PostgreSQL en Ubuntu

## Prerrequisitos

Asegúrate de tener instalado Docker y Docker Compose en tu servidor Ubuntu:

```bash
# Actualizar el sistema
sudo apt update && sudo apt upgrade -y

# Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Instalar Docker Compose
sudo apt install docker-compose-plugin -y

# Verificar instalación
docker --version
docker compose version
```

## Configuración Inicial

### 1. Crear directorio del proyecto

```bash
mkdir n8n-docker && cd n8n-docker
```

### 2. Crear archivos de configuración

Crea los siguientes archivos en el directorio:

- `docker-compose.yml` (usar el archivo proporcionado)
- `.env` (usar el archivo proporcionado)
- `init-data.sh` (usar el script proporcionado)

### 3. Configurar permisos

```bash
# Hacer ejecutable el script de inicialización
chmod +x init-data.sh

# Crear directorio para archivos locales
mkdir -p local-files
chmod 755 local-files
```

### 4. Generar clave de encriptación

```bash
# Generar una clave de encriptación segura
openssl rand -base64 32
```

**IMPORTANTE**: Copia esta clave y reemplaza `N8N_ENCRYPTION_KEY` en el archivo `.env`

### 5. Configurar variables de entorno

Edita el archivo `.env` y personaliza:

- Cambiar todas las contraseñas por valores seguros
- Configurar `N8N_ENCRYPTION_KEY` con la clave generada
- Ajustar `N8N_HOST` si vas a usar un dominio
- Configurar zona horaria si es diferente

## Despliegue

### 1. Iniciar los servicios

```bash
# Iniciar en modo detached (background)
docker compose up -d

# Ver logs en tiempo real
docker compose logs -f

# Ver estado de los contenedores
docker compose ps
```

### 2. Verificar la instalación

```bash
# Verificar que los contenedores estén corriendo
docker compose ps

# Verificar logs de n8n
docker compose logs n8n

# Verificar logs de PostgreSQL
docker compose logs postgres
```

### 3. Acceder a N8N

Abre tu navegador y ve a:
- Local: `http://localhost:5678`
- Servidor: `http://tu-ip-servidor:5678`

## Configuración de Producción

### 1. Configurar firewall

```bash
# Permitir puerto 5678
sudo ufw allow 5678/tcp

# Para PostgreSQL (solo si necesitas acceso externo)
sudo ufw allow 5432/tcp
```

### 2. Configurar dominio (opcional)

Si tienes un dominio, actualiza el archivo `.env`:

```env
N8N_HOST=tu-dominio.com
N8N_PROTOCOL=https
WEBHOOK_URL=https://tu-dominio.com/
```

### 3. Configurar SSL con Nginx (recomendado)

```nginx
server {
    listen 80;
    server_name tu-dominio.com;
    
    location / {
        proxy_pass http://localhost:5678;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## Comandos Útiles

### Gestión de contenedores

```bash
# Parar servicios
docker compose stop

# Iniciar servicios
docker compose start

# Reiniciar servicios
docker compose restart

# Ver logs
docker compose logs -f [nombre-servicio]

# Acceder al contenedor
docker compose exec n8n bash
docker compose exec postgres psql -U n8n_admin -d n8n_db
```

### Actualización

```bash
# Actualizar imágenes
docker compose pull

# Recrear contenedores con nuevas imágenes
docker compose up -d --force-recreate
```

### Backup y Restore

```bash
# Backup de la base de datos
docker compose exec postgres pg_dump -U n8n_admin n8n_db > backup.sql

# Backup de datos de n8n
docker compose exec n8n tar -czf /tmp/n8n-backup.tar.gz /home/node/.n8n
docker compose cp n8n:/tmp/n8n-backup.tar.gz ./n8n-backup.tar.gz

# Restore de la base de datos
docker compose exec -T postgres psql -U n8n_admin n8n_db < backup.sql
```

## Solución de Problemas

### 1. Problemas de conexión a PostgreSQL

```bash
# Verificar que PostgreSQL esté corriendo
docker compose logs postgres

# Verificar conectividad
docker compose exec n8n ping postgres
```

### 2. Problemas de permisos

```bash
# Verificar permisos de archivos
ls -la init-data.sh

# Corregir permisos
chmod +x init-data.sh
```

### 3. Problemas de memoria

```bash
# Verificar uso de recursos
docker compose exec n8n htop
docker stats
```

## Monitoreo

### 1. Health checks

```bash
# Verificar estado de salud
docker compose ps

# Ver detalles de health check
docker inspect n8n-main | grep -A 10 -B 5 Health
```

### 2. Logs estructurados

Los logs se almacenan en formato JSON con rotación automática para evitar el crecimiento excesivo.

## Seguridad

### 1. Mejores prácticas

- Cambiar todas las contraseñas por defecto
- Usar HTTPS en producción
- Configurar firewall apropiadamente
- Actualizar regularmente las imágenes Docker
- Hacer backups regulares

### 2. Configuración de autenticación

En producción, habilita la autenticación básica:

```env
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=tu-usuario
N8N_BASIC_AUTH_PASSWORD=tu-password-seguro
```

## Soporte y Comunidad

- Documentación oficial: https://docs.n8n.io/
- Comunidad: https://community.n8n.io/
- GitHub: https://github.com/n8n-io/n8n