const amqp = require('amqplib');

const RABBITMQ_URL = process.env.RABBITMQ_URL || 'amqp://localhost';
const EXCHANGE     = 'bahfood';

let connection = null;
let channel    = null;

const connect = async () => {
  connection = await amqp.connect(RABBITMQ_URL);
  channel    = await connection.createChannel();

  await channel.assertExchange(EXCHANGE, 'topic', { durable: true });

  connection.on('error', (err) => {
    console.error('[RabbitMQ] Erro na conexão:', err.message);
  });
  connection.on('close', () => {
    console.warn('[RabbitMQ] Conexão encerrada');
  });

  console.log('[RabbitMQ] Conectado ao broker');
  return channel;
};

const getChannel = () => {
  if (!channel) throw new Error('Canal RabbitMQ não inicializado. Chame connect() primeiro.');
  return channel;
};

const getExchange = () => EXCHANGE;

module.exports = { connect, getChannel, getExchange };
