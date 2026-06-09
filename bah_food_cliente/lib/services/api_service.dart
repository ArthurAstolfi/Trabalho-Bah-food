import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';
import '../models/pedido.dart';

// Para emulador Android use 10.0.2.2; para iOS use localhost; para dispositivo físico use o IP da máquina
const String kBaseUrl = 'http://10.0.2.2:3000/api';

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
    String perfil = 'CLIENTE',
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

  static Future<List<Pedido>> listarPedidosDoUsuario(int usuarioId) async {
    final response =
        await http.get(Uri.parse('$kBaseUrl/usuarios/$usuarioId/pedidos'));
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List<dynamic>;
      return list
          .map((j) => Pedido.fromJson(j as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Erro ao listar pedidos: ${response.statusCode}');
  }

  static Future<Pedido> buscarPedido(int id) async {
    final response = await http.get(Uri.parse('$kBaseUrl/pedidos/$id'));
    if (response.statusCode == 200) {
      return Pedido.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Pedido não encontrado');
  }

  static Future<Pedido> criarPedido({
    required int clienteId,
    required String enderecoEntrega,
    String? observacao,
    required List<Map<String, dynamic>> itens,
  }) async {
    final response = await http.post(
      Uri.parse('$kBaseUrl/pedidos'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'cliente_id': clienteId,
        'endereco_entrega': enderecoEntrega,
        if (observacao != null && observacao.isNotEmpty) 'observacao': observacao,
        'itens': itens,
      }),
    );
    if (response.statusCode == 201) {
      return Pedido.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    final body = jsonDecode(response.body);
    throw Exception(body['error'] ?? 'Erro ao criar pedido');
  }
}
