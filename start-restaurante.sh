#!/bin/bash

# Script maestro para iniciar el Restaurante Bella Vista con monitoreo
# Autor: GitHub Copilot

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}"
    echo "=================================================================="
    echo "🍽️  RESTAURANTE BELLA VISTA - INICIO COMPLETO"
    echo "=================================================================="
    echo -e "${NC}"
}

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

# Función para mostrar ayuda
show_help() {
    echo "Uso: $0 [opción]"
    echo ""
    echo "Opciones:"
    echo "  start, up       - Iniciar todos los servicios (default)"
    echo "  stop, down      - Detener todos los servicios"
    echo "  restart         - Reiniciar todos los servicios"
    echo "  status          - Mostrar estado de servicios"
    echo "  logs            - Mostrar logs de todos los servicios"
    echo "  monitoring      - Iniciar solo monitoreo"
    echo "  app             - Iniciar solo aplicación"
    echo "  clean           - Limpiar todo (contenedores + volúmenes)"
    echo "  help, -h        - Mostrar esta ayuda"
    echo ""
    echo "Ejemplos:"
    echo "  $0 start        # Iniciar todo"
    echo "  $0 monitoring   # Solo monitoreo"
    echo "  $0 status       # Ver estado"
    echo "  $0 clean        # Limpiar todo"
}

# Verificar requisitos
check_requirements() {
    print_status "Verificando requisitos..."
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker no está instalado"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose no está instalado"
        exit 1
    fi
    
    print_success "Requisitos verificados"
}

# Crear red si no existe
create_network() {
    print_status "Configurando red Docker..."
    if ! docker network ls | grep -q restaurante-network; then
        docker network create restaurante-network
        print_success "Red restaurante-network creada"
    else
        print_warning "Red restaurante-network ya existe"
    fi
}

# Iniciar aplicación principal
start_app() {
    print_status "Iniciando aplicación del restaurante..."
    docker-compose up -d
    
    print_status "Esperando que PostgreSQL esté listo..."
    sleep 10
    
    # Verificar que la app esté funcionando
    if curl -s http://localhost:3000 > /dev/null; then
        print_success "✅ Aplicación del restaurante ejecutándose en http://localhost:3000"
    else
        print_warning "⚠️  Aplicación iniciada pero aún no responde en http://localhost:3000"
    fi
}

# Iniciar monitoreo
start_monitoring() {
    print_status "Iniciando sistema de monitoreo..."
    
    if [ ! -f "docker-compose.monitoring.yml" ]; then
        print_error "Archivo docker-compose.monitoring.yml no encontrado"
        print_error "Ejecuta primero: ./scripts/setup-monitoring.sh"
        exit 1
    fi
    
    docker-compose -f docker-compose.monitoring.yml up -d
    
    print_status "Esperando que los servicios de monitoreo estén listos..."
    sleep 15
    
    # Verificar servicios de monitoreo
    local monitoring_services=("bella-vista-prometheus" "bella-vista-grafana")
    for service in "${monitoring_services[@]}"; do
        if docker ps --format "table {{.Names}}" | grep -q "$service"; then
            print_success "✅ $service está ejecutándose"
        else
            print_warning "⚠️  $service no está ejecutándose correctamente"
        fi
    done
}

# Mostrar estado de servicios
show_status() {
    print_status "Estado de servicios del Restaurante Bella Vista:"
    echo ""
    
    # Servicios principales
    echo -e "${BLUE}📱 APLICACIÓN PRINCIPAL:${NC}"
    local app_services=("bella-vista-postgres" "bella-vista-frontend-usuario")
    for service in "${app_services[@]}"; do
        if docker ps --format "table {{.Names}}" | grep -q "$service"; then
            echo -e "   ✅ $service"
        else
            echo -e "   ❌ $service"
        fi
    done
    
    echo ""
    echo -e "${BLUE}📊 MONITOREO:${NC}"
    local monitoring_services=("bella-vista-prometheus" "bella-vista-grafana" "bella-vista-postgres-exporter" "bella-vista-node-exporter" "bella-vista-cadvisor")
    for service in "${monitoring_services[@]}"; do
        if docker ps --format "table {{.Names}}" | grep -q "$service"; then
            echo -e "   ✅ $service"
        else
            echo -e "   ❌ $service"
        fi
    done
    
    echo ""
    echo -e "${BLUE}🌐 ACCESOS DISPONIBLES:${NC}"
    
    # Verificar accesos
    if curl -s http://localhost:3000 > /dev/null; then
        echo -e "   ✅ Aplicación:   ${GREEN}http://localhost:3000${NC}"
    else
        echo -e "   ❌ Aplicación:   http://localhost:3000 (no responde)"
    fi
    
    if curl -s http://localhost:3001 > /dev/null; then
        echo -e "   ✅ Grafana:      ${GREEN}http://localhost:3001${NC} (admin/bella123)"
    else
        echo -e "   ❌ Grafana:      http://localhost:3001 (no responde)"
    fi
    
    if curl -s http://localhost:9090 > /dev/null; then
        echo -e "   ✅ Prometheus:   ${GREEN}http://localhost:9090${NC}"
    else
        echo -e "   ❌ Prometheus:   http://localhost:9090 (no responde)"
    fi
}

# Detener servicios
stop_services() {
    print_status "Deteniendo servicios..."
    
    if [ -f "docker-compose.monitoring.yml" ]; then
        docker-compose -f docker-compose.monitoring.yml down
    fi
    
    docker-compose down
    
    print_success "Servicios detenidos"
}

# Limpiar todo
clean_all() {
    print_warning "¿Estás seguro de que quieres eliminar TODOS los datos? (y/N)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        print_status "Limpiando todos los servicios y datos..."
        
        if [ -f "docker-compose.monitoring.yml" ]; then
            docker-compose -f docker-compose.monitoring.yml down -v
        fi
        
        docker-compose down -v
        
        # Limpiar imágenes no utilizadas
        docker system prune -f
        
        print_success "Limpieza completada"
    else
        print_status "Operación cancelada"
    fi
}

# Mostrar logs
show_logs() {
    print_status "Mostrando logs de todos los servicios..."
    echo "Presiona Ctrl+C para detener"
    
    # Crear un script temporal para mostrar logs combinados
    {
        docker-compose logs -f &
        if [ -f "docker-compose.monitoring.yml" ]; then
            docker-compose -f docker-compose.monitoring.yml logs -f &
        fi
        wait
    }
}

# Función principal
main() {
    print_header
    
    case "${1:-start}" in
        "start"|"up")
            check_requirements
            create_network
            start_app
            start_monitoring
            echo ""
            show_status
            echo ""
            print_success "🎉 ¡Restaurante Bella Vista iniciado completamente!"
            echo ""
            echo -e "${YELLOW}📋 PRÓXIMOS PASOS:${NC}"
            echo "   1. Visita la aplicación: http://localhost:3000"
            echo "   2. Ve los dashboards: http://localhost:3001 (admin/bella123)"
            echo "   3. Monitorea métricas: http://localhost:9090"
            echo ""
            ;;
        "stop"|"down")
            stop_services
            ;;
        "restart")
            stop_services
            sleep 2
            check_requirements
            create_network
            start_app
            start_monitoring
            show_status
            ;;
        "status")
            show_status
            ;;
        "logs")
            show_logs
            ;;
        "monitoring")
            check_requirements
            create_network
            start_monitoring
            ;;
        "app")
            check_requirements
            create_network
            start_app
            ;;
        "clean")
            clean_all
            ;;
        "help"|"--help"|"-h")
            show_help
            ;;
        *)
            print_error "Comando desconocido: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

main "$@"
