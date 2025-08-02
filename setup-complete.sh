#!/bin/bash

# ================================================================
# 🍽️ RESTAURANTE BELLA VISTA - SETUP COMPLETO AUTOMATIZADO
# ================================================================
# Este script configura el proyecto completo desde cero
# Autor: GitHub Copilot
# Fecha: $(date)

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
    echo "🍽️  RESTAURANTE BELLA VISTA - SETUP AUTOMÁTICO"
    echo "=================================================================="
    echo -e "${NC}"
}

print_step() {
    echo -e "${BLUE}[PASO $1/8]${NC} $2"
}

print_status() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✅ SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[⚠️ WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[❌ ERROR]${NC} $1"
}

# ========================================
# 🎯 SCRIPT DE DESPLIEGUE COMPLETO
# Restaurante Bella Vista
# ========================================

# Función para verificar requisitos
check_requirements() {
    print_step "1" "Verificando requisitos del sistema..."
    
    # Verificar si existe .env
    if [ ! -f ".env" ]; then
        print_warning "Archivo .env no encontrado"
        
        if [ -f ".env.example" ]; then
            print_status "Copiando .env.example a .env..."
            cp .env.example .env
            print_success "Archivo .env creado desde plantilla"
            print_warning "IMPORTANTE: Revisa y ajusta las variables en .env según tu entorno"
        else
            print_warning "No se encuentra .env.example. Creando .env básico..."
            cat > .env << 'EOL'
NODE_ENV=production
APP_PORT=3000
POSTGRES_DB=bella_vista
POSTGRES_USER=restaurante
POSTGRES_PASSWORD=bella123
GRAFANA_ADMIN_PASSWORD=bella123
EOL
            print_success "Archivo .env básico creado"
        fi
    else
        print_success "Archivo .env encontrado"
    fi
    
    local missing_requirements=()
    
    if ! command -v docker &> /dev/null; then
        missing_requirements+=("Docker")
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        missing_requirements+=("Docker Compose")
    fi
    
    if ! command -v curl &> /dev/null; then
        missing_requirements+=("curl")
    fi
    
    if [ ${#missing_requirements[@]} -ne 0 ]; then
        print_error "Faltan los siguientes requisitos:"
        for req in "${missing_requirements[@]}"; do
            echo "   - $req"
        done
        echo ""
        echo "🔧 Para instalar en Ubuntu/Debian:"
        echo "   sudo apt update"
        echo "   sudo apt install docker.io docker-compose curl"
        echo ""
        echo "🔧 Para instalar en CentOS/RHEL:"
        echo "   sudo yum install docker docker-compose curl"
        echo ""
        echo "🔧 Para Windows:"
        echo "   Instalar Docker Desktop desde: https://docker.com/products/docker-desktop"
        exit 1
    fi
    
    print_success "Todos los requisitos están instalados"
}

# Función para verificar que Docker esté corriendo
check_docker_running() {
    print_step "2" "Verificando que Docker esté ejecutándose..."
    
    if ! docker info &> /dev/null; then
        print_error "Docker no está ejecutándose"
        echo "🔧 Soluciones:"
        echo "   - Linux: sudo systemctl start docker"
        echo "   - Windows/Mac: Iniciar Docker Desktop"
        exit 1
    fi
    
    print_success "Docker está ejecutándose correctamente"
}

# Función para crear red de Docker
setup_network() {
    print_step "3" "Configurando red de Docker..."
    
    if docker network ls | grep -q restaurante-network; then
        print_warning "La red 'restaurante-network' ya existe"
    else
        docker network create restaurante-network
        print_success "Red 'restaurante-network' creada"
    fi
}

# Función para levantar la aplicación principal
start_application() {
    print_step "4" "Iniciando aplicación del restaurante..."
    
    print_status "Construyendo imágenes y levantando servicios..."
    docker-compose up -d --build
    
    print_status "Esperando que PostgreSQL esté listo..."
    sleep 15
    
    # Verificar que los servicios estén corriendo
    local services=("bella-vista-postgres" "bella-vista-frontend-usuario")
    for service in "${services[@]}"; do
        if docker ps --format "table {{.Names}}" | grep -q "$service"; then
            print_success "✅ $service está ejecutándose"
        else
            print_error "❌ $service no está ejecutándose"
            return 1
        fi
    done
    
    # Verificar que la aplicación responda
    local max_attempts=30
    local attempt=1
    while [ $attempt -le $max_attempts ]; do
        if curl -s http://localhost:3000 > /dev/null 2>&1; then
            print_success "✅ Aplicación responde en http://localhost:3000"
            break
        fi
        
        if [ $attempt -eq $max_attempts ]; then
            print_error "❌ La aplicación no responde después de $max_attempts intentos"
            return 1
        fi
        
        print_status "Esperando que la aplicación responda... (intento $attempt/$max_attempts)"
        sleep 2
        ((attempt++))
    done
}

# Función para levantar monitoreo
start_monitoring() {
    print_step "5" "Iniciando sistema de monitoreo..."
    
    if [ ! -f "docker-compose.monitoring.yml" ]; then
        print_error "Archivo docker-compose.monitoring.yml no encontrado"
        return 1
    fi
    
    print_status "Levantando servicios de monitoreo..."
    docker-compose -f docker-compose.monitoring.yml up -d
    
    print_status "Esperando que los servicios de monitoreo estén listos..."
    sleep 20
    
    # Verificar servicios de monitoreo
    local monitoring_services=("bella-vista-prometheus" "bella-vista-grafana" "bella-vista-postgres-exporter" "bella-vista-node-exporter" "bella-vista-cadvisor")
    for service in "${monitoring_services[@]}"; do
        if docker ps --format "table {{.Names}}" | grep -q "$service"; then
            print_success "✅ $service está ejecutándose"
        else
            print_warning "⚠️ $service no está ejecutándose correctamente"
        fi
    done
    
    # Verificar que Grafana responda
    local max_attempts=30
    local attempt=1
    while [ $attempt -le $max_attempts ]; do
        if curl -s http://localhost:3001/api/health > /dev/null 2>&1; then
            print_success "✅ Grafana responde en http://localhost:3001"
            break
        fi
        
        if [ $attempt -eq $max_attempts ]; then
            print_warning "⚠️ Grafana no responde, pero continuaremos"
            break
        fi
        
        print_status "Esperando que Grafana responda... (intento $attempt/$max_attempts)"
        sleep 2
        ((attempt++))
    done
}

# Función para configurar dashboards automáticamente
setup_dashboards() {
    print_step "6" "Configurando dashboards de Grafana..."
    
    # Esperar un poco más para que Grafana esté completamente listo
    sleep 10
    
    # Obtener UID del datasource Prometheus
    local prometheus_uid
    prometheus_uid=$(curl -s -u "admin:bella123" "http://localhost:3001/api/datasources" 2>/dev/null | grep -o '"uid":"[^"]*"' | head -1 | cut -d'"' -f4)
    
    if [ -z "$prometheus_uid" ]; then
        print_warning "No se pudo obtener el UID del datasource, usando UID por defecto"
        prometheus_uid="PBFA97CFB590B2093"
    fi
    
    print_status "Creando dashboard principal con datos en tiempo real..."
    
    # Crear dashboard funcional
    cat > /tmp/dashboard-auto.json << EOF
{
  "dashboard": {
    "id": null,
    "title": "🍽️ Bella Vista - Dashboard Principal",
    "tags": ["restaurante", "principal", "auto-setup"],
    "timezone": "",
    "refresh": "5s",
    "time": {
      "from": "now-15m",
      "to": "now"
    },
    "panels": [
      {
        "id": 1,
        "title": "📊 Total HTTP Requests",
        "type": "stat",
        "targets": [
          {
            "expr": "http_requests_total",
            "refId": "A"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "color": {
              "mode": "thresholds"
            },
            "thresholds": {
              "steps": [
                {
                  "color": "green",
                  "value": null
                }
              ]
            }
          }
        },
        "gridPos": {
          "h": 8,
          "w": 6,
          "x": 0,
          "y": 0
        },
        "datasource": {
          "type": "prometheus",
          "uid": "$prometheus_uid"
        }
      },
      {
        "id": 2,
        "title": "🍽️ Vistas del Menú",
        "type": "stat",
        "targets": [
          {
            "expr": "menu_views_total",
            "refId": "A"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "color": {
              "mode": "thresholds"
            },
            "thresholds": {
              "steps": [
                {
                  "color": "blue",
                  "value": null
                }
              ]
            }
          }
        },
        "gridPos": {
          "h": 8,
          "w": 6,
          "x": 6,
          "y": 0
        },
        "datasource": {
          "type": "prometheus",
          "uid": "$prometheus_uid"
        }
      },
      {
        "id": 3,
        "title": "💰 Ingresos Totales",
        "type": "stat",
        "targets": [
          {
            "expr": "revenue_total",
            "refId": "A"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "color": {
              "mode": "thresholds"
            },
            "thresholds": {
              "steps": [
                {
                  "color": "green",
                  "value": null
                }
              ]
            },
            "unit": "currencyEUR"
          }
        },
        "gridPos": {
          "h": 8,
          "w": 6,
          "x": 12,
          "y": 0
        },
        "datasource": {
          "type": "prometheus",
          "uid": "$prometheus_uid"
        }
      },
      {
        "id": 4,
        "title": "📦 Total Pedidos",
        "type": "stat",
        "targets": [
          {
            "expr": "orders_total",
            "refId": "A"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "color": {
              "mode": "thresholds"
            },
            "thresholds": {
              "steps": [
                {
                  "color": "orange",
                  "value": null
                }
              ]
            }
          }
        },
        "gridPos": {
          "h": 8,
          "w": 6,
          "x": 18,
          "y": 0
        },
        "datasource": {
          "type": "prometheus",
          "uid": "$prometheus_uid"
        }
      },
      {
        "id": 5,
        "title": "📈 Actividad en Tiempo Real",
        "type": "timeseries",
        "targets": [
          {
            "expr": "http_requests_total",
            "refId": "A",
            "legendFormat": "Requests Totales"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "color": {
              "mode": "palette-classic"
            },
            "custom": {
              "axisPlacement": "auto",
              "drawStyle": "line",
              "lineInterpolation": "linear",
              "lineWidth": 2,
              "pointSize": 5,
              "showPoints": "auto",
              "spanNulls": false
            }
          }
        },
        "gridPos": {
          "h": 8,
          "w": 24,
          "x": 0,
          "y": 8
        },
        "datasource": {
          "type": "prometheus",
          "uid": "$prometheus_uid"
        }
      }
    ]
  },
  "overwrite": true
}
EOF
    
    # Intentar crear el dashboard
    if curl -X POST -H "Content-Type: application/json" -u "admin:bella123" \
        "http://localhost:3001/api/dashboards/db" \
        -d @/tmp/dashboard-auto.json &> /dev/null; then
        print_success "✅ Dashboard principal creado exitosamente"
    else
        print_warning "⚠️ No se pudo crear el dashboard automáticamente"
        print_status "Podrás crearlo manualmente más tarde"
    fi
    
    # Limpiar archivo temporal
    rm -f /tmp/dashboard-auto.json
}

# Función para generar datos de prueba
generate_test_data() {
    print_step "7" "Generando datos de prueba..."
    
    print_status "Generando tráfico de ejemplo..."
    for i in {1..20}; do
        curl -s http://localhost:3000/ > /dev/null 2>&1 || true
        if [ $((i % 5)) -eq 0 ]; then
            echo -n "."
        fi
    done
    echo ""
    
    print_success "✅ Datos de prueba generados"
}

# Función para mostrar resumen final
show_summary() {
    print_step "8" "¡Setup completado!"
    
    echo ""
    echo -e "${GREEN}🎉 ¡RESTAURANTE BELLA VISTA CONFIGURADO EXITOSAMENTE!${NC}"
    echo "=================================================================="
    echo ""
    echo -e "${CYAN}📱 APLICACIÓN PRINCIPAL:${NC}"
    echo "   🍽️ Restaurante: http://localhost:3000"
    echo ""
    echo -e "${CYAN}📊 MONITOREO Y DASHBOARDS:${NC}"
    echo "   📈 Grafana:    http://localhost:3001"
    echo "   🔍 Prometheus: http://localhost:9090"
    echo "   📦 cAdvisor:   http://localhost:8080"
    echo ""
    echo -e "${CYAN}🔑 CREDENCIALES:${NC}"
    echo "   Grafana: admin / bella123"
    echo ""
    echo -e "${CYAN}🎯 DASHBOARDS PRINCIPALES:${NC}"
    echo "   🍽️ Dashboard Principal: Buscar 'Bella Vista - Dashboard Principal' en Grafana"
    echo "   📁 Otros dashboards disponibles en la carpeta 'Restaurante Bella Vista'"
    echo ""
    echo -e "${CYAN}🚀 COMANDOS ÚTILES:${NC}"
    echo "   # Generar tráfico para ver métricas:"
    echo "   ./live-traffic.sh"
    echo ""
    echo "   # Ver logs:"
    echo "   docker-compose logs -f"
    echo "   docker-compose -f docker-compose.monitoring.yml logs -f"
    echo ""
    echo "   # Reiniciar servicios:"
    echo "   docker-compose restart"
    echo "   docker-compose -f docker-compose.monitoring.yml restart"
    echo ""
    echo "   # Detener todo:"
    echo "   docker-compose down"
    echo "   docker-compose -f docker-compose.monitoring.yml down"
    echo ""
    echo -e "${YELLOW}📋 PRÓXIMOS PASOS:${NC}"
    echo "   1. Visita http://localhost:3000 para ver la aplicación"
    echo "   2. Ve a http://localhost:3001 (admin/bella123) para ver dashboards"
    echo "   3. Ejecuta './live-traffic.sh' para generar métricas en tiempo real"
    echo ""
    echo -e "${GREEN}¡Disfruta tu Restaurante Bella Vista! 🍽️✨${NC}"
}

# Función principal
main() {
    print_header
    
    # Verificar si ya está ejecutándose
    if docker ps | grep -q bella-vista; then
        print_warning "Parece que el proyecto ya está ejecutándose"
        echo "¿Quieres continuar y reiniciar? (y/N)"
        read -r response
        if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            echo "Setup cancelado"
            exit 0
        fi
        
        print_status "Deteniendo servicios existentes..."
        docker-compose down 2>/dev/null || true
        docker-compose -f docker-compose.monitoring.yml down 2>/dev/null || true
        sleep 2
    fi
    
    # Ejecutar pasos del setup
    check_requirements
    check_docker_running
    setup_network
    start_application
    start_monitoring
    setup_dashboards
    generate_test_data
    show_summary
}

# Ejecutar función principal
main "$@"
