class SessionService {
  SessionService._();

  static final SessionService instance =
      SessionService._();

  String? token;
  String? role;
  String? fullName;

  bool get isLoggedIn => token != null;

  bool get isHost =>
      isLoggedIn && role == 'anfitrion';

  void saveLogin(Map<String, dynamic> response) {
    final receivedToken = response['token'];
    final user = response['user'];

    if (receivedToken is! String ||
        receivedToken.isEmpty ||
        user is! Map ||
        user['role'] is! String) {
      throw const FormatException(
        'El servidor devolvió una sesión inválida.',
      );
    }

    token = receivedToken;
    role = user['role'] as String;
    fullName = user['full_name']?.toString();
  }

  void logout() {
    token = null;
    role = null;
    fullName = null;
  }
}