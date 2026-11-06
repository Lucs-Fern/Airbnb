
import 'package:flutter/material.dart';

import '../../config/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/session_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _hidePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // INICIO DE SESIÓN REAL CON NODE.JS
  Future<void> _submit() async {
    // Validar los campos
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Evitar múltiples solicitudes
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Enviar credenciales al backend
      final response = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      SessionService.instance.saveLogin(response);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // Mostrar confirmación
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response['message']?.toString() ??
                'Inicio de sesión exitoso.',
          ),
          backgroundColor: AppTheme.primary,
        ),
      );

      // Entrar al Home solamente si el backend
      // confirmó que las credenciales son correctas
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.home,
      );

    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // Mostrar error del backend
      String message = error.toString();

      message = message.replaceFirst(
        'Exception: ',
        '',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Volver',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 460,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.house_rounded,
                        color: AppTheme.primary,
                        size: 54,
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Qué bueno verte de nuevo',
                        style: TextStyle(
                          fontSize: 29,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        'Inicia sesión para continuar con Roomly.',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // CORREO ELECTRÓNICO
                      const Text(
                        'Correo electrónico',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _emailController,
                        enabled: !_isLoading,
                        keyboardType:
                            TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'nombre@correo.com',
                          prefixIcon: Icon(
                            Icons.mail_outline_rounded,
                          ),
                        ),
                        validator: (value) {
                          final email =
                              value?.trim() ?? '';

                          if (email.isEmpty) {
                            return 'Ingresa tu correo electrónico.';
                          }

                          if (!RegExp(
                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                          ).hasMatch(email)) {
                            return 'Ingresa un correo válido.';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // CONTRASEÑA
                      const Text(
                        'Contraseña',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _passwordController,
                        enabled: !_isLoading,
                        obscureText: _hidePassword,
                        decoration: InputDecoration(
                          hintText: 'Ingresa tu contraseña',
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                          ),
                          suffixIcon: IconButton(
                            tooltip: _hidePassword
                                ? 'Mostrar contraseña'
                                : 'Ocultar contraseña',
                            onPressed: () {
                              setState(() {
                                _hidePassword =
                                    !_hidePassword;
                              });
                            },
                            icon: Icon(
                              _hidePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty) {
                            return 'Ingresa tu contraseña.';
                          }

                          return null;
                        },
                      ),

                      // RECUPERAR CONTRASEÑA
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'La recuperación por correo '
                                        'se desarrollará en una '
                                        'siguiente fase.',
                                      ),
                                    ),
                                  );
                                },
                          child: const Text(
                            '¿Olvidaste tu contraseña?',
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // BOTÓN DE LOGIN
                      ElevatedButton(
                        onPressed:
                            _isLoading ? null : _submit,
                        child: _isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Iniciar sesión',
                              ),
                      ),

                      const SizedBox(height: 20),

                      // IR AL REGISTRO
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment:
                            WrapCrossAlignment.center,
                        children: [
                          const Text(
                            '¿No tienes cuenta?',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          TextButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    Navigator
                                        .pushReplacementNamed(
                                      context,
                                      AppRoutes.register,
                                    );
                                  },
                            child: const Text(
                              'Regístrate',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
