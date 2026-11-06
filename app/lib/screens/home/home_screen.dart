import '../reservations/host_requests_screen.dart'; //temporal

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/property.dart';

import '../properties/property_detail_screen.dart';
import '../reservations/my_reservations_screen.dart';

import '../../services/session_service.dart';
import '../../services/property_service.dart';
import '../properties/create_property_screen.dart';
import '../properties/my_properties_screen.dart';

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

  final PropertyService _propertyService = PropertyService();

  List<Property> _properties = [];
  Map<int, String> _propertyImageUrls = {};
  Map<int, String> _propertyPriceUnits = {};
  Map<int, String> _propertyHouseRules = {};

  bool _loadingProperties = true;
  String? _propertiesError;

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    setState(() {
      _loadingProperties = true;
      _propertiesError = null;
    });

    try {
      final rows = await _propertyService.getProperties();

      final loadedProperties = <Property>[];
      final loadedImageUrls = <int, String>{};
      final loadedHouseRules = <int, String>{};
      final loadedPriceUnits = <int, String>{};

      for (final row in rows) {
        final id = int.parse(row['id'].toString());

        // NUEVO: Obtener la unidad real del precio.
        loadedPriceUnits[id] = row['price_unit'] == 'night' ? 'night' : 'month';

        final capacity = int.tryParse(row['capacity'].toString()) ?? 1;

        final price = double.tryParse(row['price_monthly'].toString()) ?? 0.0;

        final rawAmenities = row['amenities'];

        final amenities = rawAmenities is List
            ? rawAmenities.map((item) => item.toString()).toList()
            : <String>[];

        loadedProperties.add(
          Property(
            id: id,
            title: row['title']?.toString() ?? '',
            location: row['location']?.toString() ?? '',
            price: price,
            type: row['type']?.toString() ?? '',
            description: row['description']?.toString() ?? '',
            capacity: capacity,
            duration: row['duration']?.toString() ?? '',
            amenities: amenities,
            available: row['available'] == true,
          ),
        );

        final imagePath = row['image_path']?.toString() ?? '';

        if (imagePath.isNotEmpty) {
          loadedImageUrls[id] = _propertyService.getImageUrl(imagePath);
        }

        final rules = row['house_rules']?.toString() ?? '';

        if (rules.trim().isNotEmpty) {
          loadedHouseRules[id] = rules;
        }
      }

      if (!mounted) return;

      setState(() {
        _properties = loadedProperties;
        _propertyImageUrls = loadedImageUrls;
        _propertyHouseRules = loadedHouseRules;

        // NUEVO: Guardar las unidades de precio.
        _propertyPriceUnits = loadedPriceUnits;

        _loadingProperties = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loadingProperties = false;
        _propertiesError = error.toString();
      });
    }
  }

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
            const Icon(Icons.house_rounded, color: AppTheme.primary, size: 30),
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

          if (index == 0) {
            _loadProperties();
          }
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
    return RefreshIndicator(
      onRefresh: _loadProperties,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1240),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryLight, Color(0xFFF1F6EF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DESCUBRE ROOMLY',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.3,
                                  color: AppTheme.primary,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Encuentra un lugar para sentirte en casa',
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              SizedBox(height: 9),
                              Text(
                                'Explora habitaciones y apartamentos que se adaptan a ti.',
                                style: TextStyle(
                                  height: 1.45,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.home_work_rounded,
                          size: 48,
                          color: AppTheme.primary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  const Text(
                    '¿Dónde quieres vivir?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 21),
                  const Text(
                    'Tipo de alojamiento',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      ...['Todos', 'Apartamento', 'Habitación'].map((type) {
                        final isSelected = _selectedType == type;

                        return ChoiceChip(
                          label: Text(type),
                          selected: isSelected,
                          selectedColor: AppTheme.primaryLight,
                          backgroundColor: AppTheme.surface,
                          side: BorderSide(
                            color: isSelected
                                ? AppTheme.primary
                                : AppTheme.border,
                          ),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? AppTheme.primary
                                : AppTheme.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                          onSelected: (_) {
                            setState(() {
                              _selectedType = type;
                            });
                          },
                        );
                      }),
                      ActionChip(
                        avatar: const Icon(
                          Icons.tune_rounded,
                          color: AppTheme.primary,
                          size: 18,
                        ),
                        label: const Text('Más filtros'),
                        onPressed: () => _showMessage(
                          'Los filtros avanzados se implementarán después.',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 29),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Alojamientos para ti',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_filteredProperties.length} resultados',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if (_loadingProperties)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_propertiesError != null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.wifi_off_rounded,
                              size: 42,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No se pudieron cargar los alojamientos.',
                            ),
                            const SizedBox(height: 10),
                            TextButton.icon(
                              onPressed: _loadProperties,
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (_filteredProperties.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 48,
                            color: AppTheme.primary,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No encontramos alojamientos con esos criterios.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    LayoutBuilder(
                      builder: (context, constraints) {
                        const spacing = 18.0;

                        final columns = constraints.maxWidth >= 1100
                            ? 3
                            : constraints.maxWidth >= 700
                            ? 2
                            : 1;

                        final cardWidth =
                            (constraints.maxWidth - spacing * (columns - 1)) /
                            columns;

                        return Wrap(
                          spacing: spacing,
                          runSpacing: 18,
                          children: _filteredProperties.map((property) {
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
  }

  Widget _buildPropertyCard(Property property) {
    final isFavorite = _favoriteIds.contains(property.id);

    final imageUrl = _propertyImageUrls[property.id];

    final priceUnit = _propertyPriceUnits[property.id] == 'night'
        ? 'noche'
        : 'mes';

    // Mostrar separadores de miles en el precio.
    final formattedPrice = property.price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        );

    void openDetail() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PropertyDetailScreen(
            property: property,
            imageUrl: imageUrl,
            houseRules: _propertyHouseRules[property.id],
            priceUnit: _propertyPriceUnits[property.id] ?? 'month',
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: AppTheme.surface,
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: AppTheme.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // =========================================
          // FOTOGRAFÍA PRINCIPAL
          // =========================================
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 10,
                child: Container(
                  width: double.infinity,
                  color: AppTheme.primaryLight,
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              _getPropertyIcon(property),
                              color: AppTheme.primary,
                              size: 70,
                            );
                          },
                        )
                      : Icon(
                          _getPropertyIcon(property),
                          color: AppTheme.primary,
                          size: 70,
                        ),
                ),
              ),

              // Tipo de alojamiento
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    property.type,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),

              // Botón de favoritos
              Positioned(
                top: 8,
                right: 8,
                child: IconButton.filled(
                  tooltip: isFavorite
                      ? 'Quitar de favoritos'
                      : 'Agregar a favoritos',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: isFavorite ? Colors.red : AppTheme.primary,
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

          // =========================================
          // INFORMACIÓN DEL ALOJAMIENTO
          // =========================================
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),

                const SizedBox(height: 10),

                // Ubicación
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 17,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        property.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Descripción resumida
                Text(
                  property.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 16),

                // Capacidad y duración
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.people_outline_rounded,
                          size: 16,
                          color: AppTheme.primary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${property.capacity} persona(s)',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_month_outlined,
                          size: 16,
                          color: AppTheme.primary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          property.duration,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                const Divider(color: AppTheme.border, height: 1),

                const SizedBox(height: 14),

                // =========================================
                // PRECIO Y BOTÓN DE DETALLE
                // =========================================
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '\$$formattedPrice COP',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'por $priceUnit',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),

                    TextButton.icon(
                      onPressed: openDetail,
                      label: const Text('Ver detalle'),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
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
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.border),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.people_alt_rounded, color: AppTheme.primary, size: 34),
              SizedBox(height: 14),
              Text(
                'Encuentra tu próximo roomie',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 9),
              Text(
                'La convivencia también importa. Pronto podrás descubrir '
                'personas con gustos y hábitos compatibles con los tuyos.',
                style: TextStyle(color: AppTheme.textSecondary, height: 1.5),
              ),
            ],
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
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
        ),

        const SizedBox(height: 16),

        if (favorites.isEmpty)
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppTheme.border),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.favorite_border_rounded,
                  size: 44,
                  color: AppTheme.primary,
                ),
                SizedBox(height: 12),
                Text(
                  'Todavía no tienes alojamientos guardados. '
                  'Pulsa el corazón en una publicación para guardarla.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textSecondary, height: 1.5),
                ),
              ],
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
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryLight, Color(0xFFF1F6EF)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 34,
                backgroundColor: AppTheme.surface,
                child: Icon(
                  Icons.person_rounded,
                  size: 36,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mi perfil',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      SessionService.instance.fullName?.trim().isNotEmpty ==
                              true
                          ? SessionService.instance.fullName!
                          : 'Cuenta Roomly',
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      SessionService.instance.isHost
                          ? 'Anfitrión'
                          : 'Mi cuenta',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        if (SessionService.instance.isHost)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Mis alojamientos',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
          ),

        if (SessionService.instance.isHost)
          _buildComingSoonCard(
            Icons.add_home_work_outlined,
            'Publicar alojamiento',
            'Crea una publicación con fotos, precio y descripción.',
            onTap: () async {
              final created = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreatePropertyScreen(),
                ),
              );

              if (!mounted) return;

              if (created == true) {
                setState(() {
                  _selectedIndex = 0;
                });

                _loadProperties();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Alojamiento publicado con éxito.'),
                  ),
                );
              }
            },
          ),

        if (SessionService.instance.isHost)
          _buildComingSoonCard(
            Icons.inventory_2_outlined,
            'Mis publicaciones',
            'Consulta y elimina los alojamientos que publicaste.',
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyPropertiesScreen(),
                ),
              );

              if (!mounted) return;

              _loadProperties();
            },
          ),

        const SizedBox(height: 8),

        const Text(
          'Aquí podrás gestionar tus datos personales, '
          'tus alojamientos y tus preferencias de convivencia.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.textSecondary, height: 1.5),
        ),

        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'Mi cuenta',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
        ),

        _buildComingSoonCard(
          Icons.person_outline_rounded,
          'Datos personales',
          'Nombre, teléfono, foto y descripción.',
        ),

        _buildComingSoonCard(
          Icons.calendar_month_outlined,
          'Mis reservas',
          'Consulta tus solicitudes de hospedaje y su estado.',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MyReservationsScreen(),
              ),
            );
          },
        ),

        _buildComingSoonCard(
          Icons.settings_outlined,
          'Preferencias',
          'Configura tus hábitos y estilo de convivencia.',
        ),

        _buildComingSoonCard(
          Icons.assignment_outlined,
          'Solicitudes recibidas',
          'Gestiona las solicitudes de tus alojamientos.',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HostRequestsScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildComingSoonCard(
    IconData icon,
    String title,
    String description, {
    VoidCallback? onTap,
  }) {
    return Card(
      color: AppTheme.surface,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppTheme.border),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryLight,
          child: Icon(icon, color: AppTheme.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(description),
        ),
        trailing: onTap != null
            ? const Icon(Icons.chevron_right_rounded)
            : null,
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  IconData _getPropertyIcon(Property property) {
    if (property.type == 'Habitación') {
      return Icons.bedroom_parent_rounded;
    }

    return Icons.apartment_rounded;
  }
}
