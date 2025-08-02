#!/bin/bash

# Script para verificar la conectividad del monitoreo
# Verificar conectividad de monitoreo - Restaurante Bella Vista

set -e

echo "🔍 VERIFICANDO CONECTIVIDAD DE MONITOREO..."
echo "================================================="

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✅ SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[❌ ERROR]${NC} $1"
}

# Verificar que los contenedores estén ejecutándose
echo "1. Verificando contenedores..."
CONTAINERS=("bella-vista-prometheus" "bella-vista-grafana" "bella-vista-frontend-usuario")
for container in "${CONTAINERS[@]}"; do
    if docker ps --format "table {{.Names}}" | grep -q "$container"; then
        print_success "$container está ejecutándose"
    else
        print_error "$container NO está ejecutándose"
        exit 1
    fi
done

# Verificar conectividad de red
echo -e "\n2. Verificando conectividad de red..."
if docker exec bella-vista-prometheus wget -q --spider http://bella-vista-frontend-usuario:3000/metrics; then
    print_success "Prometheus puede alcanzar el frontend"
else
    print_error "Prometheus NO puede alcanzar el frontend"
    exit 1
fi

# Verificar targets en Prometheus
echo -e "\n3. Verificando targets en Prometheus..."
TARGETS_UP=$(curl -s "http://localhost:9090/api/v1/targets" | grep -o '"health":"up"' | wc -l)
TARGETS_DOWN=$(curl -s "http://localhost:9090/api/v1/targets" | grep -o '"health":"down"' | wc -l)

print_status "Targets UP: $TARGETS_UP"
print_status "Targets DOWN: $TARGETS_DOWN"

if [ "$TARGETS_UP" -ge 4 ]; then
    print_success "La mayoría de targets están funcionando"
else
    print_error "Demasiados targets están caídos"
fi

# Verificar métricas del frontend
echo -e "\n4. Verificando métricas del frontend..."
if curl -s http://localhost:3000/metrics | grep -q "http_requests_total"; then
    print_success "Frontend está exponiendo métricas correctamente"
else
    print_error "Frontend NO está exponiendo métricas"
    exit 1
fi

# Verificar dashboards en Grafana
echo -e "\n5. Verificando dashboards en Grafana..."
DASHBOARDS=$(curl -s -u admin:bella123 "http://localhost:3001/api/search?query=Bella" | grep -o '"title":"[^"]*"' | wc -l)
if [ "$DASHBOARDS" -ge 1 ]; then
    print_success "Dashboards de Bella Vista encontrados: $DASHBOARDS"
else
    print_error "No se encontraron dashboards de Bella Vista"
fi

echo -e "\n🎉 VERIFICACIÓN COMPLETADA"
echo "================================================="
print_success "El sistema de monitoreo está funcionando correctamente"
echo -e "\n📊 Accesos:"
echo "   🍽️ Aplicación: http://localhost:3000"
echo "   📈 Grafana: http://localhost:3001 (admin/bella123)"
echo "   🔍 Prometheus: http://localhost:9090"
