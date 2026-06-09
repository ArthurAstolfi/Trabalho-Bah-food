import 'item_pedido.dart';

class Pedido {
  final int id;
  final int clienteId;
  final int? prestadorId;
  final String status;
  final String enderecoEntrega;
  final String? observacao;
  final double total;
  final List<ItemPedido> itens;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Pedido({
    required this.id,
    required this.clienteId,
    this.prestadorId,
    required this.status,
    required this.enderecoEntrega,
    this.observacao,
    required this.total,
    required this.itens,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    final itensJson = json['itens'] as List<dynamic>? ?? [];
    return Pedido(
      id: json['id'] as int,
      clienteId: json['cliente_id'] as int,
      prestadorId: json['prestador_id'] as int?,
      status: json['status'] as String,
      enderecoEntrega: json['endereco_entrega'] as String,
      observacao: json['observacao'] as String?,
      total: double.parse(json['total'].toString()),
      itens: itensJson
          .map((i) => ItemPedido.fromJson(i as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
