import 'package:flutter/material.dart';

import 'config/app_routes.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RoomlyApp());
}

class RoomlyApp extends StatelessWidget {
  const RoomlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roomly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.welcome,
      routes: AppRoutes.routes,
    );
  }
}