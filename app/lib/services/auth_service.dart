
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl =
      'http://127.0.0.1:3000/api/auth';

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

    final data = jsonDecode(response.body)
        as Map<String, dynamic>;

    if (response.statusCode == 200 &&
        data['success'] == true) {
      return data;
    }

    throw Exception(
      data['message'] ?? 'No fue posible iniciar sesión.',
    );
  }
}
 