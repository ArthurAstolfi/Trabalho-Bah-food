import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pedido.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../widgets/pedido_card.dart';
import 'detalhe_pedido_screen.dart';

// Atualiza automaticamente a cada 5 segundos (polling assíncrono)
const Duration _intervaloPolling = Duration(seconds: 5);

class MeusPedidosScreen extends StatefulWidget {
  const MeusPedidosScreen({super.key});

  @override
  State<MeusPedidosScreen> createState() => _MeusPedidosScreenState();
}

class _MeusPedidosScreenState extends State<MeusPedidosScreen>
    with AutomaticKeepAliveClientMixin {
  List<Pedido> _pedidos = [];
  bool _carregandoInicial = true;
  String? _erro;
  Timer? _timer;
  DateTime? _ultimaAtualizacao;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _carregar();
    _timer =
        Timer.periodic(_intervaloPolling, (_) => _carregar(silencioso: true));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _carregar({bool silencioso = false}) async {
    final usuario = context.read<AuthProvider>().usuario;
    if (usuario == null) return;
    try {
      final pedidos = await ApiService.listarPedidosDoUsuario(usuario.id);
      if (mounted) {
        setState(() {
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
              const Text('Não foi possível carregar os pedidos',
                  style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(_erro!,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
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
                    backgroundColor: const Color(0xFFB22222),
                    foregroundColor: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFFB22222),
      onRefresh: _carregar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF8F0),
              border: Border(
                  bottom: BorderSide(color: Color(0xFFEEDDCC), width: 1)),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Meus Pedidos',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B0000),
                      ),
                    ),
                    if (_ultimaAtualizacao != null)
                      Text(
                        'Atualizado às ${_ultimaAtualizacao!.hour.toString().padLeft(2, '0')}:${_ultimaAtualizacao!.minute.toString().padLeft(2, '0')}:${_ultimaAtualizacao!.second.toString().padLeft(2, '0')}',
                        style:
                            const TextStyle(fontSize: 11, color: Colors.grey),
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
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.sync, size: 12, color: Colors.green.shade700),
                      const SizedBox(width: 3),
                      Text(
                        'auto 5s',
                        style: TextStyle(
                            fontSize: 10, color: Colors.green.shade700),
                      ),
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
                            Icon(Icons.receipt_long_outlined,
                                size: 80, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('Nenhum pedido ainda',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.grey)),
                            SizedBox(height: 8),
                            Text('Explore o cardápio e faça seu primeiro pedido!',
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
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetalhePedidoScreen(
                                pedidoId: _pedidos[index].id),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
