import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/carrinho_provider.dart';
import '../services/api_service.dart';
import 'detalhe_pedido_screen.dart';

class CarrinhoScreen extends StatefulWidget {
  const CarrinhoScreen({super.key});

  @override
  State<CarrinhoScreen> createState() => _CarrinhoScreenState();
}

class _CarrinhoScreenState extends State<CarrinhoScreen> {
  final _enderecoController = TextEditingController();
  final _obsController = TextEditingController();
  bool _enviando = false;

  @override
  void dispose() {
    _enderecoController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  Future<void> _confirmarPedido() async {
    if (_enderecoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe o endereço de entrega'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _enviando = true);
    try {
      final usuario = context.read<AuthProvider>().usuario!;
      final carrinho = context.read<CarrinhoProvider>();
      final pedido = await ApiService.criarPedido(
        clienteId: usuario.id,
        enderecoEntrega: _enderecoController.text.trim(),
        observacao: _obsController.text.trim(),
        itens: carrinho.toApiItens(),
      );
      carrinho.limpar();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => DetalhePedidoScreen(pedidoId: pedido.id)),
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
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final carrinho = context.watch<CarrinhoProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Carrinho'),
        backgroundColor: const Color(0xFFB22222),
        foregroundColor: Colors.white,
      ),
      body: carrinho.itens.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Carrinho vazio',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                  SizedBox(height: 8),
                  Text('Adicione itens do cardápio',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Itens selecionados',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ...carrinho.itens.map(
                    (item) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              const Color(0xFFB22222).withAlpha(25),
                          child: Text(
                            '${item.quantidade}x',
                            style: const TextStyle(
                                color: Color(0xFFB22222),
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
                          ),
                        ),
                        title: Text(item.nomeItem,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                            'R\$ ${item.precoUnitario.toStringAsFixed(2)} × ${item.quantidade}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'R\$ ${(item.precoUnitario * item.quantidade).toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFB22222)),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red, size: 20),
                              onPressed: () => context
                                  .read<CarrinhoProvider>()
                                  .removerTudo(item.nomeItem),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total do pedido',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(
                        'R\$ ${carrinho.totalPreco.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFB22222)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Endereço de entrega *',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _enderecoController,
                    decoration: const InputDecoration(
                      hintText: 'Ex: Rua Garibaldi, 123 – Porto Alegre',
                      prefixIcon: Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  const Text('Observação (opcional)',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _obsController,
                    decoration: const InputDecoration(
                      hintText: 'Ex: Sem cebola, por favor',
                      prefixIcon: Icon(Icons.note_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: _enviando ? null : _confirmarPedido,
                      icon: _enviando
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.check_circle_outline),
                      label: Text(
                          _enviando ? 'Enviando pedido...' : 'Confirmar Pedido'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB22222),
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }
}
