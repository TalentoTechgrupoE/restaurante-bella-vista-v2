-- Migration: Ajustar esquema para compatibilidad con frontend-usuario
-- Ejecutar después de init-db.sql

-- 1. Agregar tabla de productos (alias para platos)
CREATE OR REPLACE VIEW productos AS
SELECT 
    id,
    nombre,
    descripcion,
    precio,
    categoria_id,
    imagen_url,
    disponible,
    tiempo_preparacion,
    ingredientes,
    vegetariano,
    vegano,
    sin_gluten,
    created_at,
    updated_at
FROM platos;

-- 2. Ajustar tabla de categorías para incluir orden
ALTER TABLE categorias ADD COLUMN IF NOT EXISTS orden INTEGER DEFAULT 1;

-- Actualizar orden de categorías existentes
UPDATE categorias SET orden = 1 WHERE nombre = 'Entrantes';
UPDATE categorias SET orden = 2 WHERE nombre = 'Platos Principales';
UPDATE categorias SET orden = 3 WHERE nombre = 'Postres';
UPDATE categorias SET orden = 4 WHERE nombre = 'Bebidas';
UPDATE categorias SET orden = 5 WHERE nombre = 'Vinos';

-- 3. Crear tabla pedidos compatible con frontend
DROP TABLE IF EXISTS pedido_items CASCADE;

CREATE TABLE pedidos_frontend (
    id SERIAL PRIMARY KEY,
    numero_pedido VARCHAR(50) UNIQUE NOT NULL DEFAULT 'P' || LPAD(nextval('pedidos_frontend_id_seq')::text, 6, '0'),
    numero_mesa INTEGER NOT NULL,
    cliente_nombre VARCHAR(200) DEFAULT 'Cliente',
    notas TEXT,
    estado VARCHAR(50) DEFAULT 'pendiente',
    total DECIMAL(10,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE pedido_items (
    id SERIAL PRIMARY KEY,
    pedido_id INTEGER REFERENCES pedidos_frontend(id) ON DELETE CASCADE,
    producto_id INTEGER REFERENCES platos(id),
    cantidad INTEGER NOT NULL DEFAULT 1,
    precio_unitario DECIMAL(10,2) NOT NULL,
    notas_item TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Crear vista para compatibilidad con el frontend
CREATE OR REPLACE VIEW pedidos AS
SELECT * FROM pedidos_frontend;

-- 5. Insertar algunos platos adicionales con imágenes
INSERT INTO platos (nombre, descripcion, precio, categoria_id, imagen_url, tiempo_preparacion, vegetariano, sin_gluten) VALUES 
('Ensalada César', 'Lechuga romana, pollo, crutones, parmesano y aderezo césar', 12.90, 1, '/images/ensalada-cesar.jpg', 8, false, false),
('Paella Valenciana', 'Arroz con pollo, conejo, judía verde, garrofón y azafrán', 24.90, 2, '/images/paella.jpg', 35, false, true),
('Lasaña de la Casa', 'Lasaña casera con carne, bechamel y queso gratinado', 15.90, 2, '/images/lasana.jpg', 30, false, false),
('Tarta de Queso', 'Tarta de queso cremosa con coulis de frutos rojos', 6.90, 3, '/images/tarta-queso.jpg', 5, true, false),
('Sangría de la Casa', 'Refrescante sangría con frutas de temporada', 4.50, 4, '/images/sangria.jpg', 3, true, true),
('Agua con Gas', 'Agua mineral con gas 500ml', 2.80, 4, '/images/agua-gas.jpg', 1, true, true);

-- 6. Crear función para generar número de pedido automático
CREATE OR REPLACE FUNCTION generate_pedido_number()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.numero_pedido IS NULL OR NEW.numero_pedido = '' THEN
        NEW.numero_pedido := 'P' || LPAD(NEW.id::text, 6, '0');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_generate_pedido_number
    BEFORE INSERT ON pedidos_frontend
    FOR EACH ROW
    EXECUTE FUNCTION generate_pedido_number();

-- 7. Trigger para actualizar updated_at en pedidos_frontend
CREATE TRIGGER update_pedidos_frontend_updated_at 
    BEFORE UPDATE ON pedidos_frontend
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 8. Insertar datos de prueba
INSERT INTO pedidos_frontend (numero_mesa, cliente_nombre, notas, estado, total)
VALUES (1, 'Juan Pérez', 'Sin cebolla, por favor', 'preparando', 25.40);

INSERT INTO pedido_items (pedido_id, producto_id, cantidad, precio_unitario, notas_item)
VALUES 
(1, 1, 2, 8.50, ''),
(1, 4, 1, 22.50, 'Término medio');

COMMIT;
