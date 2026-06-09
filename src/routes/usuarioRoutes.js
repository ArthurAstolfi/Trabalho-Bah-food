const { Router } = require('express');
const usuarioController = require('../controllers/usuarioController');
const pedidoController  = require('../controllers/pedidoController');

const router = Router();

// GET /api/usuarios/buscar?email=xxx  deve vir ANTES de /:id
router.get('/buscar',        usuarioController.buscarPorEmail);
router.post('/',             usuarioController.criar);
router.get('/:id',           usuarioController.buscarPorId);
router.get('/:id/pedidos',   pedidoController.listarPorUsuario);

module.exports = router;
