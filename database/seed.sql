-- Usuarios
INSERT INTO usuarios (nome, email, telefone, perfil) VALUES
  ('Joao Gaucho',       'joao@bahfood.com',   '51999990000', 'CLIENTE'),
  ('Carlos Entregador', 'carlos@bahfood.com', '51988880000', 'PRESTADOR')
ON CONFLICT (email) DO NOTHING;

-- Pedido
INSERT INTO pedidos (cliente_id, prestador_id, status, endereco_entrega, observacao, total) VALUES
  (1, 2, 'ACEITO', 'Rua Borges de Medeiros, 100 - Porto Alegre', 'Sem cebola', 103.80)
ON CONFLICT DO NOTHING;

-- Itens do pedido
INSERT INTO itens_pedido (pedido_id, nome_item, quantidade, preco_unitario) VALUES
  (1, 'Churrasco Gaucho', 2, 45.90),
  (1, 'Chimarrao',        1, 12.00)
ON CONFLICT DO NOTHING;
