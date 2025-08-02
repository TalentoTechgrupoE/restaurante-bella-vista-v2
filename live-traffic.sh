#!/bin/bash

echo "🚀 Generando tráfico continuo para dashboards..."
echo "💡 Presiona Ctrl+C para detener"

while true; do
    # Generar vistas del menú
    curl -s http://localhost:3000/ > /dev/null
    echo "🍽️ Vista del menú generada - $(date '+%H:%M:%S')"
    
    # Acceder a diferentes APIs
    curl -s http://localhost:3000/api/menu > /dev/null
    curl -s http://localhost:3000/api/categorias > /dev/null
    
    # Mostrar métricas actuales cada 10 iteraciones
    if [ $((RANDOM % 10)) -eq 0 ]; then
        echo "📊 Métricas actuales:"
        curl -s http://localhost:3000/metrics | grep -E "(http_requests_total|menu_views_total|revenue_total)" | sed 's/^/   /'
        echo ""
    fi
    
    sleep 2
done
