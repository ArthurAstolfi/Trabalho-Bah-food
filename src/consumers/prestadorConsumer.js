const { getChannel, getExchange } = require('../config/rabbitmq');

const FILA = 'fila.prestador';

const iniciar = async () => {
  const channel  = getChannel();
  const exchange = getExchange();

  await channel.assertQueue(FILA, { durable: true });
  await channel.bindQueue(FILA, exchange, 'pedido.criado');

  channel.prefetch(1);

  channel.consume(FILA, (msg) => {
    if (!msg) return;

    const payload = JSON.parse(msg.content.toString());

    console.log('\n[PRESTADOR] Novo pedido recebido!');
    console.log(`  ID do Pedido : ${payload.pedido_id}`);
    console.log(`  Cliente ID   : ${payload.cliente_id}`);
    console.log(`  Endereço     : ${payload.endereco}`);
    console.log(`  Total        : R$ ${payload.total}`);
    console.log(`  Itens        : ${JSON.stringify(payload.itens)}`);
    console.log(`  Recebido em  : ${payload.timestamp}`);

    channel.ack(msg);
  });

  console.log(`[PrestadorConsumer] Aguardando eventos em "${FILA}" (routing key: pedido.criado)`);
};

module.exports = { iniciar };
