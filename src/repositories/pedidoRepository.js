const pool = require('../config/database');

const SELECT_COM_ITENS = `
  SELECT
    p.*,
    COALESCE(json_agg(i.*) FILTER (WHERE i.id IS NOT NULL), '[]') AS itens
  FROM pedidos p
  LEFT JOIN itens_pedido i ON i.pedido_id = p.id
`;

const createWithItems = async ({ cliente_id, endereco_entrega, observacao, itens }) => {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    const { rows: [pedido] } = await client.query(
      'INSERT INTO pedidos (cliente_id, endereco_entrega, observacao) VALUES ($1, $2, $3) RETURNING *',
      [cliente_id, endereco_entrega, observacao || null]
    );

    for (const item of itens) {
      await client.query(
        'INSERT INTO itens_pedido (pedido_id, nome_item, quantidade, preco_unitario) VALUES ($1, $2, $3, $4)',
        [pedido.id, item.nome_item, item.quantidade, item.preco_unitario]
      );
    }

    const { rows: [atualizado] } = await client.query(
      `UPDATE pedidos
         SET total = (SELECT COALESCE(SUM(quantidade * preco_unitario), 0) FROM itens_pedido WHERE pedido_id = $1)
       WHERE id = $1
       RETURNING *`,
      [pedido.id]
    );

    await client.query('COMMIT');
    return atualizado;
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
};

const findById = async (id) => {
  const { rows } = await pool.query(
    `${SELECT_COM_ITENS} WHERE p.id = $1 GROUP BY p.id`,
    [id]
  );
  return rows[0] || null;
};

const findAll = async ({ status, cliente_id, prestador_id } = {}) => {
  const params = [];
  const conditions = [];

  if (status) {
    params.push(status);
    conditions.push(`p.status = $${params.length}`);
  }
  if (cliente_id) {
    params.push(Number(cliente_id));
    conditions.push(`p.cliente_id = $${params.length}`);
  }
  if (prestador_id) {
    params.push(Number(prestador_id));
    conditions.push(`p.prestador_id = $${params.length}`);
  }

  const where = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';
  const { rows } = await pool.query(
    `${SELECT_COM_ITENS} ${where} GROUP BY p.id ORDER BY p.created_at DESC`,
    params
  );
  return rows;
};

const updateStatus = async (id, { status, prestador_id }) => {
  if (prestador_id) {
    const { rows } = await pool.query(
      'UPDATE pedidos SET status = $1, prestador_id = $2 WHERE id = $3 RETURNING *',
      [status, prestador_id, id]
    );
    return rows[0] || null;
  }

  const { rows } = await pool.query(
    'UPDATE pedidos SET status = $1 WHERE id = $2 RETURNING *',
    [status, id]
  );
  return rows[0] || null;
};

const findByUsuarioId = async (usuario_id) => {
  const { rows } = await pool.query(
    `${SELECT_COM_ITENS}
     WHERE p.cliente_id = $1 OR p.prestador_id = $1
     GROUP BY p.id ORDER BY p.created_at DESC`,
    [usuario_id]
  );
  return rows;
};

module.exports = { createWithItems, findById, findAll, updateStatus, findByUsuarioId };
