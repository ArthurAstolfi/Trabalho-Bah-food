require('dotenv').config();
const app  = require('./src/app');
const pool = require('./src/config/database');

const PORT = process.env.PORT || 3000;

pool.connect()
  .then(client => {
    client.release();
    console.log('Conectado ao PostgreSQL');
    app.listen(PORT, () => console.log(`Servidor rodando em http://localhost:${PORT}`));
  })
  .catch(err => {
    console.error('Falha ao conectar ao banco:', err.message);
    process.exit(1);
  });
