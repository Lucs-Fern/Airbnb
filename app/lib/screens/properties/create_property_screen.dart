
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_theme.dart';
import '../../services/property_service.dart';
import '../../services/session_service.dart';

class CreatePropertyScreen extends StatefulWidget {
  const CreatePropertyScreen({super.key});

  @override
  State<CreatePropertyScreen> createState() =>
      _CreatePropertyScreenState();
}

class _CreatePropertyScreenState
    extends State<CreatePropertyScreen> {
  final _formKey = GlobalKey<FormState>();

  final _title = TextEditingController();
  final _description = TextEditingController();
  final _location = TextEditingController();
  final _price = TextEditingController();
  final _capacity = TextEditingController();
  final _houseRules = TextEditingController();

  final _service = PropertyService();
  final _picker = ImagePicker();

  String _type = 'Apartamento';
  String _duration = 'Largo plazo';

  final Set<String> _amenities = {};

  XFile? _photo;
  Uint8List? _photoBytes;
  bool _saving = false;

  static const _availableAmenities = [
    'WiFi',
    'Cocina',
    'Lavadora',
    'Parqueadero',
    'Aire acondicionado',
    'Amoblado',
    'Servicios incluidos',
    'Mascotas permitidas',
  ];

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _location.dispose();
    _price.dispose();
    _capacity.dispose();
    _houseRules.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  Future<void> _selectPhoto() async {
    try {
      final photo = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 80,
      );

      if (photo == null) return;

      final bytes = await photo.readAsBytes();

      if (bytes.length > 5 * 1024 * 1024) {
        _showError('La imagen no puede superar 5 MB.');
        return;
      }

      if (!mounted) return;

      setState(() {
        _photo = photo;
        _photoBytes = bytes;
      });
    } catch (_) {
      _showError(
        'No fue posible seleccionar la fotografía.',
      );
    }
  }

  Future<void> _publish() async {
    if (_saving) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!SessionService.instance.isHost) {
      _showError(
        'Solo los anfitriones pueden publicar alojamientos.',
      );
      return;
    }

    if (_photo == null || _photoBytes == null) {
      _showError('Selecciona una fotografía.');
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await _service.createProperty(
        title: _title.text,
        description: _description.text,
        location: _location.text,
        price: double.parse(_price.text.trim()),
        type: _type,
        capacity: int.parse(_capacity.text.trim()),
        duration: _duration,
        amenities: _amenities.toList(),
        houseRules: _houseRules.text,
        imageBytes: _photoBytes!,
        imageName: _photo!.name,
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (error) {
      _showError(
        error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    required String? Function(String?) validator,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            enabled: !_saving,
            maxLines: maxLines,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicar alojamiento'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text(
                    'Nueva publicación',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Completa la información del alojamiento '
                    'que deseas ofrecer.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // FOTOGRAFÍA
                  if (_photoBytes != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.memory(
                        _photoBytes!,
                        height: 210,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      height: 170,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 60,
                        color: AppTheme.primary,
                      ),
                    ),

                  const SizedBox(height: 12),

                  OutlinedButton.icon(
                    onPressed: _saving ? null : _selectPhoto,
                    icon: const Icon(
                      Icons.photo_library_outlined,
                    ),
                    label: Text(
                      _photo == null
                          ? 'Seleccionar fotografía'
                          : 'Cambiar fotografía',
                    ),
                  ),

                  const SizedBox(height: 22),

                  _field(
                    'Título del alojamiento',
                    _title,
                    hint: 'Ej. Habitación privada en Cali',
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.length < 5 ||
                          text.length > 150) {
                        return 'Escribe un título de 5 a 150 caracteres.';
                      }
                      return null;
                    },
                  ),

                  _field(
                    'Descripción',
                    _description,
                    maxLines: 4,
                    hint: 'Describe el espacio y sus características',
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.length < 20 ||
                          text.length > 5000) {
                        return 'La descripción debe tener entre 20 y 5000 caracteres.';
                      }
                      return null;
                    },
                  ),

                  _field(
                    'Ubicación o barrio',
                    _location,
                    hint: 'Ej. San Fernando, Cali',
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.length < 3 ||
                          text.length > 200) {
                        return 'Ingresa una ubicación válida.';
                      }
                      return null;
                    },
                  ),

                  const Text(
                    'Tipo de alojamiento',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  DropdownButtonFormField<String>(
                    initialValue: _type,
                    items: const [
                      DropdownMenuItem(
                        value: 'Apartamento',
                        child: Text('Apartamento'),
                      ),
                      DropdownMenuItem(
                        value: 'Habitación',
                        child: Text('Habitación'),
                      ),
                    ],
                    onChanged: _saving
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() => _type = value);
                            }
                          },
                  ),

                  const SizedBox(height: 18),

                  _field(
                    'Precio mensual (COP)',
                    _price,
                    hint: 'Ej. 550000',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final price =
                          double.tryParse(value?.trim() ?? '');
                      if (price == null || price <= 0) {
                        return 'Ingresa un precio válido.';
                      }
                      return null;
                    },
                  ),

                  _field(
                    'Capacidad de personas',
                    _capacity,
                    hint: 'Ej. 2',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final number =
                          int.tryParse(value?.trim() ?? '');
                      if (number == null ||
                          number < 1 ||
                          number > 30) {
                        return 'Ingresa entre 1 y 30 personas.';
                      }
                      return null;
                    },
                  ),

                  const Text(
                    'Duración del arrendamiento',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  DropdownButtonFormField<String>(
                    initialValue: _duration,
                    items: const [
                      DropdownMenuItem(
                        value: 'Corto plazo',
                        child: Text('Corto plazo'),
                      ),
                      DropdownMenuItem(
                        value: 'Mediano plazo',
                        child: Text('Mediano plazo'),
                      ),
                      DropdownMenuItem(
                        value: 'Largo plazo',
                        child: Text('Largo plazo'),
                      ),
                      DropdownMenuItem(
                        value: 'Mediano y largo plazo',
                        child: Text('Mediano y largo plazo'),
                      ),
                    ],
                    onChanged: _saving
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(
                                () => _duration = value,
                              );
                            }
                          },
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Servicios del alojamiento',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    runSpacing: 5,
                    children: _availableAmenities.map((item) {
                      return FilterChip(
                        label: Text(item),
                        selected: _amenities.contains(item),
                        onSelected: _saving
                            ? null
                            : (selected) {
                                setState(() {
                                  if (selected) {
                                    _amenities.add(item);
                                  } else {
                                    _amenities.remove(item);
                                  }
                                });
                              },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 22),

                  _field(
                    'Reglas de convivencia (opcional)',
                    _houseRules,
                    maxLines: 3,
                    hint:
                        'Ej. No fumar, mascotas permitidas, '
                        'horarios de visitas...',
                    validator: (value) {
                      if ((value ?? '').length > 2000) {
                        return 'Máximo 2000 caracteres.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  ElevatedButton.icon(
                    onPressed: _saving ? null : _publish,
                    icon: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.publish_rounded,
                          ),
                    label: Text(
                      _saving
                          ? 'Publicando...'
                          : 'Publicar alojamiento',
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
