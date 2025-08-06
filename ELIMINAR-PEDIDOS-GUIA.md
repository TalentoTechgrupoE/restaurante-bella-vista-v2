# 🗑️ COMANDOS SQL PARA ELIMINAR PEDIDOS

## 📋 Conectarse a la Base de Datos
```bash
# Opción 1: Desde terminal
docker exec -it bella-vista-postgres psql -U postgres -d bellavista_db

# Opción 2: Comando directo
docker exec bella-vista-postgres psql -U postgres -d bellavista_db -c "TU_COMANDO_SQL"
```

## 🔥 Eliminar TODOS los Pedidos (¡PELIGROSO!)
```sql
-- Primero eliminar detalles (por la relación FK)
DELETE FROM detalle_pedidos;

-- Luego eliminar pedidos
DELETE FROM pedidos;

-- Verificar que no queden registros
SELECT COUNT(*) as pedidos_restantes FROM pedidos;
```

## 📅 Eliminar por Fecha
```sql
-- Eliminar pedidos anteriores a una fecha específica
DELETE FROM detalle_pedidos WHERE pedido_id IN (
    SELECT id FROM pedidos WHERE created_at < '2025-01-01'
);
DELETE FROM pedidos WHERE created_at < '2025-01-01';

-- Eliminar pedidos de hoy
DELETE FROM detalle_pedidos WHERE pedido_id IN (
    SELECT id FROM pedidos WHERE DATE(created_at) = CURRENT_DATE
);
DELETE FROM pedidos WHERE DATE(created_at) = CURRENT_DATE;

-- Eliminar pedidos de la última semana
DELETE FROM detalle_pedidos WHERE pedido_id IN (
    SELECT id FROM pedidos WHERE created_at >= CURRENT_DATE - INTERVAL '7 days'
);
DELETE FROM pedidos WHERE created_at >= CURRENT_DATE - INTERVAL '7 days';
```

## 🏷️ Eliminar por Estado
```sql
-- Eliminar pedidos cancelados
DELETE FROM detalle_pedidos WHERE pedido_id IN (
    SELECT id FROM pedidos WHERE estado = 'cancelado'
);
DELETE FROM pedidos WHERE estado = 'cancelado';

-- Eliminar pedidos ya pagados (limpiar historial)
DELETE FROM detalle_pedidos WHERE pedido_id IN (
    SELECT id FROM pedidos WHERE estado = 'pagado'
);
DELETE FROM pedidos WHERE estado = 'pagado';

-- Eliminar pedidos pendientes (si hay errores)
DELETE FROM detalle_pedidos WHERE pedido_id IN (
    SELECT id FROM pedidos WHERE estado = 'pendiente'
);
DELETE FROM pedidos WHERE estado = 'pendiente';
```

## 👤 Eliminar por Cliente
```sql
-- Eliminar pedidos de un cliente específico
DELETE FROM detalle_pedidos WHERE pedido_id IN (
    SELECT id FROM pedidos WHERE cliente_nombre = 'Juan Pérez'
);
DELETE FROM pedidos WHERE cliente_nombre = 'Juan Pérez';

-- Eliminar pedidos que contengan un nombre (búsqueda parcial)
DELETE FROM detalle_pedidos WHERE pedido_id IN (
    SELECT id FROM pedidos WHERE cliente_nombre ILIKE '%María%'
);
DELETE FROM pedidos WHERE cliente_nombre ILIKE '%María%';
```

## 🏠 Eliminar por Mesa
```sql
-- Eliminar pedidos de la mesa 5
DELETE FROM detalle_pedidos WHERE pedido_id IN (
    SELECT p.id FROM pedidos p 
    JOIN mesas m ON p.mesa_id = m.id 
    WHERE m.numero = 5
);
DELETE FROM pedidos WHERE mesa_id IN (
    SELECT id FROM mesas WHERE numero = 5
);

-- Eliminar pedidos de múltiples mesas
DELETE FROM detalle_pedidos WHERE pedido_id IN (
    SELECT p.id FROM pedidos p 
    JOIN mesas m ON p.mesa_id = m.id 
    WHERE m.numero IN (1, 2, 3)
);
DELETE FROM pedidos WHERE mesa_id IN (
    SELECT id FROM mesas WHERE numero IN (1, 2, 3)
);
```

## 🔍 Eliminar por ID Específico
```sql
-- Eliminar un pedido específico por ID
DELETE FROM detalle_pedidos WHERE pedido_id = 'uuid-del-pedido';
DELETE FROM pedidos WHERE id = 'uuid-del-pedido';
```

## 💰 Eliminar por Rango de Precio
```sql
-- Eliminar pedidos con total menor a 10€
DELETE FROM detalle_pedidos WHERE pedido_id IN (
    SELECT id FROM pedidos WHERE total < 10.00
);
DELETE FROM pedidos WHERE total < 10.00;

-- Eliminar pedidos con total entre 50€ y 100€
DELETE FROM detalle_pedidos WHERE pedido_id IN (
    SELECT id FROM pedidos WHERE total BETWEEN 50.00 AND 100.00
);
DELETE FROM pedidos WHERE total BETWEEN 50.00 AND 100.00;
```

## 🔄 Comandos de Verificación (Antes y Después)

### Antes de Eliminar
```sql
-- Ver cuántos pedidos tienes
SELECT COUNT(*) as total_pedidos FROM pedidos;

-- Ver pedidos por estado
SELECT estado, COUNT(*) as cantidad 
FROM pedidos 
GROUP BY estado 
ORDER BY cantidad DESC;

-- Ver pedidos recientes
SELECT id, cliente_nombre, estado, total, created_at 
FROM pedidos 
ORDER BY created_at DESC 
LIMIT 10;
```

### Después de Eliminar
```sql
-- Verificar eliminación
SELECT COUNT(*) as pedidos_restantes FROM pedidos;
SELECT COUNT(*) as detalles_restantes FROM detalle_pedidos;

-- Ver qué pedidos quedan
SELECT estado, COUNT(*) as cantidad 
FROM pedidos 
GROUP BY estado;
```

## ⚡ Comandos Rápidos con Docker

```bash
# Ver pedidos actuales
docker exec bella-vista-postgres psql -U postgres -d bellavista_db -c "SELECT COUNT(*) FROM pedidos;"

# Eliminar todos los pedidos
docker exec bella-vista-postgres psql -U postgres -d bellavista_db -c "DELETE FROM detalle_pedidos; DELETE FROM pedidos;"

# Eliminar pedidos cancelados
docker exec bella-vista-postgres psql -U postgres -d bellavista_db -c "DELETE FROM detalle_pedidos WHERE pedido_id IN (SELECT id FROM pedidos WHERE estado = 'cancelado'); DELETE FROM pedidos WHERE estado = 'cancelado';"
```

## ⚠️ IMPORTANTE
- **Siempre elimina primero `detalle_pedidos`** antes que `pedidos` (por la clave foránea)
- **Haz respaldo** antes de eliminar datos importantes
- **Verifica** los datos antes de eliminar con SELECT
- **Los UUIDs** deben ir entre comillas simples en SQL
