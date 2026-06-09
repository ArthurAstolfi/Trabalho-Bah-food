import 'dart:convert';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:http/http.dart' as http;
import '../models/usuario.dart';
import '../models/pedido.dart';

String get kBaseUrl {
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:3000/api';
  }
  return 'http://localhost:3000/api';
}

class ApiService {
  static Future<Usuario?> buscarPorEmail(String email) async {
    final uri = Uri.parse('$kBaseUrl/usuarios/buscar')
        .replace(queryParameters: {'email': email});
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return Usuario.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    if (response.statusCode == 404) return null;
    throw Exception('Erro ao buscar usuário: ${response.statusCode}');
  }

  static Future<Usuario> criarUsuario({
    required String nome,
    required String email,
    String perfil = 'PRESTADOR',
  }) async {
    final response = await http.post(
      Uri.parse('$kBaseUrl/usuarios'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nome': nome, 'email': email, 'perfil': perfil}),
    );
    if (response.statusCode == 201) {
      return Usuario.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    final body = jsonDecode(response.body);
    throw Exception(body['error'] ?? 'Erro ao criar usuário');
  }

  // Pedidos com status PENDENTE — visíveis para todos os prestadores
  static Future<List<Pedido>> listarPedidosPendentes() async {
    final response = await http.get(
      Uri.parse('$kBaseUrl/pedidos').replace(
          queryParameters: {'status': 'PENDENTE'}),
    );
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List<dynamic>;
      return list
          .map((j) => Pedido.fromJson(j as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Erro ao listar pedidos: ${response.statusCode}');
  }

  // Pedidos onde este prestador é o responsável
  static Future<List<Pedido>> listarMeusPedidos(int prestadorId) async {
    final response = await http.get(
      Uri.parse('$kBaseUrl/pedidos').replace(
          queryParameters: {'prestador_id': '$prestadorId'}),
    );
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List<dynamic>;
      return list
          .map((j) => Pedido.fromJson(j as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Erro ao listar meus pedidos: ${response.statusCode}');
  }

  static Future<Pedido> buscarPedido(int id) async {
    final response = await http.get(Uri.parse('$kBaseUrl/pedidos/$id'));
    if (response.statusCode == 200) {
      return Pedido.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Pedido não encontrado');
  }

  static Future<Pedido> atualizarStatus({
    required int pedidoId,
    required String novoStatus,
    int? prestadorId,
  }) async {
    final body = <String, dynamic>{'status': novoStatus};
    if (prestadorId != null) body['prestador_id'] = prestadorId;

    final response = await http.patch(
      Uri.parse('$kBaseUrl/pedidos/$pedidoId/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode == 200) {
      return Pedido.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    final err = jsonDecode(response.body);
    throw Exception(err['error'] ?? 'Erro ao atualizar status');
  }
}
