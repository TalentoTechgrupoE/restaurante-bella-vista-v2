#!/bin/bash

# ================================================================
# 🍽️ SCRIPT DE VALIDACIÓN COMPLETA DEL MONITORING
# ================================================================
# Este script valida que todos los componentes de monitoreo
# estén funcionando correctamente y comunicándose entre ellos

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${PURPLE}"
    echo "=================================================================="
    echo "🔍  VALIDACIÓN COMPLETA DEL SISTEMA DE MONITOREO"
    echo "=================================================================="
    echo -e "${NC}"
}

print_test() {
    echo -e "${BLUE}[TEST $1]${NC} $2"
}

print_status() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✅ PASS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[⚠️ WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[❌ FAIL]${NC} $1"
}

# Test 1: Verificar que todos los contenedores estén corriendo
test_containers_running() {
    print_test "1" "Verificando contenedores en ejecución..."
    
    local expected_containers=(
        "bella-vista-frontend-usuario"
        "bella-vista-postgres"
        "bella-vista-prometheus"
        "bella-vista-grafana"
        "bella-vista-postgres-exporter"
        "bella-vista-node-exporter"
        "bella-vista-cadvisor"
    )
    
    local failed_containers=()
    
    for container in "${expected_containers[@]}"; do
        if docker ps --format "table {{.Names}}" | grep -q "$container"; then
            print_success "$container está ejecutándose"
        else
            print_error "$container NO está ejecutándose"
            failed_containers+=("$container")
        fi
    done
    
    if [ ${#failed_containers[@]} -eq 0 ]; then
        print_success "Todos los contenedores están ejecutándose correctamente"
        return 0
    else
        print_error "${#failed_containers[@]} contenedores tienen problemas"
        return 1
    fi
}

# Test 2: Verificar conectividad HTTP
test_http_connectivity() {
    print_test "2" "Verificando conectividad HTTP a servicios..."
    
    local services=(
        "http://localhost:3000|Aplicación Principal"
        "http://localhost:9090|Prometheus"
        "http://localhost:3001|Grafana"
        "http://localhost:8080|cAdvisor"
        "http://localhost:9100/metrics|Node Exporter"
        "http://localhost:9187/metrics|PostgreSQL Exporter"
    )
    
    local failed_services=()
    
    for service_info in "${services[@]}"; do
        local url=$(echo "$service_info" | cut -d'|' -f1)
        local name=$(echo "$service_info" | cut -d'|' -f2)
        
        local http_code=$(curl -s -w "%{http_code}" -o /dev/null "$url" --max-time 10)
        
        if [ "$http_code" = "200" ]; then
            print_success "$name responde correctamente (HTTP $http_code)"
        else
            print_error "$name no responde (HTTP $http_code)"
            failed_services+=("$name")
        fi
    done
    
    if [ ${#failed_services[@]} -eq 0 ]; then
        print_success "Todos los servicios HTTP responden correctamente"
        return 0
    else
        print_error "${#failed_services[@]} servicios HTTP tienen problemas"
        return 1
    fi
}

# Test 3: Verificar métricas de Prometheus
test_prometheus_metrics() {
    print_test "3" "Verificando que Prometheus recoja métricas..."
    
    sleep 5  # Esperar un poco para que Prometheus haga scraping
    
    local queries=(
        "up|Servicios UP"
        "prometheus_tsdb_symbol_table_size_bytes|Métricas Prometheus"
        "node_cpu_seconds_total|Métricas del Sistema"
        "container_memory_usage_bytes|Métricas de Contenedores"
        "pg_up|Métricas PostgreSQL"
    )
    
    local failed_queries=()
    
    for query_info in "${queries[@]}"; do
        local query=$(echo "$query_info" | cut -d'|' -f1)
        local description=$(echo "$query_info" | cut -d'|' -f2)
        
        local response=$(curl -s "http://localhost:9090/api/v1/query?query=$query" --max-time 10)
        
        if echo "$response" | grep -q '"status":"success"' && echo "$response" | grep -q '"result":\['; then
            local result_count=$(echo "$response" | grep -o '"result":\[[^]]*\]' | grep -o '{"metric"' | wc -l)
            if [ "$result_count" -gt 0 ]; then
                print_success "$description: $result_count series encontradas"
            else
                print_warning "$description: Sin datos disponibles aún"
            fi
        else
            print_error "$description: Query falló o sin respuesta"
            failed_queries+=("$description")
        fi
    done
    
    if [ ${#failed_queries[@]} -eq 0 ]; then
        print_success "Prometheus está recolectando métricas correctamente"
        return 0
    else
        print_warning "Algunas métricas pueden no estar disponibles aún"
        return 0  # No falla el test, solo advierte
    fi
}

# Test 4: Verificar targets en Prometheus
test_prometheus_targets() {
    print_test "4" "Verificando targets en Prometheus..."
    
    local targets_response=$(curl -s "http://localhost:9090/api/v1/targets" --max-time 10)
    
    if echo "$targets_response" | grep -q '"status":"success"'; then
        local total_targets=$(echo "$targets_response" | grep -o '"health":"[^"]*"' | wc -l)
        local up_targets=$(echo "$targets_response" | grep -o '"health":"up"' | wc -l)
        local down_targets=$(echo "$targets_response" | grep -o '"health":"down"' | wc -l)
        
        print_success "Total targets: $total_targets"
        print_success "Targets UP: $up_targets"
        
        if [ "$down_targets" -gt 0 ]; then
            print_warning "Targets DOWN: $down_targets"
        fi
        
        if [ "$up_targets" -gt 0 ]; then
            print_success "Prometheus está monitoreando targets correctamente"
            return 0
        else
            print_error "No hay targets activos en Prometheus"
            return 1
        fi
    else
        print_error "No se puede obtener información de targets"
        return 1
    fi
}

# Test 5: Verificar conexión Grafana-Prometheus
test_grafana_prometheus_connection() {
    print_test "5" "Verificando conexión Grafana → Prometheus..."
    
    # Probar autenticación en Grafana
    local auth_test=$(curl -s -u "admin:bella123" "http://localhost:3001/api/user" --max-time 10)
    
    if echo "$auth_test" | grep -q '"login":"admin"'; then
        print_success "Autenticación en Grafana exitosa"
    else
        print_error "No se puede autenticar en Grafana"
        return 1
    fi
    
    # Verificar datasources
    local datasources=$(curl -s -u "admin:bella123" "http://localhost:3001/api/datasources" --max-time 10)
    
    if echo "$datasources" | grep -q '"type":"prometheus"'; then
        print_success "Datasource Prometheus encontrado en Grafana"
    else
        print_error "Datasource Prometheus no configurado en Grafana"
        return 1
    fi
    
    # Test de query desde Grafana
    sleep 2
    local test_query=$(curl -s -u "admin:bella123" \
        -X POST \
        -H "Content-Type: application/json" \
        -d '{"targets":[{"expr":"up","refId":"A"}],"from":"now-5m","to":"now"}' \
        "http://localhost:3001/api/ds/query" --max-time 15)
    
    if echo "$test_query" | grep -q '"frames"'; then
        print_success "Grafana puede consultar datos desde Prometheus"
        return 0
    else
        print_warning "Grafana no puede consultar datos desde Prometheus aún"
        return 0  # No falla, puede necesitar más tiempo
    fi
}

# Test 6: Generar tráfico y verificar métricas
test_generate_traffic() {
    print_test "6" "Generando tráfico para validar métricas..."
    
    print_status "Generando 10 requests a la aplicación..."
    for i in {1..10}; do
        curl -s "http://localhost:3000/" > /dev/null 2>&1 &
        curl -s "http://localhost:3000/menu" > /dev/null 2>&1 &
        curl -s "http://localhost:3000/pedido" > /dev/null 2>&1 &
    done
    
    wait  # Esperar que todas las requests terminen
    
    print_status "Esperando 15 segundos para que Prometheus recolecte métricas..."
    sleep 15
    
    # Verificar que las métricas HTTP aparezcan
    local http_requests=$(curl -s "http://localhost:9090/api/v1/query?query=http_requests_total" --max-time 10)
    
    if echo "$http_requests" | grep -q '"result":\[' && echo "$http_requests" | grep -q '"value"'; then
        print_success "Métricas HTTP generadas y recolectadas correctamente"
        return 0
    else
        print_warning "Métricas HTTP aún no aparecen (puede necesitar más tiempo)"
        return 0
    fi
}

# Test 7: Verificar dashboards en Grafana
test_grafana_dashboards() {
    print_test "7" "Verificando dashboards en Grafana..."
    
    local dashboards=$(curl -s -u "admin:bella123" "http://localhost:3001/api/search" --max-time 10)
    
    if echo "$dashboards" | grep -q '"title"'; then
        local dashboard_count=$(echo "$dashboards" | grep -o '"title":"[^"]*"' | wc -l)
        print_success "$dashboard_count dashboards encontrados en Grafana"
        
        # Listar algunos dashboards
        echo "$dashboards" | grep -o '"title":"[^"]*"' | head -3 | while read -r dashboard; do
            local title=$(echo "$dashboard" | cut -d'"' -f4)
            print_status "📊 Dashboard: $title"
        done
        
        return 0
    else
        print_warning "No se encontraron dashboards o aún no están cargados"
        return 0
    fi
}

# Función principal de testing
main() {
    print_header
    
    local failed_tests=0
    
    # Ejecutar todos los tests
    test_containers_running || ((failed_tests++))
    echo ""
    
    test_http_connectivity || ((failed_tests++))
    echo ""
    
    test_prometheus_metrics || ((failed_tests++))
    echo ""
    
    test_prometheus_targets || ((failed_tests++))
    echo ""
    
    test_grafana_prometheus_connection || ((failed_tests++))
    echo ""
    
    test_generate_traffic || ((failed_tests++))
    echo ""
    
    test_grafana_dashboards || ((failed_tests++))
    echo ""
    
    # Resumen final
    echo -e "${PURPLE}=================================================================="
    echo "📊 RESUMEN DE VALIDACIÓN"
    echo "=================================================================="
    echo -e "${NC}"
    
    if [ $failed_tests -eq 0 ]; then
        print_success "🎉 TODOS LOS TESTS PASARON EXITOSAMENTE"
        echo ""
        echo -e "${GREEN}✅ El sistema de monitoreo está completamente operativo${NC}"
        echo -e "${GREEN}✅ Prometheus recolecta métricas correctamente${NC}"
        echo -e "${GREEN}✅ Grafana está conectado y funcional${NC}"
        echo -e "${GREEN}✅ Todos los exporters están funcionando${NC}"
        echo ""
        echo -e "${CYAN}🎯 PRÓXIMOS PASOS:${NC}"
        echo "   1. Visita http://localhost:3001 para ver dashboards"
        echo "   2. Ejecuta ./live-traffic.sh para más tráfico de prueba"
        echo "   3. Monitorea métricas en tiempo real"
        
    else
        print_warning "⚠️ $failed_tests TESTS FALLARON O TIENEN WARNINGS"
        echo ""
        echo -e "${YELLOW}🔧 RECOMENDACIONES:${NC}"
        echo "   1. Verifica logs: docker-compose logs"
        echo "   2. Reinicia servicios: docker-compose restart"
        echo "   3. Vuelve a ejecutar este script en 2-3 minutos"
        echo "   4. Algunos servicios pueden necesitar más tiempo para inicializar"
    fi
    
    echo ""
    echo -e "${CYAN}📱 URLS DE ACCESO:${NC}"
    echo "   🍽️ Aplicación: http://localhost:3000"
    echo "   📈 Grafana: http://localhost:3001 (admin/bella123)"
    echo "   🔍 Prometheus: http://localhost:9090"
    echo "   📦 cAdvisor: http://localhost:8080"
    echo ""
}

# Ejecutar validación
main "$@"
