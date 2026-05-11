# Proposta de Projeto: Bah-Food

**Disciplina:** Laboratório de Desenvolvimento de Aplicações Móveis e Distribuídas
**Instituição:** PUC Minas – Engenharia de Software
**Aluno:** Arthur Astolfi Cardoso
**Data:** 11 de maio de 2026

## 1. Introdução e Motivação

O **Bah-Food** é uma plataforma de delivery especializada na culinária tradicional do Rio
Grande do Sul. O projeto surge da oportunidade de nicho no mercado de entregas, onde a
especialização regional oferece uma experiência de usuário mais rica e curada.
Tecnicamente, o sistema é concebido como um **Sistema Distribuído** focado na
**Arquitetura Orientada a Eventos (EDA,)**. A motivação principal é aplicar os conceitos de
comunicação assíncrona para resolver o problema de latência e acoplamento em sistemas
de entrega em tempo real, garantindo que a notificação de um novo pedido chegue ao
entregador (prestador) instantaneamente através de um Middleware Orientado a
Mensagens (MOM), sem a necessidade de requisições constantes (polling) ao servidor.

## 2. Perfis de Usuário

O sistema é estruturado estritamente sobre dois perfis de usuários distintos, conforme
exigido pelo projeto integrador:
● **Cliente (Usuário Final):** O gaúcho ou entusiasta da culinária que deseja consumir o
serviço. Através de um aplicativo móvel desenvolvido em Flutter, o cliente realiza a
autenticação, navega pelos itens do cardápio, efetua pedidos e monitora o progresso
de sua refeição de forma passiva, recebendo atualizações automáticas de estado.
● **Prestador (Entregador):** O profissional responsável pela logística. Utilizando uma
interface distinta no aplicativo Flutter, o prestador mantém-se em estado de "escuta"
para novos eventos de pedidos. Ele tem a capacidade de visualizar demandas
próximas, aceitar ou recusar serviços e gerenciar o ciclo de vida da entrega

## 3. Funcionalidades Principais (Detalhamento)

O escopo funcional do Bah-Food foi desenhado para cobrir o ciclo completo de um delivery
distribuído:

## 3.1. Gestão de Pedidos (CRUD Essencial)


O backend permitirá a manipulação completa do ciclo de vida do pedido via endpoints
RESTful. Isso inclui a criação de novas solicitações com múltiplos itens, a consulta de
histórico pelo cliente e a listagem de pedidos "abertos" para o perfil de entregador.

## 3.2. Fluxo de Notificação Orientado a Eventos (EDA)

Diferente de sistemas síncronos, o Bah-Food utilizará o MOM para:
● **Despacho Automático:** Assim que o pagamento/pedido é confirmado, o backend
dispara uma mensagem para uma fila específica.
● **Consumo pelo Prestador:** O aplicativo do entregador, agindo como um consumidor
da fila, recebe o payload do pedido em tempo real, permitindo uma resposta rápida à
demanda.

## 3.3. Rastreamento e Atualização de Status

Implementação de uma máquina de estados para o pedido:

1. **PENDENTE:** Pedido criado, aguardando entregador.
2. **ACEITO:** Entregador vinculado ao pedido.
3. **EM_PREPARO / COLETADO:** O prestador confirma a retirada na cozinha.
4. **FINALIZADO:** Confirmação da entrega no destino.


