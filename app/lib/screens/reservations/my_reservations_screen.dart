import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/reservation.dart';
import '../../repositories/reservation_repository.dart';

class MyReservationsScreen extends StatelessWidget {
  const MyReservationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reservations =
        ReservationRepository.instance.reservations;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mis reservas',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 700,
            ),
            child: reservations.isEmpty
                ? _buildEmptyState()
                : ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      const Text(
                        'Tus solicitudes',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Aquí puedes consultar el estado de '
                        'tus solicitudes de hospedaje.',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),

                      ...reservations.map(
                        (reservation) =>
                            _ReservationCard(
                          reservation: reservation,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_month_outlined,
            size: 70,
            color: AppTheme.textSecondary,
          ),
          SizedBox(height: 18),
          Text(
            'Todavía no tienes reservas',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Cuando envíes una solicitud de hospedaje '
            'aparecerá aquí.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  final Reservation reservation;

  const _ReservationCard({
    required this.reservation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.home_work_outlined,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  reservation.propertyTitle,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _StatusChip(
                status: reservation.status,
              ),
            ],
          ),

          const SizedBox(height: 18),

          _InfoRow(
            icon: Icons.login_rounded,
            label: 'Entrada',
            value: _formatDate(
              reservation.startDate,
            ),
          ),

          const SizedBox(height: 10),

          _InfoRow(
            icon: Icons.logout_rounded,
            label: 'Salida',
            value: _formatDate(
              reservation.endDate,
            ),
          ),

          const SizedBox(height: 10),

          _InfoRow(
            icon: Icons.people_outline,
            label: 'Personas',
            value: '${reservation.guests}',
          ),

          const SizedBox(height: 10),

          _InfoRow(
            icon: Icons.tag_rounded,
            label: 'Reserva',
            value: '#${reservation.id}',
          ),
        ],
      ),
    );
  }

  static String _formatDate(
    DateTime date,
  ) {
    final day =
        date.day.toString().padLeft(2, '0');

    final month =
        date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 19,
          color: AppTheme.textSecondary,
        ),
        const SizedBox(width: 9),
        Text(
          '$label:',
          style: const TextStyle(
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final ReservationStatus status;

  const _StatusChip({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    String text;
    IconData icon;

    switch (status) {
      case ReservationStatus.pending:
        text = 'Pendiente';
        icon = Icons.schedule_rounded;

      case ReservationStatus.accepted:
        text = 'Aceptada';
        icon = Icons.check_circle_outline;

      case ReservationStatus.rejected:
        text = 'Rechazada';
        icon = Icons.cancel_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: AppTheme.primary,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: AppTheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}