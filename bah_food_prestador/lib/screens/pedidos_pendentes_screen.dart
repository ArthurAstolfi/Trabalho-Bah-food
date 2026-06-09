import 'dart:async';
import 'package:flutter/material.dart';
import '../models/pedido.dart';
import '../services/api_service.dart';
import '../widgets/pedido_card.dart';
import 'detalhe_pedido_screen.dart';

// Polling assíncrono: prestador é notificado de novos pedidos a cada 5s
const Duration _intervaloPolling = Duration(seconds: 5);

class PedidosPendentesScreen extends StatefulWidget {
  const PedidosPendentesScreen({super.key});

  @override
  State<PedidosPendentesScreen> createState() =>
      _PedidosPendentesScreenState();
}

class _PedidosPendentesScreenState extends State<PedidosPendentesScreen>
    with AutomaticKeepAliveClientMixin {
  List<Pedido> _pedidos = [];
  bool _carregandoInicial = true;
  String? _erro;
  Timer? _timer;
  DateTime? _ultimaAtualizacao;
  int _totalAnterior = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _carregar();
    _timer = Timer.periodic(_intervaloPolling, (_) => _carregar(silencioso: true));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _carregar({bool silencioso = false}) async {
    try {
      final pedidos = await ApiService.listarPedidosPendentes();
      if (mounted) {
        // Notifica se chegou pedido novo
        if (silencioso && pedidos.length > _totalAnterior) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '🔔 Novo pedido disponível! (${pedidos.length - _totalAnterior} novo(s))'),
              backgroundColor: const Color(0xFF2E7D32),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        setState(() {
          _totalAnterior = pedidos.length;
          _pedidos = pedidos;
          _carregandoInicial = false;
          _erro = null;
          _ultimaAtualizacao = DateTime.now();
        });
      }
    } catch (e) {
      if (mounted && !silencioso) {
        setState(() {
          _erro = e.toString().replaceFirst('Exception: ', '');
          _carregandoInicial = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_carregandoInicial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(_erro!,
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() => _carregandoInicial = true);
                  _carregar();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF2E7D32),
      onRefresh: _carregar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F8E9),
              border: Border(
                  bottom: BorderSide(color: Color(0xFFC8E6C9), width: 1)),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pedidos Disponíveis',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    if (_ultimaAtualizacao != null)
                      Text(
                        'Atualizado às ${_ultimaAtualizacao!.hour.toString().padLeft(2, '0')}:${_ultimaAtualizacao!.minute.toString().padLeft(2, '0')}:${_ultimaAtualizacao!.second.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.sync, size: 12, color: Colors.green.shade700),
                      const SizedBox(width: 3),
                      Text('auto 5s',
                          style: TextStyle(
                              fontSize: 10, color: Colors.green.shade700)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _pedidos.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 80),
                      Center(
                        child: Column(
                          children: [
                            Icon(Icons.inbox_outlined,
                                size: 80, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('Nenhum pedido pendente',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.grey)),
                            SizedBox(height: 8),
                            Text('Você será notificado quando chegar um pedido',
                                style: TextStyle(color: Colors.grey),
                                textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 6, bottom: 16),
                    itemCount: _pedidos.length,
                    itemBuilder: (context, index) {
                      return PedidoCard(
                        pedido: _pedidos[index],
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetalhePedidoScreen(
                                  pedidoId: _pedidos[index].id),
                            ),
                          );
                          _carregar();
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
