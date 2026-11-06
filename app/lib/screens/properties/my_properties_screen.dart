import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/property_service.dart';

class MyPropertiesScreen extends StatefulWidget {
  const MyPropertiesScreen({super.key});

  @override
  State<MyPropertiesScreen> createState() => _MyPropertiesScreenState();
}

class _MyPropertiesScreenState extends State<MyPropertiesScreen> {
  final PropertyService _service = PropertyService();
  late Future<List<Map<String, dynamic>>> _propertiesFuture;
  final Set<int> _deletingIds = {};

  @override
  void initState() {
    super.initState();
    _propertiesFuture = _service.getMyProperties();
  }

  Future<void> _refresh() async {
    final future = _service.getMyProperties();
    setState(() => _propertiesFuture = future);
    try {
      await future;
    } catch (_) {
      // El mensaje del error lo muestra el FutureBuilder.
    }
  }

  Future<void> _confirmDelete(Map<String, dynamic> property) async {
    final id = int.tryParse(property['id'].toString());
    if (id == null || _deletingIds.contains(id)) return;

    final title = property['title']?.toString() ?? 'este alojamiento';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar publicación'),
        content: Text(
          '¿Seguro que deseas eliminar "$title"? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _deletingIds.add(id));
    try {
      await _service.deleteProperty(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Publicación eliminada.')),
      );
      await _refresh();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) setState(() => _deletingIds.remove(id));
    }
  }

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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('No se pudieron cargar tus publicaciones.'),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            final properties = snapshot.data ?? [];
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Gestiona los alojamientos que publicaste.',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  if (properties.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text('Todavía no tienes publicaciones.'),
                      ),
                    ),
                  ...properties.map((property) {
                    final id = int.tryParse(property['id'].toString()) ?? -1;
                    final imagePath = property['image_path']?.toString() ?? '';
                    final imageUrl = imagePath.isEmpty
                        ? null
                        : _service.getImageUrl(imagePath);

                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 650),
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 14),
                          clipBehavior: Clip.antiAlias,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 110,
                                  height: 90,
                                  child: imageUrl != null
                                      ? Image.network(
                                          imageUrl,
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(Icons.house_outlined),
                                        )
                                      : const Icon(Icons.house_outlined),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        property['title']?.toString() ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        property['location']?.toString() ?? '',
                                      ),
                                      const SizedBox(height: 10),
                                      OutlinedButton.icon(
                                        onPressed: _deletingIds.contains(id)
                                            ? null
                                            : () => _confirmDelete(property),
                                        icon: const Icon(
                                          Icons.delete_outline_rounded,
                                          color: Colors.red,
                                        ),
                                        label: const Text('Eliminar'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
