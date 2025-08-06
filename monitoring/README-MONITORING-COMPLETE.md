# 📊 Sistema de Monitoreo - Restaurante Bella Vista

## 🎯 Overview

Este sistema de monitoreo proporciona observabilidad completa para el Restaurante Bella Vista, incluyendo métricas de aplicación, sistema, base de datos y contenedores.

## 🏗️ Arquitectura de Monitoreo

```
📊 STACK DE MONITOREO
├── 🔍 Prometheus (Puerto 9090)
│   ├── Recolección de métricas
│   ├── Almacenamiento time-series
│   └── Alertas (futuro)
├── 📈 Grafana (Puerto 3001)
│   ├── Dashboards interactivos
│   ├── Visualizaciones en tiempo real
│   └── Alertas visuales
└── 📊 Exporters
    ├── 🖥️ Node Exporter (Puerto 9100) - Métricas del sistema
    ├── 🗄️ PostgreSQL Exporter (Puerto 9187) - Métricas de BD
    └── 📦 cAdvisor (Puerto 8080) - Métricas de contenedores
```

## 🚀 Deployment Automático

El sistema de monitoreo se despliega automáticamente cuando ejecutas:

```bash
./setup-complete.sh
```

Este script:
1. ✅ Verifica requisitos del sistema
2. ✅ Levanta la aplicación principal
3. ✅ Despliega el stack de monitoreo
4. ✅ **Valida comunicación entre servicios**
5. ✅ Configura dashboards automáticamente
6. ✅ Genera datos de prueba

## 🔗 Validación de Conectividad

### ✅ Validación Automática Incluida

El script `setup-complete.sh` incluye una función `validate_monitoring_connectivity()` que verifica:

- 🔍 **Prometheus API** responde correctamente
- 📊 **Grafana** está accesible y configurado
- 📦 **cAdvisor** está exportando métricas de contenedores
- 🖥️ **Node Exporter** está exportando métricas del sistema
- 🗄️ **PostgreSQL Exporter** está conectado a la base de datos
- 🔗 **Conectividad Grafana → Prometheus** funciona
- 📈 **Targets en Prometheus** están UP

### 🧪 Validación Manual Completa

Para una validación exhaustiva, ejecuta:

```bash
./scripts/test-monitoring.sh
```

Este script ejecuta 7 tests completos:
1. **Contenedores** - Verifica que todos estén corriendo
2. **HTTP Connectivity** - Testa acceso a todos los servicios
3. **Prometheus Metrics** - Valida recolección de métricas
4. **Prometheus Targets** - Verifica estado de targets
5. **Grafana-Prometheus** - Testa conectividad entre servicios
6. **Traffic Generation** - Genera tráfico y valida métricas
7. **Grafana Dashboards** - Verifica dashboards disponibles

## 📱 URLs de Acceso

| Servicio | URL | Credenciales |
|----------|-----|--------------|
| 🍽️ **Aplicación** | http://localhost:3000 | - |
| 📈 **Grafana** | http://localhost:3001 | admin/bella123 |
| 🔍 **Prometheus** | http://localhost:9090 | - |
| 📦 **cAdvisor** | http://localhost:8080 | - |
| 🖥️ **Node Metrics** | http://localhost:9100/metrics | - |
| 🗄️ **DB Metrics** | http://localhost:9187/metrics | - |

## 📊 Métricas Disponibles

### 🍽️ Aplicación
- `http_requests_total` - Total de requests HTTP
- `menu_views_total` - Vistas del menú
- `orders_total` - Pedidos realizados
- `revenue_total` - Ingresos totales

### 🖥️ Sistema (Node Exporter)
- `node_cpu_seconds_total` - Uso de CPU
- `node_memory_MemAvailable_bytes` - Memoria disponible
- `node_disk_io_time_seconds_total` - I/O de disco
- `node_network_receive_bytes_total` - Tráfico de red

### 🗄️ Base de Datos (PostgreSQL)
- `pg_up` - Estado de conexión
- `pg_stat_database_tup_fetched` - Rows leídas
- `pg_stat_database_tup_inserted` - Inserciones
- `pg_locks_count` - Locks activos

### 📦 Contenedores (cAdvisor)
- `container_memory_usage_bytes` - Uso de memoria por contenedor
- `container_cpu_usage_seconds_total` - Uso de CPU por contenedor
- `container_network_receive_bytes_total` - Red por contenedor

## 🔧 Configuración

### Prometheus (`prometheus/prometheus.yml`)
```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  
  - job_name: 'postgres'
    static_configs:
      - targets: ['bella-vista-postgres-exporter:9187']
    scrape_interval: 30s
  
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['bella-vista-node-exporter:9100']
    scrape_interval: 30s
  
  - job_name: 'cadvisor'
    static_configs:
      - targets: ['bella-vista-cadvisor:8080']
    scrape_interval: 30s
  
  - job_name: 'restaurante-frontend'
    static_configs:
      - targets: ['bella-vista-frontend-usuario:3000']
    metrics_path: '/metrics'
    scrape_interval: 15s
```

### Grafana Datasource (`grafana/provisioning/datasources/prometheus.yml`)
```yaml
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    orgId: 1
    url: http://bella-vista-prometheus:9090
    basicAuth: false
    isDefault: true
    editable: true
```

## 🚨 Troubleshooting

### Problema: Servicios no responden

```bash
# Verificar contenedores
docker ps

# Ver logs específicos
docker-compose -f docker-compose.monitoring.yml logs prometheus
docker-compose -f docker-compose.monitoring.yml logs grafana

# Reiniciar servicios
docker-compose -f docker-compose.monitoring.yml restart
```

### Problema: Prometheus no recoge métricas

```bash
# Verificar targets en Prometheus
curl http://localhost:9090/api/v1/targets

# Verificar configuración
docker exec bella-vista-prometheus cat /etc/prometheus/prometheus.yml

# Recargar configuración
curl -X POST http://localhost:9090/-/reload
```

### Problema: Grafana no conecta con Prometheus

```bash
# Verificar datasources
curl -u "admin:bella123" http://localhost:3001/api/datasources

# Test de conectividad desde Grafana
curl -u "admin:bella123" -X POST \
  -H "Content-Type: application/json" \
  -d '{"targets":[{"expr":"up","refId":"A"}]}' \
  http://localhost:3001/api/ds/query
```

## 🎯 Comandos Útiles

```bash
# Validación completa del sistema
./scripts/test-monitoring.sh

# Generar tráfico de prueba
./live-traffic.sh

# Ver todos los logs de monitoreo
docker-compose -f docker-compose.monitoring.yml logs -f

# Restart completo del monitoreo
docker-compose -f docker-compose.monitoring.yml down
docker-compose -f docker-compose.monitoring.yml up -d

# Verificar métricas específicas
curl http://localhost:9090/api/v1/query?query=up
curl http://localhost:9100/metrics | grep node_cpu
curl http://localhost:9187/metrics | grep pg_up
```

## 🎉 Características Destacadas

- ✅ **Deploy automático** con un solo comando
- ✅ **Validación completa** de conectividad
- ✅ **Dashboards pre-configurados**
- ✅ **Métricas de aplicación, sistema y BD**
- ✅ **Tests automatizados** incluidos
- ✅ **Documentación completa**
- ✅ **Troubleshooting integrado**

¡El sistema está diseñado para funcionar out-of-the-box! 🚀
