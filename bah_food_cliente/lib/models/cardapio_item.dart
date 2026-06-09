class CardapioItem {
  final String nome;
  final String descricao;
  final double preco;
  final String emoji;

  const CardapioItem({
    required this.nome,
    required this.descricao,
    required this.preco,
    required this.emoji,
  });
}

const List<CardapioItem> kCardapioItems = [
  CardapioItem(
    nome: 'Churrasco Gaúcho',
    descricao: 'Picanha, costela e linguiça na brasa com farofa e vinagrete',
    preco: 45.90,
    emoji: '🥩',
  ),
  CardapioItem(
    nome: 'Costela no Bafo',
    descricao: 'Costela bovina assada lentamente por 8 horas com temperos regionais',
    preco: 55.00,
    emoji: '🍖',
  ),
  CardapioItem(
    nome: 'Arroz de Carreteiro',
    descricao: 'Arroz com charque desfiado, cebola e temperos gaúchos tradicionais',
    preco: 28.00,
    emoji: '🍚',
  ),
  CardapioItem(
    nome: 'Galeto ao Molho',
    descricao: 'Frango caipira grelhado ao molho de ervas finas com batatas',
    preco: 38.00,
    emoji: '🍗',
  ),
  CardapioItem(
    nome: 'Bife de Chorizo',
    descricao: 'Corte nobre argentino com batatas coradas e salada mista',
    preco: 62.00,
    emoji: '🥩',
  ),
  CardapioItem(
    nome: 'Sopa de Capeletti',
    descricao: 'Sopa tradicional com capeletti em caldo de galinha caipira',
    preco: 22.00,
    emoji: '🍜',
  ),
  CardapioItem(
    nome: 'Quibe Gaúcho',
    descricao: 'Quibe assado com especiarias do pampa, servido com tahine',
    preco: 18.00,
    emoji: '🫔',
  ),
  CardapioItem(
    nome: 'Chimarrão Premium',
    descricao: 'Cuia de erva-mate selecionada do Rio Grande do Sul com bomba de prata',
    preco: 12.00,
    emoji: '🧉',
  ),
];
