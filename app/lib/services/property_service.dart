import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'auth_service.dart';
import 'session_service.dart';

class PropertyService {
  final String propertiesUrl = AuthService.baseUrl.replaceFirst(
    RegExp(r'/auth/?$'),
    '/properties',
  );

  // ==========================================
  // CREAR ALOJAMIENTO
  // ==========================================

  Future<Map<String, dynamic>> createProperty({
    required String title,
    required String description,
    required String location,
    required double price,
    required String type,
    required int capacity,
    required String duration,
    required List<String> amenities,
    required String houseRules,
    required Uint8List imageBytes,
    required String imageName,
  }) async {
    final token = SessionService.instance.token;

    if (token == null || token.isEmpty) {
      throw Exception('Debes iniciar sesión nuevamente.');
    }

    if (imageBytes.length > 5 * 1024 * 1024) {
      throw Exception('La imagen no puede superar 5 MB.');
    }

    // Identificar el formato de la fotografía.
    final name = imageName.toLowerCase();
    String mimeType;

    if (name.endsWith('.png')) {
      mimeType = 'image/png';
    } else if (name.endsWith('.webp')) {
      mimeType = 'image/webp';
    } else if (name.endsWith('.jpg') || name.endsWith('.jpeg')) {
      mimeType = 'image/jpeg';
    } else {
      throw Exception('Selecciona una fotografía JPG, PNG o WebP.');
    }

    final request = http.MultipartRequest('POST', Uri.parse(propertiesUrl));

    request.headers['Authorization'] = 'Bearer $token';

    request.fields.addAll({
      'title': title.trim(),
      'description': description.trim(),
      'location': location.trim(),
      'price_monthly': price.toString(),
      'type': type,
      'capacity': capacity.toString(),
      'duration': duration,
      'amenities': jsonEncode(amenities),
      'house_rules': houseRules.trim(),
    });

    request.files.add(
      http.MultipartFile.fromBytes(
        'photo',
        imageBytes,
        filename: imageName,
        contentType: MediaType.parse(mimeType),
      ),
    );

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 45),
    );

    final response = await http.Response.fromStream(streamedResponse);

    Map<String, dynamic> data;

    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('El servidor no devolvió una respuesta válida.');
    }

    if (response.statusCode == 201 && data['success'] == true) {
      return data;
    }

    throw Exception(
      data['message']?.toString() ?? 'No fue posible publicar el alojamiento.',
    );
  }

  // ==========================================
  // NUEVO: EDITAR ALOJAMIENTO
  // ==========================================

  Future<Map<String, dynamic>> updateProperty({
    required int id,
    required String title,
    required String description,
    required String location,
    required double price,
    required String type,
    required int capacity,
    required String duration,
    required List<String> amenities,
    required String houseRules,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    // ========================================
    // 1. VALIDAR PUBLICACIÓN Y SESIÓN
    // ========================================

    if (id <= 0) {
      throw Exception('El identificador del alojamiento no es válido.');
    }

    final token = SessionService.instance.token;

    if (token == null || token.isEmpty) {
      throw Exception('Debes iniciar sesión nuevamente.');
    }

    // ========================================
    // 2. PREPARAR LA SOLICITUD
    // ========================================

    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('$propertiesUrl/$id'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    // Enviar todos los campos al backend.
    request.fields.addAll({
      'title': title.trim(),
      'description': description.trim(),
      'location': location.trim(),
      'price_monthly': price.toString(),
      'type': type,
      'capacity': capacity.toString(),
      'duration': duration,
      'amenities': jsonEncode(amenities),
      'house_rules': houseRules.trim(),
    });

    // ========================================
    // 3. FOTOGRAFÍA OPCIONAL
    // ========================================

    // Si no se envía una fotografía nueva,
    // el backend conservará la existente.
    if (imageBytes != null || imageName != null) {
      if (imageBytes == null || imageName == null) {
        throw Exception('No se pudo preparar la fotografía seleccionada.');
      }

      if (imageBytes.isEmpty) {
        throw Exception('La fotografía seleccionada está vacía.');
      }

      if (imageBytes.length > 5 * 1024 * 1024) {
        throw Exception('La imagen no puede superar 5 MB.');
      }

      final name = imageName.toLowerCase();

      String mimeType;

      if (name.endsWith('.png')) {
        mimeType = 'image/png';
      } else if (name.endsWith('.webp')) {
        mimeType = 'image/webp';
      } else if (name.endsWith('.jpg') || name.endsWith('.jpeg')) {
        mimeType = 'image/jpeg';
      } else {
        throw Exception('Selecciona una fotografía JPG, PNG o WebP.');
      }

      request.files.add(
        http.MultipartFile.fromBytes(
          'photo',
          imageBytes,
          filename: imageName,
          contentType: MediaType.parse(mimeType),
        ),
      );
    }

    // ========================================
    // 4. ENVIAR CAMBIOS AL BACKEND
    // ========================================

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 45),
    );

    final response = await http.Response.fromStream(streamedResponse);

    // ========================================
    // 5. INTERPRETAR RESPUESTA
    // ========================================

    Map<String, dynamic> data;

    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception(
        'El servidor no devolvió una respuesta válida '
        'al actualizar el alojamiento.',
      );
    }

    // Una edición correcta devuelve HTTP 200.
    if (response.statusCode == 200 && data['success'] == true) {
      return data;
    }

    // Mostrar el mensaje real del backend.
    throw Exception(
      data['message']?.toString() ??
          'No fue posible actualizar el alojamiento.',
    );
  }

  // ==========================================
  // CONSULTAR ALOJAMIENTOS PÚBLICOS
  // ==========================================

  Future<List<Map<String, dynamic>>> getProperties() async {
    final response = await http
        .get(Uri.parse(propertiesUrl))
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('No se pudieron cargar los alojamientos.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (data['success'] != true || data['properties'] is! List) {
      throw Exception('Respuesta inválida del servidor.');
    }

    return (data['properties'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  // ==========================================
  // OBTENER URL DE FOTOGRAFÍA
  // ==========================================

  String getImageUrl(String imagePath) {
    return Uri.parse(AuthService.baseUrl).resolve(imagePath).toString();
  }

  // ==========================================
  // MIS PUBLICACIONES
  // ==========================================

  Future<List<Map<String, dynamic>>> getMyProperties() async {
    final token = SessionService.instance.token;

    if (token == null || token.isEmpty) {
      throw Exception('Debes iniciar sesión nuevamente.');
    }

    final response = await http
        .get(
          Uri.parse('$propertiesUrl/mine'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 20));

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(
        data['message']?.toString() ??
            'No se pudieron consultar tus publicaciones.',
      );
    }

    return (data['properties'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  // ==========================================
  // ELIMINAR PUBLICACIÓN PROPIA
  // ==========================================

  Future<void> deleteProperty(int id) async {
    final token = SessionService.instance.token;

    if (token == null || token.isEmpty) {
      throw Exception('Debes iniciar sesión nuevamente.');
    }

    final response = await http
        .delete(
          Uri.parse('$propertiesUrl/$id'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 20));

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(
        data['message']?.toString() ?? 'No se pudo eliminar el alojamiento.',
      );
    }
  }
}
