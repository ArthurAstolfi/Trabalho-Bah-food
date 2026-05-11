const pool = require('../config/database');

const create = async ({ nome, email, telefone, perfil }) => {
  const { rows } = await pool.query(
    'INSERT INTO usuarios (nome, email, telefone, perfil) VALUES ($1, $2, $3, $4) RETURNING *',
    [nome, email, telefone || null, perfil]
  );
  return rows[0];
};

const findById = async (id) => {
  const { rows } = await pool.query('SELECT * FROM usuarios WHERE id = $1', [id]);
  return rows[0] || null;
};

const findByEmail = async (email) => {
  const { rows } = await pool.query('SELECT * FROM usuarios WHERE email = $1', [email]);
  return rows[0] || null;
};

module.exports = { create, findById, findByEmail };
