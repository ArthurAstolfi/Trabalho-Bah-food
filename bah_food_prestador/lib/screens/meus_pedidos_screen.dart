import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pedido.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../widgets/pedido_card.dart';
import 'detalhe_pedido_screen.dart';

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
    final usuario = context.read<AuthProvider>().usuario;
    if (usuario == null) return;
    try {
      final pedidos = await ApiService.listarMeusPedidos(usuario.id);
      if (mounted) {
        setState(() {
          _pedidos = pedidos;
          _carregandoInicial = false;
          _erro = null;
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.grey),
            const SizedBox(height: 12),
            Text(_erro!, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() => _carregandoInicial = true);
                _carregar();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white),
              child: const Text('Tentar novamente'),
            ),
          ],
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
            child: const Text(
              'Minhas Entregas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
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
                            Icon(Icons.delivery_dining_outlined,
                                size: 80, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('Nenhuma entrega aceita ainda',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.grey)),
                            SizedBox(height: 8),
                            Text('Aceite pedidos na aba "Disponíveis"',
                                style: TextStyle(color: Colors.grey)),
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
