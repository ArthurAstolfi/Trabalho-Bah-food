const pedidoRepository  = require('../repositories/pedidoRepository');
const usuarioRepository = require('../repositories/usuarioRepository');

// Maquina de estados: quais transicoes sao permitidas
const TRANSICOES = {
  PENDENTE:   ['ACEITO', 'CANCELADO'],
  ACEITO:     ['EM_PREPARO', 'CANCELADO'],
  EM_PREPARO: ['COLETADO'],
  COLETADO:   ['FINALIZADO'],
  FINALIZADO: [],
  CANCELADO:  [],
};

const criar = async ({ cliente_id, endereco_entrega, observacao, itens }) => {
  if (!cliente_id || !endereco_entrega || !itens || itens.length === 0) {
    const err = new Error('Campos obrigatorios: cliente_id, endereco_entrega, itens (array nao vazio)');
    err.status = 400;
    throw err;
  }

  const cliente = await usuarioRepository.findById(cliente_id);
  if (!cliente) {
    const err = new Error('Cliente nao encontrado');
    err.status = 404;
    throw err;
  }
  if (cliente.perfil !== 'CLIENTE') {
    const err = new Error('O usuario informado nao e um CLIENTE');
    err.status = 400;
    throw err;
  }

  for (const item of itens) {
    if (!item.nome_item || !item.quantidade || !item.preco_unitario) {
      const err = new Error('Cada item deve ter: nome_item, quantidade, preco_unitario');
      err.status = 400;
      throw err;
    }
  }

  const pedido = await pedidoRepository.createWithItems({
    cliente_id,
    endereco_entrega,
    observacao,
    itens,
  });

  return pedidoRepository.findById(pedido.id);
};

const listar = async ({ status, cliente_id } = {}) => {
  return pedidoRepository.findAll({ status, cliente_id });
};

const buscarPorId = async (id) => {
  const pedido = await pedidoRepository.findById(id);
  if (!pedido) {
    const err = new Error('Pedido nao encontrado');
    err.status = 404;
    throw err;
  }
  return pedido;
};

const atualizarStatus = async (id, { status, prestador_id }) => {
  if (!status) {
    const err = new Error('Campo obrigatorio: status');
    err.status = 400;
    throw err;
  }

  const pedido = await pedidoRepository.findById(id);
  if (!pedido) {
    const err = new Error('Pedido nao encontrado');
    err.status = 404;
    throw err;
  }

  const transicoesPossiveis = TRANSICOES[pedido.status] || [];
  if (!transicoesPossiveis.includes(status)) {
    const err = new Error(
      `Transicao invalida: ${pedido.status} → ${status}. Permitidas: ${transicoesPossiveis.join(', ') || 'nenhuma'}`
    );
    err.status = 422;
    throw err;
  }

  // Ao aceitar, o prestador_id e obrigatorio
  if (status === 'ACEITO') {
    if (!prestador_id) {
      const err = new Error('Campo obrigatorio para aceitar: prestador_id');
      err.status = 400;
      throw err;
    }
    const prestador = await usuarioRepository.findById(prestador_id);
    if (!prestador || prestador.perfil !== 'PRESTADOR') {
      const err = new Error('Prestador nao encontrado ou perfil incorreto');
      err.status = 404;
      throw err;
    }
  }

  return pedidoRepository.updateStatus(id, { status, prestador_id });
};

const listarPorUsuario = async (usuario_id) => {
  const usuario = await usuarioRepository.findById(usuario_id);
  if (!usuario) {
    const err = new Error('Usuario nao encontrado');
    err.status = 404;
    throw err;
  }
  return pedidoRepository.findByUsuarioId(usuario_id);
};

module.exports = { criar, listar, buscarPorId, atualizarStatus, listarPorUsuario };
