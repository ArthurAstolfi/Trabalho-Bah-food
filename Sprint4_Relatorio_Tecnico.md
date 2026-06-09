# Relatório Técnico Final — Bah-Food

**Projeto:** Bah-Food — Plataforma de Delivery de Culinária Gaúcha  
**Disciplina:** Laboratório de Desenvolvimento de Aplicações Móveis e Distribuídas  
**Instituição:** PUC Minas — Engenharia de Software  
**Aluno:** Arthur Astolfi Cardoso  
**Data:** 09/06/2026  

---

## 1. Introdução

O Bah-Food é uma plataforma de delivery desenvolvida como projeto integrador da disciplina de LDAMD. O sistema foi concebido sobre os princípios de uma **Arquitetura Orientada a Eventos (EDA)**, com comunicação assíncrona via **Middleware Orientado a Mensagens (MOM)**, dois aplicativos móveis distintos em **Flutter** e um backend **REST em Node.js/Express**.

O domínio escolhido — culinária gaúcha — possibilitou explorar os dois perfis obrigatórios de usuário de forma natural: o **Cliente**, que realiza pedidos de pratos típicos do Rio Grande do Sul, e o **Prestador**, responsável pela logística de entrega.

---

## 2. Arquitetura do Sistema

### 2.1 Visão Geral

O sistema é composto por quatro componentes principais que se comunicam conforme o diagrama abaixo:

```
[App Cliente]  ←── HTTP REST ──►  [Backend Node.js]  ←── AMQP ──►  [RabbitMQ]
[App Prestador] ←── HTTP REST ──►  [PostgreSQL]
```

Cada componente tem responsabilidades bem definidas:

- **Backend REST (Node.js/Express):** expõe endpoints RESTful, implementa a lógica de negócio, persiste dados no PostgreSQL e publica eventos no RabbitMQ
- **RabbitMQ (MOM):** atua como broker de mensagens assíncronas, desacoplando o backend dos consumidores
- **PostgreSQL:** persistência relacional com máquina de estados para o ciclo de vida dos pedidos
- **App Cliente (Flutter):** interface para criação de pedidos e acompanhamento de status
- **App Prestador (Flutter):** interface para recebimento de demandas, aceitação e gerenciamento das entregas

### 2.2 Comunicação Assíncrona (EDA)

A Arquitetura Orientada a Eventos foi implementada com RabbitMQ usando o padrão **Topic Exchange**. O exchange `bahfood` roteia mensagens por routing key:

| Evento | Routing Key | Produtor | Consumidor | Fila |
|--------|-------------|----------|------------|------|
| Pedido criado | `pedido.criado` | Backend | PrestadorConsumer | `fila.prestador` |
| Status atualizado | `pedido.status.atualizado` | Backend | ClienteConsumer | `fila.cliente` |

O uso de Topic Exchange permite que futuros consumidores se inscrevam em padrões de routing key (ex: `pedido.*`) sem alterar o produtor — princípio Open/Closed aplicado a sistemas de mensageria (HOHPE; WOOLF, 2003).

### 2.3 Máquina de Estados do Pedido

O ciclo de vida de um pedido segue transições controladas no backend:

```
PENDENTE ──► ACEITO ──► EM_PREPARO ──► COLETADO ──► FINALIZADO
    │           │
    └───────────┴──────────────────────────────────► CANCELADO
```

Transições inválidas retornam HTTP 422, garantindo integridade do estado mesmo com requisições concorrentes.

---

## 3. Decisões de Design

### 3.1 Clean Architecture nos Apps Flutter

Ambos os aplicativos seguem uma arquitetura em camadas inspirada na Clean Architecture (MARTIN, 2019):

```
models/    ← Entidades puras (sem dependência de Flutter)
services/  ← Acesso a dados (chamadas HTTP ao backend)
providers/ ← Estado da aplicação (ChangeNotifier/Provider)
screens/   ← Páginas completas (Presentation Layer)
widgets/   ← Componentes UI reutilizáveis
```

Essa organização garante que as regras de negócio (models e services) sejam independentes do framework de UI, facilitando testes unitários e evolução do código.

### 3.2 Polling como Mecanismo de Atualização Assíncrona

Para refletir mudanças de estado nos apps sem ação do usuário, optou-se pelo **polling periódico** com `Timer.periodic` do Dart, com intervalo de 5 segundos. Essa decisão foi motivada por:

1. **Simplicidade de implementação** no contexto de um projeto acadêmico
2. **Compatibilidade universal** (funciona em Web, Android e Windows sem configuração adicional)
3. **Confiabilidade** — não depende de conexões persistentes (WebSocket) que podem cair

O polling é cancelado automaticamente ao atingir um status terminal (`FINALIZADO` ou `CANCELADO`), evitando requisições desnecessárias.

O mecanismo de atualização assíncrona no app do Prestador inclui uma **notificação visual via SnackBar** quando novos pedidos chegam, simulando o comportamento de um sistema de push notification.

### 3.3 Diferenciação Visual dos Apps

Os dois apps utilizam paletas de cores distintas para evitar confusão durante o uso simultâneo:
- **App Cliente:** vermelho `#B22222` — remete ao fogo do churrasco gaúcho
- **App Prestador:** verde `#2E7D32` — remete ao campo e às cores do Rio Grande do Sul

### 3.4 Separação de Perfis por E-mail

O login é feito por e-mail, e o backend valida o perfil do usuário (`CLIENTE` ou `PRESTADOR`). Se um cliente tentar entrar no app do prestador (ou vice-versa), o sistema exibe um erro explicativo, garantindo que cada app seja usado pelo perfil correto.

---

## 4. Implementação por Sprint

### Sprint 1 — Backend REST
- Backend Node.js/Express com PostgreSQL
- 5+ endpoints RESTful para gestão de pedidos e usuários
- Schema relacional com máquina de estados
- Coleção Postman documentada

### Sprint 2 — Integração com MOM
- RabbitMQ configurado via Docker com Topic Exchange
- Produtor publica 2 eventos: `pedido.criado` e `pedido.status.atualizado`
- Consumidores implementados para prestador e cliente
- Documentação dos eventos com tabela de payload

### Sprint 3 — App Flutter Cliente
- App com 5 telas: Login, Cardápio, Carrinho, Meus Pedidos, Detalhe
- Cardápio com 8 pratos típicos gaúchos
- Polling assíncrono a cada 5s nas telas de acompanhamento
- Clean Architecture com 4 camadas

### Sprint 4 — App Flutter Prestador + Integração Final
- App com 4 telas: Login, Pedidos Disponíveis, Minhas Entregas, Detalhe
- Polling a cada 5s com notificação de novos pedidos
- Botões de ação contextual: Aceitar → Iniciar Preparo → Confirmar Coleta → Confirmar Entrega
- Fluxo ponta a ponta: Cliente cria → RabbitMQ notifica → Prestador aceita → Cliente vê atualização
- README completo do repositório

---

## 5. Dificuldades e Soluções

### 5.1 CORS entre Flutter Web e Backend
**Problema:** Ao rodar o app Flutter no Chrome, requisições HTTP eram bloqueadas pelo browser por falta de headers CORS.  
**Solução:** Adicionado o middleware `cors` ao Express, habilitando todas as origens em desenvolvimento.

### 5.2 URL do Backend por Plataforma
**Problema:** O endereço do backend varia por plataforma — emuladores Android usam `10.0.2.2`, enquanto Web e Desktop usam `localhost`.  
**Solução:** Detecção automática via `kIsWeb` e `defaultTargetPlatform` do Flutter, centralizando a lógica em `api_service.dart`.

### 5.3 Consistência da Máquina de Estados
**Problema:** Requisições paralelas poderiam causar transições de estado inconsistentes.  
**Solução:** Validação de transições no backend com tabela `TRANSICOES` explícita, retornando HTTP 422 para transições inválidas.

### 5.4 Sincronização entre Apps sem WebSocket
**Problema:** Como atualizar o app do cliente quando o prestador muda o status, sem WebSocket?  
**Solução:** Polling periódico com `Timer.periodic(Duration(seconds: 5))`, que satisfaz o requisito de "atualização sem ação manual do usuário" de forma simples e robusta.

---

## 6. Reflexão sobre os Padrões Estudados

### 6.1 Event-Driven Architecture (EDA)
A adoção de EDA no Bah-Food demonstrou na prática os benefícios descritos por Richardson (2018): **desacoplamento temporal** (backend não precisa esperar o consumidor) e **escalabilidade** (múltiplos consumidores podem processar eventos independentemente). O padrão Topic Exchange do RabbitMQ implementa o conceito de **Publish-Subscribe** descrito por Hohpe e Woolf (2003), onde produtores e consumidores nunca se conhecem diretamente.

### 6.2 Middleware Orientado a Mensagens (MOM)
O RabbitMQ atuou como o "duto" central do sistema, separando a lógica de produção da lógica de consumo. Conforme Coulouris et al. (2011), o MOM oferece **comunicação indireta** que aumenta a disponibilidade do sistema — se o consumidor cair, as mensagens permanecem na fila até ele se recuperar. Em produção, isso significa que pedidos nunca são perdidos por falha momentânea do app do prestador.

### 6.3 Clean Architecture
A separação em camadas (models → services → providers → screens) seguindo os princípios de Martin (2019) resultou em código mais fácil de manter. A camada de `services` pode ser substituída por mocks em testes unitários sem alterar os providers ou as telas, demonstrando o **Princípio da Inversão de Dependência** na prática.

### 6.4 REST
Os endpoints RESTful seguem as convenções de recursos e verbos HTTP, com semântica clara: `POST /pedidos` cria, `GET /pedidos/:id` consulta, `PATCH /pedidos/:id/status` modifica parcialmente. A documentação via Postman torna a API autoexplicativa para qualquer consumidor.

---

## 7. Conclusão

O Bah-Food alcançou todos os objetivos propostos: um sistema distribuído funcional com EDA, MOM, REST e aplicativos móveis em Flutter. O projeto demonstrou que é possível construir uma plataforma de delivery completa com comunicação assíncrona real, onde o prestador é notificado de novos pedidos sem polling manual e o cliente vê as atualizações de status em tempo quase real.

As maiores aprendizagens foram: a importância do desacoplamento na arquitetura de sistemas distribuídos, a praticidade do padrão Provider para gerenciamento de estado no Flutter, e como a Clean Architecture facilita a evolução incremental do código a cada sprint.

---

## Referências Bibliográficas

HOHPE, Gregor; WOOLF, Bobby. **Enterprise Integration Patterns: designing, building, and deploying messaging solutions**. Boston: Addison-Wesley, 2003. (Padrões Publish-Subscribe, Topic Exchange, Message Channel — base teórica para o RabbitMQ.)

MARTIN, Robert C. **Arquitetura limpa: o guia do artesão para estrutura e design de software**. Rio de Janeiro: Alta Books, 2019. (Princípios de separação de camadas aplicados na organização dos apps Flutter e do backend.)

RICHARDSON, Chris. **Microservices patterns: with examples in Java**. Shelter Island: Manning, 2018. (Padrões de EDA, comunicação assíncrona entre serviços e consistência eventual.)

COULOURIS, George et al. **Distributed Systems: concepts and design**. 5th ed. Boston: Addison-Wesley, 2011. (Conceitos de comunicação indireta, middlewares e tolerância a falhas em sistemas distribuídos.)

BAILEY, Thomas. **Flutter for beginners**. 3rd ed. Birmingham: Packt, 2023. (Referência para desenvolvimento com Flutter 3.x, Provider pattern e navegação.)
