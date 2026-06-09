# Bah-Food 🧉

Plataforma de delivery especializada na culinária tradicional do Rio Grande do Sul, desenvolvida como projeto integrador da disciplina **Laboratório de Desenvolvimento de Aplicações Móveis e Distribuídas** — PUC Minas, Engenharia de Software.

**Aluno:** Arthur Astolfi Cardoso  
**Semestre:** 1º Semestre 2026

---

## Visão Geral da Arquitetura

```
┌─────────────────────┐     HTTP REST      ┌──────────────────────┐
│  App Flutter Cliente│◄──────────────────►│                      │
│  (bah_food_cliente) │                    │   Backend Node.js    │
└─────────────────────┘                    │   Express + REST     │
                                           │   (porta 3000)       │
┌─────────────────────┐     HTTP REST      │                      │
│ App Flutter Prestador◄─────────────────►│                      │
│(bah_food_prestador) │                    └──────────┬───────────┘
└─────────────────────┘                              │
                                                     │
                                          ┌──────────▼───────────┐
                                          │     RabbitMQ (MOM)   │
                                          │  Exchange: bahfood    │
                                          │  (porta 5673)        │
                                          └──────────┬───────────┘
                                                     │
                                          ┌──────────▼───────────┐
                                          │   PostgreSQL         │
                                          │   (porta 5433)       │
                                          └──────────────────────┘
```

---

## Estrutura do Repositório

```
Trabalho-Bah-food/
├── src/                        # Backend Node.js/Express
│   ├── app.js                  # Configuração Express + CORS
│   ├── config/
│   │   ├── database.js         # Pool PostgreSQL
│   │   └── rabbitmq.js         # Conexão RabbitMQ
│   ├── controllers/            # Handlers HTTP
│   ├── services/               # Lógica de negócio
│   ├── repositories/           # Acesso ao banco de dados
│   ├── routes/                 # Rotas Express
│   ├── messaging/
│   │   └── producer.js         # Publicador de eventos RabbitMQ
│   └── consumers/
│       ├── prestadorConsumer.js # Consome pedido.criado
│       └── clienteConsumer.js   # Consome pedido.status.atualizado
├── bah_food_cliente/           # App Flutter – Perfil Cliente
│   └── lib/
│       ├── models/             # Entidades de domínio
│       ├── services/           # Chamadas HTTP
│       ├── providers/          # Estado (ChangeNotifier)
│       ├── screens/            # Telas
│       └── widgets/            # Componentes reutilizáveis
├── bah_food_prestador/         # App Flutter – Perfil Prestador
│   └── lib/  (mesma estrutura)
├── database/
│   ├── schema.sql              # DDL do banco
│   └── seed.sql                # Dados iniciais
├── docker-compose.yml          # PostgreSQL + RabbitMQ
├── index.js                    # Entry point do backend
└── .env.example                # Variáveis de ambiente
```

---

## Pré-requisitos

- **Node.js** 18+
- **Docker Desktop**
- **Flutter SDK** 3.10+ ([flutter.dev](https://flutter.dev))
- **Chrome** (para rodar Flutter Web)

---

## Como Executar

### 1. Subir a infraestrutura (banco + MOM)

```bash
docker-compose up -d
```

Isso inicia:
- PostgreSQL na porta **5433**
- RabbitMQ na porta **5673** (painel em http://localhost:15673 — usuário: guest / senha: guest)

### 2. Configurar variáveis de ambiente

```bash
cp .env.example .env
```

O `.env.example` já vem configurado para o Docker local.

### 3. Instalar dependências e iniciar o backend

```bash
npm install
npm run dev
```

O servidor sobe em **http://localhost:3000**. Você deve ver:
```
[DB] Conectado ao PostgreSQL
[RabbitMQ] Conectado ao broker
[HTTP] Servidor rodando em http://localhost:3000
```

### 4. Rodar o App do Cliente

```bash
cd bah_food_cliente
flutter pub get
flutter run -d chrome
```

### 5. Rodar o App do Prestador

```bash
cd bah_food_prestador
flutter pub get
flutter run -d chrome
```

> **Dica:** abra dois terminais e rode os dois apps simultaneamente para ver o fluxo completo funcionando.

---

## Endpoints da API

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| `GET` | `/health` | Health check |
| `POST` | `/api/usuarios` | Criar usuário (CLIENTE ou PRESTADOR) |
| `GET` | `/api/usuarios/:id` | Buscar usuário por ID |
| `GET` | `/api/usuarios/buscar?email=` | Buscar usuário por e-mail |
| `GET` | `/api/usuarios/:id/pedidos` | Listar pedidos de um usuário |
| `POST` | `/api/pedidos` | Criar novo pedido |
| `GET` | `/api/pedidos` | Listar pedidos (filtros: status, cliente_id, prestador_id) |
| `GET` | `/api/pedidos/:id` | Buscar pedido por ID |
| `PATCH` | `/api/pedidos/:id/status` | Atualizar status do pedido |

---

## Fluxo de Eventos (MOM)

```
Cliente cria pedido
      │
      ▼
Backend → publica evento [pedido.criado]
      │                no Exchange "bahfood"
      ▼
PrestadorConsumer consome [pedido.criado]
      │                da fila "fila.prestador"
      ▼
Prestador aceita pedido
      │
      ▼
Backend → publica evento [pedido.status.atualizado]
      │
      ▼
ClienteConsumer consome [pedido.status.atualizado]
                         da fila "fila.cliente"
```

---

## Coleção Postman

Importe o arquivo `BahFood.postman_collection.json` no Postman para testar todos os endpoints.
