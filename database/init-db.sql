-- Bella Vista Restaurant Database Initialization
-- Este script inicializa la base de datos con las tablas necesarias

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Tabla de categorías de platos
CREATE TABLE IF NOT EXISTS categorias (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de platos del menú
CREATE TABLE IF NOT EXISTS platos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10,2) NOT NULL,
    categoria_id INTEGER REFERENCES categorias(id),
    imagen_url VARCHAR(500),
    disponible BOOLEAN DEFAULT true,
    tiempo_preparacion INTEGER DEFAULT 15, -- minutos
    ingredientes TEXT[],
    alergenos TEXT[],
    vegetariano BOOLEAN DEFAULT false,
    vegano BOOLEAN DEFAULT false,
    sin_gluten BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de mesas del restaurante
CREATE TABLE IF NOT EXISTS mesas (
    id SERIAL PRIMARY KEY,
    numero INTEGER NOT NULL UNIQUE,
    capacidad INTEGER NOT NULL,
    ubicacion VARCHAR(100), -- 'terraza', 'interior', 'privada'
    activa BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de pedidos
CREATE TABLE IF NOT EXISTS pedidos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    mesa_id INTEGER REFERENCES mesas(id),
    cliente_nombre VARCHAR(200),
    cliente_telefono VARCHAR(20),
    estado VARCHAR(50) DEFAULT 'pendiente', -- 'pendiente', 'preparando', 'listo', 'servido', 'pagado', 'cancelado'
    total DECIMAL(10,2) DEFAULT 0,
    observaciones TEXT,
    tiempo_estimado INTEGER, -- minutos
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de detalles del pedido
CREATE TABLE IF NOT EXISTS detalle_pedidos (
    id SERIAL PRIMARY KEY,
    pedido_id UUID REFERENCES pedidos(id) ON DELETE CASCADE,
    plato_id INTEGER REFERENCES platos(id),
    cantidad INTEGER NOT NULL DEFAULT 1,
    precio_unitario DECIMAL(10,2) NOT NULL,
    observaciones TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de reservas
CREATE TABLE IF NOT EXISTS reservas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cliente_nombre VARCHAR(200) NOT NULL,
    cliente_telefono VARCHAR(20) NOT NULL,
    cliente_email VARCHAR(200),
    fecha_reserva DATE NOT NULL,
    hora_reserva TIME NOT NULL,
    num_personas INTEGER NOT NULL,
    mesa_id INTEGER REFERENCES mesas(id),
    estado VARCHAR(50) DEFAULT 'confirmada', -- 'pendiente', 'confirmada', 'cancelada', 'completada'
    observaciones TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de usuarios del sistema (para el panel admin)
CREATE TABLE IF NOT EXISTS usuarios (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(200) UNIQUE,
    rol VARCHAR(50) DEFAULT 'empleado', -- 'admin', 'gerente', 'empleado', 'cocinero'
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP
);

-- Insertar datos de ejemplo
INSERT INTO categorias (nombre, descripcion) VALUES 
('Entrantes', 'Deliciosos aperitivos para comenzar'),
('Platos Principales', 'Nuestras especialidades de la casa'),
('Postres', 'Dulces tentaciones para finalizar'),
('Bebidas', 'Refrescantes opciones para acompañar'),
('Vinos', 'Selección de vinos nacionales e internacionales');

INSERT INTO mesas (numero, capacidad, ubicacion) VALUES 
(1, 2, 'interior'),
(2, 4, 'interior'),
(3, 6, 'interior'),
(4, 2, 'terraza'),
(5, 4, 'terraza'),
(6, 8, 'privada'),
(7, 4, 'interior'),
(8, 2, 'terraza'),
(9, 6, 'interior'),
(10, 4, 'ventana')
ON CONFLICT (numero) DO NOTHING;

INSERT INTO platos (nombre, descripcion, precio, categoria_id, tiempo_preparacion, vegetariano, sin_gluten) VALUES 
('Bruschetta de Tomate', 'Pan tostado con tomate fresco, albahaca y aceite de oliva', 8.50, 1, 5, true, false),
('Carpaccio de Ternera', 'Finas láminas de ternera con rúcula y parmesano', 14.90, 1, 10, false, true),
('Risotto de Setas', 'Cremoso risotto con setas de temporada y trufa', 16.80, 2, 25, true, true),
('Salmón a la Plancha', 'Salmón fresco con verduras asadas y salsa de limón', 22.50, 2, 20, false, true),
('Tiramisú Casero', 'El clásico postre italiano con un toque especial', 7.90, 3, 5, true, false),
('Agua Mineral', 'Agua mineral natural 500ml', 2.50, 4, 1, true, true),
('Rioja Crianza', 'Vino tinto D.O. Rioja, cosecha 2019', 18.00, 5, 1, true, true);

-- Crear usuario admin por defecto (password: admin123)
-- En producción, usar hash seguro
INSERT INTO usuarios (username, password_hash, email, rol) VALUES 
('admin', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewYVsLCO9Xq5wjgO', 'admin@bellavista.com', 'admin');

-- Índices para mejorar rendimiento
CREATE INDEX IF NOT EXISTS idx_platos_categoria ON platos(categoria_id);
CREATE INDEX IF NOT EXISTS idx_platos_disponible ON platos(disponible);
CREATE INDEX IF NOT EXISTS idx_pedidos_estado ON pedidos(estado);
CREATE INDEX IF NOT EXISTS idx_pedidos_mesa ON pedidos(mesa_id);
CREATE INDEX IF NOT EXISTS idx_reservas_fecha ON reservas(fecha_reserva);
CREATE INDEX IF NOT EXISTS idx_reservas_estado ON reservas(estado);

-- Función para actualizar timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers para actualizar updated_at automáticamente
CREATE TRIGGER update_platos_updated_at BEFORE UPDATE ON platos
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_pedidos_updated_at BEFORE UPDATE ON pedidos
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_reservas_updated_at BEFORE UPDATE ON reservas
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
