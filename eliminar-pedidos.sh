#!/bin/bash

# ================================================================
# 🗑️ COMANDOS RÁPIDOS PARA ELIMINAR PEDIDOS
# ================================================================

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Función para ejecutar SQL
run_sql() {
    docker exec bella-vista-postgres psql -U restaurante -d bella_vista -c "$1"
}

echo -e "${BLUE}🗑️ COMANDOS PARA ELIMINAR PEDIDOS${NC}"
echo "=================================================="

echo ""
echo -e "${BLUE}📊 ESTADO ACTUAL:${NC}"
echo "Total de pedidos: $(run_sql "SELECT COUNT(*) FROM pedidos;" | grep -E '^\s*[0-9]+\s*$' | tr -d ' ')"
echo ""

echo -e "${YELLOW}Selecciona qué quieres hacer:${NC}"
echo "1. 🔍 Ver todos los pedidos"
echo "2. 🔥 Eliminar TODOS los pedidos"
echo "3. 📅 Eliminar pedidos de hoy"
echo "4. 🏷️ Eliminar pedidos cancelados"
echo "5. 👤 Eliminar por cliente específico"
echo "6. 🏠 Eliminar por mesa específica"
echo "7. ❌ Salir"
echo ""

read -p "Opción (1-7): " choice

case $choice in
    1)
        echo -e "${BLUE}📋 TODOS LOS PEDIDOS:${NC}"
        run_sql "
            SELECT 
                p.id,
                COALESCE(m.numero, 0) as mesa,
                COALESCE(p.cliente_nombre, 'Sin nombre') as cliente,
                p.estado,
                COALESCE(p.total, 0) as total,
                p.created_at
            FROM pedidos p
            LEFT JOIN mesas m ON p.mesa_id = m.id
            ORDER BY p.created_at DESC;
        "
        ;;
    2)
        echo -e "${RED}⚠️ PELIGRO: Eliminarás TODOS los pedidos${NC}"
        read -p "Escribe 'CONFIRMAR' para continuar: " confirm
        if [ "$confirm" = "CONFIRMAR" ]; then
            echo "Eliminando todos los pedidos..."
            run_sql "DELETE FROM detalle_pedidos; DELETE FROM pedidos;"
            echo -e "${GREEN}✅ Todos los pedidos eliminados${NC}"
        else
            echo "Cancelado"
        fi
        ;;
    3)
        echo "Eliminando pedidos de hoy..."
        run_sql "
            DELETE FROM detalle_pedidos WHERE pedido_id IN (
                SELECT id FROM pedidos WHERE DATE(created_at) = CURRENT_DATE
            );
            DELETE FROM pedidos WHERE DATE(created_at) = CURRENT_DATE;
        "
        echo -e "${GREEN}✅ Pedidos de hoy eliminados${NC}"
        ;;
    4)
        echo "Eliminando pedidos cancelados..."
        run_sql "
            DELETE FROM detalle_pedidos WHERE pedido_id IN (
                SELECT id FROM pedidos WHERE estado = 'cancelado'
            );
            DELETE FROM pedidos WHERE estado = 'cancelado';
        "
        echo -e "${GREEN}✅ Pedidos cancelados eliminados${NC}"
        ;;
    5)
        read -p "Nombre del cliente: " cliente
        echo "Eliminando pedidos de $cliente..."
        run_sql "
            DELETE FROM detalle_pedidos WHERE pedido_id IN (
                SELECT id FROM pedidos WHERE cliente_nombre ILIKE '%$cliente%'
            );
            DELETE FROM pedidos WHERE cliente_nombre ILIKE '%$cliente%';
        "
        echo -e "${GREEN}✅ Pedidos de $cliente eliminados${NC}"
        ;;
    6)
        read -p "Número de mesa: " mesa
        echo "Eliminando pedidos de la mesa $mesa..."
        run_sql "
            DELETE FROM detalle_pedidos WHERE pedido_id IN (
                SELECT p.id FROM pedidos p 
                LEFT JOIN mesas m ON p.mesa_id = m.id 
                WHERE m.numero = $mesa
            );
            DELETE FROM pedidos WHERE mesa_id = (
                SELECT id FROM mesas WHERE numero = $mesa
            );
        "
        echo -e "${GREEN}✅ Pedidos de la mesa $mesa eliminados${NC}"
        ;;
    7)
        echo "Saliendo..."
        exit 0
        ;;
    *)
        echo "Opción inválida"
        ;;
esac

echo ""
echo -e "${BLUE}📊 ESTADO FINAL:${NC}"
echo "Pedidos restantes: $(run_sql "SELECT COUNT(*) FROM pedidos;" | grep -E '^\s*[0-9]+\s*$' | tr -d ' ')"
