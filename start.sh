#!/bin/bash

echo "🍽️ Iniciando Restaurante Bella Vista..."
echo "======================================"

# Verificar Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker no está instalado"
    exit 1
fi

# Verificar Docker Compose (versión moderna integrada)
if ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose no está disponible"
    echo "💡 Asegúrate de tener Docker Desktop actualizado"
    exit 1
fi

echo "✅ Docker detectado"

# Levantar servicios
echo "🚀 Levantando servicios..."
docker compose up -d

echo ""
echo "🌐 Servicios disponibles:"
echo "========================"
echo "👤 Frontend Usuario: http://localhost:3000 ✅"
echo "🗄️ Base de Datos:    localhost:5432 ✅"
echo ""
echo "� Componentes en backup:"
echo "🎯 Panel Admin:      (movido a _backup_complete_*/)"
echo "🔌 API Backend:      (sin implementar)"
echo ""
echo "📊 Estado de servicios:"
docker compose ps
