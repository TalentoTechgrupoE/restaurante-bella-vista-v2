#!/bin/bash

# ================================================================
# 🗑️ SCRIPT PARA LIMPIAR TABLA DE PEDIDOS
# ================================================================
# Este script proporciona varias opciones para eliminar registros

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🗑️ OPCIONES PARA ELIMINAR PEDIDOS${NC}"
echo "=================================================="
echo ""
echo "1. 🔥 Eliminar TODOS los pedidos (peligroso)"
echo "2. 📅 Eliminar pedidos por fecha"
echo "3. 🏷️ Eliminar pedidos por estado"
echo "4. 👤 Eliminar pedidos de un cliente específico"
echo "5. 🏠 Eliminar pedidos de una mesa específica"
echo "6. 🔍 Ver pedidos antes de eliminar"
echo "7. ❌ Cancelar"
echo ""
read -p "Selecciona una opción (1-7): " option

case $option in
    1)
        echo -e "${RED}⚠️ ADVERTENCIA: Esto eliminará TODOS los pedidos${NC}"
        echo -e "${RED}   Esta acción NO se puede deshacer${NC}"
        read -p "¿Estás seguro? Escribe 'ELIMINAR' para confirmar: " confirm
        if [ "$confirm" = "ELIMINAR" ]; then
            echo "Eliminando TODOS los pedidos..."
            docker exec bella-vista-postgres psql -U restaurante -d bella_vista -c "
                DELETE FROM detalle_pedidos;
                DELETE FROM pedidos;
                SELECT 'Todos los pedidos eliminados' as resultado;
            "
        else
            echo "Operación cancelada"
        fi
        ;;
    2)
        read -p "Eliminar pedidos anteriores a qué fecha (YYYY-MM-DD): " fecha
        echo -e "${YELLOW}Eliminando pedidos anteriores a $fecha...${NC}"
        docker exec bella-vista-postgres psql -U restaurante -d bella_vista -c "
            DELETE FROM detalle_pedidos WHERE pedido_id IN (
                SELECT id FROM pedidos WHERE created_at < '$fecha'
            );
            DELETE FROM pedidos WHERE created_at < '$fecha';
            SELECT 'Pedidos anteriores a $fecha eliminados' as resultado;
        "
        ;;
    3)
        echo "Estados disponibles: pendiente, preparando, listo, servido, pagado, cancelado"
        read -p "Eliminar pedidos con estado: " estado
        echo -e "${YELLOW}Eliminando pedidos con estado '$estado'...${NC}"
        docker exec bella-vista-postgres psql -U postgres -d bellavista_db -c "
            DELETE FROM detalle_pedidos WHERE pedido_id IN (
                SELECT id FROM pedidos WHERE estado = '$estado'
            );
            DELETE FROM pedidos WHERE estado = '$estado';
            SELECT 'Pedidos con estado $estado eliminados' as resultado;
        "
        ;;
    4)
        read -p "Nombre del cliente: " cliente
        echo -e "${YELLOW}Eliminando pedidos del cliente '$cliente'...${NC}"
        docker exec bella-vista-postgres psql -U postgres -d bellavista_db -c "
            DELETE FROM detalle_pedidos WHERE pedido_id IN (
                SELECT id FROM pedidos WHERE cliente_nombre ILIKE '%$cliente%'
            );
            DELETE FROM pedidos WHERE cliente_nombre ILIKE '%$cliente%';
            SELECT 'Pedidos del cliente $cliente eliminados' as resultado;
        "
        ;;
    5)
        read -p "Número de mesa: " mesa
        echo -e "${YELLOW}Eliminando pedidos de la mesa $mesa...${NC}"
        docker exec bella-vista-postgres psql -U postgres -d bellavista_db -c "
            DELETE FROM detalle_pedidos WHERE pedido_id IN (
                SELECT p.id FROM pedidos p 
                JOIN mesas m ON p.mesa_id = m.id 
                WHERE m.numero = $mesa
            );
            DELETE FROM pedidos WHERE mesa_id IN (
                SELECT id FROM mesas WHERE numero = $mesa
            );
            SELECT 'Pedidos de la mesa $mesa eliminados' as resultado;
        "
        ;;
    6)
        echo -e "${BLUE}📋 PEDIDOS ACTUALES:${NC}"
        docker exec bella-vista-postgres psql -U postgres -d bellavista_db -c "
            SELECT 
                p.id,
                m.numero as mesa,
                p.cliente_nombre,
                p.estado,
                p.total,
                p.created_at
            FROM pedidos p
            LEFT JOIN mesas m ON p.mesa_id = m.id
            ORDER BY p.created_at DESC
            LIMIT 20;
        "
        ;;
    7)
        echo "Operación cancelada"
        exit 0
        ;;
    *)
        echo "Opción inválida"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}✅ Operación completada${NC}"
