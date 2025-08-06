# 🛠️ SOLUCIÓN: Dashboard "No Data" - Problema de UID del Datasource

## 🔍 Problema Identificado
Los dashboards mostraban "No Data" porque tenían configurado un UID incorrecto del datasource de Prometheus.

## ⚙️ Diagnóstico
```bash
# 1. Verificar UID correcto del datasource
curl -s -u admin:bella123 "http://localhost:3001/api/datasources"

# 2. Resultado: UID correcto era "PBFA97CFB590B2093", no "prometheus"
```

## ✅ Solución Aplicada

### 1. Corregir UID en Dashboards
```bash
# Corregir todos los dashboards de una vez
cd "c:\Users\ad\Documents\Cursos\proyecto\mision2\restaurante-bella-vista-v2\monitoring\grafana\dashboards"
for file in *.json; do 
    sed 's/"uid": "prometheus"/"uid": "PBFA97CFB590B2093"/g' "$file" > "${file}_temp" && mv "${file}_temp" "$file"
done
```

### 2. Recargar Dashboards
```bash
# Forzar recarga via API
curl -X POST -u admin:bella123 "http://localhost:3001/api/admin/provisioning/dashboards/reload"
```

## 🧪 Verificación de Funcionamiento

### Test de Query Directa
```bash
curl -s -X POST -H "Content-Type: application/json" -u admin:bella123 "http://localhost:3001/api/ds/query" \
-d '{"queries":[{"expr":"up","refId":"A","datasource":{"uid":"PBFA97CFB590B2093"}}],"from":"now-1h","to":"now"}'
```

### Test de Métricas de Contenedores
```bash
curl -s -X POST -H "Content-Type: application/json" -u admin:bella123 "http://localhost:3001/api/ds/query" \
-d '{"queries":[{"expr":"container_memory_usage_bytes","refId":"A","datasource":{"uid":"PBFA97CFB590B2093"}}],"from":"now-15m","to":"now"}'
```

## 📊 Dashboards Funcionando

### ✅ Contenedores Docker
- **URL**: http://localhost:3001/d/contenedores/monitoreo-de-contenedores-docker
- **Datos**: Memoria, CPU, Red de contenedores

### ✅ Operaciones Sistema Real  
- **URL**: http://localhost:3001/d/operacional-simple/operaciones-sistema-real
- **Datos**: HTTP requests, memoria Docker, CPU

### ✅ Sistema Técnico
- **URL**: http://localhost:3001/d/tecnico/sistema-monitoreo-tecnico
- **Datos**: Métricas técnicas del sistema

## 🔧 Información Técnica

### Credenciales
- **Usuario**: admin
- **Password**: bella123

### UID del Datasource Correcto
```
"datasource": {
  "type": "prometheus", 
  "uid": "PBFA97CFB590B2093"
}
```

### Métricas Disponibles
- `up` - Estado de servicios
- `http_requests_total` - Peticiones HTTP
- `container_memory_usage_bytes` - Memoria contenedores
- `container_cpu_usage_seconds_total` - CPU contenedores
- `container_network_receive_bytes_total` - Red recibida
- `container_network_transmit_bytes_total` - Red transmitida

## 🎯 Resultado
**✅ RESUELTO**: Los dashboards ahora cargan datos correctamente y se actualizan en tiempo real cada 5 segundos.

## 🚨 Para Futuras Referencias
Siempre verificar el UID del datasource cuando los dashboards muestran "No Data":
```bash
curl -s -u admin:bella123 "http://localhost:3001/api/datasources" | grep '"uid"'
```
