# Documentação do Schema — Bah-Food

Banco de dados: **PostgreSQL 16**
Banco: `bahfood`

---

## Tabelas

### `usuarios`

Armazena clientes e prestadores de serviço (entregadores).

| Coluna       | Tipo           | Restrições                              | Descrição                        |
|--------------|----------------|-----------------------------------------|----------------------------------|
| `id`         | SERIAL         | PRIMARY KEY                             | Identificador único              |
| `nome`       | VARCHAR(100)   | NOT NULL                                | Nome completo                    |
| `email`      | VARCHAR(150)   | UNIQUE, NOT NULL                        | E-mail de contato (único)        |
| `telefone`   | VARCHAR(20)    | —                                       | Telefone opcional                |
| `perfil`     | VARCHAR(20)    | NOT NULL, CHECK (CLIENTE ou PRESTADOR)  | Papel do usuário no sistema      |
| `created_at` | TIMESTAMP      | DEFAULT NOW()                           | Data de criação do registro      |

**Perfis aceitos:** `CLIENTE`, `PRESTADOR`

---

### `pedidos`

Representa um pedido feito por um cliente, opcionalmente atribuído a um prestador.

| Coluna              | Tipo           | Restrições                              | Descrição                                      |
|---------------------|----------------|-----------------------------------------|------------------------------------------------|
| `id`                | SERIAL         | PRIMARY KEY                             | Identificador único                            |
| `cliente_id`        | INTEGER        | NOT NULL, FK → usuarios(id)             | Cliente que realizou o pedido                  |
| `prestador_id`      | INTEGER        | FK → usuarios(id)                       | Prestador responsável (preenchido ao aceitar)  |
| `status`            | VARCHAR(20)    | NOT NULL, DEFAULT 'PENDENTE', CHECK     | Status atual do pedido                         |
| `endereco_entrega`  | TEXT           | NOT NULL                                | Endereço de entrega                            |
| `observacao`        | TEXT           | —                                       | Observação opcional do cliente                 |
| `total`             | DECIMAL(10,2)  | NOT NULL, DEFAULT 0                     | Valor total calculado pelos itens              |
| `created_at`        | TIMESTAMP      | DEFAULT NOW()                           | Data de criação                                |
| `updated_at`        | TIMESTAMP      | DEFAULT NOW()                           | Última atualização (mantido por trigger)       |

**Status possíveis e transições:**

```
PENDENTE → ACEITO → EM_PREPARO → COLETADO → FINALIZADO
                                           → CANCELADO (apenas de PENDENTE ou ACEITO)
```

---

### `itens_pedido`

Itens individuais que compõem um pedido.

| Coluna           | Tipo           | Restrições                          | Descrição                         |
|------------------|----------------|-------------------------------------|-----------------------------------|
| `id`             | SERIAL         | PRIMARY KEY                         | Identificador único               |
| `pedido_id`      | INTEGER        | NOT NULL, FK → pedidos(id) CASCADE  | Pedido ao qual o item pertence    |
| `nome_item`      | VARCHAR(200)   | NOT NULL                            | Nome do produto/item              |
| `quantidade`     | INTEGER        | NOT NULL, DEFAULT 1, CHECK > 0      | Quantidade solicitada             |
| `preco_unitario` | DECIMAL(10,2)  | NOT NULL, CHECK >= 0                | Preço unitário do item            |

> A deleção de um pedido remove automaticamente seus itens (`ON DELETE CASCADE`).

---

## Funções e Triggers

### `atualizar_updated_at()`

Função PL/pgSQL chamada automaticamente antes de qualquer `UPDATE` na tabela `pedidos`. Atualiza o campo `updated_at` com o timestamp atual.

### `trigger_pedidos_updated_at`

Trigger vinculado à tabela `pedidos`. Executa `atualizar_updated_at()` para cada linha atualizada (`FOR EACH ROW BEFORE UPDATE`).

---

## Relacionamentos

```
usuarios (1) ──< pedidos (N)   [cliente_id]
usuarios (1) ──< pedidos (N)   [prestador_id]
pedidos  (1) ──< itens_pedido (N)
```
