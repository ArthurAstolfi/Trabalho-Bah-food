const { getChannel, getExchange } = require('../config/rabbitmq');

const publicar = (routingKey, payload) => {
  const channel  = getChannel();
  const exchange = getExchange();
  const buffer   = Buffer.from(JSON.stringify(payload));

  channel.publish(exchange, routingKey, buffer, { persistent: true });
  console.log(`[Producer] Evento publicado → [${routingKey}]`, payload);
};

const pedidoCriado = (pedido) => {
  publicar('pedido.criado', {
    evento:       'pedido.criado',
    timestamp:    new Date().toISOString(),
    pedido_id:    pedido.id,
    cliente_id:   pedido.cliente_id,
    endereco:     pedido.endereco_entrega,
    total:        pedido.total,
    itens:        pedido.itens,
  });
};

const pedidoStatusAtualizado = (pedido) => {
  publicar('pedido.status.atualizado', {
    evento:        'pedido.status.atualizado',
    timestamp:     new Date().toISOString(),
    pedido_id:     pedido.id,
    cliente_id:    pedido.cliente_id,
    prestador_id:  pedido.prestador_id,
    status_novo:   pedido.status,
  });
};

module.exports = { pedidoCriado, pedidoStatusAtualizado };
