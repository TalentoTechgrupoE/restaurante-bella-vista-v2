# 🍽️ Restaurante Bella Vista - Guía de Despliegue

Esta guía te permite desplegar el proyecto completo en cualquier máquina desde cero.

## 🔧 Requisitos Previos

### Instalaciones Necesarias
- **Docker** (versión 20.0 o superior)
- **Docker Compose** (versión 1.27 o superior)
- **Git**
- **curl** (para verificaciones automáticas)

### 📥 Instalación de Requisitos

#### Ubuntu/Debian:
```bash
sudo apt update
sudo apt install docker.io docker-compose git curl
sudo systemctl start docker
sudo usermod -aG docker $USER
```

#### CentOS/RHEL:
```bash
sudo yum install docker docker-compose git curl
sudo systemctl start docker
sudo usermod -aG docker $USER
```

#### Windows:
1. Instalar [Docker Desktop](https://docker.com/products/docker-desktop)
2. Instalar [Git](https://git-scm.com/download/win)
3. Usar Git Bash para ejecutar comandos

#### macOS:
```bash
brew install docker docker-compose git curl
```

## 🚀 Despliegue Automático (Recomendado)

### Paso 1: Clonar el Repositorio
```bash
git clone https://github.com/TalentoTechgrupoE/restaurante-bella-vista.git
cd restaurante-bella-vista
```

# 🍽️ Restaurante Bella Vista - Guía de Despliegue

Esta guía te permite desplegar el proyecto completo en cualquier máquina desde cero.

## 🔧 Requisitos Previos

### Instalaciones Necesarias
- **Docker** (versión 20.0 o superior)
- **Docker Compose** (versión 1.27 o superior)
- **Git**
- **curl** (para verificaciones automáticas)

### 📥 Instalación de Requisitos

#### Ubuntu/Debian:
```bash
sudo apt update
sudo apt install docker.io docker-compose git curl
sudo systemctl start docker
sudo usermod -aG docker $USER
```

#### CentOS/RHEL:
```bash
sudo yum install docker docker-compose git curl
sudo systemctl start docker
sudo usermod -aG docker $USER
```

#### Windows:
1. Instalar [Docker Desktop](https://docker.com/products/docker-desktop)
2. Instalar [Git](https://git-scm.com/download/win)
3. Usar Git Bash para ejecutar comandos

#### macOS:
```bash
brew install docker docker-compose git curl
```

## 🚀 Despliegue Automático (Recomendado)

### Paso 1: Clonar el Repositorio
```bash
git clone https://github.com/TalentoTechgrupoE/restaurante-bella-vista.git
cd restaurante-bella-vista
```

### Paso 2: Configurar Entorno (Opcional)
```bash
# El script puede crear .env automáticamente, pero puedes personalizarlo:
cp .env.example .env
nano .env  # Editar variables según tu entorno
```

### Paso 3: Validar Configuración (Opcional)
```bash
# Verificar que todo esté configurado correctamente
./validate-env.sh
```

### Paso 4: Ejecutar Setup Automático
```bash
./setup-complete.sh
```
```

**¡Y listo!** El script automático:
- ✅ Verifica todos los requisitos
- ✅ Configura la red de Docker
- ✅ Levanta la aplicación principal
- ✅ Configura el sistema de monitoreo
- ✅ Crea dashboards en Grafana
- ✅ Genera datos de prueba
- ✅ Te da todas las URLs y credenciales

## 🔧 Despliegue Manual (Paso a Paso)

Si prefieres control total sobre el proceso:

### 1. Verificar Docker
```bash
docker --version
docker-compose --version
docker info
```

### 2. Crear Red de Docker
```bash
docker network create restaurante-network
```

### 3. Levantar Aplicación Principal
```bash
# Construir y levantar servicios
docker-compose up -d --build

# Verificar que esté funcionando
curl http://localhost:3000
```

### 4. Levantar Sistema de Monitoreo
```bash
# Levantar servicios de monitoreo
docker-compose -f docker-compose.monitoring.yml up -d

# Verificar Grafana
curl http://localhost:3001/api/health
```

### 5. Configurar Dashboards (Opcional)
Los dashboards se pueden crear manualmente en Grafana o usar el script automático.

## 📊 Accesos y URLs

Una vez desplegado, tendrás acceso a:

| Servicio | URL | Credenciales |
|----------|-----|--------------|
| 🍽️ Aplicación | http://localhost:3000 | - |
| 📈 Grafana | http://localhost:3001 | admin / bella123 |
| 🔍 Prometheus | http://localhost:9090 | - |
| 📦 cAdvisor | http://localhost:8080 | - |
| 🗄️ PostgreSQL | localhost:5432 | restaurante / bella123 |

## 🎯 Verificación del Despliegue

### Verificar Servicios
```bash
# Ver contenedores corriendo
docker ps

# Verificar que responden
curl http://localhost:3000        # Aplicación
curl http://localhost:3001        # Grafana
curl http://localhost:9090        # Prometheus
```

### Generar Datos de Prueba
```bash
# Ejecutar generador de tráfico
./live-traffic.sh

# O generar requests manualmente
for i in {1..10}; do curl http://localhost:3000/; done
```

### Verificar Métricas
```bash
# Ver métricas del frontend
curl http://localhost:3000/metrics

# Ver métricas en Prometheus
curl "http://localhost:9090/api/v1/query?query=http_requests_total"
```

## 🛠️ Comandos Útiles

### Gestión de Servicios
```bash
# Ver logs
docker-compose logs -f
docker-compose -f docker-compose.monitoring.yml logs -f

# Reiniciar servicios
docker-compose restart
docker-compose -f docker-compose.monitoring.yml restart

# Detener servicios
docker-compose down
docker-compose -f docker-compose.monitoring.yml down

# Limpiar todo (¡cuidado!)
docker-compose down -v
docker-compose -f docker-compose.monitoring.yml down -v
```

### Troubleshooting
```bash
# Verificar red
docker network ls | grep restaurante

# Ver estado de contenedores
docker ps -a

# Logs específicos
docker logs bella-vista-frontend-usuario
docker logs bella-vista-grafana
docker logs bella-vista-prometheus
```

## 🌐 Configuración para Acceso Remoto

Si quieres acceder desde otras máquinas en la red:

### 1. Modificar docker-compose.yml
Cambiar:
```yaml
ports:
  - "3000:3000"  # Solo localhost
```

Por:
```yaml
ports:
  - "0.0.0.0:3000:3000"  # Todas las interfaces
```

### 2. Configurar Firewall
```bash
# Ubuntu/Debian
sudo ufw allow 3000
sudo ufw allow 3001
sudo ufw allow 9090

# CentOS/RHEL
sudo firewall-cmd --add-port=3000/tcp --permanent
sudo firewall-cmd --add-port=3001/tcp --permanent
sudo firewall-cmd --add-port=9090/tcp --permanent
sudo firewall-cmd --reload
```

## 🔒 Configuración de Producción

Para entornos de producción:

### 1. Cambiar Credenciales
Editar `.env` o variables de entorno:
```bash
GRAFANA_ADMIN_PASSWORD=tu_password_seguro
POSTGRES_PASSWORD=tu_password_seguro
```

### 2. SSL/HTTPS
Usar reverse proxy (nginx, traefik) para HTTPS.

### 3. Backup
Configurar backup automático de PostgreSQL:
```bash
# Backup manual
docker exec bella-vista-postgres pg_dump -U restaurante bella_vista > backup.sql

# Restore
docker exec -i bella-vista-postgres psql -U restaurante bella_vista < backup.sql
```

## 🆘 Solución de Problemas

### Problema: Puerto ya en uso
```bash
# Ver qué está usando el puerto
netstat -tulpn | grep :3000
# O en Windows
netstat -an | findstr :3000

# Matar proceso si es necesario
sudo kill -9 <PID>
```

### Problema: Docker no funciona
```bash
# Reiniciar Docker
sudo systemctl restart docker

# En Windows: Reiniciar Docker Desktop
```

### Problema: Falta memoria
```bash
# Limpiar Docker
docker system prune -f
docker volume prune -f
```

### Problema: Base de datos no inicia
```bash
# Ver logs de PostgreSQL
docker logs bella-vista-postgres

# Reiniciar solo la base de datos
docker-compose restart postgres
```

## 📞 Soporte

Si tienes problemas:

1. **Revisar logs**: `docker-compose logs`
2. **Verificar requisitos**: Docker version, espacio en disco
3. **Consultar documentación**: README.md del proyecto
4. **Reportar issues**: GitHub Issues del repositorio

---

**¡Disfruta tu Restaurante Bella Vista!** 🍽️✨
