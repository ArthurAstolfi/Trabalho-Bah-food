CREATE TABLE IF NOT EXISTS usuarios (
  id        SERIAL PRIMARY KEY,
  nome      VARCHAR(100) NOT NULL,
  email     VARCHAR(150) UNIQUE NOT NULL,
  telefone  VARCHAR(20),
  perfil    VARCHAR(20) NOT NULL CHECK (perfil IN ('CLIENTE', 'PRESTADOR')),
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS pedidos (
  id               SERIAL PRIMARY KEY,
  cliente_id       INTEGER NOT NULL REFERENCES usuarios(id),
  prestador_id     INTEGER REFERENCES usuarios(id),
  status           VARCHAR(20) NOT NULL DEFAULT 'PENDENTE'
                     CHECK (status IN ('PENDENTE','ACEITO','EM_PREPARO','COLETADO','FINALIZADO','CANCELADO')),
  endereco_entrega TEXT NOT NULL,
  observacao       TEXT,
  total            DECIMAL(10,2) NOT NULL DEFAULT 0,
  created_at       TIMESTAMP DEFAULT NOW(),
  updated_at       TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS itens_pedido (
  id             SERIAL PRIMARY KEY,
  pedido_id      INTEGER NOT NULL REFERENCES pedidos(id) ON DELETE CASCADE,
  nome_item      VARCHAR(200) NOT NULL,
  quantidade     INTEGER NOT NULL DEFAULT 1 CHECK (quantidade > 0),
  preco_unitario DECIMAL(10,2) NOT NULL CHECK (preco_unitario >= 0)
);

CREATE OR REPLACE FUNCTION atualizar_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_pedidos_updated_at
  BEFORE UPDATE ON pedidos
  FOR EACH ROW EXECUTE FUNCTION atualizar_updated_at();
