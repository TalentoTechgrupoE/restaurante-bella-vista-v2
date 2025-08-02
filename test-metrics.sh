#!/bin/bash

echo "🧪 Generando métricas de prueba para Bella Vista..."

# Generar vistas del menú
echo "📊 Generando vistas del menú..."
for i in {1..5}; do
    curl -s http://localhost:3000/ > /dev/null
    echo "   Vista $i generada"
    sleep 1
done

# Generar accesos a la API
echo "📡 Generando accesos a la API..."
for i in {1..3}; do
    curl -s http://localhost:3000/api/menu > /dev/null
    curl -s http://localhost:3000/api/categorias > /dev/null
    echo "   Acceso API $i generado"
    sleep 1
done

# Verificar métricas finales
echo "📈 Métricas finales:"
curl -s http://localhost:3000/metrics | grep -E "(http_requests_total|menu_views_total|orders_total|revenue_total)"

echo ""
echo "✅ Generación de métricas completada!"
echo "🔗 Accede a Grafana: http://localhost:3001 (admin/bella123)"
