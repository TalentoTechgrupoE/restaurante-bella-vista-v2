#!/bin/bash

# Script para configurar y levantar el monitoreo completo del Restaurante Bella Vista
# Autor: GitHub Copilot
# Fecha: $(date)

set -e

echo "🎨 Configurando sistema de monitoreo Restaurante Bella Vista..."
echo "=================================================="

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para mostrar mensajes con colores
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar que Docker está funcionando
print_status "Verificando Docker..."
if ! docker --version > /dev/null 2>&1; then
    print_error "Docker no está instalado o no está funcionando"
    exit 1
fi
print_success "Docker está funcionando correctamente"

# Verificar que docker-compose está disponible
print_status "Verificando Docker Compose..."
if ! docker-compose --version > /dev/null 2>&1; then
    print_error "Docker Compose no está instalado"
    exit 1
fi
print_success "Docker Compose está disponible"

# Crear la red si no existe
print_status "Creando red Docker..."
docker network create restaurante-network 2>/dev/null || print_warning "La red restaurante-network ya existe"

# Verificar si los servicios base están funcionando
print_status "Verificando servicios base del restaurante..."
if ! docker ps | grep bella-vista-postgres > /dev/null; then
    print_warning "PostgreSQL no está ejecutándose, iniciando servicios base..."
    docker-compose up -d
    print_status "Esperando que PostgreSQL esté listo..."
    sleep 10
fi

# Levantar servicios de monitoreo
print_status "Iniciando servicios de monitoreo..."
docker-compose -f docker-compose.monitoring.yml up -d

# Esperar que todos los servicios estén listos
print_status "Esperando que los servicios estén listos..."
sleep 15

# Verificar que todos los servicios están funcionando
print_status "Verificando estado de los servicios..."

services=("bella-vista-prometheus" "bella-vista-grafana" "bella-vista-postgres-exporter" "bella-vista-node-exporter" "bella-vista-cadvisor")
all_running=true

for service in "${services[@]}"; do
    if docker ps --format "table {{.Names}}" | grep -q "$service"; then
        print_success "✅ $service está ejecutándose"
    else
        print_error "❌ $service no está ejecutándose"
        all_running=false
    fi
done

if $all_running; then
    echo ""
    echo "🎉 ¡Sistema de monitoreo configurado exitosamente!"
    echo "=================================================="
    echo ""
    echo "📊 Accesos disponibles:"
    echo "   • Grafana:    http://localhost:3001"
    echo "     - Usuario: admin"
    echo "     - Password: bella123"
    echo ""
    echo "   • Prometheus: http://localhost:9090"
    echo "   • cAdvisor:   http://localhost:8080"
    echo "   • Node Exporter: http://localhost:9100"
    echo ""
    echo "🎯 Dashboards disponibles:"
    echo "   • Ejecutivo:     http://localhost:3001/d/ejecutivo"
    echo "   • Operacional:   http://localhost:3001/d/operacional"
    echo "   • Técnico:       http://localhost:3001/d/tecnico"
    echo "   • Financiero:    http://localhost:3001/d/financiero"
    echo ""
    echo "🔔 Configuración de alertas activada"
    echo ""
else
    print_error "Algunos servicios no se iniciaron correctamente"
    echo "Para ver logs de errores, ejecuta:"
    echo "docker-compose -f docker-compose.monitoring.yml logs"
    exit 1
fi

# Función para mostrar ayuda
show_help() {
    echo "Comandos útiles para gestionar el monitoreo:"
    echo ""
    echo "📊 Ver logs:"
    echo "   docker-compose -f docker-compose.monitoring.yml logs -f [servicio]"
    echo ""
    echo "🔄 Reiniciar servicios:"
    echo "   docker-compose -f docker-compose.monitoring.yml restart"
    echo ""
    echo "⬇️ Detener monitoreo:"
    echo "   docker-compose -f docker-compose.monitoring.yml down"
    echo ""
    echo "🗑️ Limpiar todo (incluyendo datos):"
    echo "   docker-compose -f docker-compose.monitoring.yml down -v"
    echo ""
}

# Mostrar ayuda si se solicita
if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
    show_help
    exit 0
fi

print_success "Configuración completada. Usa --help para ver comandos útiles."
