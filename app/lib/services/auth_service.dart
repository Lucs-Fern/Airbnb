
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = String.fromEnvironment(
  'ROOMLY_API_BASE_URL',
  defaultValue: 'http://127.0.0.1:3000/api/auth',
  );

  // INICIO DE SESIÓN
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    ).timeout(const Duration(seconds: 10));

    final data =
        jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 &&
        data['success'] == true) {
      return data;
    }

    throw Exception(
      data['message']?.toString() ??
          'No fue posible iniciar sesión.',
    );
  }

  // REGISTRO DE USUARIOS
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String role,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'full_name': fullName.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
        'phone': phone.trim(),
        'role': role,
      }),
    ).timeout(const Duration(seconds: 10));

    final data =
        jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 201 &&
        data['success'] == true) {
      return data;
    }

    throw Exception(
      data['message']?.toString() ??
          'No fue posible registrar el usuario.',
    );
  }
}
