import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_theme.dart';
import '../../services/property_service.dart';
import '../../services/session_service.dart';

class CreatePropertyScreen extends StatefulWidget {
  // Si se recibe una publicación, se abre en modo edición.
  // Si no se recibe, funciona como formulario de creación.
  final Map<String, dynamic>? property;

  const CreatePropertyScreen({super.key, this.property});

  @override
  State<CreatePropertyScreen> createState() => _CreatePropertyScreenState();
}

class _CreatePropertyScreenState extends State<CreatePropertyScreen> {
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

  bool get _isEditing => widget.property != null;

  static const List<String> _availableAmenities = [
    'WiFi',
    'Cocina',
    'Lavadora',
    'Parqueadero',
    'Aire acondicionado',
    'Amoblado',
    'Servicios incluidos',
    'Mascotas permitidas',
  ];

  static const List<String> _availableTypes = ['Apartamento', 'Habitación'];

  static const List<String> _availableDurations = [
    'Corto plazo',
    'Mediano plazo',
    'Largo plazo',
    'Mediano y largo plazo',
  ];

  // ==========================================
  // INICIALIZAR FORMULARIO
  // ==========================================

  @override
  void initState() {
    super.initState();

    // Cuando creamos una publicación nueva,
    // dejamos los campos vacíos.
    if (!_isEditing) {
      return;
    }

    // Cuando editamos, recuperamos sus datos.
    final property = widget.property!;

    _title.text = property['title']?.toString() ?? '';

    _description.text = property['description']?.toString() ?? '';

    _location.text = property['location']?.toString() ?? '';

    final savedPrice = property['price_monthly'];

    _price.text = savedPrice == null
        ? ''
        : savedPrice.toString().replaceFirst(RegExp(r'\.0+$'), '');

    _capacity.text = property['capacity']?.toString() ?? '';

    _houseRules.text = property['house_rules']?.toString() ?? '';

    final savedType = property['type']?.toString() ?? '';

    if (_availableTypes.contains(savedType)) {
      _type = savedType;
    }

    final savedDuration = property['duration']?.toString() ?? '';

    if (_availableDurations.contains(savedDuration)) {
      _duration = savedDuration;
    }

    _loadAmenities(property['amenities']);
  }

  // ==========================================
  // RECUPERAR SERVICIOS EXISTENTES
  // ==========================================

  void _loadAmenities(dynamic value) {
    if (value == null) {
      return;
    }

    // Normalmente PostgreSQL devuelve una lista.
    if (value is List) {
      for (final item in value) {
        final amenity = item.toString().trim();

        if (amenity.isNotEmpty) {
          _amenities.add(amenity);
        }
      }

      return;
    }

    // Algunas respuestas pueden contener JSON.
    if (value is String) {
      try {
        final decoded = jsonDecode(value);

        if (decoded is List) {
          for (final item in decoded) {
            final amenity = item.toString().trim();

            if (amenity.isNotEmpty) {
              _amenities.add(amenity);
            }
          }

          return;
        }
      } catch (_) {
        // Se intenta el formato de arreglo PostgreSQL.
      }

      // Compatibilidad con valores tipo {WiFi,Cocina}.
      if (value.startsWith('{') && value.endsWith('}')) {
        final content = value.substring(1, value.length - 1);

        for (final item in content.split(',')) {
          final amenity = item.trim();

          if (amenity.isNotEmpty) {
            _amenities.add(amenity);
          }
        }
      }
    }
  }

  // ==========================================
  // LIBERAR CONTROLADORES
  // ==========================================

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

  // ==========================================
  // MOSTRAR ERRORES
  // ==========================================

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ==========================================
  // SELECCIONAR FOTOGRAFÍA
  // ==========================================

  Future<void> _selectPhoto() async {
    if (_saving) return;

    try {
      final photo = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 80,
      );

      if (photo == null) return;

      final name = photo.name.toLowerCase();

      final validFormat =
          name.endsWith('.jpg') ||
          name.endsWith('.jpeg') ||
          name.endsWith('.png') ||
          name.endsWith('.webp');

      if (!validFormat) {
        _showError('Selecciona una fotografía JPG, PNG o WebP.');
        return;
      }

      final bytes = await photo.readAsBytes();

      if (bytes.isEmpty) {
        _showError('La fotografía seleccionada está vacía.');
        return;
      }

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
      _showError('No fue posible seleccionar la fotografía.');
    }
  }

  // ==========================================
  // GUARDAR PUBLICACIÓN
  // ==========================================

  Future<void> _saveProperty() async {
    if (_saving) return;

    // Validar los datos del formulario.
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    // Comprobar que el usuario sea anfitrión.
    if (!SessionService.instance.isHost) {
      _showError('Solo los anfitriones pueden administrar alojamientos.');
      return;
    }

    // Al crear una publicación, la foto es obligatoria.
    if (!_isEditing && (_photo == null || _photoBytes == null)) {
      _showError('Selecciona una fotografía.');
      return;
    }

    // Comprobar el ID antes de intentar editar.
    final propertyId = _isEditing
        ? int.tryParse(widget.property?['id']?.toString() ?? '')
        : null;

    if (_isEditing && (propertyId == null || propertyId <= 0)) {
      _showError('No se pudo identificar el alojamiento.');
      return;
    }

    final price = double.tryParse(_price.text.trim());

    final capacity = int.tryParse(_capacity.text.trim());

    if (price == null ||
        !price.isFinite ||
        price <= 0 ||
        capacity == null ||
        capacity < 1 ||
        capacity > 30) {
      _showError('Revisa el precio y la capacidad.');
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      if (_isEditing) {
        // ==================================
        // ACTUALIZAR PUBLICACIÓN EXISTENTE
        // ==================================

        await _service.updateProperty(
          id: propertyId!,
          title: _title.text,
          description: _description.text,
          location: _location.text,
          price: price,
          type: _type,
          capacity: capacity,
          duration: _duration,
          amenities: _amenities.toList(),
          houseRules: _houseRules.text,
          imageBytes: _photoBytes,
          imageName: _photo?.name,
        );
      } else {
        // ==================================
        // CREAR PUBLICACIÓN NUEVA
        // ==================================

        await _service.createProperty(
          title: _title.text,
          description: _description.text,
          location: _location.text,
          price: price,
          type: _type,
          capacity: capacity,
          duration: _duration,
          amenities: _amenities.toList(),
          houseRules: _houseRules.text,
          imageBytes: _photoBytes!,
          imageName: _photo!.name,
        );
      }

      if (!mounted) return;

      // True indica que se guardaron cambios.
      // La pantalla anterior podrá actualizar su lista.
      Navigator.pop(context, true);
    } catch (error) {
      _showError(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  // ==========================================
  // ENCABEZADOS DEL FORMULARIO
  // ==========================================

  Widget _sectionHeading(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 21, color: AppTheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // CAMPOS DE TEXTO
  // ==========================================

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
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            enabled: !_saving,
            maxLines: maxLines,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(hintText: hint),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // FOTOGRAFÍA ACTUAL O NUEVA
  // ==========================================

  Widget _photoPlaceholder() {
    return Container(
      height: 170,
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.sage),
      ),
      child: const Center(
        child: Icon(
          Icons.add_photo_alternate_outlined,
          size: 60,
          color: AppTheme.primary,
        ),
      ),
    );
  }

  Widget _buildPhotoPreview() {
    // Primero mostrar la foto recién seleccionada.
    if (_photoBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.memory(
          _photoBytes!,
          height: 210,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }

    // En edición, mostrar la foto ya guardada.
    if (_isEditing) {
      final imagePath = widget.property?['image_path']?.toString() ?? '';

      if (imagePath.isNotEmpty) {
        final imageUrl = _service.getImageUrl(imagePath);

        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            imageUrl,
            height: 210,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _photoPlaceholder();
            },
          ),
        );
      }
    }

    return _photoPlaceholder();
  }

  // ==========================================
  // PANTALLA PRINCIPAL
  // ==========================================

  @override
  Widget build(BuildContext context) {
    final amenityOptions = <String>{
      ..._availableAmenities,
      ..._amenities,
    }.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar alojamiento' : 'Publicar alojamiento'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // ==========================
                  // TÍTULO PRINCIPAL
                  // ==========================

                  Text(
                    _isEditing ? 'Editar publicación' : 'Nueva publicación',
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    _isEditing
                        ? 'Actualiza la información de tu '
                              'alojamiento y guarda los cambios.'
                        : 'Completa la información del '
                              'alojamiento que deseas ofrecer.',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ==========================
                  // FOTOGRAFÍA
                  // ==========================
                  _sectionHeading(
                    Icons.photo_camera_outlined,
                    'Fotografía del espacio',
                  ),

                  _buildPhotoPreview(),

                  const SizedBox(height: 12),

                  OutlinedButton.icon(
                    onPressed: _saving ? null : _selectPhoto,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(
                      _isEditing
                          ? 'Cambiar fotografía'
                          : _photo == null
                          ? 'Seleccionar fotografía'
                          : 'Cambiar fotografía',
                    ),
                  ),

                  if (_isEditing) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Si no seleccionas otra fotografía, '
                      'se conservará la actual.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  const SizedBox(height: 22),

                  // ==========================
                  // INFORMACIÓN GENERAL
                  // ==========================
                  _sectionHeading(
                    Icons.edit_note_rounded,
                    'Información general',
                  ),

                  _field(
                    'Título del alojamiento',
                    _title,
                    hint: 'Ej. Habitación privada en Cali',
                    validator: (value) {
                      final text = value?.trim() ?? '';

                      if (text.length < 5 || text.length > 150) {
                        return 'Escribe un título de '
                            '5 a 150 caracteres.';
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

                      if (text.length < 20 || text.length > 5000) {
                        return 'La descripción debe tener '
                            'entre 20 y 5000 caracteres.';
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

                      if (text.length < 3 || text.length > 200) {
                        return 'Ingresa una ubicación válida.';
                      }

                      return null;
                    },
                  ),

                  const Text(
                    'Tipo de alojamiento',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
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
                              setState(() {
                                _type = value;
                              });
                            }
                          },
                  ),

                  const SizedBox(height: 18),

                  // ==========================
                  // PRECIO Y CAPACIDAD
                  // ==========================
                  _sectionHeading(
                    Icons.payments_outlined,
                    'Precio y capacidad',
                  ),

                  _field(
                    _duration == 'Corto plazo'
                        ? 'Precio por noche (COP)'
                        : 'Precio mensual (COP)',
                    _price,
                    hint: _duration == 'Corto plazo'
                        ? 'Ej. 85000'
                        : 'Ej. 550000',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      final price = double.tryParse(value?.trim() ?? '');

                      if (price == null || !price.isFinite || price <= 0) {
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
                      final number = int.tryParse(value?.trim() ?? '');

                      if (number == null || number < 1 || number > 30) {
                        return 'Ingresa entre 1 y 30 personas.';
                      }

                      return null;
                    },
                  ),

                  const Text(
                    'Duración del arrendamiento',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
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
                            if (value != null && value != _duration) {
                              setState(() {
                                _duration = value;

                                // Al cambiar la unidad,
                                // el precio debe confirmarse.
                                _price.clear();
                              });
                            }
                          },
                  ),

                  const SizedBox(height: 24),

                  // ==========================
                  // SERVICIOS
                  // ==========================
                  _sectionHeading(
                    Icons.checklist_rounded,
                    'Servicios del alojamiento',
                  ),

                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    runSpacing: 5,
                    children: amenityOptions.map((item) {
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

                  // ==========================
                  // REGLAS DE CONVIVENCIA
                  // ==========================
                  _sectionHeading(Icons.rule_outlined, 'Convivencia'),

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

                  // ==========================
                  // GUARDAR O PUBLICAR
                  // ==========================
                  ElevatedButton.icon(
                    onPressed: _saving ? null : _saveProperty,
                    icon: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            _isEditing
                                ? Icons.save_rounded
                                : Icons.publish_rounded,
                          ),
                    label: Text(
                      _saving
                          ? _isEditing
                                ? 'Guardando...'
                                : 'Publicando...'
                          : _isEditing
                          ? 'Guardar cambios'
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
