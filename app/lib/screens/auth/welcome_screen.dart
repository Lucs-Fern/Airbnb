import 'package:flutter/material.dart';

import '../../config/app_routes.dart';
import '../../core/theme/app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, viewport) {
            final isDesktop = viewport.maxWidth >= 850;

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: viewport.maxHeight),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 40 : 24,
                      vertical: isDesktop ? 36 : 22,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1120),
                      child: isDesktop
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 10,
                                  child: _WelcomeContent(isDesktop: true),
                                ),
                                const SizedBox(width: 48),
                                const Expanded(
                                  flex: 11,
                                  child: _WelcomeVisual(isDesktop: true),
                                ),
                              ],
                            )
                          : ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 480),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _WelcomeContent(isDesktop: false),
                                  SizedBox(height: 26),
                                  _WelcomeVisual(isDesktop: false),
                                  SizedBox(height: 24),
                                ],
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ==========================================
// LOGOTIPO, MENSAJE Y BOTONES
// ==========================================

class _WelcomeContent extends StatelessWidget {
  final bool isDesktop;

  const _WelcomeContent({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final registerButton = ElevatedButton.icon(
      onPressed: () {
        Navigator.pushNamed(context, AppRoutes.register);
      },
      icon: const Icon(Icons.arrow_forward_rounded, size: 19),
      label: const Text('Crear mi cuenta'),
    );

    final loginButton = OutlinedButton(
      onPressed: () {
        Navigator.pushNamed(context, AppRoutes.login);
      },
      child: const Text('Iniciar sesión'),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logotipo
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.home_rounded,
                color: AppTheme.primary,
                size: 29,
              ),
            ),
            const SizedBox(width: 11),
            const Text(
              'Roomly',
              style: TextStyle(
                fontSize: 29,
                color: AppTheme.primary,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.2,
              ),
            ),
          ],
        ),

        SizedBox(height: isDesktop ? 48 : 34),

        // Etiqueta superior
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(40),
          ),
          child: const Text(
            'UN LUGAR PARA TI',
            style: TextStyle(
              color: AppTheme.primary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.25,
            ),
          ),
        ),

        const SizedBox(height: 18),

        // Título principal
        Text.rich(
          const TextSpan(
            children: [
              TextSpan(text: 'Tu espacio,\n'),
              TextSpan(
                text: 'tu gente.',
                style: TextStyle(color: AppTheme.primary),
              ),
            ],
          ),
          style: TextStyle(
            fontSize: isDesktop ? 54 : 40,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
            letterSpacing: -1.9,
            height: 1.08,
          ),
        ),

        const SizedBox(height: 19),

        Text(
          'Encuentra un espacio donde vivir a tu ritmo. '
          'Explora habitaciones y apartamentos, '
          'o comparte tu espacio con otras personas.',
          style: TextStyle(
            fontSize: isDesktop ? 16 : 15,
            height: 1.6,
            color: AppTheme.textSecondary,
          ),
        ),

        const SizedBox(height: 26),

        // Botones de navegación existentes
        LayoutBuilder(
          builder: (context, constraints) {
            final horizontalButtons = isDesktop && constraints.maxWidth >= 420;

            if (horizontalButtons) {
              return Row(
                children: [
                  Expanded(child: registerButton),
                  const SizedBox(width: 12),
                  Expanded(child: loginButton),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                registerButton,
                const SizedBox(height: 11),
                loginButton,
              ],
            );
          },
        ),

        const SizedBox(height: 27),

        // Ventajas de Roomly
        const Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _WelcomeBenefit(
              icon: Icons.calendar_month_outlined,
              label: 'Por días o meses',
            ),
            _WelcomeBenefit(
              icon: Icons.apartment_rounded,
              label: 'Habitaciones y apartamentos',
            ),
          ],
        ),
      ],
    );
  }
}

// ==========================================
// PEQUEÑAS ETIQUETAS
// ==========================================

class _WelcomeBenefit extends StatelessWidget {
  final IconData icon;
  final String label;

  const _WelcomeBenefit({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.primary, size: 16),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// ILUSTRACIÓN NATURAL PREMIUM
// ==========================================

class _WelcomeVisual extends StatelessWidget {
  final bool isDesktop;

  const _WelcomeVisual({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isDesktop ? 440 : 270,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppTheme.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x17205843),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Habitación ilustrada
          const Positioned.fill(
            child: CustomPaint(painter: _CozyRoomPainter()),
          ),

          // Etiqueta flotante
          Positioned(
            left: 16,
            top: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: AppTheme.primary,
                    size: 16,
                  ),
                  SizedBox(width: 7),
                  Text(
                    'Siéntete en casa',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tarjeta inferior
          Positioned(
            left: 17,
            right: 17,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x160C3325),
                    blurRadius: 18,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 19,
                    backgroundColor: AppTheme.primaryLight,
                    child: Icon(
                      Icons.favorite_rounded,
                      color: AppTheme.primary,
                      size: 19,
                    ),
                  ),
                  SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Tu próximo hogar empieza aquí',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Descubre espacios a tu medida',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// DIBUJO DE UN INTERIOR ACOGEDOR
// No requiere fotografías ni conexión a internet.
// ==========================================

class _CozyRoomPainter extends CustomPainter {
  const _CozyRoomPainter();

  void _rounded(Canvas canvas, Rect rect, double radius, Color color) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      Paint()..color = color,
    );
  }

  void _leaf(Canvas canvas, double x, double y, double angle, Color color) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(angle);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 15, height: 41),
      Paint()..color = color,
    );
    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 520, size.height / 420);

    // Fondo con degradado
    final area = Rect.fromLTWH(0, 0, 520, 420);

    canvas.drawRect(
      area,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE6F0E7), Color(0xFFF5F1E7)],
        ).createShader(area),
    );

    // Piso
    canvas.drawRect(
      const Rect.fromLTWH(0, 315, 520, 105),
      Paint()..color = const Color(0xFFD7E3D7),
    );

    canvas.drawLine(
      const Offset(0, 315),
      const Offset(520, 315),
      Paint()
        ..color = const Color(0xFFC9D8C9)
        ..strokeWidth = 3,
    );

    // Ventana
    _rounded(canvas, const Rect.fromLTWH(309, 64, 157, 222), 19, Colors.white);

    final window = RRect.fromRectAndRadius(
      const Rect.fromLTWH(321, 76, 133, 198),
      const Radius.circular(11),
    );

    canvas.save();
    canvas.clipRRect(window);

    canvas.drawRect(
      const Rect.fromLTWH(321, 76, 133, 198),
      Paint()..color = const Color(0xFFBBDACA),
    );

    // Sol
    canvas.drawCircle(
      const Offset(414, 117),
      21,
      Paint()..color = const Color(0xFFFFD98A),
    );

    // Paisaje
    canvas.drawOval(
      const Rect.fromLTWH(305, 183, 195, 115),
      Paint()..color = const Color(0xFF88B6A2),
    );

    canvas.drawOval(
      const Rect.fromLTWH(343, 204, 200, 97),
      Paint()..color = const Color(0xFF5B997D),
    );

    canvas.restore();

    // Divisiones de ventana
    canvas.drawLine(
      const Offset(388, 76),
      const Offset(388, 274),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 8,
    );

    canvas.drawLine(
      const Offset(321, 172),
      const Offset(454, 172),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 8,
    );

    // Cuadro decorativo
    _rounded(
      canvas,
      const Rect.fromLTWH(57, 91, 112, 125),
      11,
      const Color(0xFFD1BFA5),
    );

    _rounded(
      canvas,
      const Rect.fromLTWH(64, 98, 98, 111),
      7,
      const Color(0xFFF8F4E8),
    );

    canvas.drawCircle(
      const Offset(126, 131),
      19,
      Paint()..color = const Color(0xFFE8B98E),
    );

    final abstractArt = Path()
      ..moveTo(64, 189)
      ..quadraticBezierTo(95, 136, 118, 173)
      ..quadraticBezierTo(144, 205, 162, 155)
      ..lineTo(162, 209)
      ..lineTo(64, 209)
      ..close();

    canvas.drawPath(abstractArt, Paint()..color = const Color(0xFF6F9B84));

    // Alfombra
    canvas.drawOval(
      const Rect.fromLTWH(113, 327, 290, 63),
      Paint()..color = const Color(0xFFEBD7C3),
    );

    canvas.drawOval(
      const Rect.fromLTWH(140, 342, 230, 30),
      Paint()..color = const Color(0xFFF4E6D9),
    );

    // Sofá
    _rounded(
      canvas,
      const Rect.fromLTWH(153, 225, 204, 106),
      25,
      const Color(0xFF548971),
    );

    _rounded(
      canvas,
      const Rect.fromLTWH(144, 289, 220, 54),
      19,
      const Color(0xFF356C55),
    );

    // Brazos
    _rounded(
      canvas,
      const Rect.fromLTWH(132, 266, 38, 77),
      18,
      const Color(0xFF245A42),
    );

    _rounded(
      canvas,
      const Rect.fromLTWH(338, 266, 38, 77),
      18,
      const Color(0xFF245A42),
    );

    // Cojines
    _rounded(
      canvas,
      const Rect.fromLTWH(179, 257, 67, 49),
      14,
      const Color(0xFFA7C9B7),
    );

    _rounded(
      canvas,
      const Rect.fromLTWH(259, 257, 63, 49),
      14,
      const Color(0xFFDBA17E),
    );

    // Patas del sofá
    _rounded(
      canvas,
      const Rect.fromLTWH(173, 337, 13, 21),
      4,
      const Color(0xFF725745),
    );

    _rounded(
      canvas,
      const Rect.fromLTWH(322, 337, 13, 21),
      4,
      const Color(0xFF725745),
    );

    // Planta decorativa
    canvas.drawLine(
      const Offset(82, 314),
      const Offset(83, 236),
      Paint()
        ..color = const Color(0xFF477D5D)
        ..strokeWidth = 4,
    );

    _leaf(canvas, 64, 261, -0.55, const Color(0xFF438360));
    _leaf(canvas, 99, 248, 0.55, const Color(0xFF4C9872));
    _leaf(canvas, 78, 228, -0.15, const Color(0xFF2D7253));
    _leaf(canvas, 111, 279, 0.85, const Color(0xFF7AA88A));

    // Maceta
    _rounded(
      canvas,
      const Rect.fromLTWH(62, 298, 45, 46),
      7,
      const Color(0xFFD99A72),
    );

    // Mesa auxiliar
    _rounded(
      canvas,
      const Rect.fromLTWH(395, 319, 64, 13),
      6,
      const Color(0xFFA87855),
    );

    canvas.drawLine(
      const Offset(409, 331),
      const Offset(409, 359),
      Paint()
        ..color = const Color(0xFF947354)
        ..strokeWidth = 5,
    );

    canvas.drawLine(
      const Offset(443, 331),
      const Offset(443, 359),
      Paint()
        ..color = const Color(0xFF947354)
        ..strokeWidth = 5,
    );

    // Florero
    _rounded(
      canvas,
      const Rect.fromLTWH(415, 296, 21, 23),
      5,
      const Color(0xFFF7F8F4),
    );

    _leaf(canvas, 428, 288, -0.4, const Color(0xFF4E8761));
    _leaf(canvas, 436, 285, 0.4, const Color(0xFF65A17A));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
