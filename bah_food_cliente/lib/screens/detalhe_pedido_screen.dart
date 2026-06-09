import 'dart:async';
import 'package:flutter/material.dart';
import '../models/pedido.dart';
import '../services/api_service.dart';
import '../widgets/pedido_status_badge.dart';

// Status que encerram o ciclo — polling para quando atingido
const Set<String> _statusFinal = {'FINALIZADO', 'CANCELADO'};

// Atualiza automaticamente a cada 5 segundos enquanto o pedido está em andamento
const Duration _intervaloPolling = Duration(seconds: 5);

class DetalhePedidoScreen extends StatefulWidget {
  final int pedidoId;

  const DetalhePedidoScreen({super.key, required this.pedidoId});

  @override
  State<DetalhePedidoScreen> createState() => _DetalhePedidoScreenState();
}

class _DetalhePedidoScreenState extends State<DetalhePedidoScreen> {
  Pedido? _pedido;
  bool _carregando = true;
  String? _erro;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _carregar();
    _timer = Timer.periodic(_intervaloPolling, (_) {
      if (_pedido == null || !_statusFinal.contains(_pedido!.status)) {
        _carregar(silencioso: true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _carregar({bool silencioso = false}) async {
    try {
      final pedido = await ApiService.buscarPedido(widget.pedidoId);
      if (mounted) {
        setState(() {
          _pedido = pedido;
          _carregando = false;
          _erro = null;
        });
        if (_statusFinal.contains(pedido.status)) {
          _timer?.cancel();
        }
      }
    } catch (e) {
      if (mounted && !silencioso) {
        setState(() {
          _erro = e.toString().replaceFirst('Exception: ', '');
          _carregando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pedido #${widget.pedidoId}'),
        backgroundColor: const Color(0xFFB22222),
        foregroundColor: Colors.white,
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _erro != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 60, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text(_erro!,
                          style: const TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: const Color(0xFFB22222),
                  onRefresh: _carregar,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _cardStatus(),
                        const SizedBox(height: 16),
                        _secao('Linha do Tempo', _buildTimeline()),
                        const SizedBox(height: 16),
                        _secao('Itens do Pedido', _buildItens()),
                        const SizedBox(height: 16),
                        _secao('Entrega', _buildEntrega()),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _cardStatus() {
    final isAtivo = !_statusFinal.contains(_pedido!.status);
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Status atual',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                PedidoStatusBadge(status: _pedido!.status),
              ],
            ),
            if (isAtivo) ...[
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sync, size: 14, color: Colors.green.shade700),
                    const SizedBox(width: 6),
                    Text(
                      'Atualização automática a cada 5s',
                      style: TextStyle(
                          fontSize: 12, color: Colors.green.shade700),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _secao(String titulo, Widget conteudo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF8B0000)),
        ),
        const SizedBox(height: 8),
        conteudo,
      ],
    );
  }

  Widget _buildTimeline() {
    final etapas = <(String, String, IconData)>[
      ('PENDENTE', 'Pedido criado', Icons.hourglass_empty_rounded),
      ('ACEITO', 'Entregador a caminho', Icons.delivery_dining_rounded),
      ('EM_PREPARO', 'Em preparo na cozinha', Icons.restaurant_rounded),
      ('COLETADO', 'Coletado pelo entregador', Icons.local_shipping_rounded),
      ('FINALIZADO', 'Entregue com sucesso!', Icons.check_circle_rounded),
    ];

    const statusOrder = [
      'PENDENTE',
      'ACEITO',
      'EM_PREPARO',
      'COLETADO',
      'FINALIZADO'
    ];

    final isCancelled = _pedido!.status == 'CANCELADO';
    final currentIdx =
        isCancelled ? -1 : statusOrder.indexOf(_pedido!.status);

    final children = <Widget>[];

    for (var i = 0; i < etapas.length; i++) {
      final (_, label, icon) = etapas[i];
      final isCompleted = !isCancelled && currentIdx >= i;
      final isCurrent = !isCancelled && currentIdx == i;

      children.add(Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted
                  ? const Color(0xFFB22222)
                  : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(icon,
                size: 20,
                color: isCompleted ? Colors.white : Colors.grey.shade400),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight:
                    isCurrent ? FontWeight.bold : FontWeight.normal,
                color: isCompleted ? Colors.black87 : Colors.grey,
                fontSize: isCurrent ? 15 : 14,
              ),
            ),
          ),
          if (isCurrent)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFB22222).withAlpha(25),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFB22222)),
              ),
              child: const Text(
                'Agora',
                style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFFB22222),
                    fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ));

      if (i < etapas.length - 1) {
        children.add(Padding(
          padding: const EdgeInsets.only(left: 19),
          child: Container(
            width: 2,
            height: 18,
            color: isCompleted
                ? const Color(0xFFB22222)
                : Colors.grey.shade200,
          ),
        ));
      }
    }

    if (isCancelled) {
      children.addAll([
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.shade300),
          ),
          child: const Row(
            children: [
              Icon(Icons.cancel_outlined, color: Colors.red),
              SizedBox(width: 8),
              Text('Pedido Cancelado',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ]);
    }

    return Card(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children),
      ),
    );
  }

  Widget _buildItens() {
    return Card(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            ..._pedido!.itens.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                          '${item.nomeItem}  ×${item.quantidade}',
                          style: const TextStyle(fontSize: 14)),
                    ),
                    Text(
                      'R\$ ${(item.precoUnitario * item.quantidade).toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                Text(
                  'R\$ ${_pedido!.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFFB22222)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntrega() {
    return Card(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined,
                    color: Color(0xFFB22222)),
                const SizedBox(width: 8),
                Expanded(child: Text(_pedido!.enderecoEntrega)),
              ],
            ),
            if (_pedido!.observacao != null &&
                _pedido!.observacao!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.note_outlined, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _pedido!.observacao!,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ],
            if (_pedido!.prestadorId != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.delivery_dining_outlined,
                      color: Colors.blue),
                  const SizedBox(width: 8),
                  Text('Entregador #${_pedido!.prestadorId} designado',
                      style: const TextStyle(color: Colors.blue)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
