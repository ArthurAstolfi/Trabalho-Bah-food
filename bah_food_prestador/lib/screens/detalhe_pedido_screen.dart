import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pedido.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../widgets/pedido_status_badge.dart';

const Set<String> _statusFinal = {'FINALIZADO', 'CANCELADO'};
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
  bool _atualizando = false;
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
        if (_statusFinal.contains(pedido.status)) _timer?.cancel();
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

  Future<void> _atualizarStatus(String novoStatus) async {
    final prestador = context.read<AuthProvider>().usuario!;
    setState(() => _atualizando = true);
    try {
      await ApiService.atualizarStatus(
        pedidoId: widget.pedidoId,
        novoStatus: novoStatus,
        prestadorId: novoStatus == 'ACEITO' ? prestador.id : null,
      );
      await _carregar();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status atualizado para $novoStatus!'),
            backgroundColor: const Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _atualizando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pedido #${widget.pedidoId}'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _erro != null
              ? Center(child: Text(_erro!))
              : RefreshIndicator(
                  color: const Color(0xFF2E7D32),
                  onRefresh: _carregar,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _cardStatus(),
                        const SizedBox(height: 16),
                        _botoesAcao(),
                        const SizedBox(height: 16),
                        _secao('Itens do Pedido', _buildItens()),
                        const SizedBox(height: 16),
                        _secao('Endereço de Entrega', _buildEntrega()),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _cardStatus() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pedido #',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text('${_pedido!.id}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 22)),
              ],
            ),
            PedidoStatusBadge(status: _pedido!.status),
          ],
        ),
      ),
    );
  }

  Widget _botoesAcao() {
    if (_atualizando) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final acoes = _getAcoes(_pedido!.status);
    if (acoes.isEmpty) return const SizedBox.shrink();

    return Column(
      children: acoes
          .map((acao) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => _confirmarAcao(acao),
                    icon: Icon(acao.icone),
                    label: Text(acao.label),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: acao.cor,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Future<void> _confirmarAcao(_AcaoPedido acao) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(acao.label),
        content: Text(acao.mensagemConfirmacao),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: acao.cor),
            child:
                Text('Confirmar', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmar == true) _atualizarStatus(acao.novoStatus);
  }

  List<_AcaoPedido> _getAcoes(String status) {
    return switch (status) {
      'PENDENTE' => [
          _AcaoPedido(
            label: 'Aceitar Pedido',
            novoStatus: 'ACEITO',
            icone: Icons.check_circle_outline,
            cor: const Color(0xFF2E7D32),
            mensagemConfirmacao: 'Deseja aceitar este pedido?',
          ),
        ],
      'ACEITO' => [
          _AcaoPedido(
            label: 'Iniciar Preparo',
            novoStatus: 'EM_PREPARO',
            icone: Icons.restaurant,
            cor: const Color(0xFF7B1FA2),
            mensagemConfirmacao: 'Confirmar que o pedido entrou em preparo?',
          ),
        ],
      'EM_PREPARO' => [
          _AcaoPedido(
            label: 'Confirmar Coleta',
            novoStatus: 'COLETADO',
            icone: Icons.local_shipping,
            cor: const Color(0xFF0277BD),
            mensagemConfirmacao: 'Confirmar que você coletou o pedido?',
          ),
        ],
      'COLETADO' => [
          _AcaoPedido(
            label: 'Confirmar Entrega',
            novoStatus: 'FINALIZADO',
            icone: Icons.check_circle,
            cor: const Color(0xFF1B5E20),
            mensagemConfirmacao: 'Confirmar que o pedido foi entregue?',
          ),
        ],
      _ => [],
    };
  }

  Widget _secao(String titulo, Widget conteudo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF1B5E20))),
        const SizedBox(height: 8),
        conteudo,
      ],
    );
  }

  Widget _buildItens() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                        child: Text('${item.nomeItem}  ×${item.quantidade}')),
                    Text(
                        'R\$ ${(item.precoUnitario * item.quantidade).toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
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
                Text('R\$ ${_pedido!.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF2E7D32))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntrega() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined,
                    color: Color(0xFF2E7D32)),
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
                      child: Text(_pedido!.observacao!,
                          style: const TextStyle(color: Colors.grey))),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AcaoPedido {
  final String label;
  final String novoStatus;
  final IconData icone;
  final Color cor;
  final String mensagemConfirmacao;

  const _AcaoPedido({
    required this.label,
    required this.novoStatus,
    required this.icone,
    required this.cor,
    required this.mensagemConfirmacao,
  });
}
