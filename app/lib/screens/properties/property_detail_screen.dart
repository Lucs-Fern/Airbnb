import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/property.dart';

class PropertyDetailScreen extends StatelessWidget {
  final Property property;

  const PropertyDetailScreen({
    super.key,
    required this.property,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalle del alojamiento',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  height: 260,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDECE2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    property.type == 'Habitación'
                        ? Icons.bedroom_parent_rounded
                        : Icons.apartment_rounded,
                    size: 100,
                    color: AppTheme.primary,
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        property.title,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Guardar en favoritos',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Alojamiento agregado a favoritos.',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.favorite_border_rounded,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 20,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        property.location,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Text(
                  '\$${property.price.toStringAsFixed(0)} COP / mes',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 20),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _InfoChip(
                      icon: Icons.home_outlined,
                      text: property.type,
                    ),
                    _InfoChip(
                      icon: Icons.people_outline_rounded,
                      text: '${property.capacity} persona(s)',
                    ),
                    _InfoChip(
                      icon: Icons.calendar_month_outlined,
                      text: property.duration,
                    ),
                    _InfoChip(
                      icon: property.available
                          ? Icons.check_circle_outline
                          : Icons.cancel_outlined,
                      text: property.available
                          ? 'Disponible'
                          : 'No disponible',
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                const Text(
                  'Descripción',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  property.description,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: AppTheme.textSecondary,
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  'Características',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 12),

                ...property.amenities.map(
                  (amenity) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          color: AppTheme.primary,
                          size: 21,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          amenity,
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.map_outlined,
                        color: AppTheme.primary,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'La ubicación en el mapa se integrará '
                          'con OpenStreetMap.',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                ElevatedButton.icon(
                  onPressed: property.available
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'La solicitud de reserva será '
                                'la siguiente función a desarrollar.',
                              ),
                            ),
                          );
                        }
                      : null,
                  icon: const Icon(Icons.calendar_month_rounded),
                  label: const Text('Solicitar reserva'),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 17,
            color: AppTheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}