# 🍽️ Restaurante Bella Vista

**Sistema de pedidos moderno con monitoreo avanzado - Ultra 2025**

![Estado](https://img.shields.io/badge/Estado-Completado-brightgreen)
![Versión](https://img.shields.io/badge/Versión-2.0-blue)
![Docker](https://img.shields.io/badge/Docker-Ready-blue)
![Monitoreo](https://img.shields.io/badge/Monitoring-Prometheus%2BGrafana-orange)

## 🚀 Inicio Ultra Rápido

### ⚡ **Despliegue Automático (Recomendado)**

```bash
# 1. Clonar repositorio
git clone https://github.com/TalentoTechGrupoE/restaurante-bella-vista.git
cd restaurante-bella-vista

# 2. Ejecutar despliegue completo automático
./setup-complete.sh
```

**¡Listo en menos de 5 minutos!** El sistema estará disponible en:
- 🍽️ **Aplicación:** http://localhost:3000
- 📊 **Grafana:** http://localhost:3001 (admin/bella123)
- 📈 **Prometheus:** http://localhost:9090
- 🔍 **Métricas:** http://localhost:3000/metrics

### 🔧 **Configuración Manual (Avanzado)**

```bash
# 1. Configurar entorno
cp .env.example .env
nano .env  # Editar según tus necesidades

# 2. Validar configuración
./validate-env.sh

# 3. Desplegar paso a paso
docker-compose up -d --build
./monitoring/scripts/setup-monitoring.sh
```

### 📚 **Documentación Completa**

- 📖 **[Guía de Despliegue](DEPLOY.md)** - Instrucciones detalladas
- ⚙️ **[Variables de Entorno](documentacion/variables-entorno.md)** - Configuración
- 🗄️ **[Base de Datos](documentacion/base-de-datos.md)** - Esquema y datos
- 📊 **[Resumen Técnico](documentacion/RESUMEN-TECNICO.md)** - Arquitectura

## ✨ Características

### 🎨 Aplicación
- 🎨 **Diseño Ultra Moderno 2025** - Paleta coral, turquesa y dorado
- 🎠 **Carrusel Interactivo** - Platos destacados con navegación táctil
- 📱 **Totalmente Responsive** - Optimizado para móvil, tablet y desktop
- 🛒 **Sistema de Pedidos** - Carrito funcional con modal interactivo
- 🗄️ **Base de Datos PostgreSQL** - Datos persistentes
- 🐳 **Docker Ready** - Instalación con un solo comando

### 📊 Sistema de Monitoreo (NUEVO)
- � **Dashboard Ejecutivo** - Para propietarios y gerentes
- 🍽️ **Dashboard Operacional** - Para supervisores y meseros
- 🔧 **Dashboard Técnico** - Para administradores IT
- 💼 **Dashboard Financiero** - Para contabilidad y análisis
- 🚨 **Alertas Inteligentes** - Detección proactiva de problemas
- 📈 **Métricas en Tiempo Real** - Ingresos, pedidos, rendimiento

## �🏗️ Arquitectura Completa

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ Frontend Usuario│───▶│   PostgreSQL    │◀───│   Monitoring    │
│   (puerto 3000) │    │   (puerto 5432) │    │                 │
└─────────────────┘    └─────────────────┘    │ • Prometheus    │
                                              │ • Grafana       │
                                              │ • Exporters     │
                                              └─────────────────┘
```

## 🛠️ Stack Tecnológico

### Aplicación
- **Frontend**: Node.js, Express, EJS, Alpine.js
- **Base de Datos**: PostgreSQL 15
- **Estilos**: CSS3 con efectos glassmorphism y animaciones

### Monitoreo  
- **Métricas**: Prometheus + Exporters
- **Dashboards**: Grafana con 4 dashboards especializados
- **Alertas**: Sistema de alertas proactivo
- **Contenedores**: cAdvisor para métricas Docker

## 📦 Instalación

### Requisitos Previos
- Docker Desktop instalado y ejecutándose
- Git (para clonar el repositorio)
- 8GB RAM mínimo recomendado (para monitoreo)

### Instalación Completa (Recomendada)
```bash
# 1. Clonar proyecto
git clone https://github.com/TalentoTechGrupoE/restaurante-bella-vista.git

# 2. Entrar al directorio
cd restaurante-bella-vista

# 3. Iniciar todo (aplicación + monitoreo)
./start-restaurante.sh

# O comandos específicos:
./start-restaurante.sh start        # Todo
./start-restaurante.sh app          # Solo aplicación
./start-restaurante.sh monitoring   # Solo monitoreo
./start-restaurante.sh status       # Ver estado
```

### Instalación Solo Aplicación
```bash
# Levantar solo la aplicación
docker-compose up -d

# Verificar estado
docker-compose ps

# Acceder a la aplicación
http://localhost:3000
```

## 📊 Sistema de Monitoreo

### Dashboards Disponibles

| Dashboard | URL | Audiencia | Refresh |
|-----------|-----|-----------|---------|
| 🏢 **Ejecutivo** | [localhost:3001/d/ejecutivo](http://localhost:3001/d/ejecutivo) | Propietarios, Gerentes | 30s |
| 🍽️ **Operacional** | [localhost:3001/d/operacional](http://localhost:3001/d/operacional) | Supervisores, Meseros | 15s |
| 🔧 **Técnico** | [localhost:3001/d/tecnico](http://localhost:3001/d/tecnico) | Administradores IT | 10s |
| 💼 **Financiero** | [localhost:3001/d/financiero](http://localhost:3001/d/financiero) | Contabilidad | 5m |

### Servicios de Monitoreo

| Servicio | Puerto | Función |
|----------|--------|---------|
| **Grafana** | [3001](http://localhost:3001) | Dashboards (admin/bella123) |
| **Prometheus** | [9090](http://localhost:9090) | Base de datos métricas |
| **cAdvisor** | [8080](http://localhost:8080) | Métricas contenedores |
| **Node Exporter** | 9100 | Métricas del sistema |
| **PostgreSQL Exporter** | 9187 | Métricas base de datos |

### Métricas Principales

**🏢 Para Gerentes:**
- 💰 Ingresos en tiempo real
- 📈 % de objetivo diario alcanzado
- 👥 Clientes atendidos
- 🎯 Ticket promedio

**🍽️ Para Operaciones:**
- 🪑 Mesas ocupadas vs. disponibles
- 🍕 Pedidos activos en cocina
- ⏱️ Tiempo promedio por mesa
- 🚨 Pedidos retrasados (+30min)

**🔧 Para IT:**
- 🟢 Estado de servicios (UP/DOWN)
- 💾 Uso de memoria por contenedor
- 🖥️ Uso de CPU en tiempo real
- 🗄️ Conexiones a PostgreSQL
- 🚨 Errores por minuto

**💼 Para Finanzas:**
- 💳 Distribución pagos (efectivo/tarjeta/digital)
- 📉 % errores en pagos
- 📊 Ingresos por categoría/plato
- 📈 Tendencias semanales

## 🎯 Funcionalidades

### ✅ Implementadas
- [x] Menú interactivo con 15 platos
- [x] Carrusel de platos destacados
- [x] Sistema de carrito de compras
- [x] Modal de pedido con selección de mesa
- [x] Base de datos con datos de prueba
- [x] Diseño responsive completo
- [x] Efectos visuales modernos

### 🚧 Funcionalidades Futuras
- [ ] Panel de administración
- [ ] API REST para móviles
- [ ] Sistema de autenticación
- [ ] Notificaciones en tiempo real

## 📁 Estructura del Proyecto

```
restaurante-bella-vista/
├── 📁 frontend-usuario/          # Frontend principal
│   ├── 📁 public/css/           # Estilos modernos
│   ├── 📁 views/                # Templates EJS
│   ├── 📄 server.js             # Servidor Express
│   └── 📄 Dockerfile            # Imagen Docker
├── 📁 database/                  # Base de datos
│   └── 📄 init-db.sql           # Esquema y datos
├── 📁 documentacion/             # Documentación técnica
├── 📄 docker-compose.yml        # Configuración Docker
├── 📄 start.sh                  # Script de inicio
└── 📄 README.md                 # Este archivo
```

## 🔧 Comandos Útiles

```bash
# Iniciar servicios
docker-compose up -d

# Ver logs
docker-compose logs -f

# Parar servicios
docker-compose down

# Limpiar todo (incluye volúmenes)
docker-compose down -v

# Reconstruir imágenes
docker-compose build
```

## 🌐 URLs de Acceso

- **Frontend**: http://localhost:3000
- **Base de Datos**: localhost:5432
  - Usuario: `restaurante`
  - Password: `bella123`
  - Base de datos: `bella_vista`

## 📚 Documentación

- [📋 Guía Completa](./documentacion/README-FINAL.md)
- [🔧 Documentación Técnica](./documentacion/RESUMEN-TECNICO.md)
- [🗄️ Base de Datos](./documentacion/base-de-datos.md)

## 🤝 Contribuir

1. Fork el proyecto
2. Crea tu rama de feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para detalles.

## 👥 Equipo

**Equipo de Desarrollo Bella Vista - Talento Tech Grupo E**

**👨‍💼 Autores del Proyecto:**
- 🏗️ **Jesús Gil** - Arquitecto de Software
- 👨‍💻 **César Sáenz** - Desarrollador Backend
- 👨‍💻 **Brandon Torre** - Desarrollador Frontend

**📧 Contacto Oficial:** talentotechgrupoe@gmail.com  
**🐙 GitHub:** https://github.com/TalentoTechGrupoE/restaurante-bella-vista.git  
**📅 Fecha de finalización:** 13 de Julio, 2025

## 📞 Soporte

Para reportar bugs o solicitar features:
- 🐛 [Issues](https://github.com/TalentoTechGrupoE/restaurante-bella-vista/issues)
- 📧 Email: talentotechgrupoe@gmail.com
- 🐙 GitHub: https://github.com/TalentoTechGrupoE/restaurante-bella-vista.git

**Desarrollado por Talento Tech Grupo E**

---

⭐ **¡Si te gusta el proyecto, dale una estrella!** ⭐

**Fecha de release**: 13 de Julio, 2025  
**Estado**: ✅ Producción Ready

---

### 👨‍💻 **Desarrollado con ❤️ por Talento Tech Grupo E**
**Autores:** Jesús Gil, César Sáenz, Brandon Torre  
**GitHub:** https://github.com/TalentoTechGrupoE/restaurante-bella-vista.git  
**Email:** talentotechgrupoe@gmail.com
