# 🍽️ Restaurante Bella Vista

**Sistema de pedidos moderno con diseño ultra 2025**

![Estado](https://img.shields.io/badge/Estado-Completado-brightgreen)
![Versión](https://img.shields.io/badge/Versión-1.0-blue)
![Docker](https://img.shields.io/badge/Docker-Ready-blue)

## 🚀 Inicio Rápido

```bash
# Clonar repositorio
git clone https://github.com/TU_USUARIO/restaurante-bella-vista.git
cd restaurante-bella-vista

# Iniciar aplicación (requiere Docker)
./start.sh

# Abrir en navegador
http://localhost:3000
```

## ✨ Características

- 🎨 **Diseño Ultra Moderno 2025** - Paleta coral, turquesa y dorado
- 🎠 **Carrusel Interactivo** - Platos destacados con navegación táctil
- 📱 **Totalmente Responsive** - Optimizado para móvil, tablet y desktop
- 🛒 **Sistema de Pedidos** - Carrito funcional con modal interactivo
- 🗄️ **Base de Datos PostgreSQL** - Datos persistentes
- 🐳 **Docker Ready** - Instalación con un solo comando

## 🏗️ Arquitectura

```
┌─────────────────┐    ┌─────────────────┐
│ Frontend Usuario│───▶│   PostgreSQL    │
│   (puerto 3000) │    │   (puerto 5432) │
└─────────────────┘    └─────────────────┘
```

## 🛠️ Tecnologías

- **Frontend**: Node.js, Express, EJS, Alpine.js
- **Base de Datos**: PostgreSQL 15
- **Contenedores**: Docker & Docker Compose
- **Estilos**: CSS3 con efectos glassmorphism y animaciones

## 📦 Instalación

### Requisitos Previos
- Docker Desktop instalado y ejecutándose
- Git (para clonar el repositorio)

### Instalación Automática
```bash
# 1. Clonar proyecto
git clone https://github.com/TU_USUARIO/restaurante-bella-vista.git

# 2. Entrar al directorio
cd restaurante-bella-vista

# 3. Ejecutar script de inicio
./start.sh
```

### Instalación Manual
```bash
# Levantar servicios
docker-compose up -d

# Verificar estado
docker-compose ps

# Acceder a la aplicación
http://localhost:3000
```

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

**Equipo de Desarrollo Bella Vista**
- Desarrollo y diseño: Equipo técnico
- Fecha de finalización: 13 de Julio, 2025

## 📞 Soporte

Para reportar bugs o solicitar features:
- 🐛 [Issues](https://github.com/TU_USUARIO/restaurante-bella-vista/issues)
- 📧 Email: dev@bellavista.com

---

⭐ **¡Si te gusta el proyecto, dale una estrella!** ⭐

**Fecha de release**: 13 de Julio, 2025  
**Estado**: ✅ Producción Ready
