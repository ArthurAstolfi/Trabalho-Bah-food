const pedidoService = require('../services/pedidoService');

const criar = async (req, res) => {
  const pedido = await pedidoService.criar(req.body);
  res.status(201).json(pedido);
};

const listar = async (req, res) => {
  const pedidos = await pedidoService.listar(req.query);
  res.json(pedidos);
};

const buscarPorId = async (req, res) => {
  const pedido = await pedidoService.buscarPorId(Number(req.params.id));
  res.json(pedido);
};

const atualizarStatus = async (req, res) => {
  const pedido = await pedidoService.atualizarStatus(Number(req.params.id), req.body);
  res.json(pedido);
};

const listarPorUsuario = async (req, res) => {
  const pedidos = await pedidoService.listarPorUsuario(Number(req.params.id));
  res.json(pedidos);
};

module.exports = { criar, listar, buscarPorId, atualizarStatus, listarPorUsuario };
