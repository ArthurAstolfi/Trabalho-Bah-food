import 'package:flutter/material.dart';

class PedidoStatusBadge extends StatelessWidget {
  final String status;

  const PedidoStatusBadge({super.key, required this.status});

  Color _cor() {
    return switch (status) {
      'PENDENTE'   => const Color(0xFFFF8C00),
      'ACEITO'     => const Color(0xFF2196F3),
      'EM_PREPARO' => const Color(0xFF9C27B0),
      'COLETADO'   => const Color(0xFF00ACC1),
      'FINALIZADO' => const Color(0xFF43A047),
      'CANCELADO'  => const Color(0xFFE53935),
      _            => Colors.grey,
    };
  }

  String _label() {
    return switch (status) {
      'PENDENTE'   => 'Pendente',
      'ACEITO'     => 'Aceito',
      'EM_PREPARO' => 'Em Preparo',
      'COLETADO'   => 'Coletado',
      'FINALIZADO' => 'Finalizado',
      'CANCELADO'  => 'Cancelado',
      _            => status,
    };
  }

  @override
  Widget build(BuildContext context) {
    final cor = _cor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cor.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cor),
      ),
      child: Text(
        _label(),
        style: TextStyle(
            color: cor, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
