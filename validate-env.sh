#!/bin/bash

# ================================================================
# 🔍 SCRIPT DE VALIDACIÓN DE ENTORNO
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

# Variables para tracking
WARNINGS=0
ERRORS=0
TOTAL_CHECKS=0

# Función para verificar variable de entorno
check_env_var() {
    local var_name="$1"
    local description="$2"
    local is_critical="$3"
    local suggested_value="$4"
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    if [ -n "${!var_name}" ]; then
        if [ "$is_critical" = "true" ] && [ "${!var_name}" = "$suggested_value" ]; then
            print_warning "$var_name está configurada pero usa el valor por defecto (¡cambiar en producción!)"
            WARNINGS=$((WARNINGS + 1))
        else
            print_success "$var_name: ${!var_name}"
        fi
    else
        if [ "$is_critical" = "true" ]; then
            print_error "$var_name NO está configurada - $description"
            ERRORS=$((ERRORS + 1))
        else
            print_warning "$var_name no está configurada - $description (opcional)"
            WARNINGS=$((WARNINGS + 1))
        fi
    fi
}

# Función para verificar puerto disponible
check_port() {
    local port="$1"
    local service="$2"
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    if command -v netstat &> /dev/null; then
        if netstat -tuln | grep -q ":$port "; then
            print_warning "Puerto $port ($service) está en uso"
            WARNINGS=$((WARNINGS + 1))
        else
            print_success "Puerto $port ($service) está disponible"
        fi
    elif command -v ss &> /dev/null; then
        if ss -tuln | grep -q ":$port "; then
            print_warning "Puerto $port ($service) está en uso"
            WARNINGS=$((WARNINGS + 1))
        else
            print_success "Puerto $port ($service) está disponible"
        fi
    else
        print_warning "No se puede verificar el puerto $port (netstat/ss no disponible)"
        WARNINGS=$((WARNINGS + 1))
    fi
}

# Función para verificar herramientas del sistema
check_system_tools() {
    local tools=("docker" "docker-compose" "curl")
    
    for tool in "${tools[@]}"; do
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
        if command -v "$tool" &> /dev/null; then
            print_success "$tool está instalado"
        else
            print_error "$tool NO está instalado"
            ERRORS=$((ERRORS + 1))
        fi
    done
}

# Función para validar formato de variables
validate_formats() {
    # Validar puerto (debe ser número)
    if [ -n "$APP_PORT" ]; then
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
        if [[ "$APP_PORT" =~ ^[0-9]+$ ]] && [ "$APP_PORT" -ge 1 ] && [ "$APP_PORT" -le 65535 ]; then
            print_success "APP_PORT tiene formato válido: $APP_PORT"
        else
            print_error "APP_PORT tiene formato inválido: $APP_PORT (debe ser número entre 1-65535)"
            ERRORS=$((ERRORS + 1))
        fi
    fi
    
    # Validar formato de hora
    if [ -n "$OPENING_TIME" ]; then
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
        if [[ "$OPENING_TIME" =~ ^[0-2][0-9]:[0-5][0-9]$ ]]; then
            print_success "OPENING_TIME tiene formato válido: $OPENING_TIME"
        else
            print_error "OPENING_TIME tiene formato inválido: $OPENING_TIME (usar formato HH:MM)"
            ERRORS=$((ERRORS + 1))
        fi
    fi
    
    # Validar formato de email
    if [ -n "$RESTAURANT_EMAIL" ]; then
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
        if [[ "$RESTAURANT_EMAIL" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
            print_success "RESTAURANT_EMAIL tiene formato válido: $RESTAURANT_EMAIL"
        else
            print_error "RESTAURANT_EMAIL tiene formato inválido: $RESTAURANT_EMAIL"
            ERRORS=$((ERRORS + 1))
        fi
    fi
}

# Función para generar reporte de seguridad
security_report() {
    print_header "🛡️  REPORTE DE SEGURIDAD"
    
    local security_issues=0
    
    # Verificar contraseñas por defecto
    if [ "$POSTGRES_PASSWORD" = "bella123" ]; then
        print_error "POSTGRES_PASSWORD usa el valor por defecto - CAMBIAR INMEDIATAMENTE"
        security_issues=$((security_issues + 1))
    fi
    
    if [ "$GRAFANA_ADMIN_PASSWORD" = "bella123" ]; then
        print_error "GRAFANA_ADMIN_PASSWORD usa el valor por defecto - CAMBIAR INMEDIATAMENTE"
        security_issues=$((security_issues + 1))
    fi
    
    if [ "$JWT_SECRET" = "tu-clave-secreta-muy-segura-aqui" ]; then
        print_error "JWT_SECRET usa el valor por defecto - CAMBIAR INMEDIATAMENTE"
        security_issues=$((security_issues + 1))
    fi
    
    # Verificar longitud de contraseñas
    if [ -n "$POSTGRES_PASSWORD" ] && [ ${#POSTGRES_PASSWORD} -lt 12 ]; then
        print_warning "POSTGRES_PASSWORD es demasiado corta (mínimo 12 caracteres recomendado)"
        security_issues=$((security_issues + 1))
    fi
    
    if [ -n "$GRAFANA_ADMIN_PASSWORD" ] && [ ${#GRAFANA_ADMIN_PASSWORD} -lt 12 ]; then
        print_warning "GRAFANA_ADMIN_PASSWORD es demasiado corta (mínimo 12 caracteres recomendado)"
        security_issues=$((security_issues + 1))
    fi
    
    if [ $security_issues -eq 0 ]; then
        print_success "No se encontraron problemas de seguridad críticos"
    else
        print_error "Se encontraron $security_issues problemas de seguridad"
    fi
    
    echo ""
}

# ========================================
# EJECUCIÓN PRINCIPAL
# ========================================

# Verificar si existe archivo .env
if [ ! -f ".env" ]; then
    print_error "Archivo .env no encontrado"
    echo ""
    print_info "Ejecuta: cp .env.example .env"
    exit 1
fi

# Cargar variables de entorno
set -a
source .env
set +a

print_header "🔍 VALIDACIÓN DE ENTORNO - RESTAURANTE BELLA VISTA"

# Verificar herramientas del sistema
print_header "🛠️  VERIFICACIÓN DE HERRAMIENTAS DEL SISTEMA"
check_system_tools

echo ""

# Verificar variables críticas
print_header "🎯 VARIABLES CRÍTICAS DE LA APLICACIÓN"
check_env_var "NODE_ENV" "Entorno de ejecución" "true"
check_env_var "APP_PORT" "Puerto de la aplicación" "true"
check_env_var "POSTGRES_PASSWORD" "Contraseña de la base de datos" "true" "bella123"
check_env_var "GRAFANA_ADMIN_PASSWORD" "Contraseña de Grafana" "true" "bella123"

echo ""

# Verificar variables de base de datos
print_header "🗄️  CONFIGURACIÓN DE BASE DE DATOS"
check_env_var "POSTGRES_DB" "Nombre de la base de datos" "false"
check_env_var "POSTGRES_USER" "Usuario de la base de datos" "false"
check_env_var "POSTGRES_HOST" "Host de la base de datos" "false"
check_env_var "POSTGRES_PORT" "Puerto de la base de datos" "false"

echo ""

# Verificar variables de monitoreo
print_header "📊 CONFIGURACIÓN DE MONITOREO"
check_env_var "GRAFANA_PORT" "Puerto de Grafana" "false"
check_env_var "PROMETHEUS_PORT" "Puerto de Prometheus" "false"
check_env_var "ENABLE_METRICS" "Habilitar métricas" "false"

echo ""

# Verificar variables del restaurante
print_header "🏪 CONFIGURACIÓN DEL RESTAURANTE"
check_env_var "RESTAURANT_NAME" "Nombre del restaurante" "false"
check_env_var "OPENING_TIME" "Hora de apertura" "false"
check_env_var "CLOSING_TIME" "Hora de cierre" "false"
check_env_var "MAX_TABLES" "Número máximo de mesas" "false"

echo ""

# Verificar puertos disponibles
print_header "🚪 VERIFICACIÓN DE PUERTOS"
check_port "${APP_PORT:-3000}" "Frontend"
check_port "${GRAFANA_PORT:-3001}" "Grafana"
check_port "${PROMETHEUS_PORT:-9090}" "Prometheus"
check_port "5432" "PostgreSQL"

echo ""

# Validar formatos
print_header "✅ VALIDACIÓN DE FORMATOS"
validate_formats

echo ""

# Reporte de seguridad
security_report

# Resumen final
print_header "📋 RESUMEN DE VALIDACIÓN"

echo -e "${CYAN}Total de verificaciones: $TOTAL_CHECKS${NC}"

if [ $ERRORS -eq 0 ]; then
    print_success "No se encontraron errores críticos"
else
    print_error "Se encontraron $ERRORS errores críticos"
fi

if [ $WARNINGS -eq 0 ]; then
    print_success "No se encontraron advertencias"
else
    print_warning "Se encontraron $WARNINGS advertencias"
fi

echo ""

# Estado final
if [ $ERRORS -eq 0 ]; then
    print_success "🚀 El entorno está listo para el despliegue"
    exit 0
else
    print_error "🛑 Corrige los errores antes de continuar"
    echo ""
    print_info "Consulta la documentación en: documentacion/variables-entorno.md"
    exit 1
fi
