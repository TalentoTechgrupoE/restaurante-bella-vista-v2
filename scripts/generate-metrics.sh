#!/bin/bash

# Script para generar métricas de ejemplo para el Restaurante Bella Vista
# Este script simula actividad del restaurante para probar los dashboards

set -e

echo "🍽️ Generando métricas de ejemplo para Restaurante Bella Vista..."

# Función para generar métricas random realistas
generate_restaurant_metrics() {
    local timestamp=$(date +%s)
    local hour=$(date +%H)
    
    # Simular diferentes niveles de actividad según la hora
    if [ $hour -ge 12 ] && [ $hour -le 14 ]; then
        # Hora de almuerzo - alta actividad
        mesas_ocupadas=$((15 + $RANDOM % 5))
        pedidos_activos=$((8 + $RANDOM % 12))
        ingresos_acumulados=$((800 + $RANDOM % 400))
    elif [ $hour -ge 19 ] && [ $hour -le 22 ]; then
        # Hora de cena - muy alta actividad
        mesas_ocupadas=$((16 + $RANDOM % 4))
        pedidos_activos=$((10 + $RANDOM % 15))
        ingresos_acumulados=$((1200 + $RANDOM % 600))
    else
        # Horas normales - baja actividad
        mesas_ocupadas=$((2 + $RANDOM % 8))
        pedidos_activos=$((1 + $RANDOM % 5))
        ingresos_acumulados=$((200 + $RANDOM % 300))
    fi
    
    # Calcular métricas derivadas
    pedidos_total=$((ingresos_acumulados / 25 + $RANDOM % 10))
    tiempo_mesa_promedio=$((35 + $RANDOM % 30))
    pedidos_retrasados=$((pedidos_activos > 15 ? $RANDOM % 3 : 0))
    
    echo "# Métricas del Restaurante Bella Vista"
    echo "# HELP restaurante_mesas_ocupadas Número de mesas ocupadas actualmente"
    echo "# TYPE restaurante_mesas_ocupadas gauge"
    echo "restaurante_mesas_ocupadas $mesas_ocupadas"
    echo ""
    
    echo "# HELP restaurante_pedidos_activos Pedidos actualmente en cocina"
    echo "# TYPE restaurante_pedidos_activos gauge"
    echo "restaurante_pedidos_activos $pedidos_activos"
    echo ""
    
    echo "# HELP restaurante_ingresos_euros Ingresos acumulados del día en euros"
    echo "# TYPE restaurante_ingresos_euros counter"
    echo "restaurante_ingresos_euros $ingresos_acumulados"
    echo ""
    
    echo "# HELP restaurante_pedidos_total Total de pedidos del día"
    echo "# TYPE restaurante_pedidos_total counter"
    echo "restaurante_pedidos_total $pedidos_total"
    echo ""
    
    echo "# HELP restaurante_tiempo_mesa_minutos Tiempo promedio en mesa"
    echo "# TYPE restaurante_tiempo_mesa_minutos gauge"
    echo "restaurante_tiempo_mesa_minutos $tiempo_mesa_promedio"
    echo ""
    
    # Métricas por categoría de comida
    local categorias=("pizzas" "pastas" "ensaladas" "postres" "bebidas")
    for categoria in "${categorias[@]}"; do
        local valor=$((10 + $RANDOM % 20))
        echo "# HELP restaurante_items_pedidos_total Items pedidos por categoría"
        echo "# TYPE restaurante_items_pedidos_total counter"
        echo "restaurante_items_pedidos_total{item=\"$categoria\"} $valor"
        echo ""
    done
    
    # Métricas de pago
    local efectivo=$((ingresos_acumulados * 30 / 100))
    local tarjeta=$((ingresos_acumulados * 65 / 100))
    local digital=$((ingresos_acumulados * 5 / 100))
    
    echo "# HELP restaurante_pagos_total Pagos por método"
    echo "# TYPE restaurante_pagos_total counter"
    echo "restaurante_pagos_total{metodo=\"efectivo\"} $efectivo"
    echo "restaurante_pagos_total{metodo=\"tarjeta\"} $tarjeta"
    echo "restaurante_pagos_total{metodo=\"digital\"} $digital"
    echo ""
    
    # Métricas de errores (muy bajas en un restaurante bien gestionado)
    local errores_pago=$((pedidos_total * 2 / 100))  # 2% de errores
    local errores_total=$((pedidos_total * 1 / 100))  # 1% de errores generales
    
    echo "# HELP restaurante_errores_pago_total Errores en pagos"
    echo "# TYPE restaurante_errores_pago_total counter"
    echo "restaurante_errores_pago_total $errores_pago"
    echo ""
    
    echo "# HELP restaurante_errores_total Errores totales del sistema"
    echo "# TYPE restaurante_errores_total counter"
    echo "restaurante_errores_total $errores_total"
    echo ""
    
    # Métricas de duración de pedidos
    for i in {1..5}; do
        local mesa=$((1 + $RANDOM % 20))
        local duracion=$((600 + $RANDOM % 1800))  # Entre 10 y 40 minutos
        if [ $pedidos_retrasados -gt 0 ] && [ $i -le $pedidos_retrasados ]; then
            duracion=$((1800 + $RANDOM % 1200))  # Pedidos retrasados: >30 min
        fi
        echo "# HELP restaurante_pedidos_duracion_segundos Duración de pedidos activos"
        echo "# TYPE restaurante_pedidos_duracion_segundos gauge"
        echo "restaurante_pedidos_duracion_segundos{mesa=\"$mesa\"} $duracion"
    done
    echo ""
    
    # Ingresos por categoría para análisis financiero
    for categoria in "${categorias[@]}"; do
        local ingreso_categoria=$((ingresos_acumulados * (10 + $RANDOM % 30) / 100))
        echo "# HELP restaurante_ingresos_por_categoria_euros Ingresos por categoría"
        echo "# TYPE restaurante_ingresos_por_categoria_euros counter"
        echo "restaurante_ingresos_por_categoria_euros{categoria=\"$categoria\"} $ingreso_categoria"
    done
    echo ""
    
    # Top items por ingresos
    local items=("Pizza Margherita" "Pasta Carbonara" "Ensalada César" "Tiramisú" "Vino Tinto")
    for item in "${items[@]}"; do
        local ingreso_item=$((50 + $RANDOM % 200))
        echo "# HELP restaurante_ingresos_por_item_euros Ingresos por item específico"
        echo "# TYPE restaurante_ingresos_por_item_euros counter"
        echo "restaurante_ingresos_por_item_euros{item=\"$item\"} $ingreso_item"
    done
}

# Crear endpoint para métricas si no existe
create_metrics_endpoint() {
    local metrics_dir="/tmp/restaurante-metrics"
    mkdir -p "$metrics_dir"
    
    echo "📊 Generando métricas..."
    generate_restaurant_metrics > "$metrics_dir/metrics.txt"
    
    echo "📁 Métricas guardadas en: $metrics_dir/metrics.txt"
    echo ""
    echo "Para servir las métricas en puerto 8090:"
    echo "cd $metrics_dir && python3 -m http.server 8090"
    echo ""
    echo "Las métricas estarán disponibles en:"
    echo "http://localhost:8090/metrics.txt"
}

# Función para simular actividad continua
simulate_continuous_activity() {
    echo "🔄 Iniciando simulación continua de actividad..."
    echo "Presiona Ctrl+C para detener"
    
    local counter=1
    while true; do
        echo "📊 Generando métricas... (iteración $counter)"
        generate_restaurant_metrics > "/tmp/restaurante-metrics/metrics.txt"
        echo "✅ Métricas actualizadas $(date)"
        
        sleep 30  # Actualizar cada 30 segundos
        ((counter++))
    done
}

# Función principal
main() {
    case "${1:-generate}" in
        "generate")
            create_metrics_endpoint
            ;;
        "continuous")
            create_metrics_endpoint
            simulate_continuous_activity
            ;;
        "serve")
            create_metrics_endpoint
            cd /tmp/restaurante-metrics
            echo "🌐 Sirviendo métricas en http://localhost:8090/metrics.txt"
            python3 -m http.server 8090
            ;;
        "help"|"--help"|"-h")
            echo "Uso: $0 [comando]"
            echo ""
            echo "Comandos disponibles:"
            echo "  generate    - Generar métricas una vez (default)"
            echo "  continuous  - Generar métricas continuamente cada 30s"
            echo "  serve       - Generar y servir métricas en puerto 8090"
            echo "  help        - Mostrar esta ayuda"
            echo ""
            echo "Ejemplos:"
            echo "  $0 generate"
            echo "  $0 continuous"
            echo "  $0 serve"
            ;;
        *)
            echo "❌ Comando desconocido: $1"
            echo "Usa '$0 help' para ver comandos disponibles"
            exit 1
            ;;
    esac
}

main "$@"
