import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  Usuario? _usuario;
  bool _isLoading = false;
  String? _erro;

  Usuario? get usuario => _usuario;
  bool get isLoading => _isLoading;
  String? get erro => _erro;

  Future<void> loginOuCriar({
    required String nome,
    required String email,
  }) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      final emailNorm = email.trim().toLowerCase();
      Usuario? existente = await ApiService.buscarPorEmail(emailNorm);
      if (existente != null) {
        if (existente.perfil != 'CLIENTE') {
          _erro = 'Este e-mail pertence a um Prestador. Use o app do Prestador.';
          return;
        }
        _usuario = existente;
      } else {
        _usuario = await ApiService.criarUsuario(
          nome: nome.trim(),
          email: emailNorm,
          perfil: 'CLIENTE',
        );
      }
    } catch (e) {
      _erro = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _usuario = null;
    _erro = null;
    notifyListeners();
  }
}
