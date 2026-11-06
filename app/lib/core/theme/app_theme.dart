
import 'package:flutter/material.dart';

class AppTheme {
  // ==========================================
  // ROOMLY - NATURAL PREMIUM
  // ==========================================

  // Colores principales
  static const Color primary = Color(0xFF205843);
  static const Color primaryDark = Color(0xFF174533);
  static const Color primaryLight = Color(0xFFE2EFE6);

  // Colores complementarios
  static const Color sage = Color(0xFFA7C9B7);
  static const Color accent = Color(0xFFD99A72);

  // Fondos
  static const Color background = Color(0xFFF7F8F4);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFF0F4EF);

  // Textos
  static const Color textPrimary = Color(0xFF25312B);
  static const Color textSecondary = Color(0xFF68766D);

  // Bordes
  static const Color border = Color(0xFFDCE5DC);

  // Estados
  static const Color success = Color(0xFF27835B);
  static const Color error = Color(0xFFC34848);

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: primaryLight,
      onPrimaryContainer: primaryDark,
      secondary: sage,
      onSecondary: primaryDark,
      surface: surface,
      onSurface: textPrimary,
      error: error,
    );

    return ThemeData(
      useMaterial3: true,

      brightness: Brightness.light,

      colorScheme: colorScheme,

      scaffoldBackgroundColor: background,

      // ==========================================
      // TIPOGRAFÍA
      // ==========================================

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          letterSpacing: -0.8,
        ),
        headlineMedium: TextStyle(
          fontSize: 27,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          height: 1.5,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.5,
          color: textSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          height: 1.4,
          color: textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),

      // ==========================================
      // BARRA SUPERIOR
      // ==========================================

      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        toolbarHeight: 64,
        iconTheme: IconThemeData(
          color: primary,
          size: 23,
        ),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),

      // ==========================================
      // CAMPOS DE TEXTO
      // ==========================================

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),

        hintStyle: const TextStyle(
          fontSize: 14,
          color: textSecondary,
        ),

        labelStyle: const TextStyle(
          color: textSecondary,
          fontWeight: FontWeight.w500,
        ),

        prefixIconColor: primary,
        suffixIconColor: textSecondary,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: border,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: border,
            width: 1,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: primary,
            width: 1.8,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: error,
            width: 1.2,
          ),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: error,
            width: 1.8,
          ),
        ),
      ),

      // ==========================================
      // BOTONES PRINCIPALES
      // ==========================================

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: sage,
          disabledForegroundColor: Colors.white70,

          minimumSize: const Size.fromHeight(54),

          elevation: 0,

          padding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 15,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),

          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
        ),
      ),

      // ==========================================
      // BOTONES SECUNDARIOS
      // ==========================================

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          backgroundColor: surface,

          minimumSize: const Size.fromHeight(52),

          side: const BorderSide(
            color: border,
            width: 1.2,
          ),

          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),

          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ==========================================
      // BOTONES DE TEXTO
      // ==========================================

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ==========================================
      // TARJETAS
      // ==========================================

      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: border,
            width: 1,
          ),
        ),
      ),

      // ==========================================
      // BARRA DE NAVEGACIÓN INFERIOR
      // ==========================================

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,

        indicatorColor: primaryLight,

        height: 76,

        elevation: 0,

        labelBehavior:
            NavigationDestinationLabelBehavior.alwaysShow,

        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(
                color: primary,
                size: 24,
              );
            }

            return const IconThemeData(
              color: textSecondary,
              size: 23,
            );
          },
        ),

        labelTextStyle:
            WidgetStateProperty.resolveWith<TextStyle>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: primary,
              );
            }

            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textSecondary,
            );
          },
        ),
      ),

      // ==========================================
      // FILTROS Y CHIPS
      // ==========================================

      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: primaryLight,

        side: const BorderSide(
          color: border,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),

        labelStyle: const TextStyle(
          color: textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),

        secondaryLabelStyle: const TextStyle(
          color: primary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),

        showCheckmark: true,
        checkmarkColor: primary,
      ),

      // ==========================================
      // DIVISORES
      // ==========================================

      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),

      // ==========================================
      // VENTANAS DE CONFIRMACIÓN
      // ==========================================

      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),

      // ==========================================
      // MENSAJES INFERIORES
      // ==========================================

      snackBarTheme: SnackBarThemeData(
        backgroundColor: primaryDark,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        behavior: SnackBarBehavior.floating,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),

      // ==========================================
      // ICONOS
      // ==========================================

      iconTheme: const IconThemeData(
        color: primary,
        size: 22,
      ),

      // ==========================================
      // INDICADORES DE CARGA
      // ==========================================

      progressIndicatorTheme:
          const ProgressIndicatorThemeData(
        color: primary,
      ),

      // ==========================================
      // ELEMENTOS SELECCIONADOS
      // ==========================================

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return primary;
            }

            return null;
          },
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }

            return null;
          },
        ),

        trackColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return primary;
            }

            return null;
          },
        ),
      ),
    );
  }
}
