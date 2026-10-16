
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/property.dart';

import '../properties/property_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _searchText = '';
  String _selectedType = 'Todos';

  final Set<int> _favoriteIds = {};

final List<Property> _properties = [
  const Property(
    id: 1,
    title: 'Apartamento acogedor',
    location: 'San Fernando, Cali',
    price: 850000,
    type: 'Apartamento',
    description:
        'Apartamento amoblado, con buena iluminación y cerca de transporte público.',
    capacity: 2,
    duration: 'Mediano plazo',
    amenities: [
      'WiFi',
      'Cocina',
      'Lavadora',
      'Aire acondicionado',
    ],
    available: true,
  ),
  const Property(
    id: 2,
    title: 'Habitación privada',
    location: 'San Antonio, Cali',
    price: 550000,
    type: 'Habitación',
    description:
        'Habitación privada dentro de una vivienda compartida, ideal para estudiantes.',
    capacity: 1,
    duration: 'Largo plazo',
    amenities: [
      'WiFi',
      'Cocina compartida',
      'Servicios incluidos',
    ],
    available: true,
  ),
  const Property(
    id: 3,
    title: 'Estudio para una persona',
    location: 'El Ingenio, Cali',
    price: 1000000,
    type: 'Apartamento',
    description:
        'Espacio tranquilo e independiente, ideal para estudiar o trabajar.',
    capacity: 1,
    duration: 'Corto y mediano plazo',
    amenities: [
      'WiFi',
      'Cocina',
      'Baño privado',
      'Aire acondicionado',
    ],
    available: true,
  ),
];

  List<Property> get _filteredProperties {
    return _properties.where((property) {
      final matchesSearch =
          property.title.toLowerCase().contains(_searchText.toLowerCase()) ||
          property.location.toLowerCase().contains(_searchText.toLowerCase());

      final matchesType =
          _selectedType == 'Todos' || property.type == _selectedType;

      return matchesSearch && matchesType;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(
              Icons.house_rounded,
              color: AppTheme.primary,
              size: 30,
            ),
            const SizedBox(width: 8),
            const Text(
              'Roomly',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w800,
                fontSize: 24,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Notificaciones',
            onPressed: () {
              _showMessage('Las notificaciones se implementarán más adelante.');
            },
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildExplorePage(),
            _buildRoomiesPage(),
            _buildFavoritesPage(),
            _buildProfilePage(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.search_rounded),
            label: 'Explorar',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline_rounded),
            label: 'Roomies',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border_rounded),
            label: 'Favoritos',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  Widget _buildExplorePage() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        const Text(
          'Encuentra tu próximo hogar',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Espacios que se adaptan a tu vida y a tu presupuesto.',
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 22),

        TextField(
          onChanged: (value) {
            setState(() {
              _searchText = value.trim();
            });
          },
          decoration: const InputDecoration(
            hintText: 'Ciudad, barrio o alojamiento',
            prefixIcon: Icon(Icons.search_rounded),
          ),
        ),
        const SizedBox(height: 14),

        OutlinedButton.icon(
          onPressed: () {
            _showMessage('Los filtros avanzados se implementarán después.');
          },
          icon: const Icon(Icons.tune_rounded),
          label: const Text('Más filtros'),
        ),
        const SizedBox(height: 22),

        const Text(
          'Tipo de alojamiento',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['Todos', 'Apartamento', 'Habitación'].map((type) {
            return ChoiceChip(
              label: Text(type),
              selected: _selectedType == type,
              onSelected: (_) {
                setState(() {
                  _selectedType = type;
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Alojamientos para ti',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              '${_filteredProperties.length} resultados',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        if (_filteredProperties.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 35),
            child: Column(
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 48,
                  color: AppTheme.textSecondary,
                ),
                SizedBox(height: 12),
                Text('No encontramos alojamientos con esos criterios.'),
              ],
            ),
          )
        else
          ..._filteredProperties.map(_buildPropertyCard),
      ],
    );
  }

  Widget _buildPropertyCard(Property property) {
    final isFavorite = _favoriteIds.contains(property.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 22),
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 170,
                width: double.infinity,
                color: _getPropertyColor(property),
                child: Icon(
                  _getPropertyIcon(property),
                  size: 76,
                  color: AppTheme.primary,
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    property.type,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton.filled(
                  tooltip: isFavorite
                      ? 'Quitar de favoritos'
                      : 'Agregar a favoritos',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: isFavorite
                        ? Colors.red
                        : AppTheme.textPrimary,
                  ),
                  onPressed: () {
                    setState(() {
                      if (isFavorite) {
                        _favoriteIds.remove(property.id);
                      } else {
                        _favoriteIds.add(property.id);
                      }
                    });
                  },
                  icon: Icon(
                    isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 17,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        property.location,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                Text(
                  property.description,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${property.price.toString()} COP / mes',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PropertyDetailScreen(
                              property: property,
                            ),
                        ),
                        );
                      },
                      child: const Text('Ver detalle'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomiesPage() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Encuentra tu próximo roomie',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'La convivencia también importa. Pronto podrás descubrir '
          'personas con gustos y hábitos compatibles con los tuyos.',
          style: TextStyle(
            color: AppTheme.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        _buildComingSoonCard(
          Icons.volume_off_rounded,
          'Preferencias de ruido',
          'Encuentra personas que prefieran ambientes similares.',
        ),
        _buildComingSoonCard(
          Icons.cleaning_services_outlined,
          'Hábitos de limpieza',
          'Compara rutinas y organización de los espacios.',
        ),
        _buildComingSoonCard(
          Icons.people_alt_outlined,
          'Compatibilidad',
          'Calcularemos coincidencias entre perfiles.',
        ),
      ],
    );
  }

  Widget _buildFavoritesPage() {
    final favorites = _properties
        .where((property) => _favoriteIds.contains(property.id))
        .toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Mis favoritos',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),
        if (favorites.isEmpty)
          const Text(
            'Todavía no tienes alojamientos guardados. '
            'Pulsa el corazón en una publicación para guardarla.',
            style: TextStyle(
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          )
        else
          ...favorites.map(_buildPropertyCard),
      ],
    );
  }

  Widget _buildProfilePage() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const CircleAvatar(
          radius: 42,
          backgroundColor: AppTheme.primaryLight,
          child: Icon(
            Icons.person_rounded,
            size: 48,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Mi perfil',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Aquí podrás gestionar tus datos personales, '
          'tus alojamientos y tus preferencias de convivencia.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        _buildComingSoonCard(
          Icons.person_outline_rounded,
          'Datos personales',
          'Nombre, teléfono, foto y descripción.',
        ),
        _buildComingSoonCard(
          Icons.settings_outlined,
          'Preferencias',
          'Configura tus hábitos y estilo de convivencia.',
        ),
      ],
    );
  }

  Widget _buildComingSoonCard(
    IconData icon,
    String title,
    String description,
  ) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryLight,
          child: Icon(icon, color: AppTheme.primary),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(description),
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }


  Color _getPropertyColor(Property property) {
  if (property.type == 'Habitación') {
    return const Color(0xFFF1E4D4);
  }

  return const Color(0xFFDDECE2);
}

IconData _getPropertyIcon(Property property) {
  if (property.type == 'Habitación') {
    return Icons.bedroom_parent_rounded;
  }

  return Icons.apartment_rounded;
 }
}


