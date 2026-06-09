# Sprint 3 – App Flutter do Cliente

**Projeto:** Bah-Food  
**Disciplina:** Lab. de Desenvolvimento de Aplicações Móveis e Distribuídas  
**Aluno:** Arthur Astolfi Cardoso  
**Data:** 09/06/2026  

---

## 1. Objetivo

Desenvolver o aplicativo móvel Flutter para o usuário **Cliente**, com integração funcional ao backend REST (Node.js/Express) e atualização assíncrona de estado via polling periódico de 5 segundos.

---

## 2. Telas Implementadas

O app possui **5 telas** cobrindo o fluxo completo do cliente:

| Tela | Descrição |
|------|-----------|
| `LoginScreen` | Autenticação/cadastro por nome + e-mail. Cria conta automaticamente se não existir. |
| `HomeScreen` | Shell de navegação com `BottomNavigationBar` e `AppBar` com carrinho. |
| `CardapioScreen` | Listagem de 8 itens típicos gaúchos com controle de quantidade. |
| `CarrinhoScreen` | Resumo do carrinho, campo de endereço/observação e confirmação de pedido. |
| `MeusPedidosScreen` | Histórico de pedidos com **polling automático a cada 5s**. |
| `DetalhePedidoScreen` | Detalhes do pedido, linha do tempo visual e **polling automático a cada 5s**. |

---

## 3. Arquitetura Clean Architecture

```
bah_food_cliente/lib/
│
├── models/                  ← Entidades de domínio (sem dependência de Flutter)
│   ├── usuario.dart         ← Entidade Usuário
│   ├── pedido.dart          ← Entidade Pedido (com lista de ItemPedido)
│   ├── item_pedido.dart     ← Entidade Item do Pedido
│   └── cardapio_item.dart   ← Entidade Item do Cardápio + dados estáticos
│
├── services/                ← Camada de acesso a dados (chamadas HTTP)
│   └── api_service.dart     ← Todos os endpoints REST do backend
│
├── providers/               ← Gerenciamento de estado (Application Layer)
│   ├── auth_provider.dart   ← Estado de autenticação (ChangeNotifier)
│   └── carrinho_provider.dart ← Estado do carrinho (ChangeNotifier)
│
├── screens/                 ← Páginas completas (Presentation Layer)
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── cardapio_screen.dart
│   ├── meus_pedidos_screen.dart
│   ├── carrinho_screen.dart
│   └── detalhe_pedido_screen.dart
│
└── widgets/                 ← Componentes reutilizáveis
    ├── item_cardapio_card.dart  ← Card de item do cardápio
    ├── pedido_card.dart         ← Card de pedido na listagem
    └── pedido_status_badge.dart ← Badge colorido de status
```

### Diagrama de Camadas

```
┌─────────────────────────────────────────────────────┐
│                   PRESENTATION                      │
│  screens/ (Telas)      widgets/ (Componentes UI)    │
├─────────────────────────────────────────────────────┤
│                 APPLICATION STATE                   │
│          providers/ (ChangeNotifier / Provider)     │
├─────────────────────────────────────────────────────┤
│                   DATA LAYER                        │
│           services/ (HTTP / ApiService)             │
├─────────────────────────────────────────────────────┤
│                   DOMAIN / MODELS                   │
│            models/ (Entidades Dart puras)           │
└─────────────────────────────────────────────────────┘
```

---

## 4. Integração com o Backend REST

Todos os endpoints consumidos pelo app:

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| `GET` | `/api/usuarios/buscar?email=xxx` | Busca usuário por e-mail (login) |
| `POST` | `/api/usuarios` | Cria novo usuário CLIENTE |
| `POST` | `/api/pedidos` | Cria novo pedido com itens |
| `GET` | `/api/pedidos/:id` | Busca detalhes de um pedido |
| `GET` | `/api/usuarios/:id/pedidos` | Lista todos os pedidos do cliente |

> **Nota:** O endpoint `GET /api/usuarios/buscar` foi adicionado ao backend nesta sprint para suportar o login por e-mail.

---

## 5. Atualização Assíncrona de Estado (Polling)

A atualização assíncrona é implementada usando `Timer.periodic` do Dart:

```dart
// Inicializa polling a cada 5 segundos
_timer = Timer.periodic(const Duration(seconds: 5), (_) {
  _carregar(silencioso: true);
});

// Cancela polling ao atingir status final
if (_statusFinal.contains(pedido.status)) {
  _timer?.cancel();
}
```

### Comportamento:
- **`MeusPedidosScreen`**: polling contínuo a cada 5s enquanto a tela está montada
- **`DetalhePedidoScreen`**: polling a cada 5s; **para automaticamente** quando o pedido atinge `FINALIZADO` ou `CANCELADO`
- O timer é cancelado no `dispose()` para evitar memory leaks
- Atualizações "silenciosas" não alteram o estado de loading (UX fluida)

---

## 6. Fluxo Completo do Cliente

```
1. Login (nome + e-mail)
       ↓
2. Cardápio (browse + adicionar ao carrinho)
       ↓
3. Carrinho (revisar itens + endereço)
       ↓
4. Confirmar Pedido → POST /api/pedidos
       ↓ (RabbitMQ publica evento pedido.criado)
5. Detalhe do Pedido (polling 5s → acompanha status)
       ↓
   PENDENTE → ACEITO → EM_PREPARO → COLETADO → FINALIZADO
```

---

## 7. Dependências

```yaml
dependencies:
  flutter: sdk
  http: ^1.2.0       # Chamadas HTTP ao backend REST
  provider: ^6.1.2   # Gerenciamento de estado reativo
```

---

## 8. Instruções para Executar

### Pré-requisitos
- Flutter SDK 3.10+ instalado ([flutter.dev](https://flutter.dev))
- Android Studio com emulador configurado (API 21+)
- Backend Bah-Food rodando (`npm start` ou `npm run dev`)
- Docker com postgres + rabbitmq ativos (`docker-compose up -d`)

### Passos

```bash
# 1. Na pasta do projeto Flutter
cd bah_food_cliente

# 2. Instalar dependências
flutter pub get

# 3. Verificar dispositivo disponível
flutter devices

# 4. Executar o app
flutter run

# Para gerar APK de debug
flutter build apk --debug
```

> **Importante:** No emulador Android, o backend é acessado via `10.0.2.2:3000`.  
> Se usar dispositivo físico, altere `kBaseUrl` em `lib/services/api_service.dart`  
> para o IP da sua máquina na rede local (ex: `http://192.168.1.100:3000/api`).

---

## 9. Atualização no Backend (Sprint 3)

Para suportar a Sprint 3, o backend recebeu as seguintes alterações:

1. **`src/app.js`** – adicionado middleware `cors` para aceitar requisições do app Flutter
2. **`src/routes/usuarioRoutes.js`** – adicionado `GET /buscar?email=xxx` antes de `/:id`
3. **`src/controllers/usuarioController.js`** – adicionado handler `buscarPorEmail`
4. **`src/services/usuarioService.js`** – adicionada função `buscarPorEmail`
5. **`docker-compose.yml`** – unificado com postgres + rabbitmq em arquivo único
6. **`package.json`** – adicionada dependência `cors: ^2.8.5`

---

## 10. Critérios de Avaliação Atendidos

| Critério | Peso | Implementação |
|----------|------|---------------|
| Funcionalidade do app (fluxo completo executável) | 30% | 5 telas cobrindo login → cardápio → carrinho → pedido → acompanhamento |
| Integração correta com o backend REST | 25% | 5 endpoints REST consumidos via `http` package |
| Atualização assíncrona de estado | 20% | `Timer.periodic(5s)` em `MeusPedidosScreen` e `DetalhePedidoScreen` |
| Organização do código (Clean Architecture) | 15% | Camadas: models / services / providers / screens / widgets |
| Qualidade da interface (usabilidade e clareza) | 10% | Material 3, tema gaúcho vermelho, badges de status coloridos, linha do tempo |
