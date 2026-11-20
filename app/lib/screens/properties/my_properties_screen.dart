import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/property_service.dart';

import 'create_property_screen.dart';

class MyPropertiesScreen extends StatefulWidget {
  const MyPropertiesScreen({super.key});

  @override
  State<MyPropertiesScreen> createState() => _MyPropertiesScreenState();
}

class _MyPropertiesScreenState extends State<MyPropertiesScreen> {
  final PropertyService _service = PropertyService();

  late Future<List<Map<String, dynamic>>> _propertiesFuture;

  final Set<int> _deletingIds = {};
  final Set<int> _editingIds = {};

  @override
  void initState() {
    super.initState();
    _propertiesFuture = _service.getMyProperties();
  }

  // ==========================================
  // ACTUALIZAR PUBLICACIONES
  // ==========================================

  Future<void> _refresh() async {
    final future = _service.getMyProperties();

    setState(() {
      _propertiesFuture = future;
    });

    try {
      await future;
    } catch (_) {
      // FutureBuilder muestra el estado de error.
    }
  }

  // ==========================================
  // NUEVO: ABRIR FORMULARIO DE EDICIÓN
  // ==========================================

  Future<void> _editProperty(Map<String, dynamic> property) async {
    final id = int.tryParse(property['id']?.toString() ?? '');

    if (id == null ||
        id <= 0 ||
        _editingIds.contains(id) ||
        _deletingIds.contains(id)) {
      return;
    }

    setState(() {
      _editingIds.add(id);
    });

    try {
      // Abrir el formulario existente en modo edición.
      // Los campos se cargarán con los datos actuales.
      final updated = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => CreatePropertyScreen(property: property),
        ),
      );

      if (!mounted) return;

      // Si el usuario guardó los cambios,
      // recargar las publicaciones desde PostgreSQL.
      if (updated == true) {
        await _refresh();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Publicación actualizada correctamente.'),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _editingIds.remove(id);
        });
      }
    }
  }

  // ==========================================
  // CONFIRMAR Y ELIMINAR PUBLICACIÓN
  // ==========================================

  Future<void> _confirmDelete(Map<String, dynamic> property) async {
    final id = int.tryParse(property['id']?.toString() ?? '');

    if (id == null ||
        id <= 0 ||
        _deletingIds.contains(id) ||
        _editingIds.contains(id)) {
      return;
    }

    final title = property['title']?.toString() ?? 'este alojamiento';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.delete_outline_rounded, color: AppTheme.error),
              SizedBox(width: 10),
              Expanded(child: Text('Eliminar publicación')),
            ],
          ),
          content: Text(
            '¿Seguro que deseas eliminar "$title"? '
            'Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text(
                'Eliminar',
                style: TextStyle(
                  color: AppTheme.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _deletingIds.add(id);
    });

    try {
      await _service.deleteProperty(id);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Publicación eliminada.')));

      await _refresh();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _deletingIds.remove(id);
        });
      }
    }
  }

  // ==========================================
  // FORMATO DE PRECIOS EN PESOS COLOMBIANOS
  // ==========================================

  String _formatPrice(dynamic value) {
    final price = num.tryParse(value?.toString() ?? '');

    if (price == null) {
      return 'Precio no disponible';
    }

    final number = price.toStringAsFixed(0);

    final formatted = number.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );

    return '\$$formatted COP';
  }

  // ==========================================
  // ETIQUETAS DE INFORMACIÓN
  // ==========================================

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TARJETA DE PUBLICACIÓN
  // ==========================================

  Widget _buildPropertyCard(Map<String, dynamic> property) {
    final id = int.tryParse(property['id']?.toString() ?? '') ?? -1;

    final title = property['title']?.toString() ?? '';

    final location = property['location']?.toString() ?? '';

    final type = property['type']?.toString() ?? '';

    final duration = property['duration']?.toString() ?? '';

    final capacity = int.tryParse(property['capacity']?.toString() ?? '');

    final imagePath = property['image_path']?.toString() ?? '';

    final imageUrl = imagePath.isEmpty ? null : _service.getImageUrl(imagePath);

    final priceUnit = property['price_unit']?.toString() == 'night'
        ? 'noche'
        : 'mes';

    final price = _formatPrice(property['price_monthly']);

    final isDeleting = _deletingIds.contains(id);
    final isEditing = _editingIds.contains(id);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: AppTheme.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ====================================
          // FOTOGRAFÍA DEL ALOJAMIENTO
          // ====================================

          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  width: double.infinity,
                  color: AppTheme.primaryLight,
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }

                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.home_work_outlined,
                                color: AppTheme.primary,
                                size: 64,
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Icon(
                            Icons.home_work_outlined,
                            color: AppTheme.primary,
                            size: 64,
                          ),
                        ),
                ),
              ),

              // Tipo de alojamiento
              if (type.isNotEmpty)
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(color: Color(0x12000000), blurRadius: 10),
                      ],
                    ),
                    child: Text(
                      type,
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // ====================================
          // INFORMACIÓN DE LA PUBLICACIÓN
          // ====================================
          Padding(
            padding: const EdgeInsets.all(19),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.isEmpty ? 'Alojamiento sin título' : title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),

                const SizedBox(height: 11),

                // Ubicación
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: AppTheme.textSecondary,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        location.isEmpty ? 'Ubicación no disponible' : location,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Precio
                Text(
                  price,
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'por $priceUnit',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 17),

                // Capacidad y duración
                Wrap(
                  spacing: 9,
                  runSpacing: 9,
                  children: [
                    if (capacity != null && capacity > 0)
                      _buildInfoChip(
                        icon: Icons.people_outline_rounded,
                        label:
                            '$capacity ${capacity == 1 ? 'persona' : 'personas'}',
                      ),

                    if (duration.isNotEmpty)
                      _buildInfoChip(
                        icon: Icons.calendar_month_outlined,
                        label: duration,
                      ),
                  ],
                ),

                const SizedBox(height: 18),

                const Divider(color: AppTheme.border, height: 1),

                const SizedBox(height: 13),

                // ====================================
                // NUEVO: BOTONES EDITAR Y ELIMINAR
                // ====================================
                Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.end,
                    children: [
                      // Abrir formulario de edición.
                      FilledButton.icon(
                        onPressed: id <= 0 || isDeleting || isEditing
                            ? null
                            : () => _editProperty(property),
                        icon: const Icon(Icons.edit_outlined, size: 19),
                        label: const Text('Editar'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                      ),

                      // Conservar la eliminación existente.
                      OutlinedButton.icon(
                        onPressed: id <= 0 || isDeleting || isEditing
                            ? null
                            : () => _confirmDelete(property),
                        icon: isDeleting
                            ? const SizedBox(
                                width: 17,
                                height: 17,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.delete_outline_rounded,
                                size: 19,
                                color: AppTheme.error,
                              ),
                        label: Text(
                          isDeleting ? 'Eliminando...' : 'Eliminar',
                          style: const TextStyle(
                            color: AppTheme.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 44),
                          side: const BorderSide(color: AppTheme.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // ENCABEZADO
  // ==========================================

  Widget _buildHeader(int total) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.home_work_outlined,
              color: AppTheme.primary,
              size: 29,
            ),
          ),

          const SizedBox(width: 15),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mis alojamientos',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Administra las publicaciones que has creado.',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '$total',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // PANTALLA PRINCIPAL
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis publicaciones')),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _propertiesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.wifi_off_rounded,
                        color: AppTheme.primary,
                        size: 46,
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'No se pudieron cargar tus publicaciones.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 14),
                      OutlinedButton.icon(
                        onPressed: _refresh,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final properties = snapshot.data ?? [];

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 36),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1040),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeader(properties.length),

                          const SizedBox(height: 22),

                          // Estado sin publicaciones
                          if (properties.isEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 48,
                                horizontal: 24,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.surface,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(color: AppTheme.border),
                              ),
                              child: const Column(
                                children: [
                                  Icon(
                                    Icons.home_outlined,
                                    size: 54,
                                    color: AppTheme.primary,
                                  ),
                                  SizedBox(height: 15),
                                  Text(
                                    'Todavía no tienes publicaciones',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 7),
                                  Text(
                                    'Cuando publiques un alojamiento, '
                                    'aparecerá aquí para que puedas administrarlo.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            // Dos columnas en PC, una en celular.
                            LayoutBuilder(
                              builder: (context, constraints) {
                                const spacing = 18.0;

                                final columns = constraints.maxWidth >= 850
                                    ? 2
                                    : 1;

                                final cardWidth =
                                    (constraints.maxWidth -
                                        spacing * (columns - 1)) /
                                    columns;

                                return Wrap(
                                  spacing: spacing,
                                  runSpacing: 18,
                                  children: properties.map((property) {
                                    return SizedBox(
                                      width: cardWidth,
                                      child: _buildPropertyCard(property),
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
