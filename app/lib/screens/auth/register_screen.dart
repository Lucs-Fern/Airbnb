import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  String _role = 'Huésped';
  bool _hidePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Datos válidos. El registro se conectará al backend '
          'en una siguiente fase.',
        ),
      ),
    );
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
              constraints: const BoxConstraints(maxWidth: 460),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Crea tu cuenta',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 30,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Empieza a encontrar tu lugar y tu gente.',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Nombre completo',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          hintText: 'Tu nombre',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().length < 3) {
                            return 'Ingresa tu nombre completo.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Correo electrónico',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'nombre@correo.com',
                          prefixIcon: Icon(Icons.mail_outline_rounded),
                        ),
                        validator: (value) {
                          final email = value?.trim() ?? '';
                          if (!RegExp(
                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                          ).hasMatch(email)) {
                            return 'Ingresa un correo válido.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Teléfono',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          hintText: 'Número de contacto',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        validator: (value) {
                          final phone = (value ?? '').replaceAll(
                            RegExp(r'\D'),
                            '',
                          );
                          if (phone.length < 7 || phone.length > 15) {
                            return 'Ingresa un teléfono válido.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        '¿Cómo utilizarás Roomly?',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _role,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.people_outline_rounded),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Huésped',
                            child: Text('Busco alojamiento'),
                          ),
                          DropdownMenuItem(
                            value: 'Anfitrión',
                            child: Text('Quiero publicar un alojamiento'),
                          ),
                          DropdownMenuItem(
                            value: 'Roomie',
                            child: Text('Busco compañeros de vivienda'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _role = value);
                          }
                        },
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Contraseña',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _hidePassword,
                        decoration: InputDecoration(
                          hintText: 'Mínimo 8 caracteres',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            onPressed: () {
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
                          if (value == null || value.length < 8) {
                            return 'Usa al menos 8 caracteres.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Confirmar contraseña',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: 'Escribe otra vez tu contraseña',
                          prefixIcon: Icon(Icons.lock_outline_rounded),
                        ),
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return 'Las contraseñas no coinciden.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),
                      ElevatedButton(
                        onPressed: _submit,
                        child: const Text('Crear cuenta'),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Por ahora este formulario valida los datos localmente. '
                        'El registro real se conectará al backend.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          height: 1.5,
                        ),
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
