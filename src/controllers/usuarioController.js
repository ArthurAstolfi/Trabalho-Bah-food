const usuarioService = require('../services/usuarioService');

const criar = async (req, res) => {
  const usuario = await usuarioService.criar(req.body);
  res.status(201).json(usuario);
};

const buscarPorId = async (req, res) => {
  const usuario = await usuarioService.buscarPorId(Number(req.params.id));
  res.json(usuario);
};

module.exports = { criar, buscarPorId };
