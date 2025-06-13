# Scripts de gestión para N8N

## start.sh - Iniciar servicios
```bash
#!/bin/bash
echo "=== Iniciando N8N con PostgreSQL ==="
docker compose up -d
echo "=== Servicios iniciados ==="
echo "N8N disponible en: http://localhost:5678"
docker compose ps
```

## stop.sh - Detener servicios
```bash
#!/bin/bash
echo "=== Deteniendo servicios N8N ==="
docker compose stop
echo "=== Servicios detenidos ==="
```

## restart.sh - Reiniciar servicios
```bash
#!/bin/bash
echo "=== Reiniciando servicios N8N ==="
docker compose restart
echo "=== Servicios reiniciados ==="
docker compose ps
```

## logs.sh - Ver logs
```bash
#!/bin/bash
if [ "$1" = "n8n" ]; then
    docker compose logs -f n8n
elif [ "$1" = "postgres" ]; then
    docker compose logs -f postgres
else
    docker compose logs -f
fi
```

## backup.sh - Crear backup
```bash
#!/bin/bash
BACKUP_DIR="./backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "=== Creando backup de PostgreSQL ==="
docker compose exec postgres pg_dump -U n8n_admin n8n_db > "$BACKUP_DIR/database.sql"

echo "=== Creando backup de datos N8N ==="
docker compose exec n8n tar -czf /tmp/n8n-data.tar.gz /home/node/.n8n
docker compose cp n8n:/tmp/n8n-data.tar.gz "$BACKUP_DIR/n8n-data.tar.gz"

echo "=== Backup completado en: $BACKUP_DIR ==="
```

## update.sh - Actualizar servicios
```bash
#!/bin/bash
echo "=== Actualizando imágenes N8N ==="
docker compose pull
echo "=== Recreando contenedores ==="
docker compose up -d --force-recreate
echo "=== Actualización completada ==="
docker compose ps
```

## status.sh - Estado de servicios
```bash
#!/bin/bash
echo "=== Estado de los servicios ==="
docker compose ps
echo ""
echo "=== Health checks ==="
docker compose exec n8n wget --no-verbose --tries=1 --spider http://localhost:5678/healthz && echo "N8N: OK" || echo "N8N: ERROR"
docker compose exec postgres pg_isready -h localhost -U n8n_admin -d n8n_db && echo "PostgreSQL: OK" || echo "PostgreSQL: ERROR"
```

## Uso de los scripts

Para usar estos scripts en Ubuntu, guárdalos como archivos `.sh` y hazlos ejecutables:

```bash
chmod +x *.sh
```

Luego puedes ejecutarlos:
```bash
./start.sh
./logs.sh n8n
./backup.sh
./status.sh
```