#!/bin/bash

# ================================================================
# 🍽️ SCRIPT PARA GESTIONAR PRODUCTOS/PLATOS
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

echo -e "${BLUE}🍽️ GESTIÓN DE PRODUCTOS DEL RESTAURANTE${NC}"
echo "=================================================="

echo ""
echo "1. 📋 Ver todos los productos disponibles"
echo "2. ➕ Añadir productos faltantes (IDs hasta 20)"
echo "3. 🔄 Activar/Desactivar un producto"
echo "4. 🗑️ Eliminar un producto específico"
echo "5. 🔍 Buscar producto por ID"
echo "6. ❌ Salir"
echo ""

read -p "Selecciona una opción (1-6): " choice

case $choice in
    1)
        echo -e "${BLUE}📋 PRODUCTOS DISPONIBLES:${NC}"
        run_sql "
            SELECT 
                p.id,
                p.nombre,
                p.precio,
                c.nombre as categoria,
                CASE WHEN p.disponible THEN '✅ Sí' ELSE '❌ No' END as disponible
            FROM platos p
            LEFT JOIN categorias c ON p.categoria_id = c.id
            ORDER BY p.id;
        "
        ;;
    2)
        echo -e "${YELLOW}Añadiendo productos hasta ID 20...${NC}"
        run_sql "
            INSERT INTO platos (nombre, descripcion, precio, categoria_id, disponible) VALUES 
            ('Pasta Carbonara', 'Pasta cremosa con panceta y parmesano', 13.50, 2, true),
            ('Pollo al Curry', 'Pollo tierno en salsa de curry con arroz', 15.80, 2, true),
            ('Tarta de Queso', 'Deliciosa tarta de queso con frutos rojos', 6.90, 3, true),
            ('Café Expresso', 'Café italiano tradicional', 2.20, 4, true),
            ('Vino Blanco', 'Vino blanco de la casa', 15.00, 4, true),
            ('Gazpacho', 'Sopa fría de verduras andaluza', 7.50, 1, true),
            ('Paella Valenciana', 'Paella tradicional con pollo y verduras', 18.90, 2, true),
            ('Flan Casero', 'Flan tradicional con caramelo', 5.50, 3, true),
            ('Cerveza Artesana', 'Cerveza de elaboración propia', 4.50, 4, true),
            ('Tortilla Española', 'Tortilla de patatas casera', 8.90, 1, true),
            ('Pulpo a la Gallega', 'Pulpo tierno con pimentón y aceite', 16.50, 1, true)
            ON CONFLICT (id) DO NOTHING;
        "
        echo -e "${GREEN}✅ Productos añadidos hasta ID 20${NC}"
        ;;
    3)
        read -p "ID del producto a cambiar estado: " producto_id
        echo "Estado actual:"
        run_sql "SELECT id, nombre, disponible FROM platos WHERE id = $producto_id;"
        read -p "¿Activar (true) o Desactivar (false)?: " nuevo_estado
        run_sql "UPDATE platos SET disponible = $nuevo_estado WHERE id = $producto_id;"
        echo -e "${GREEN}✅ Estado del producto actualizado${NC}"
        ;;
    4)
        read -p "ID del producto a eliminar: " producto_id
        echo "Producto a eliminar:"
        run_sql "SELECT id, nombre, precio FROM platos WHERE id = $producto_id;"
        read -p "¿Confirmas la eliminación? (y/N): " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            run_sql "DELETE FROM platos WHERE id = $producto_id;"
            echo -e "${GREEN}✅ Producto eliminado${NC}"
        else
            echo "Eliminación cancelada"
        fi
        ;;
    5)
        read -p "ID del producto a buscar: " producto_id
        echo -e "${BLUE}🔍 INFORMACIÓN DEL PRODUCTO:${NC}"
        run_sql "
            SELECT 
                p.id,
                p.nombre,
                p.descripcion,
                p.precio,
                c.nombre as categoria,
                p.disponible,
                p.tiempo_preparacion
            FROM platos p
            LEFT JOIN categorias c ON p.categoria_id = c.id
            WHERE p.id = $producto_id;
        "
        ;;
    6)
        echo "Saliendo..."
        exit 0
        ;;
    *)
        echo "Opción inválida"
        ;;
esac

echo ""
echo -e "${BLUE}📊 RESUMEN ACTUAL:${NC}"
run_sql "
    SELECT 
        COUNT(*) as total_productos,
        COUNT(CASE WHEN disponible THEN 1 END) as disponibles,
        COUNT(CASE WHEN NOT disponible THEN 1 END) as no_disponibles
    FROM platos;
"
