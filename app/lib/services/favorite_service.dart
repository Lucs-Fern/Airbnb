import 'dart:convert';

import 'package:http/http.dart' as http;

import 'auth_service.dart';
import 'session_service.dart';

// ==========================================
// ROOMLY - FAVORITOS PERMANENTES
// ==========================================

class FavoriteService {
  final String favoritesUrl = AuthService.baseUrl.replaceFirst(
    RegExp(r'/auth/?$'),
    '/favorites',
  );

  // ========================================
  // OBTENER TOKEN DEL USUARIO
  // ========================================

  String _getToken() {
    final token = SessionService.instance.token;

    if (token == null || token.isEmpty) {
      throw Exception('Debes iniciar sesión para gestionar tus favoritos.');
    }

    return token;
  }

  // ========================================
  // INTERPRETAR RESPUESTA DEL SERVIDOR
  // ========================================

  Map<String, dynamic> _readResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      throw const FormatException();
    } catch (_) {
      throw Exception('El servidor no devolvió una respuesta válida.');
    }
  }

  // ========================================
  // CONSULTAR MIS FAVORITOS
  // ========================================

  Future<List<Map<String, dynamic>>> getFavorites() async {
    final token = _getToken();

    final response = await http
        .get(
          Uri.parse(favoritesUrl),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 20));

    final data = _readResponse(response);

    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(
        data['message']?.toString() ?? 'No fue posible cargar tus favoritos.',
      );
    }

    if (data['favorites'] is! List) {
      throw Exception('La lista de favoritos no tiene un formato válido.');
    }

    return (data['favorites'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  // ========================================
  // AGREGAR A FAVORITOS
  // ========================================

  Future<void> addFavorite(int propertyId) async {
    if (propertyId <= 0) {
      throw Exception('El alojamiento seleccionado no es válido.');
    }

    final token = _getToken();

    final response = await http
        .post(
          Uri.parse('$favoritesUrl/$propertyId'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 20));

    final data = _readResponse(response);

    // El backend puede responder 201 al crear
    // o 200 si ya estaba guardado.
    if ((response.statusCode == 200 || response.statusCode == 201) &&
        data['success'] == true) {
      return;
    }

    throw Exception(
      data['message']?.toString() ?? 'No fue posible agregar el favorito.',
    );
  }

  // ========================================
  // QUITAR DE FAVORITOS
  // ========================================

  Future<void> removeFavorite(int propertyId) async {
    if (propertyId <= 0) {
      throw Exception('El alojamiento seleccionado no es válido.');
    }

    final token = _getToken();

    final response = await http
        .delete(
          Uri.parse('$favoritesUrl/$propertyId'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 20));

    final data = _readResponse(response);

    if (response.statusCode == 200 && data['success'] == true) {
      return;
    }

    throw Exception(
      data['message']?.toString() ?? 'No fue posible quitar el favorito.',
    );
  }

  // ========================================
  // OBTENER IDS DE MIS FAVORITOS
  // ========================================

  // Permite que Flutter sepa cuáles
  // corazones deben aparecer marcados.
  Future<Set<int>> getFavoriteIds() async {
    final favorites = await getFavorites();

    final ids = <int>{};

    for (final property in favorites) {
      final id = int.tryParse(property['id']?.toString() ?? '');

      if (id != null && id > 0) {
        ids.add(id);
      }
    }

    return ids;
  }
}
