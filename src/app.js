const express      = require('express');
const usuarioRoutes = require('./routes/usuarioRoutes');
const pedidoRoutes  = require('./routes/pedidoRoutes');
const errorHandler  = require('./middleware/errorHandler');

const app = express();
app.use(express.json());

app.get('/health', (req, res) => res.json({ status: 'ok' }));

app.use('/api/usuarios', usuarioRoutes);
app.use('/api/pedidos',  pedidoRoutes);

app.use(errorHandler);

module.exports = app;
