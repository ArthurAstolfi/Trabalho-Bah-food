import 'package:flutter/material.dart';
import '../models/cardapio_item.dart';
import '../widgets/item_cardapio_card.dart';

class CardapioScreen extends StatelessWidget {
  const CardapioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cardápio Gaúcho',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B0000),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${kCardapioItems.length} itens disponíveis',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 6, bottom: 16),
            itemCount: kCardapioItems.length,
            itemBuilder: (context, index) {
              return ItemCardapioCard(item: kCardapioItems[index]);
            },
          ),
        ),
      ],
    );
  }
}
