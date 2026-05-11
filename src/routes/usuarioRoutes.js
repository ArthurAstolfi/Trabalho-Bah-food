const { Router } = require('express');
const usuarioController = require('../controllers/usuarioController');
const pedidoController  = require('../controllers/pedidoController');

const router = Router();

router.post('/',        usuarioController.criar);
router.get('/:id',      usuarioController.buscarPorId);
router.get('/:id/pedidos', pedidoController.listarPorUsuario);

module.exports = router;
