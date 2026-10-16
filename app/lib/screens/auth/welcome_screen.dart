import 'package:flutter/material.dart';

import '../../config/app_routes.dart';
import '../../core/theme/app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.house_rounded,
                            color: AppTheme.primary,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Roomly',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary,
                            letterSpacing: -1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 34),
                    const Text(
                      'Tu espacio,\ntu gente.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 36,
                        height: 1.12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.2,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Encuentra un lugar donde vivir y personas '
                      'con las que puedas sentirte a gusto.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Ilustración provisional hecha con Flutter.
                    Container(
                      height: 235,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE4EFE5),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            top: 22,
                            right: 26,
                            child: Icon(
                              Icons.wb_sunny_rounded,
                              color: Colors.amber.shade600,
                              size: 36,
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 112,
                                height: 112,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const Icon(
                                  Icons.home_work_rounded,
                                  size: 72,
                                  color: AppTheme.primary,
                                ),
                              ),
                              const SizedBox(height: 18),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _PersonAvatar(color: Color(0xFFD9A47E)),
                                  SizedBox(width: 10),
                                  _PersonAvatar(color: Color(0xFF8FB9A0)),
                                  SizedBox(width: 10),
                                  _PersonAvatar(color: Color(0xFFB5A3D8)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Encuentra tu próximo hogar',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Alquila por días, meses o más tiempo. '
                      'Vive solo o encuentra tu próximo roomie.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 28),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.register);
                      },
                      child: const Text('Comenzar'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.login);
                      },
                      child: const Text('Ya tengo una cuenta'),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Encuentra un lugar que se adapte a ti.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PersonAvatar extends StatelessWidget {
  final Color color;

  const _PersonAvatar({required this.color});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 23,
      backgroundColor: color,
      child: const Icon(
        Icons.person_rounded,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}