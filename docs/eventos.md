# Documentação dos Eventos – Bah-Food (Sprint 2)

## Infraestrutura MOM

| Propriedade  | Valor                         |
|--------------|-------------------------------|
| Broker       | RabbitMQ 3.13                 |
| Exchange     | `bahfood` (tipo: `topic`)     |
| Protocolo    | AMQP 0-9-1                    |
| Persistência | Mensagens `persistent: true`  |

---

## Filas e Bindings

| Fila             | Exchange  | Routing Key               | Consumidor        |
|------------------|-----------|---------------------------|-------------------|
| `fila.prestador` | `bahfood` | `pedido.criado`           | PrestadorConsumer |
| `fila.cliente`   | `bahfood` | `pedido.status.atualizado`| ClienteConsumer   |

---

## Eventos

### 1. `pedido.criado`

**Produtor:** `pedidoService.criar`  
**Consumidor:** `PrestadorConsumer` (fila `fila.prestador`)  
**Momento:** Imediatamente após a gravação bem-sucedida do pedido no banco.  
**Descrição:** Notifica os entregadores disponíveis que um novo pedido foi realizado e está aguardando aceite.

**Payload de exemplo:**
```json
{
  "evento": "pedido.criado",
  "timestamp": "2026-05-22T14:30:00.000Z",
  "pedido_id": 42,
  "cliente_id": 7,
  "endereco": "Av. Borges de Medeiros, 100 – Porto Alegre/RS",
  "total": "89.90",
  "itens": [
    { "nome_item": "Churrasco Gaúcho", "quantidade": 2, "preco_unitario": "34.90" },
    { "nome_item": "Chimarrão", "quantidade": 1, "preco_unitario": "20.10" }
  ]
}
```

---

### 2. `pedido.status.atualizado`

**Produtor:** `pedidoService.atualizarStatus`  
**Consumidor:** `ClienteConsumer` (fila `fila.cliente`)  
**Momento:** A cada transição de estado do pedido (ACEITO, EM_PREPARO, COLETADO, FINALIZADO, CANCELADO).  
**Descrição:** Notifica o cliente sobre a mudança de estado do seu pedido sem necessidade de polling REST.

**Payload de exemplo:**
```json
{
  "evento": "pedido.status.atualizado",
  "timestamp": "2026-05-22T14:35:00.000Z",
  "pedido_id": 42,
  "cliente_id": 7,
  "prestador_id": 3,
  "status_novo": "ACEITO"
}
```

---

## Fluxo Assíncrono

```
Cliente (REST POST /api/pedidos)
        │
        ▼
  pedidoService.criar()
        │  persiste no PostgreSQL
        │
        ├──► [Producer] publica "pedido.criado" → exchange "bahfood"
        │                          │
        │              ┌───────────▼──────────────┐
        │              │  fila.prestador           │
        │              │  PrestadorConsumer        │
        │              │  → simula notificação     │
        │              │    ao app do entregador   │
        │              └───────────────────────────┘
        ▼
  HTTP 201 retornado ao cliente

Prestador (REST PATCH /api/pedidos/:id/status)
        │
        ▼
  pedidoService.atualizarStatus()
        │  atualiza no PostgreSQL
        │
        ├──► [Producer] publica "pedido.status.atualizado" → exchange "bahfood"
        │                          │
        │              ┌───────────▼──────────────┐
        │              │  fila.cliente             │
        │              │  ClienteConsumer          │
        │              │  → simula notificação     │
        │              │    ao app do cliente      │
        │              └───────────────────────────┘
        ▼
  HTTP 200 retornado ao prestador
```

---

## Relatório de Integração

**Escolha da ferramenta:** RabbitMQ foi escolhido por ser o MOM mais maduro para Node.js/Express, ter suporte nativo a AMQP 0-9-1, oferecer Management UI para monitoramento em tempo real e ser trivialmente containerizável com Docker.

**Padrão utilizado:** Exchange do tipo `topic` com routing keys hierárquicas (`pedido.criado`, `pedido.status.atualizado`). Esse padrão permite que nas Sprints 3 e 4 novos consumidores (ex.: bridge WebSocket para os apps Flutter) se inscrevam em padrões específicos (`pedido.status.*`) sem alterar os produtores.

**Desafios encontrados:**
- Garantir que o canal RabbitMQ esteja disponível antes de qualquer publicação: resolvido inicializando a conexão no bootstrap do `index.js` antes de subir o servidor HTTP.
- Tolerância a falhas na conexão: tratado com listeners de `error` e `close` na conexão AMQP, com log explícito para diagnóstico.
