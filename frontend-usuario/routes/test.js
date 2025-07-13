const express = require('express');
const router = express.Router();

// Ruta de test para debugging
router.get('/test', (req, res) => {
    const testData = {
        title: 'Test - Debugging',
        destacados: [
            { id: 1, nombre: 'Test Pizza', descripcion: 'Pizza de prueba', precio: 10.99, imagen: '🍕' },
            { id: 2, nombre: 'Test Burger', descripcion: 'Burger de prueba', precio: 8.99, imagen: '🍔' },
            { id: 3, nombre: 'Test Pasta', descripcion: 'Pasta de prueba', precio: 12.50, imagen: '🍝' }
        ],
        productos: [
            { id: 1, nombre: 'Test Pizza', descripcion: 'Pizza de prueba', precio: 10.99, imagen: '🍕', categoria_id: 1 },
            { id: 2, nombre: 'Test Burger', descripcion: 'Burger de prueba', precio: 8.99, imagen: '🍔', categoria_id: 2 },
            { id: 3, nombre: 'Test Pasta', descripcion: 'Pasta de prueba', precio: 12.50, imagen: '🍝', categoria_id: 3 }
        ],
        categorias: [
            { id: 1, nombre: 'Pizzas' },
            { id: 2, nombre: 'Burgers' },
            { id: 3, nombre: 'Pastas' }
        ]
    };
    
    res.render('test', testData);
});

module.exports = router;
