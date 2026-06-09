const express      = require('express');
const cors         = require('cors');
const usuarioRoutes = require('./routes/usuarioRoutes');
const pedidoRoutes  = require('./routes/pedidoRoutes');
const errorHandler  = require('./middleware/errorHandler');

const app = express();
app.use(cors());
app.use(express.json());

app.get('/health', (req, res) => res.json({ status: 'ok' }));

app.use('/api/usuarios', usuarioRoutes);
app.use('/api/pedidos',  pedidoRoutes);

app.use(errorHandler);

module.exports = app;
