const express = require('express');
const cors = require('cors');
const path = require('path');
const { Pool } = require('pg');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Configuración de PostgreSQL
const pool = new Pool({
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    database: process.env.DB_NAME,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
});

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, 'public')));

// Motor de plantillas
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// Variables para métricas
let metrics = {
    requests_total: 0,
    menu_views: 0,
    orders_submitted: 0,
    errors_total: 0,
    uptime_start: Date.now()
};

// Middleware para contar requests
app.use((req, res, next) => {
    metrics.requests_total++;
    next();
});

// Función para probar conexión a BD
async function testConnection() {
    try {
        const client = await pool.connect();
        const result = await client.query('SELECT NOW()');
        console.log('✅ Conectado a PostgreSQL:', result.rows[0].now);
        client.release();
        return true;
    } catch (err) {
        console.error('❌ Error conectando a PostgreSQL:', err.message);
        return false;
    }
}

// RUTAS

// Página principal - Menú
app.get('/', async (req, res) => {
    metrics.menu_views++; // Contador de vistas del menú
    try {
        // Intentar obtener datos de la base de datos
        const client = await pool.connect();
        
        try {
            // Obtener categorías
            const categoriasResult = await client.query(`
                SELECT id, nombre, descripcion 
                FROM categorias 
                WHERE activo = true 
                ORDER BY id
            `);
            
            // Obtener platos
            const platosResult = await client.query(`
                SELECT id, nombre, descripcion, precio, categoria_id, imagen_url, disponible, tiempo_preparacion
                FROM platos 
                WHERE disponible = true 
                ORDER BY categoria_id, nombre
            `);
            
            const categorias = categoriasResult.rows;
            const productos = platosResult.rows;
            
            // Si no hay datos en BD, usar datos de demostración
            if (categorias.length === 0 || productos.length === 0) {
                console.log('⚠️ No hay datos en BD, usando datos de demostración');
                const categoriasDemo = menuDemo.categorias;
                const productosDemo = menuDemo.platos;
                const destacadosDemo = productosDemo.filter(p => p.destacado);
                
                client.release();
                return res.render('index', {
                    title: 'Bella Vista - Menú',
                    categorias: categoriasDemo,
                    productos: productosDemo,
                    destacados: destacadosDemo,
                    usandoDatosDemo: true
                });
            }
            
            // Simular destacados (primeros 6 platos)
            const destacados = productos.slice(0, 6);
            
            client.release();
            
            res.render('index', {
                title: 'Bella Vista - Menú',
                categorias: categorias,
                productos: productos,
                destacados: destacados,
                usandoDatosDemo: false
            });
            
        } catch (dbError) {
            client.release();
            throw dbError;
        }
        
    } catch (error) {
        metrics.errors_total++; // Contador de errores
        console.error('Error obteniendo menú:', error);
        
        // Fallback a datos de demostración
        console.log('🔄 Fallback: usando datos de demostración');
        const categorias = menuDemo.categorias;
        const productos = menuDemo.platos;
        const destacados = productos.filter(p => p.destacado);
        
        res.render('index', {
            title: 'Bella Vista - Menú',
            categorias: categorias,
            productos: productos,
            destacados: destacados,
            usandoDatosDemo: true
        });
    }
});

// API - Obtener menú
app.get('/api/menu', async (req, res) => {
    try {
        const categoria = req.query.categoria;
        
        // Intentar obtener datos de la base de datos
        const client = await pool.connect();
        
        try {
            // Obtener categorías
            const categoriasResult = await client.query(`
                SELECT id, nombre, descripcion 
                FROM categorias 
                WHERE activo = true 
                ORDER BY id
            `);
            
            // Construir query para platos con filtro opcional por categoría
            let platosQuery = `
                SELECT id, nombre, descripcion, precio, categoria_id, imagen_url, disponible, tiempo_preparacion
                FROM platos 
                WHERE disponible = true
            `;
            let queryParams = [];
            
            if (categoria && categoria !== 'null' && categoria !== 'undefined') {
                platosQuery += ` AND categoria_id = $1`;
                queryParams.push(categoria);
            }
            
            platosQuery += ` ORDER BY categoria_id, nombre`;
            
            const platosResult = await client.query(platosQuery, queryParams);
            
            const categorias = categoriasResult.rows;
            const productos = platosResult.rows;
            
            client.release();
            
            // Si no hay datos en BD, usar datos de demostración
            if (categorias.length === 0 || productos.length === 0) {
                console.log('⚠️ API: No hay datos en BD, usando datos de demostración');
                let productosDemo = menuDemo.platos;
                
                // Filtrar por categoría si se especifica
                if (categoria && categoria !== 'null' && categoria !== 'undefined') {
                    productosDemo = productosDemo.filter(p => p.categoria_id == categoria);
                }
                
                return res.json({
                    success: true,
                    categorias: menuDemo.categorias,
                    productos: productosDemo,
                    usandoDatosDemo: true
                });
            }
            
            res.json({
                success: true,
                categorias: categorias,
                productos: productos,
                usandoDatosDemo: false
            });
            
        } catch (dbError) {
            client.release();
            throw dbError;
        }
        
    } catch (error) {
        console.error('Error obteniendo API menú:', error);
        
        // Fallback a datos de demostración
        console.log('🔄 API Fallback: usando datos de demostración');
        const categoria = req.query.categoria;
        let productos = menuDemo.platos;
        
        // Filtrar por categoría si se especifica
        if (categoria && categoria !== 'null' && categoria !== 'undefined') {
            productos = productos.filter(p => p.categoria_id == categoria);
        }
        
        res.json({
            success: true,
            categorias: menuDemo.categorias,
            productos: productos,
            usandoDatosDemo: true
        });
    }
});

// API - Obtener categorías
app.get('/api/categorias', async (req, res) => {
    try {
        // Intentar obtener datos de la base de datos
        const client = await pool.connect();
        
        try {
            const result = await client.query(`
                SELECT id, nombre, descripcion 
                FROM categorias 
                WHERE activo = true 
                ORDER BY id
            `);
            
            client.release();
            
            // Si no hay datos en BD, usar datos de demostración
            if (result.rows.length === 0) {
                console.log('⚠️ API Categorías: No hay datos en BD, usando datos de demostración');
                return res.json({
                    success: true,
                    categorias: menuDemo.categorias,
                    usandoDatosDemo: true
                });
            }
            
            res.json({
                success: true,
                categorias: result.rows,
                usandoDatosDemo: false
            });
            
        } catch (dbError) {
            client.release();
            throw dbError;
        }
        
    } catch (error) {
        console.error('Error obteniendo categorías:', error);
        
        // Fallback a datos de demostración
        console.log('🔄 API Categorías Fallback: usando datos de demostración');
        res.json({
            success: true,
            categorias: menuDemo.categorias,
            usandoDatosDemo: true
        });
    }
});

// Página de pedidos
app.get('/pedido', (req, res) => {
    res.render('pedido', {
        title: 'Realizar Pedido'
    });
});

// API - Crear pedido
app.post('/api/pedidos', async (req, res) => {
    metrics.orders_submitted++; // Contador de pedidos enviados
    const client = await pool.connect();
    
    try {
        await client.query('BEGIN');
        
        const { numero_mesa, cliente_nombre, items, notas } = req.body;
        
        // Validaciones
        if (!numero_mesa || !items || !Array.isArray(items) || items.length === 0) {
            return res.status(400).json({
                success: false,
                message: 'Faltan campos requeridos: numero_mesa, items'
            });
        }
        
        // Buscar o crear la mesa
        let mesaResult = await client.query(
            'SELECT id FROM mesas WHERE numero = $1 AND activa = true',
            [numero_mesa]
        );
        
        let mesaId;
        if (mesaResult.rows.length === 0) {
            // Crear la mesa si no existe
            const nuevaMesa = await client.query(
                'INSERT INTO mesas (numero, capacidad, ubicacion) VALUES ($1, 4, $2) RETURNING id',
                [numero_mesa, 'interior']
            );
            mesaId = nuevaMesa.rows[0].id;
        } else {
            mesaId = mesaResult.rows[0].id;
        }
        
        // Crear el pedido
        const pedidoResult = await client.query(`
            INSERT INTO pedidos (mesa_id, cliente_nombre, observaciones, estado)
            VALUES ($1, $2, $3, 'pendiente')
            RETURNING id
        `, [mesaId, cliente_nombre || 'Cliente', notas || '']);
        
        const pedidoId = pedidoResult.rows[0].id;
        
        let total = 0;
        
        // Insertar items del pedido
        for (const item of items) {
            const { producto_id, cantidad, notas_item } = item;
            
            // Obtener precio del producto
            const productoResult = await client.query(
                'SELECT precio, nombre FROM platos WHERE id = $1 AND disponible = true',
                [producto_id]
            );
            
            if (productoResult.rows.length === 0) {
                throw new Error(`Producto con ID ${producto_id} no disponible`);
            }
            
            const precio = productoResult.rows[0].precio;
            const subtotal = precio * cantidad;
            total += subtotal;
            
            await client.query(`
                INSERT INTO detalle_pedidos (pedido_id, plato_id, cantidad, precio_unitario, observaciones)
                VALUES ($1, $2, $3, $4, $5)
            `, [pedidoId, producto_id, cantidad, precio, notas_item || '']);
        }
        
        // Actualizar total del pedido
        await client.query(
            'UPDATE pedidos SET total = $1 WHERE id = $2',
            [total, pedidoId]
        );
        
        await client.query('COMMIT');
        
        res.json({
            success: true,
            message: 'Pedido creado exitosamente',
            pedido: {
                id: pedidoId,
                numero_pedido: pedidoId, // Usando el UUID como número de pedido
                total: total
            }
        });
        
    } catch (error) {
        await client.query('ROLLBACK');
        console.error('Error creando pedido:', error);
        res.status(500).json({
            success: false,
            message: error.message
        });
    } finally {
        client.release();
    }
});

// RUTAS TEMPORALMENTE DESHABILITADAS (requieren BD)
/*
// Página de seguimiento
app.get('/seguimiento/:numero_pedido', async (req, res) => {
    try {
        const numeroPedido = req.params.numero_pedido;
        
        const result = await pool.query(`
            SELECT 
                p.id,
                p.numero_pedido,
                p.numero_mesa,
                p.cliente_nombre,
                p.estado,
                p.total,
                p.created_at,
                p.updated_at,
                JSON_AGG(
                    JSON_BUILD_OBJECT(
                        'producto', pr.nombre,
                        'cantidad', pi.cantidad,
                        'precio', pi.precio_unitario,
                        'notas', pi.notas_item
                    )
                ) as items
            FROM pedidos p
            LEFT JOIN pedido_items pi ON p.id = pi.pedido_id
            LEFT JOIN productos pr ON pi.producto_id = pr.id
            WHERE p.numero_pedido = $1
            GROUP BY p.id
        `, [numeroPedido]);
        
        if (result.rows.length === 0) {
            return res.render('error', {
                title: 'Pedido no encontrado',
                message: `No se encontró el pedido #${numeroPedido}`
            });
        }
        
        res.render('seguimiento', {
            title: `Seguimiento - Pedido #${numeroPedido}`,
            pedido: result.rows[0]
        });
        
    } catch (error) {
        console.error('Error obteniendo pedido:', error);
        res.render('error', {
            title: 'Error',
            message: 'Error obteniendo información del pedido'
        });
    }
});
*/

// Página de seguimiento (versión simplificada)
app.get('/seguimiento/:numero_pedido', (req, res) => {
    const numeroPedido = req.params.numero_pedido;
    res.render('seguimiento', {
        title: `Seguimiento - Pedido #${numeroPedido}`,
        pedido: {
            numero_pedido: numeroPedido,
            estado: 'En preparación',
            total: 45.50,
            cliente_nombre: 'Cliente Demo',
            items: [
                { producto: 'Salmón a la Parrilla', cantidad: 1, precio: 28.50 },
                { producto: 'Tiramisú Artesanal', cantidad: 2, precio: 8.50 }
            ]
        }
    });
});

// API - Estado del pedido
app.get('/api/pedidos/:numero_pedido', async (req, res) => {
    try {
        const numeroPedido = req.params.numero_pedido;
        
        const result = await pool.query(`
            SELECT estado, updated_at
            FROM pedidos
            WHERE numero_pedido = $1
        `, [numeroPedido]);
        
        if (result.rows.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Pedido no encontrado'
            });
        }
        
        res.json({
            success: true,
            estado: result.rows[0].estado,
            updated_at: result.rows[0].updated_at
        });
        
    } catch (error) {
        console.error('Error obteniendo estado del pedido:', error);
        res.status(500).json({
            success: false,
            message: 'Error obteniendo estado del pedido'
        });
    }
});

// Datos de menú de ejemplo (para demostración)
const menuDemo = {
    categorias: [
        { id: 1, nombre: "Entradas", descripcion: "Aperitivos deliciosos", icono: "🥗" },
        { id: 2, nombre: "Platos Principales", descripcion: "Nuestras especialidades", icono: "🍖" },
        { id: 3, nombre: "Pastas", descripcion: "Pasta fresca italiana", icono: "🍝" },
        { id: 4, nombre: "Postres", descripcion: "Dulces tentaciones", icono: "🍰" },
        { id: 5, nombre: "Bebidas", descripcion: "Refrescantes y especiales", icono: "🍹" }
    ],
    platos: [
        // Entradas
        { id: 1, nombre: "Bruschetta Mediterránea", descripcion: "Pan tostado con tomate, albahaca fresca y aceite de oliva", precio: 12.50, categoria_id: 1, imagen: "🥖", destacado: true },
        { id: 2, nombre: "Tabla de Quesos Artesanales", descripcion: "Selección de quesos locales con frutos secos y miel", precio: 18.00, categoria_id: 1, imagen: "🧀", destacado: false },
        { id: 3, nombre: "Ceviche de Pescado", descripcion: "Pescado fresco marinado en limón con cebolla morada", precio: 16.00, categoria_id: 1, imagen: "🐟", destacado: true },
        
        // Platos Principales
        { id: 4, nombre: "Salmón a la Parrilla", descripcion: "Salmón fresco con vegetales asados y salsa de limón", precio: 28.50, categoria_id: 2, imagen: "🐟", destacado: true },
        { id: 5, nombre: "Ribeye Premium", descripcion: "Corte premium de 300g con papas rústicas y chimichurri", precio: 35.00, categoria_id: 2, imagen: "🥩", destacado: true },
        { id: 6, nombre: "Pollo Mediterráneo", descripcion: "Pechuga de pollo con hierbas, tomates cherry y aceitunas", precio: 22.00, categoria_id: 2, imagen: "🍗", destacado: false },
        
        // Pastas
        { id: 7, nombre: "Pasta Carbonara Clásica", descripcion: "Spaghetti con panceta, huevo, parmesano y pimienta negra", precio: 19.50, categoria_id: 3, imagen: "🍝", destacado: true },
        { id: 8, nombre: "Ravioli de Espinaca", descripcion: "Pasta rellena de espinaca y ricotta con salsa de mantequilla", precio: 21.00, categoria_id: 3, imagen: "🥟", destacado: false },
        { id: 9, nombre: "Lasaña de la Casa", descripcion: "Lasaña tradicional con carne, bechamel y queso gratinado", precio: 24.00, categoria_id: 3, imagen: "🍝", destacado: true },
        
        // Postres
        { id: 10, nombre: "Tiramisú Artesanal", descripcion: "Postre italiano con café, mascarpone y cacao", precio: 8.50, categoria_id: 4, imagen: "🍰", destacado: true },
        { id: 11, nombre: "Cheesecake de Frutos Rojos", descripcion: "Cremoso cheesecake con mermelada casera de frutos rojos", precio: 9.00, categoria_id: 4, imagen: "🍓", destacado: false },
        { id: 12, nombre: "Volcán de Chocolate", descripcion: "Bizcocho de chocolate caliente con centro líquido", precio: 10.50, categoria_id: 4, imagen: "🍫", destacado: true },
        
        // Bebidas
        { id: 13, nombre: "Sangría de la Casa", descripcion: "Sangría tradicional con frutas frescas", precio: 7.50, categoria_id: 5, imagen: "🍷", destacado: false },
        { id: 14, nombre: "Limonada Artesanal", descripcion: "Limonada fresca con hierbas aromáticas", precio: 5.50, categoria_id: 5, imagen: "🍋", destacado: false },
        { id: 15, nombre: "Café Espresso Premium", descripcion: "Café de origen único, tostado artesanalmente", precio: 4.00, categoria_id: 5, imagen: "☕", destacado: true }
    ]
};

// Endpoint de métricas para Prometheus
app.get('/metrics', async (req, res) => {
    try {
        const uptime_seconds = Math.floor((Date.now() - metrics.uptime_start) / 1000);
        
        // Obtener estadísticas de la base de datos
        let total_orders = 0;
        let total_revenue = 0;
        let db_connections = 0;
        
        try {
            const client = await pool.connect();
            
            // Contar pedidos
            const ordersResult = await client.query('SELECT COUNT(*) as count, COALESCE(SUM(total), 0) as revenue FROM pedidos');
            total_orders = parseInt(ordersResult.rows[0].count) || 0;
            total_revenue = parseFloat(ordersResult.rows[0].revenue) || 0;
            
            // Contar conexiones activas
            const connResult = await client.query('SELECT COUNT(*) as count FROM pg_stat_activity WHERE state = $1', ['active']);
            db_connections = parseInt(connResult.rows[0].count) || 0;
            
            client.release();
        } catch (dbError) {
            console.error('Error obteniendo métricas de BD:', dbError);
            metrics.errors_total++;
        }
        
        // Generar métricas en formato Prometheus
        const prometheusMetrics = `# HELP http_requests_total Total number of HTTP requests
# TYPE http_requests_total counter
http_requests_total ${metrics.requests_total}

# HELP menu_views_total Total number of menu page views
# TYPE menu_views_total counter
menu_views_total ${metrics.menu_views}

# HELP orders_submitted_total Total number of orders submitted
# TYPE orders_submitted_total counter
orders_submitted_total ${metrics.orders_submitted}

# HELP orders_total Total number of orders in database
# TYPE orders_total gauge
orders_total ${total_orders}

# HELP revenue_total Total revenue in euros
# TYPE revenue_total gauge
revenue_total ${total_revenue}

# HELP database_connections_active Active database connections
# TYPE database_connections_active gauge
database_connections_active ${db_connections}

# HELP errors_total Total number of errors
# TYPE errors_total counter
errors_total ${metrics.errors_total}

# HELP uptime_seconds Application uptime in seconds
# TYPE uptime_seconds gauge
uptime_seconds ${uptime_seconds}

# HELP nodejs_version_info Node.js version information
# TYPE nodejs_version_info gauge
nodejs_version_info{version="${process.version}"} 1
`;

        res.set('Content-Type', 'text/plain');
        res.send(prometheusMetrics);
        
    } catch (error) {
        console.error('Error generando métricas:', error);
        metrics.errors_total++;
        res.status(500).send('Error generando métricas');
    }
});

// Manejo de errores 404
app.use((req, res) => {
    res.status(404).render('error', {
        title: 'Página no encontrada',
        message: 'La página que buscas no existe'
    });
});

// Iniciar servidor
async function startServer() {
    const connected = await testConnection();
    
    app.listen(PORT, () => {
        console.log(`🍽️ Bella Vista Frontend Usuario ejecutándose en http://localhost:${PORT}`);
        console.log(`📊 Estado de la base de datos: ${connected ? '✅ Conectada' : '❌ Sin conexión'}`);
        console.log(`📋 Rutas disponibles:`);
        console.log(`   🏠 GET  /                    - Página principal (menú)`);
        console.log(`   🛒 GET  /pedido              - Página de pedidos`);
        console.log(`   📊 GET  /seguimiento/:numero - Seguimiento de pedido`);
        console.log(`   📡 GET  /api/menu            - API del menú`);
        console.log(`   📡 GET  /api/categorias      - API de categorías`);
        console.log(`   📡 POST /api/pedidos         - API crear pedido`);
        console.log(`   📡 GET  /api/pedidos/:numero - API estado pedido`);
    });
}

startServer();
