import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/welcome_screen.dart';
import '../screens/home/home_screen.dart';

class AppRoutes {
  static const String welcome = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';

  static Map<String, WidgetBuilder> get routes => {
        welcome: (_) => const WelcomeScreen(),
        login: (_) => const LoginScreen(),
        register: (_) => const RegisterScreen(),
        home: (_) => const HomeScreen(),
      };
}
