class ItemPedido {
  final int id;
  final int pedidoId;
  final String nomeItem;
  final int quantidade;
  final double precoUnitario;

  const ItemPedido({
    required this.id,
    required this.pedidoId,
    required this.nomeItem,
    required this.quantidade,
    required this.precoUnitario,
  });

  factory ItemPedido.fromJson(Map<String, dynamic> json) {
    return ItemPedido(
      id: json['id'] as int,
      pedidoId: json['pedido_id'] as int,
      nomeItem: json['nome_item'] as String,
      quantidade: json['quantidade'] as int,
      precoUnitario: double.parse(json['preco_unitario'].toString()),
    );
  }
}
