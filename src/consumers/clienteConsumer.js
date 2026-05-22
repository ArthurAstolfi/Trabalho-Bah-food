const { getChannel, getExchange } = require('../config/rabbitmq');

const FILA = 'fila.cliente';

const iniciar = async () => {
  const channel  = getChannel();
  const exchange = getExchange();

  await channel.assertQueue(FILA, { durable: true });
  await channel.bindQueue(FILA, exchange, 'pedido.status.atualizado');

  channel.prefetch(1);

  channel.consume(FILA, (msg) => {
    if (!msg) return;

    const payload = JSON.parse(msg.content.toString());

    console.log('\n[CLIENTE] Status do pedido atualizado!');
    console.log(`  ID do Pedido  : ${payload.pedido_id}`);
    console.log(`  Novo Status   : ${payload.status_novo}`);
    console.log(`  Prestador ID  : ${payload.prestador_id ?? 'N/A'}`);
    console.log(`  Atualizado em : ${payload.timestamp}`);

    channel.ack(msg);
  });

  console.log(`[ClienteConsumer] Aguardando eventos em "${FILA}" (routing key: pedido.status.atualizado)`);
};

module.exports = { iniciar };
