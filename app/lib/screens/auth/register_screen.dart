import 'dart:convert';

import 'package:flutter/material.dart';

import '../../config/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _authService = AuthService();

  String? _selectedRole;
  bool _hidePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _authService.register(
        fullName: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        password: _passwordController.text,
        role: _selectedRole!,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response['message']?.toString() ?? 'Usuario registrado con éxito.',
          ),
          backgroundColor: AppTheme.primary,
        ),
      );

      // Después de registrarse debe iniciar sesión.
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    } catch (error) {
      if (!mounted) return;

      final message = error.toString().replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
      );

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _isLoading
              ? null
              : () {
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.house_rounded,
                          color: AppTheme.primary,
                          size: 32,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Crea tu cuenta en Roomly',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Regístrate para encontrar un hogar '
                      'o publicar tu alojamiento.',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),

                    const SizedBox(height: 28),

                    // NOMBRE
                    const Text('Nombre completo'),
                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _nameController,
                      enabled: !_isLoading,
                      decoration: const InputDecoration(
                        hintText: 'Tu nombre completo',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      validator: (value) {
                        final name = value?.trim() ?? '';

                        if (name.length < 2 || name.length > 120) {
                          return 'Ingresa un nombre válido.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // CORREO
                    const Text('Correo electrónico'),
                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _emailController,
                      enabled: !_isLoading,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'nombre@correo.com',
                        prefixIcon: Icon(Icons.mail_outline_rounded),
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';

                        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                .hasMatch(email) ||
                            email.length > 255) {
                          return 'Ingresa un correo válido.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // TELÉFONO
                    const Text('Teléfono (opcional)'),
                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _phoneController,
                      enabled: !_isLoading,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        hintText: 'Número de contacto',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: (value) {
                        if ((value ?? '').length > 25) {
                          return 'El número es demasiado largo.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // ROL
                    const Text('¿Cómo usarás Roomly?'),
                    const SizedBox(height: 8),

                    DropdownButtonFormField<String>(
                      initialValue: _selectedRole,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.people_outline_rounded),
                      ),
                      hint: const Text('Selecciona un rol'),
                      items: const [
                        DropdownMenuItem(
                          value: 'huesped',
                          child: Text('Huésped'),
                        ),
                        DropdownMenuItem(
                          value: 'anfitrion',
                          child: Text('Anfitrión'),
                        ),
                        DropdownMenuItem(
                          value: 'roomie',
                          child: Text('Roomie'),
                        ),
                      ],
                      onChanged: _isLoading
                          ? null
                          : (value) {
                              setState(() {
                                _selectedRole = value;
                              });
                            },
                      validator: (value) {
                        if (value == null) {
                          return 'Selecciona un rol.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // CONTRASEÑA
                    const Text('Contraseña'),
                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _passwordController,
                      enabled: !_isLoading,
                      obscureText: _hidePassword,
                      decoration: InputDecoration(
                        hintText: 'Mínimo 8 caracteres',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  setState(() {
                                    _hidePassword = !_hidePassword;
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
                        final password = value ?? '';

                        if (password.length < 8) {
                          return 'Usa al menos 8 caracteres.';
                        }

                        if (utf8.encode(password).length > 72) {
                          return 'La contraseña es demasiado larga.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // CONFIRMAR CONTRASEÑA
                    const Text('Confirmar contraseña'),
                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _confirmPasswordController,
                      enabled: !_isLoading,
                      obscureText: _hidePassword,
                      decoration: const InputDecoration(
                        hintText: 'Repite tu contraseña',
                        prefixIcon: Icon(Icons.lock_reset_rounded),
                      ),
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Las contraseñas no coinciden.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 28),

                    // CREAR CUENTA
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Crear cuenta'),
                    ),

                    const SizedBox(height: 16),

                    // VOLVER A LOGIN
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Flexible(child: Text('¿Ya tienes cuenta?')),
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    AppRoutes.login,
                                  );
                                },
                          child: const Text('Inicia sesión'),
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
    );
  }
}
