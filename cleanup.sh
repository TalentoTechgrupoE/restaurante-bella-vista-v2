#!/bin/bash

# ================================================================
# 🧹 SCRIPT DE LIMPIEZA DEL PROYECTO
# Restaurante Bella Vista
# ================================================================

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Funciones de output
print_header() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

# Función para confirmar acciones destructivas
confirm_action() {
    local message="$1"
    echo -e "${YELLOW}⚠️  $message${NC}"
    echo -e "${YELLOW}Esta acción NO se puede deshacer.${NC}"
    read -p "¿Estás seguro? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${CYAN}Operación cancelada${NC}"
        return 1
    fi
    return 0
}

# Función para detener todos los servicios
stop_services() {
    print_header "🛑 DETENIENDO SERVICIOS"
    
    # Detener aplicación principal
    if [ -f "docker-compose.yml" ]; then
        print_info "Deteniendo aplicación principal..."
        docker-compose down
        print_success "Aplicación principal detenida"
    fi
    
    # Detener monitoreo
    if [ -f "monitoring/docker-compose.monitoring.yml" ]; then
        print_info "Deteniendo servicios de monitoreo..."
        docker-compose -f monitoring/docker-compose.monitoring.yml down
        print_success "Servicios de monitoreo detenidos"
    fi
    
    echo ""
}

# Función para limpiar contenedores
clean_containers() {
    print_header "🐳 LIMPIANDO CONTENEDORES"
    
    # Obtener contenedores del proyecto
    local containers=$(docker ps -a --filter "name=restaurante" --format "{{.Names}}" 2>/dev/null)
    
    if [ -z "$containers" ]; then
        print_info "No se encontraron contenedores del proyecto"
    else
        print_info "Eliminando contenedores del proyecto..."
        echo "$containers" | xargs docker rm -f 2>/dev/null || true
        print_success "Contenedores eliminados"
    fi
    
    echo ""
}

# Función para limpiar imágenes
clean_images() {
    print_header "🖼️  LIMPIANDO IMÁGENES"
    
    # Buscar imágenes del proyecto
    local images=$(docker images --filter "reference=restaurante*" --format "{{.Repository}}:{{.Tag}}" 2>/dev/null)
    
    if [ -z "$images" ]; then
        print_info "No se encontraron imágenes del proyecto"
    else
        print_info "Eliminando imágenes del proyecto..."
        echo "$images" | xargs docker rmi -f 2>/dev/null || true
        print_success "Imágenes eliminadas"
    fi
    
    echo ""
}

# Función para limpiar volúmenes
clean_volumes() {
    print_header "💾 LIMPIANDO VOLÚMENES"
    
    if confirm_action "Se eliminarán TODOS los datos de la base de datos"; then
        # Buscar volúmenes del proyecto
        local volumes=$(docker volume ls --filter "name=restaurante" --format "{{.Name}}" 2>/dev/null)
        
        if [ -z "$volumes" ]; then
            print_info "No se encontraron volúmenes del proyecto"
        else
            print_info "Eliminando volúmenes del proyecto..."
            echo "$volumes" | xargs docker volume rm -f 2>/dev/null || true
            print_success "Volúmenes eliminados"
        fi
    fi
    
    echo ""
}

# Función para limpiar red
clean_networks() {
    print_header "🌐 LIMPIANDO REDES"
    
    # Verificar si existe la red del proyecto
    if docker network ls | grep -q "restaurante-network"; then
        print_info "Eliminando red del proyecto..."
        docker network rm restaurante-network 2>/dev/null || true
        print_success "Red eliminada"
    else
        print_info "No se encontró la red del proyecto"
    fi
    
    echo ""
}

# Función para limpiar archivos temporales
clean_temp_files() {
    print_header "🗂️  LIMPIANDO ARCHIVOS TEMPORALES"
    
    # Limpiar logs temporales
    if [ -d "logs" ]; then
        print_info "Limpiando directorio de logs..."
        rm -rf logs/*.log 2>/dev/null || true
        print_success "Logs temporales eliminados"
    fi
    
    # Limpiar cachés de Node.js
    if [ -d "frontend-usuario/node_modules" ]; then
        print_info "Limpiando node_modules..."
        rm -rf frontend-usuario/node_modules 2>/dev/null || true
        print_success "node_modules eliminado"
    fi
    
    # Limpiar package-lock.json
    if [ -f "frontend-usuario/package-lock.json" ]; then
        print_info "Eliminando package-lock.json..."
        rm -f frontend-usuario/package-lock.json 2>/dev/null || true
        print_success "package-lock.json eliminado"
    fi
    
    echo ""
}

# Función para limpiar datos de Grafana/Prometheus
clean_monitoring_data() {
    print_header "📊 LIMPIANDO DATOS DE MONITOREO"
    
    if confirm_action "Se eliminarán dashboards, configuraciones y datos históricos de monitoreo"; then
        # Limpiar datos de Grafana
        if [ -d "monitoring/grafana-data" ]; then
            print_info "Limpiando datos de Grafana..."
            rm -rf monitoring/grafana-data 2>/dev/null || true
            print_success "Datos de Grafana eliminados"
        fi
        
        # Limpiar datos de Prometheus
        if [ -d "monitoring/prometheus-data" ]; then
            print_info "Limpiando datos de Prometheus..."
            rm -rf monitoring/prometheus-data 2>/dev/null || true
            print_success "Datos de Prometheus eliminados"
        fi
    fi
    
    echo ""
}

# Función para limpieza completa del sistema Docker
clean_docker_system() {
    print_header "🧹 LIMPIEZA COMPLETA DEL SISTEMA DOCKER"
    
    if confirm_action "Se ejecutará 'docker system prune -a' - eliminará TODO lo no utilizado en Docker"; then
        print_info "Ejecutando limpieza completa de Docker..."
        docker system prune -a -f --volumes
        print_success "Sistema Docker limpiado completamente"
    fi
    
    echo ""
}

# Función para mostrar espacio liberado
show_space_info() {
    print_header "📊 INFORMACIÓN DE ESPACIO"
    
    print_info "Espacio usado por Docker:"
    docker system df
    
    echo ""
}

# Función para restablecer configuración
reset_config() {
    print_header "⚙️ RESTABLECIENDO CONFIGURACIÓN"
    
    if confirm_action "Se eliminará el archivo .env (se puede recrear desde .env.example)"; then
        if [ -f ".env" ]; then
            print_info "Eliminando archivo .env..."
            rm -f .env
            print_success "Archivo .env eliminado"
            print_info "Para recrear: cp .env.example .env"
        else
            print_info "No se encontró archivo .env"
        fi
    fi
    
    echo ""
}

# Menú principal
show_menu() {
    echo ""
    print_header "🧹 MENÚ DE LIMPIEZA - RESTAURANTE BELLA VISTA"
    echo ""
    echo -e "${CYAN}Selecciona una opción:${NC}"
    echo ""
    echo -e "${YELLOW}BÁSICAS:${NC}"
    echo "  1) 🛑 Detener todos los servicios"
    echo "  2) 🐳 Limpiar contenedores del proyecto"
    echo "  3) 🖼️  Limpiar imágenes del proyecto"
    echo "  4) 🌐 Limpiar redes del proyecto"
    echo ""
    echo -e "${YELLOW}DATOS:${NC}"
    echo "  5) 💾 Limpiar volúmenes (⚠️  ELIMINA DATOS DB)"
    echo "  6) 📊 Limpiar datos de monitoreo"
    echo "  7) 🗂️  Limpiar archivos temporales"
    echo "  8) ⚙️  Restablecer configuración (.env)"
    echo ""
    echo -e "${YELLOW}AVANZADAS:${NC}"
    echo "  9) 🚀 Limpieza rápida (servicios + contenedores + redes)"
    echo " 10) 🧹 Limpieza completa (TODO excepto configuración)"
    echo " 11) ☢️  Limpieza NUCLEAR (⚠️  ELIMINA TODO)"
    echo " 12) 🐳 Limpiar sistema Docker completo"
    echo ""
    echo -e "${YELLOW}INFORMACIÓN:${NC}"
    echo " 13) 📊 Mostrar información de espacio"
    echo " 14) ❌ Salir"
    echo ""
}

# Función de limpieza rápida
quick_clean() {
    print_header "🚀 LIMPIEZA RÁPIDA"
    stop_services
    clean_containers
    clean_networks
    print_success "Limpieza rápida completada"
}

# Función de limpieza completa
full_clean() {
    print_header "🧹 LIMPIEZA COMPLETA"
    stop_services
    clean_containers
    clean_images
    clean_networks
    clean_temp_files
    clean_monitoring_data
    print_success "Limpieza completa finalizada"
}

# Función de limpieza nuclear
nuclear_clean() {
    print_header "☢️  LIMPIEZA NUCLEAR"
    print_warning "Esta opción eliminará ABSOLUTAMENTE TODO"
    
    if confirm_action "¿Estás COMPLETAMENTE seguro? Esta acción es IRREVERSIBLE"; then
        stop_services
        clean_containers
        clean_images
        clean_volumes
        clean_networks
        clean_temp_files
        clean_monitoring_data
        reset_config
        print_success "Limpieza nuclear completada - El proyecto está como recién clonado"
    fi
}

# ========================================
# PROGRAMA PRINCIPAL
# ========================================

# Verificar que estamos en el directorio correcto
if [ ! -f "docker-compose.yml" ]; then
    print_error "No se encontró docker-compose.yml"
    print_error "Asegúrate de ejecutar este script desde el directorio raíz del proyecto"
    exit 1
fi

# Verificar que Docker esté instalado
if ! command -v docker &> /dev/null; then
    print_error "Docker no está instalado"
    exit 1
fi

# Bucle principal del menú
while true; do
    show_menu
    read -p "Ingresa tu opción (1-14): " choice
    
    case $choice in
        1)
            stop_services
            ;;
        2)
            clean_containers
            ;;
        3)
            clean_images
            ;;
        4)
            clean_networks
            ;;
        5)
            clean_volumes
            ;;
        6)
            clean_monitoring_data
            ;;
        7)
            clean_temp_files
            ;;
        8)
            reset_config
            ;;
        9)
            quick_clean
            ;;
        10)
            full_clean
            ;;
        11)
            nuclear_clean
            ;;
        12)
            clean_docker_system
            ;;
        13)
            show_space_info
            ;;
        14)
            print_success "¡Hasta luego!"
            exit 0
            ;;
        *)
            print_error "Opción inválida. Por favor selecciona 1-14."
            ;;
    esac
    
    echo ""
    read -p "Presiona Enter para continuar..."
done
