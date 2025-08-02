# 🔧 Configuración de Variables de Entorno

## 📋 Configuración Básica

Este archivo describe todas las variables de entorno utilizadas en el proyecto Restaurante Bella Vista.

### 🚀 Configuración Rápida

1. **Copiar archivo de ejemplo:**
   ```bash
   cp .env.example .env
   ```

2. **Ajustar valores según tu entorno**

3. **Variables mínimas requeridas:**
   ```env
   POSTGRES_PASSWORD=bella123
   GRAFANA_ADMIN_PASSWORD=bella123
   ```

## 📊 Variables por Categoría

### 🍽️ **Aplicación Principal**

| Variable | Valor por Defecto | Descripción |
|----------|------------------|-------------|
| `NODE_ENV` | `production` | Entorno de ejecución (`development`, `production`) |
| `APP_PORT` | `3000` | Puerto de la aplicación web |
| `APP_HOST` | `0.0.0.0` | Host de la aplicación |

### 🗄️ **Base de Datos PostgreSQL**

| Variable | Valor por Defecto | Descripción |
|----------|------------------|-------------|
| `POSTGRES_DB` | `bella_vista` | Nombre de la base de datos |
| `POSTGRES_USER` | `restaurante` | Usuario de la base de datos |
| `POSTGRES_PASSWORD` | `bella123` | ⚠️ **CAMBIAR EN PRODUCCIÓN** |
| `POSTGRES_HOST` | `postgres` | Host del contenedor |
| `POSTGRES_PORT` | `5432` | Puerto interno |
| `DB_POOL_MIN` | `2` | Conexiones mínimas del pool |
| `DB_POOL_MAX` | `10` | Conexiones máximas del pool |

### 📊 **Monitoreo - Grafana**

| Variable | Valor por Defecto | Descripción |
|----------|------------------|-------------|
| `GRAFANA_PORT` | `3001` | Puerto de acceso a Grafana |
| `GRAFANA_ADMIN_USER` | `admin` | Usuario administrador |
| `GRAFANA_ADMIN_PASSWORD` | `bella123` | ⚠️ **CAMBIAR EN PRODUCCIÓN** |
| `GRAFANA_ALLOW_SIGN_UP` | `false` | Permitir registro de usuarios |

### 📈 **Monitoreo - Prometheus**

| Variable | Valor por Defecto | Descripción |
|----------|------------------|-------------|
| `PROMETHEUS_PORT` | `9090` | Puerto de acceso a Prometheus |
| `PROMETHEUS_RETENTION` | `30d` | Retención de datos |
| `ENABLE_METRICS` | `true` | Habilitar métricas |

### 🏪 **Configuración del Restaurante**

| Variable | Valor por Defecto | Descripción |
|----------|------------------|-------------|
| `RESTAURANT_NAME` | `"Bella Vista"` | Nombre del restaurante |
| `OPENING_TIME` | `12:00` | Hora de apertura |
| `CLOSING_TIME` | `23:00` | Hora de cierre |
| `MAX_TABLES` | `20` | Número máximo de mesas |
| `DAILY_REVENUE_TARGET` | `2000` | Objetivo diario (euros) |

### 🚨 **Alertas y Umbrales**

| Variable | Valor por Defecto | Descripción |
|----------|------------------|-------------|
| `ALERT_INGRESOS_MINIMOS` | `500` | Ingresos mínimos diarios (€) |
| `ALERT_PEDIDOS_MAXIMOS_COCINA` | `20` | Máximo pedidos simultáneos |
| `ALERT_MEMORY_THRESHOLD` | `90` | Umbral memoria (%) |
| `ALERT_CPU_THRESHOLD` | `80` | Umbral CPU (%) |

## 🛡️ **Configuración de Seguridad**

### ⚠️ **Variables Críticas**

Estas variables **DEBEN** cambiarse en producción:

```env
# ❌ NO usar en producción
POSTGRES_PASSWORD=bella123
GRAFANA_ADMIN_PASSWORD=bella123
JWT_SECRET=tu-clave-secreta-muy-segura-aqui

# ✅ Usar contraseñas seguras
POSTGRES_PASSWORD=mi_password_super_seguro_2024
GRAFANA_ADMIN_PASSWORD=admin_password_complejo_123
JWT_SECRET=clave-jwt-aleatoria-de-256-bits-minimo
```

### 🔒 **Buenas Prácticas**

1. **Nunca** subir el archivo `.env` al repositorio
2. Usar contraseñas de **mínimo 12 caracteres**
3. Incluir mayúsculas, minúsculas, números y símbolos
4. Cambiar contraseñas por defecto **antes** del despliegue
5. Usar secrets de Docker en producción

## 🚀 **Configuraciones por Entorno**

### 💻 **Desarrollo Local**

```env
NODE_ENV=development
DEBUG_MODE=true
VERBOSE_LOGGING=true
GENERATE_SAMPLE_DATA=true
WATCH_FILES=true
```

### 🧪 **Testing**

```env
NODE_ENV=test
POSTGRES_DB=bella_vista_test
LOG_LEVEL=warn
GENERATE_SAMPLE_DATA=false
```

### 🏭 **Producción**

```env
NODE_ENV=production
DEBUG_MODE=false
VERBOSE_LOGGING=false
LOG_LEVEL=error
GENERATE_SAMPLE_DATA=false
WATCH_FILES=false

# Usar valores seguros
POSTGRES_PASSWORD=password_production_seguro
GRAFANA_ADMIN_PASSWORD=admin_production_complejo
```

## 🔍 **Validación de Configuración**

### ✅ **Verificar Variables**

```bash
# Verificar que las variables estén cargadas
docker-compose config

# Verificar conexión a base de datos
docker-compose exec postgres psql -U restaurante -d bella_vista -c "SELECT 1;"

# Verificar métricas
curl http://localhost:3000/metrics
```

### 🐛 **Problemas Comunes**

| Problema | Causa | Solución |
|----------|-------|----------|
| Error conexión DB | Password incorrecto | Verificar `POSTGRES_PASSWORD` |
| Grafana no accesible | Puerto ocupado | Cambiar `GRAFANA_PORT` |
| Sin métricas | Métricas deshabilitadas | `ENABLE_METRICS=true` |
| Permisos | Usuario incorrecto | Verificar `POSTGRES_USER` |

## 📝 **Ejemplo de .env Completo**

```env
# Aplicación
NODE_ENV=production
APP_PORT=3000

# Base de datos
POSTGRES_DB=bella_vista
POSTGRES_USER=restaurante
POSTGRES_PASSWORD=tu_password_seguro_aqui

# Monitoreo
GRAFANA_ADMIN_PASSWORD=tu_admin_password_aqui
PROMETHEUS_RETENTION=30d

# Restaurante
RESTAURANT_NAME="Mi Restaurante"
DAILY_REVENUE_TARGET=1500
MAX_TABLES=15

# Seguridad
CORS_ORIGIN=http://localhost:3000
RATE_LIMIT_MAX_REQUESTS=100

# Logs
LOG_LEVEL=info
LOG_FORMAT=json
```

## 🔗 **Referencias**

- [Docker Compose Variables](https://docs.docker.com/compose/environment-variables/)
- [Node.js Environment Variables](https://nodejs.org/api/process.html#process_process_env)
- [PostgreSQL Configuration](https://www.postgresql.org/docs/current/config-setting.html)
- [Grafana Configuration](https://grafana.com/docs/grafana/latest/administration/configuration/)
