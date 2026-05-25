require('dotenv').config();
const app               = require('./src/app');
const pool              = require('./src/config/database');
const rabbitmq          = require('./src/config/rabbitmq');
const prestadorConsumer = require('./src/consumers/prestadorConsumer');
const clienteConsumer   = require('./src/consumers/clienteConsumer');

const PORT = process.env.PORT || 3000;

const iniciar = async () => {
  const dbClient = await pool.connect();
  dbClient.release();
  console.log('[DB] Conectado ao PostgreSQL');

  await rabbitmq.connect();
  await prestadorConsumer.iniciar();
  await clienteConsumer.iniciar();

  app.listen(PORT, () => console.log(`[HTTP] Servidor rodando em http://localhost:${PORT}`));
};

iniciar().catch((err) => {
  console.error('Falha ao inicializar:', err);
  process.exit(1);
});
