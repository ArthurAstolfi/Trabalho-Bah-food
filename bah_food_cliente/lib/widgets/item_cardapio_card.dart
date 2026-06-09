import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cardapio_item.dart';
import '../providers/carrinho_provider.dart';

class ItemCardapioCard extends StatelessWidget {
  final CardapioItem item;

  const ItemCardapioCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final carrinho = context.watch<CarrinhoProvider>();
    final qtd = carrinho.quantidadeItem(item.nome);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0E0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(item.emoji,
                    style: const TextStyle(fontSize: 32)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nome,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.descricao,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'R\$ ${item.preco.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFFB22222),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (qtd > 0) ...[
                  _BotaoQtd(
                    icon: Icons.remove,
                    onPressed: () =>
                        context.read<CarrinhoProvider>().remover(item.nome),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      '$qtd',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  _BotaoQtd(
                    icon: Icons.add,
                    onPressed: () => context
                        .read<CarrinhoProvider>()
                        .adicionar(item.nome, item.preco),
                  ),
                ] else
                  FilledButton.tonal(
                    onPressed: () => context
                        .read<CarrinhoProvider>()
                        .adicionar(item.nome, item.preco),
                    style: FilledButton.styleFrom(
                      backgroundColor:
                          const Color(0xFFB22222).withAlpha(25),
                      foregroundColor: const Color(0xFFB22222),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 16),
                        SizedBox(width: 4),
                        Text('Adicionar',
                            style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BotaoQtd extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _BotaoQtd({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton.outlined(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        style: IconButton.styleFrom(
          foregroundColor: const Color(0xFFB22222),
          side: const BorderSide(color: Color(0xFFB22222)),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
