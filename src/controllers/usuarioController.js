const usuarioService = require('../services/usuarioService');

const criar = async (req, res) => {
  const usuario = await usuarioService.criar(req.body);
  res.status(201).json(usuario);
};

const buscarPorId = async (req, res) => {
  const usuario = await usuarioService.buscarPorId(Number(req.params.id));
  res.json(usuario);
};

const buscarPorEmail = async (req, res) => {
  const { email } = req.query;
  const usuario = await usuarioService.buscarPorEmail(email);
  if (!usuario) {
    return res.status(404).json({ error: 'Usuario nao encontrado' });
  }
  res.json(usuario);
};

module.exports = { criar, buscarPorId, buscarPorEmail };
