import 'package:flutter/material.dart';

class ItemCarrinho {
  final String nomeItem;
  final double precoUnitario;
  int quantidade;

  ItemCarrinho({
    required this.nomeItem,
    required this.precoUnitario,
    this.quantidade = 1,
  });
}

class CarrinhoProvider extends ChangeNotifier {
  final List<ItemCarrinho> _itens = [];

  List<ItemCarrinho> get itens => List.unmodifiable(_itens);

  int get totalItens => _itens.fold(0, (sum, i) => sum + i.quantidade);

  double get totalPreco =>
      _itens.fold(0.0, (sum, i) => sum + i.quantidade * i.precoUnitario);

  int quantidadeItem(String nomeItem) {
    final idx = _itens.indexWhere((i) => i.nomeItem == nomeItem);
    return idx >= 0 ? _itens[idx].quantidade : 0;
  }

  void adicionar(String nomeItem, double preco) {
    final idx = _itens.indexWhere((i) => i.nomeItem == nomeItem);
    if (idx >= 0) {
      _itens[idx].quantidade++;
    } else {
      _itens.add(ItemCarrinho(nomeItem: nomeItem, precoUnitario: preco));
    }
    notifyListeners();
  }

  void remover(String nomeItem) {
    final idx = _itens.indexWhere((i) => i.nomeItem == nomeItem);
    if (idx >= 0) {
      if (_itens[idx].quantidade > 1) {
        _itens[idx].quantidade--;
      } else {
        _itens.removeAt(idx);
      }
      notifyListeners();
    }
  }

  void removerTudo(String nomeItem) {
    _itens.removeWhere((i) => i.nomeItem == nomeItem);
    notifyListeners();
  }

  void limpar() {
    _itens.clear();
    notifyListeners();
  }

  List<Map<String, dynamic>> toApiItens() {
    return _itens
        .map((i) => {
              'nome_item': i.nomeItem,
              'quantidade': i.quantidade,
              'preco_unitario': i.precoUnitario,
            })
        .toList();
  }
}
