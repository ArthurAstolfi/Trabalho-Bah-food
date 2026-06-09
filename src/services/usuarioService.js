const usuarioRepository = require('../repositories/usuarioRepository');

const PERFIS_VALIDOS = ['CLIENTE', 'PRESTADOR'];

const criar = async ({ nome, email, telefone, perfil }) => {
  if (!nome || !email || !perfil) {
    const err = new Error('Campos obrigatorios: nome, email, perfil');
    err.status = 400;
    throw err;
  }

  if (!PERFIS_VALIDOS.includes(perfil)) {
    const err = new Error(`Perfil invalido. Use: ${PERFIS_VALIDOS.join(', ')}`);
    err.status = 400;
    throw err;
  }

  const existente = await usuarioRepository.findByEmail(email);
  if (existente) {
    const err = new Error('Email ja cadastrado');
    err.status = 409;
    throw err;
  }

  return usuarioRepository.create({ nome, email, telefone, perfil });
};

const buscarPorId = async (id) => {
  const usuario = await usuarioRepository.findById(id);
  if (!usuario) {
    const err = new Error('Usuario nao encontrado');
    err.status = 404;
    throw err;
  }
  return usuario;
};

const buscarPorEmail = async (email) => {
  if (!email) {
    const err = new Error('Campo obrigatorio: email');
    err.status = 400;
    throw err;
  }
  return usuarioRepository.findByEmail(email.toLowerCase());
};

module.exports = { criar, buscarPorId, buscarPorEmail };
